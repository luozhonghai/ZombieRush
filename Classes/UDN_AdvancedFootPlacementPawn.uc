class UDN_AdvancedFootPlacementPawn extends Pawn
  Placeable;

var(FootPlacement) float FootTraceRange;
var(FootPlacement) Name LeftFootSocketName;
var(FootPlacement) Name RightFootSocketName;
var(FootPlacement) float TranslationZOffset;
var(FootPlacement) Name LeftFootPlacementSkelControlName;
var(FootPlacement) Name RightFootPlacementSkelControlName;
var SkelControlFootPlacement LeftFootPlacementSkelControl;
var SkelControlFootPlacement RightFootPlacementSkelControl;

simulated function EnableLeftFootPlacement()
{
  SetSkelControlActive(LeftFootPlacementSkelControl, true);
}

simulated function DisableLeftFootPlacement()
{
  SetSkelControlActive(LeftFootPlacementSkelControl, false);
}

simulated function EnableRightFootPlacement()
{
  SetSkelControlActive(RightFootPlacementSkelControl, true);
}

simulated function DisableRightFootPlacement()
{
  SetSkelControlActive(RightFootPlacementSkelControl, false);
}

simulated function SetSkelControlActive(SkelControlBase SkelControl, bool IsActive)
{
  if (SkelControl != None)
  {
    SkelControl.SetSkelControlActive(IsActive);
  }
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
  Super.PostInitAnimTree(SkelComp);

  if (SkelComp == Mesh)
  {
    LeftFootPlacementSkelControl = SkelControlFootPlacement(Mesh.FindSkelControl(LeftFootPlacementSkelControlName));
    RightFootPlacementSkelControl = SkelControlFootPlacement(Mesh.FindSkelControl(RightFootPlacementSkelControlName));
  }
}

simulated event Destroyed()
{
  Super.Destroyed();

  LeftFootPlacementSkelControl = None;
  RightFootPlacementSkelControl = None;
}

simulated event Tick(float DeltaTime)
{
  local Vector LeftFootHitLocation, LeftFootHitNormal, LeftFootTraceEnd, LeftFootTraceStart;
  local Vector RightFootHitLocation, RightFootHitNormal, RightFootTraceEnd, RightFootTraceStart;
  local Vector DesiredMeshTranslation;
  local Rotator SocketRotation;
  local Actor LeftFootHitActor, RightFootHitActor;

  Super.Tick(DeltaTime);

  if (Mesh == None || Physics == PHYS_Falling)
  {
    return;
  }

  Mesh.GetSocketWorldLocationAndRotation(LeftFootSocketName, LeftFootTraceStart, SocketRotation);
  LeftFootTraceStart.Z = Location.Z;
  LeftFootTraceEnd = LeftFootTraceStart - (Vect(0.f, 0.f, 1.f) * FootTraceRange);
  // 跟踪查找左脚的位置
  ForEach TraceActors(class'Actor', LeftFootHitActor, LeftFootHitLocation, LeftFootHitNormal, LeftFootTraceEnd, LeftFootTraceStart,,, TRACEFLAG_Bullet)
  {
    // 如果我们击中了世界几何体会挡住去路
    if (LeftFootHitActor.bWorldGeometry || LeftFootHitActor.IsA('InterpActor'))
    {
      break;
    }
  }

  // 跟踪查找右脚的位置
  Mesh.GetSocketWorldLocationAndRotation(RightFootSocketName, RightFootTraceStart, SocketRotation);
  RightFootTraceStart.Z = Location.Z;
  RightFootTraceEnd = RightFootTraceStart - (Vect(0.f, 0.f, 1.f) * FootTraceRange);
  // 跟踪查找右脚的位置
  ForEach TraceActors(class'Actor', RightFootHitActor, RightFootHitLocation, RightFootHitNormal, RightFootTraceEnd, RightFootTraceStart,,, TRACEFLAG_Bullet)
  {
    // 如果我们击中了世界几何体会挡住去路
    if (RightFootHitActor.bWorldGeometry || RightFootHitActor.IsA('InterpActor'))
    {
      break;
    }
  }

  // 不在接触到地面的范围内
  if (LeftFootHitActor == None && RightFootHitActor == None)
  {
    return;
  }

  if (LeftFootHitActor != None && RightFootHitActor == None)
  {
    DesiredMeshTranslation.Z = (LeftFootHitLocation.Z - Location.Z) + Mesh.default.Translation.Z + TranslationZOffset;  
  }
  else if (LeftFootHitActor == None && RightFootHitActor != None)
  {
    DesiredMeshTranslation.Z = (RightFootHitLocation.Z - Location.Z) + Mesh.default.Translation.Z + TranslationZOffset;
  }
  else
  {
    // 调整理想的网格物体平移量
    if (LeftFootHitLocation.Z < RightFootHitLocation.Z)
    {
      DesiredMeshTranslation.Z = (LeftFootHitLocation.Z - Location.Z) + Mesh.default.Translation.Z + TranslationZOffset;    
    }
    else
    {
      DesiredMeshTranslation.Z = (RightFootHitLocation.Z - Location.Z) + Mesh.default.Translation.Z + TranslationZOffset;
    }
  }

  // 设置网格物体平移量
  Mesh.SetTranslation(DesiredMeshTranslation);
}

defaultproperties
{
  LeftFootSocketName="LeftFootSocket"
  RightFootSocketName="RightFootSocket"
  FootTraceRange=96.f

  Begin Object Class=SkeletalMeshComponent Name=PawnMesh
  End Object
  Mesh=PawnMesh
  Components.Add(PawnMesh)

  Physics=PHYS_Falling

  Begin Object Name=CollisionCylinder
    CollisionRadius=+0030.0000
    CollisionHeight=+0072.000000
  End Object
}
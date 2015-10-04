class ZBLevelEntity_Fractured extends FracturedStaticMeshActor;

// Body...


var bool bExploded;

var() bool bGun_Fire;
var() bool bAxe_Fire;

var() int Health;
var() int GunDamage;
var() int AxeDamage;
// A simple way to make sure this barrier gets broken on the first hit
function HitBy(class<DamageType> DmgType)
{
  if(bGun_Fire && DmgType == class'DmgType_Gun_Fire')
  {
    Health -= GunDamage;
    if(Health <= 0)
      Explode();
  }
  else if(bAxe_Fire && DmgType == class'DmgType_Axe_Fire')
  {
    Health -= AxeDamage;
    if(Health <= 0)
      Explode();
  }
}

function bool CanBlockPawn()
{
  return !bExploded;
}
// Make sure explode only happens once
// Also set the lighting channel of the parts
/*
simulated event Explode()
{
  local array<byte> FragmentVis;
  local int i;
  local vector SpawnDir;
  local FracturedStaticMesh FracMesh;
  local FracturedStaticMeshPart FracPart;
  local float PartScale;
  local ParticleSystem EffectPSys;

  if(bExploded)
    return;

  bExploded = true;

  FracMesh = FracturedStaticMesh(FracturedStaticMeshComponent.StaticMesh);

  // Particle Systems
  // Look for override first
  if(OverrideFragmentDestroyEffects.length > 0)
  {
    // Pick randomly
    EffectPSys = OverrideFragmentDestroyEffects[Rand(OverrideFragmentDestroyEffects.length)];
  }
  // No override array, try the mesh
  else if(FracMesh.FragmentDestroyEffects.length > 0)
  {
    EffectPSys = FracMesh.FragmentDestroyEffects[Rand(FracMesh.FragmentDestroyEffects.length)];
  }
  // Spawn emitter in the emitter pool
  WorldInfo.MyEmitterPool.SpawnEmitter(EffectPSys, Location);

  // Iterate over all visible fragments spawning them
  FragmentVis = FracturedStaticMeshComponent.GetVisibleFragments();
  for(i=0; i<FragmentVis.length; i++)
  {
    // If this is a currently-visible, non-core fragment, spawn it off.
    if((FragmentVis[i] != 0) && (i != FracturedStaticMeshComponent.GetCoreFragmentIndex()))
    {
      SpawnDir = FracturedStaticMeshComponent.GetFragmentAverageExteriorNormal(i);
      PartScale = FracMesh.ExplosionPhysicsChunkScaleMin + FRand() * (FracMesh.ExplosionPhysicsChunkScaleMax - FracMesh.ExplosionPhysicsChunkScaleMin);
      // Spawn part- inherit this actors velocity
      FracPart = SpawnPart(i, (0.5 * SpawnDir * FracMesh.ChunkLinVel) + Velocity, 0.5 * VRand() * FracMesh.ChunkAngVel, PartScale, TRUE);

      if(FracPart != None)
      {
        // When something explodes we disallow collisions between all those parts.
        FracPart.FracturedStaticMeshComponent.SetRBCollidesWithChannel(RBCC_FracturedMeshPart, FALSE);
        FracPart.FracturedStaticMeshComponent.SetRBCollidesWithChannel(RBCC_Default, FALSE);
      }

      FragmentVis[i] = 0;
    }
  }

  // Update the visibility of the actor being spawned off of
  FracturedStaticMeshComponent.SetVisibleFragments(FragmentVis);

  TurnOffCollision();
}
*/

simulated event Explode()
{
  `log("ZBLevelEntity_Fractured Explode");
  super.Explode();
  bExploded = true;
  SetTimer(0.5, false, 'TurnOffCollision');
}
function TurnOffCollision()
{
  SetPhysics(PHYS_None);
  SetCollision(false, false, false);
  if (CollisionComponent != None)
  {
    CollisionComponent.SetBlockRigidBody(false);
  }
  OnFractureMeshBroken();
}

// override in sub classes
function OnFractureMeshBroken()
{
  Destroy();
  //TriggerEventClass( class'SeqEvent_Destroyed', self );
}

defaultproperties
{
  bWorldGeometry=FALSE
  bNoDelete=FALSE
}
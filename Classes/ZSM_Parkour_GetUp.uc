class ZSM_Parkour_GetUp extends ZBSpecialMove;

// Body...

var() ZombiePawn.AnimationParaConfig		AnimCfg_Animation_1;
var() ZombiePawn.AnimationParaConfig    AnimCfg_Animation_2;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
  local bool GetUpFromBack;
	Super.SpecialMoveStarted(bForced, PrevMove);
  PawnOwner.ZeroMovementVariables();
  GetUpFromBack = (PawnOwner.Mesh.GetBoneAxis('Bip01-Head', AXIS_Y).Z > 0.0);
  if (!GetUpFromBack)
  {
    PawnOwner.PlayConfigAnim(AnimCfg_Animation_1);
  }
  else
  {
    PawnOwner.PlayConfigAnim(AnimCfg_Animation_2);
  }
}
function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
  ZBPlayerCamera(PCOwner.PlayerCamera).CameraOnSpecialMoveEnd(self);
}

function bool CanOverrideMoveWith(ESpecialMove NewMove)
{
	//cant be interrupt when i get up
	return false;
}

function bool CalcCamera_KeepHeight( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
  baseLoc = PawnOwner.mesh.GetBoneLocation('Bip01-Pelvis',0);
  baseLoc.Z = PawnOwner.JumpStartHeight;
  out_CamLoc = baseLoc + CameraOffsetTarget - Vector(out_CamRot) * CameraDistance ;
  return true;
}
defaultproperties
{
  AnimCfg_Animation_1=(AnimationNames=("actor-getup"),BlendInTime=0.0,BlendOutTime=0.1,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[2]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
	AnimCfg_Animation_2=(AnimationNames=("actor-getup_02"),BlendInTime=0.0,BlendOutTime=0.1,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[2]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
	bDisableMovement=True
  bEnablePhysicsEffect=true
  CamType=ECAM_KeepHeight
}
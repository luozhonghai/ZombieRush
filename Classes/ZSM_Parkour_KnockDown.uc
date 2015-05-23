class ZSM_Parkour_KnockDown extends ZBSpecialMove;

// Body...

var() ZombiePawn.AnimationParaConfig		AnimCfg_Animation;


var() CameraShake HitWallShake;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);
  if(PCOwner.PlayerCamera != none)
	  PCOwner.PlayerCamera.PlayCameraShake(HitWallShake,10.0);
	PawnOwner.PlayConfigAnim(AnimCfg_Animation);
}
function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
}

function bool CanOverrideMoveWith(ESpecialMove NewMove)
{
	//cant be interrupt when i knocked back
	return false;
}

function bool CalcCamera_KeepHeight( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	baseLoc = PawnOwner.mesh.GetBoneLocation('Bip01-Pelvis',0);
	//baseLoc =  ZBCameraTypeRushFix(ZBPlayerCamera(ZombiePC(PawnOwner.Controller).PlayerCamera).CurrentCameraType).BaseCamLoc;
  baseLoc.Z = PawnOwner.JumpStartHeight;
 // `log("JumpStartHeight"@PawnOwner.JumpStartHeight);
	out_CamLoc = baseLoc + CameraOffsetTarget - Vector(out_CamRot) * CameraDistance ;
	return true;
}
defaultproperties
{
	//actor-Knockdown
	AnimCfg_Animation=(AnimationNames=("actor-liedown_01"),BlendInTime=0.05,BlendOutTime=-1.0,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[2]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
	bDisableMovement=True
  HitWallShake=CameraShake'Zombie_Archetype.Camera.Shake_RuntoWall'
	bEnablePhysicsEffect=true
	CamType=ECAM_KeepHeight
}
class ZSM_Parkour_KnockDown extends ZBSpecialMove;

// Body...

var() ZombiePawn.AnimationParaConfig		AnimCfg_Animation;

var bool bAirKnock; 
var  Vector CameraOffsetTarget;
var float CameraDistance;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);
	if (PawnOwner.bIsJumping)
	{
		bAirKnock = true;
		CameraOffsetTarget = ZBCameraTypeRushFix(ZBPlayerCamera(ZombiePC(PawnOwner.Controller).PlayerCamera).CurrentCameraType).CameraOffset;
	}
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

function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local vector baseLoc;
	if (!bAirKnock)
	{
		return false;
	}
	baseLoc = PawnOwner.Location;
    baseLoc.Z = PawnOwner.JumpStartHeight;

	out_CamLoc = baseLoc + CameraOffsetTarget - Vector(out_CamRot) * CameraDistance ;

	return true;
}
defaultproperties
{
	AnimCfg_Animation=(AnimationNames=("actor-Knockdown"),BlendInTime=0.05,BlendOutTime=0.0,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[2]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
	bDisableMovement=True

	CameraDistance=400.f 
	CameraOffsetTarget=(X=0f,Y=100.0f,Z=70.0f)
}
class ZSM_Parkour_StrafeLeft extends ZBSpecialMove;

// Body...
var() ZombiePawn.AnimationParaConfig		AnimCfg_Animation;
var float JumpStartHeight;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);
	JumpStartHeight = PawnOwner.Location.Z;
	PawnOwner.PlayConfigAnim(AnimCfg_Animation);
}
function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
	//ZombieParkourPC(PCOwner).OnStrafeLeftEnd();
}


defaultproperties
{
	AnimCfg_Animation=(AnimationNames=("actor-jumpleft"),BlendInTime=0.05,BlendOutTime=0.05,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[2]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
	bDisableMovement=True
}
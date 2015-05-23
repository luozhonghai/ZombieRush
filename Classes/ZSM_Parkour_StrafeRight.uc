class ZSM_Parkour_StrafeRight extends ZBSpecialMove;

// Body...
var() ZombiePawn.AnimationParaConfig		AnimCfg_Animation;


function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);
	PawnOwner.PlayConfigAnim(AnimCfg_Animation);
}
function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
	//ZombieParkourPC(PCOwner).OnStrafeRightEnd();
	//OnSpecialMoveEnd();
}


defaultproperties
{
	AnimCfg_Animation=(AnimationNames=("actor-jumpright"),BlendInTime=0.05,BlendOutTime=0.01,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[2]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
	bDisableMovement=True
  CamType=ECAM_KeepHeight
}
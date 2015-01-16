class ZSM_Push extends ZBSpecialMove;

var() ZombiePawn.AnimationParaConfig		AnimCfg_Push;


function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	if (PawnOwner.health > 0)
	{
		PawnOwner.PlayConfigAnim(AnimCfg_Push);
	}
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);

	if (PawnOwner.health > 0)
	{
	//	PawnOwner.StopConfigAnim(AnimCfg_Push, 0);
	}
}

DefaultProperties
{
	AnimCfg_Push=(AnimationNames=("zhujue-tuikai"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendintime=0.0)

		bDisableMovement=true
		bDisableTurn=true
}

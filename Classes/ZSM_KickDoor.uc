class ZSM_KickDoor extends ZBSpecialMove;

var() ZombiePawn.AnimationParaConfig		AnimCfg_Kick;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	if (PawnOwner.health > 0)
	{
		PawnOwner.PlayConfigAnim(AnimCfg_Kick);
	}
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
}
DefaultProperties
{
	AnimCfg_Kick=(AnimationNames=("zhujue-tuikai"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendintime=0.0,blendouttime=0.4)

	bDisableMovement=true
	bDisableTurn=true
}

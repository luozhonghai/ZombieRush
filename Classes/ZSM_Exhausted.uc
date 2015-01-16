class ZSM_Exhausted extends ZBSpecialMove;


var() ZombiePawn.AnimationParaConfig		AnimCfg_Exhausted;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	 PCOwner.gotoState('PlayerExhausting');
	PawnOwner.PlayConfigAnim(AnimCfg_Exhausted);
   
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);

	if (PawnOwner.health > 0)
	{
		//	PawnOwner.StopConfigAnim(AnimCfg_Push, 0);
       PCOwner.gotoState('PlayerWalking');
	}
}

DefaultProperties
{
	AnimCfg_Exhausted=(AnimationNames=("zhujue-loosepower"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendintime=0.1,blendouttime=0.1)

	//	bDisableMovement=true
		bDisableTurn=true
}

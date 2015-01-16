class NSM_Eat extends ZBSpecialMove;

var() ZombiePawn.AnimationParaConfig		AnimCfg_Eat;

var float EatEndDelay;

var() float EatDelayTime;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	if (PawnOwner.health > 0)
	{
		PawnOwner.PlayConfigAnim(AnimCfg_Eat);
	}
}


event tickspecial(float deltaTime)
{

		EatEndDelay+=deltaTime;

		if (EatEndDelay>EatDelayTime)
		{
			PawnOwner.EndSpecialMove();

		}
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);

	PawnOwner.getalocalplayercontroller().consolecommand("restartlevel");
}
DefaultProperties
{
	//zombie01-chi zombie-eat
	AnimCfg_Eat=(AnimationNames=("zombie-eat"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=true,blendintime=0.0,blendouttime=0.0)
 
		//UseCustomRMM=True
		RMMInAction=RMM_Translate

		EatDelayTime=4.0
}

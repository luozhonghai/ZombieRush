class NSM_EatPre extends ZBSpecialMove;


var() ZombiePawn.AnimationParaConfig		AnimCfg_EatPre;


function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	if (PawnOwner.health > 0)
	{
		PawnOwner.PlayConfigAnim(AnimCfg_EatPre);
	}
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
   Super.SpecialMoveEnded(PrevMove, NextMove);
///必须先停止上一个动画
   PawnOwner.StopConfigAnim(AnimCfg_EatPre, 0);
   PawnOwner.DoSpecialMove(SM_Zombie_Eat,true);
}

DefaultProperties
{
	//zombie01-pudao  zombie-pushdown
	AnimCfg_EatPre=(AnimationNames=("zombie-pushdown"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendouttime=0.0)
  
		UseCustomRMM=True
		RMMInAction=RMM_Translate

}

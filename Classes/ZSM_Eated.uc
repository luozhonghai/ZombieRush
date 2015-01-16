class ZSM_Eated extends ZBSpecialMove;


var() ZombiePawn.AnimationParaConfig		AnimCfg_Eated,AnimCfg_Eated_Back;


function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);
	if(InSpecialMoveFlags == 1)
      PawnOwner.PlayConfigAnim(AnimCfg_Eated);
    else
      PawnOwner.PlayConfigAnim(AnimCfg_Eated_Back);
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);

     ZombieRushGame(PawnOwner.WorldInfo.Game).PawnDied();
	if (PawnOwner.health > 0)
	{
		//	PawnOwner.StopConfigAnim(AnimCfg_Push, 0);
	}
}

DefaultProperties
{ 
	//zhujue-siwang actor-death_01
	AnimCfg_Eated=(AnimationNames=("actor-death_01"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendintime=0.0,blendouttime=-1)
	AnimCfg_Eated_Back=(AnimationNames=("actor-backdead"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendintime=0.0,blendouttime=-1)

		UseCustomRMM=True
		RMMInAction=RMM_Translate
		bDisableMovement=true
		bDisableTurn=true
}

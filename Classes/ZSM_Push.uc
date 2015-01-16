class ZSM_Push extends ZBSpecialMove;

var() ZombiePawn.AnimationParaConfig		AnimCfg_Push;
var() ZombiePawn.AnimationParaConfig		AnimCfg_Push_Back;
var() ZombiePawn.AnimationParaConfig		AnimCfg_Kick;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	if (PawnOwner.health > 0)
	{
		if(PCOwner.InteractZombie.ZombieType == EZT_Creep)
			PawnOwner.PlayConfigAnim(AnimCfg_Kick);
		else if( ZSM_GetHurt(PawnOwner.SpecialMoves[SM_Combat_GetHurt]).HurtDirFlag != 1)  
			PawnOwner.PlayConfigAnim(AnimCfg_Push);
		else
			PawnOwner.PlayConfigAnim(AnimCfg_Push_Back);
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
	
	//AnimCfg_Push=(AnimationNames=("zhujue-tuikai"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendintime=0.0,blendouttime=0.4)
  	AnimCfg_Push=(AnimationNames=("actor-pushaway_01"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendintime=0.0,blendouttime=0.3)
  	AnimCfg_Push_Back=(AnimationNames=("actor-pushaway_02"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendintime=0.0,blendouttime=0.3)
  	AnimCfg_Kick=(AnimationNames=("zhujue-tikai"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendintime=0.0,blendouttime=0.3)

		bDisableMovement=true
		bDisableTurn=true
}

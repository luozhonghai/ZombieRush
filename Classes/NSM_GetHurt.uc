class NSM_GetHurt extends ZBSpecialMove;


var() ZombiePawn.AnimationParaConfig		AnimCfg_Hurt;

var() ZombiePawn.AnimationParaConfig		AnimCfg_Die;

var() ZombiePawn.AnimationParaConfig		AnimCfg_Gun_Hurt;

var() ZombiePawn.AnimationParaConfig		AnimCfg_Gun_Die;

var ZombiePawn.AnimationParaConfig LastAnimCfg;
var bool bPushedEndTimer;

var float PushedEndDelay;
var const float PushedDelayTime;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	PawnOwner.ZeroMovementVariables();
	if (PawnOwner.health > 0)
	{
		if(InSpecialMoveFlags == 1)
		{
			PawnOwner.PlayConfigAnim(AnimCfg_Gun_Hurt);
			LastAnimCfg = AnimCfg_Gun_Hurt;
		}
		else
		{
			PawnOwner.PlayConfigAnim(AnimCfg_Hurt);
			LastAnimCfg = AnimCfg_Hurt;
		}
	}
	//   zombie direct cut will cause damage, other zombie just take same effect
	else 
	{
		if(InSpecialMoveFlags == 1)
		{
			PawnOwner.PlayConfigAnim(AnimCfg_Gun_Die);
			LastAnimCfg = AnimCfg_Gun_Die;
		}
		else
		{
			PawnOwner.PlayConfigAnim(AnimCfg_Die);
			LastAnimCfg = AnimCfg_Die;
		}
	}
}

function AnimCfg_AnimEndNotify()
{
	// By default end this special move.
	if(LastAnimCfg == AnimCfg_Die || LastAnimCfg == AnimCfg_Gun_Die){
		//	ZombiePC(PawnOwner.getalocalplayercontroller()).HurtByZombieCinematicRecover();
		bPushedEndTimer = true;
	}

	else if(LastAnimCfg == AnimCfg_Hurt || LastAnimCfg == AnimCfg_Gun_Hurt)
		PawnOwner.EndSpecialMove();
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);

	//PawnOwner.Mesh.RootMotionMode = RMM_Ignore;
	/*
	if (PawnOwner.health <= 0)
	{
		//PawnOwner.StopConfigAnim(AnimCfg_Hurt, 0);
          PawnOwner.CustomDie();
	}*/
}

function bool CanChainMove(ESpecialMove NextMove)
{
	return FALSE;
}

event tickspecial(float deltaTime)
{
	if (bPushedEndTimer)
	{
		PushedEndDelay+=deltaTime;

		if (PushedEndDelay>PushedDelayTime)
		{
			bPushedEndTimer=false;
			PushedEndDelay=0;
			PawnOwner.CustomDie();
		}
	}
}
DefaultProperties
{
	bDisableMovement=true
	bDisableTurn=true
	UseCustomRMM=True
	RMMInAction=RMM_Translate

	AnimCfg_Hurt=(AnimationNames=("zombie01_jitui"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bloop=false,BlendInTime=0.15,BlendOutTime=0.15)
	AnimCfg_Die=(AnimationNames=("zombie01_jidao01"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendouttime=-1.0)
   
    AnimCfg_Gun_Hurt=(AnimationNames=("zombie-Getshot"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bloop=false,BlendInTime=0.1,BlendOutTime=0.1)
	AnimCfg_Gun_Die=(AnimationNames=("zombie-death"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bloop=false,BlendInTime=0.1,BlendOutTime=-1.0)
	PushedDelayTime=3.0
}

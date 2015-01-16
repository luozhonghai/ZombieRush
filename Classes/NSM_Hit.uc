class NSM_Hit extends ZBSpecialMove;


var() ZombiePawn.AnimationParaConfig		AnimCfg_Hit;

var() ZombiePawn.AnimationParaConfig		AnimCfg_Hit_Back;

var() ZombiePawn.AnimationParaConfig		AnimCfg_Hit_Leg;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

//	PawnOwner.Mesh.RootMotionMode = RMM_Ignore;
	if (PawnOwner.health > 0)
	{
		if(PawnOwner.ZombieType == EZT_Walk)
		{
			if(InSpecialMoveFlags != 1)
				PawnOwner.PlayConfigAnim(AnimCfg_Hit);
			else
				PawnOwner.PlayConfigAnim(AnimCfg_Hit_Back);
		}
		else if (PawnOwner.ZombieType == EZT_Creep)
			PawnOwner.PlayConfigAnim(AnimCfg_Hit_Leg);
	}
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);

	if (PawnOwner.health > 0)
	{
	//	PawnOwner.StopConfigAnim(AnimCfg_Hit, 0);
	}
}

event tickspecial(float deltaTime)
{

//	EatEndDelay+=deltaTime;

	if (ZombieControllerBase(PawnOwner.Controller).globalPlayerController.InteractZombie!=none
		&&PawnOwner != ZombieControllerBase(PawnOwner.Controller).globalPlayerController.InteractZombie)
	{
		PawnOwner.EndSpecialMove();

	}
}

DefaultProperties
{
	//zombie01-zhua   zombie-baotui  zombie-Struggle_01
	AnimCfg_Hit=(AnimationNames=("zombie-Struggle_01"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=true)
	
	AnimCfg_Hit_Back=(AnimationNames=("zombie-Struggle_02"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=true)

	AnimCfg_Hit_Leg=(AnimationNames=("zombie-baotui"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=true)
}

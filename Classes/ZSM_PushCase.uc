class ZSM_PushCase extends ZBSpecialMove;

var() ZombiePawn.AnimationParaConfig		AnimCfg_PushCase;
var() float PushSpeed,PushDelay;
var float PreviousGroundSpeed,PushStartDelay;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

//	PawnOwner.setphysics(PHYS_Custom);
	if (PawnOwner.health > 0)
	{
	//	ZombiePlayerPawn(PawnOwner).Rotation.Pitch = 0;
		ZombiePlayerPawn(PawnOwner).InteractCase.setBase(PawnOwner);
		ZombiePlayerPawn(PawnOwner).InteractCase.sethardattach(true);
		PawnOwner.PlayConfigAnim(AnimCfg_PushCase);
		PreviousGroundSpeed = PawnOwner.GroundSpeed;
    PawnOwner.GroundSpeed = PushSpeed;
		PushStartDelay =  0.0;
	}
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
	PawnOwner.Acceleration = vect(0,0,0);
	PawnOwner.StopConfigAnim(AnimCfg_PushCase, 0.1);
	//PawnOwner.setphysics(PHYS_Walking);
	PawnOwner.GroundSpeed = PreviousGroundSpeed;
	ZombieRushPawn(PawnOwner).bCaptureCase = false;

	ZombiePlayerPawn(PawnOwner).InteractCase.setBase(none);
	//when special move interrupted (captured by zombie), reset this flag
	ZombieRushPawn(PawnOwner).bHitWall = false;
}
event tickspecial(float deltaTime)
{
 //   PawnOwner.move(PawnOwner.Velocity*deltaTime);
  local bool res;
	PushStartDelay+=deltaTime;
	if(PushStartDelay >= PushDelay)
	{
		res = ZombieRushPawn(PawnOwner).TraceCaseBlocked();
		if(!res)
	     PawnOwner.Acceleration = 2048*vector(PawnOwner.rotation);
	  else
	     PawnOwner.Acceleration = vect(0,0,0);
	}
}
DefaultProperties
{
	AnimCfg_PushCase=(AnimationNames=("zhujue_tuixiangzi"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=true,blendintime=0.0,blendouttime=0.4)

		bDisableMovement=true
		bDisableTurn=true

		PushSpeed = 100
		PushDelay =  0.5
}

class ZSM_PushCase extends ZBSpecialMove;

var() ZombiePawn.AnimationParaConfig		AnimCfg_PushCase;
var() float PushSpeed,PushDelay;
var() float PushEndWaitTime;
var float PreviousGroundSpeed,PushStartDelay, PushEndWait;
var Actor InteractCase;
var bool bPostPushUpdate;

var Vector PushDir;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

//	PawnOwner.setphysics(PHYS_Custom);
	if (PawnOwner.health > 0)
	{
		InteractCase = ZombiePlayerPawn(PawnOwner).InteractCase;
	//	ZombiePlayerPawn(PawnOwner).Rotation.Pitch = 0;
	//	if(InterpActor(InteractCase) != None) {
			  InteractCase.setBase(PawnOwner);
			  InteractCase.sethardattach(true);
	//	}
		
		PawnOwner.PlayConfigAnim(AnimCfg_PushCase);
		PreviousGroundSpeed = PawnOwner.GroundSpeed;
    PawnOwner.GroundSpeed = PushSpeed;
		PushStartDelay =  0.0;
		PushEndWait = 0.0;
		bPostPushUpdate = false;
		PushDir = vector(PawnOwner.rotation);

		ZombieRushPawn(PawnOwner).bHitWall = true;
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
  
 // if(InterpActor(InteractCase) != None) {
		InteractCase.setBase(none);
//	}
	//when special move interrupted (captured by zombie), reset this flag
	ZombieRushPawn(PawnOwner).bHitWall = false;
}
event tickspecial(float deltaTime)
{
 //   PawnOwner.move(PawnOwner.Velocity*deltaTime);
  local bool res;
  local Vector Impulse;


  if (bPostPushUpdate)
  {
  	PostPushWaitUpdate(deltaTime);
  }
  else
  {
  	NormalPushUpdate(deltaTime);
  }
}

function NormalPushUpdate(float deltaTime)
{
	local bool res;
  local Vector Impulse;
	PushStartDelay+=deltaTime;
	if(PushStartDelay >= PushDelay)
	{
		res = ZombieRushPawn(PawnOwner).TraceCaseBlocked();
		if(!res)
		{
			if(InterpActor(InteractCase) != None) 
	     PawnOwner.Acceleration = 2048*vector(PawnOwner.rotation);
	    else if(KActor(InteractCase) != None) 
	    {

	    	if(ZombieRushPawn(PawnOwner).TraceCaseBottomEmpty()) 
	    	{
	    		InteractCase.SetPhysics(PHYS_RigidBody);
	    		Impulse = vector(PawnOwner.rotation) * 500; 
	      	KActor(InteractCase).StaticMeshComponent.AddImpulse(Impulse, PawnOwner.Location);
	      	bPostPushUpdate = true;
	      	PawnOwner.StopConfigAnim(AnimCfg_PushCase, 0.1);
	      	PawnOwner.Acceleration = vect(0,0,0);
	    	}
	    	else 
	    	{
	    		PawnOwner.Acceleration = 2048*vector(PawnOwner.rotation);
	    	}	
	    }
	  }
	  else
	    PawnOwner.Acceleration = vect(0,0,0);
	}

	if (Normal(ZombieParkourPC(PCOwner).InputJoyVectorProjectToWorld) dot PushDir < 0.1)
	{
		PawnOwner.EndSpecialMove();
	}
}
function PostPushWaitUpdate(float deltaTime)
{
	PushEndWait+=deltaTime;
	if(PushEndWait >= PushEndWaitTime)
	{
		PawnOwner.EndSpecialMove();
	}
}


function bool CanReceiveInput()
{
	return true;
}

DefaultProperties
{
	AnimCfg_PushCase=(AnimationNames=("zhujue_tuixiangzi"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=true,blendintime=0.0,blendouttime=0.4)

		bDisableMovement=true
		bDisableTurn=true

		PushSpeed = 100
		PushDelay =  0.5
		PushEndWaitTime = 1.2
}

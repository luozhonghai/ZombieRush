class ZBAIControllerTest extends ZBAIControllerBase;




//attack ready booleans.  Set true when the attack is available.  Set to false when the attack is on a cooldown

var bool attackReady_melee;

var bool moveAwayFinish;

var bool idleFinish;
//actual timers for the cooldowns

var float timer_melee;

var float timer_moveaway;

var float timer_idle;

var int index;
var int counter;

//keep record of previous state
var Name previousState;

//for wander
var Vector WanderLocation;
var Vector SpawnLocation;
var float WanderRange;

//for move away from player
enum EMoveAwayType
{
	EMAT_Left,
	EMAT_Right,// not implement
	EMAT_Idle,
};
var EMoveAwayType MoveAwayDir;
var int MoveAwayRandNum;

//for Leap

var vector PendingLeapPosition;
var ZBAIPawnBase ActiveAIPawn;



var		transient int	AwareUpdateFrameCount;
var		transient array<Actor>	NearbyDynamics;
var(Path) float AwareRadius;
var(Path) float AvoidOtherRadius;
var(Path) float AvoidOtherStrength;
var(Path)	int		AwareUpdateInterval;


event PostBeginPlay()
{
	Super.PostBeginPlay();



}


function initializeGame()
{
	super.initializeGame();

	if (Pawn == none)
	{
		return;
	}

	//cast the ActiveAIPawn
	ActiveAIPawn = ZBAIPawnBase(Pawn);

	SpawnLocation = ActiveAIPawn.location;
	//get the AnimationNode for animations
	AnimationNodeSlot = AnimNodeSlot(Pawn.Mesh.FindAnimNode('CustomSlot'));


	//give the zombie the force weapon
	ActiveAIPawn.AddDefaultInventory();

}
/** Change AI states */
protected event ExecuteWhatToDoNext()
{
/*
	if(VSize(globalPlayerController.Pawn.Location - Pawn.Location) <70)
		GotoState('MeleeAttackPlayer');
	else if(VSize(globalPlayerController.Pawn.Location - Pawn.Location) <ActiveAIPawn.moveToPlayerUpperRange)
	{
		if (ActorReachable(globalPlayerController.Pawn) == false)
		{
			GotoState('FindPathNodeTowardsPlayer');
		}
		else
		{
			//GotoState('MoveTowardsPlayer');
			GotoState('MoveToPlayer');
		}
	}

	else if (VSize(globalPlayerController.Pawn.Location - Pawn.Location) < ActiveAIPawn.lookAtPlayerUpperRange)
	{
		GotoState('LongDistance_SeePlayer');
	}
	else
		GotoState('Patrol');	*/

}

///////////////////////////////////////////////////////////////////////////////////////
//AI STATES
///////////////////////////////////////////////////////////////////////////////////////
/** Basic patrol */
state Patrol
{
	event BeginState(Name PreviousStateName)
	{
		index = int(RandRange(1, 5));

		ActiveAIPawn.GroundSpeed = ActiveAIPawn.speed_outsideMeleeRange;
		ActiveAIPawn.AccelRate = ActiveAIPawn.speed_normalAccel;
	}

	function Vector CalculateMovementDirection()
	{
		local Vector destination;
		local Rotator vectorRotation;
		//get random angle
		vectorRotation.Yaw = (FRand() * 360 * 182);
		//get the normalized vector between pawn and player
		destination = Normal(ActivePlayerPawn.Location - ActiveAIPawn.Location);
		//apply the rotation to the vector
		destination = destination << vectorRotation;
		ActiveAIPawn.SetRotation(Rotator(destination));
		//`log(""$(vectorRotation.Yaw / 182));
		return destination;
	}

Begin:
	previousState = GetStateName();
	for(counter = 0; counter < index; counter++)
	{
		//`log("11");

		WanderLocation = ActiveAIPawn.Location + (CalculateMovementDirection() * ActiveAIPawn.other_movementVectorLength * RandRange(0.7, 1));
		if (VSize(WanderLocation - SpawnLocation)<=WanderRange)
		{
            MoveTo(WanderLocation, ActiveAIPawn);
		}
		else
             MoveTo(SpawnLocation, ActiveAIPawn);
		
	}
	Sleep(RandRange(1.3, 2));
	LatentWhatToDoNext();
}



/** Stop and look at player */
state LongDistance_SeePlayer
{

	event BeginState(Name PreviousStateName)
	{

	}
begin:
	//look at player
	MoveTo(Pawn.Location, globalPlayerController.Pawn);

	//fire off next decision loop
	LatentWhatToDoNext();
}



state FindPathNodeTowardsPlayer
{
	function resetVariables()
	{

	}

	function moveToPathNode()
	{

	}

Begin:

	//WhatToDoNext();
	MoveTo(FindPathToward(globalPlayerController.Pawn).Location, FindPathToward(globalPlayerController.Pawn));
	LatentWhatToDoNext();
}



/** Move towards the player */
state MoveTowardsPlayer
{

	event BeginState(Name PreviousStateName)
	{
	  ActiveAIPawn.GroundSpeed = ActiveAIPawn.speed_outsideMeleeRange/2;
	}
begin:
	MoveToward(ActivePlayerPawn, ActivePlayerPawn);

	//fire off next decision loop
	LatentWhatToDoNext();
}


//executes a melee attack
state MeleeAttackPlayer
{

	simulated function Tick(float DeltaTime)
	{
		global.tick(DeltaTime);

		performPhysics(DeltaTime);
	}

	function Vector CalculateMovementDirection()
	{
		local Vector destination;
		local Rotator vectorRotation;
		vectorRotation.Yaw = (FRand() * 180 * 182) - (90*182);
		vectorRotation.Yaw -= (-180 * 182);
		destination = Normal(ActivePlayerPawn.Location - ActiveAIPawn.Location);
		destination = destination << vectorRotation;
		//make the spider face the direction he's walking
		//Ãæ³¯ player
		   //ActiveAIPawn.SetRotation(Rotator(destination));
		return destination;
	}

begin:
	previousState = GetStateName();
	if(attackReady_melee)
	{
		attackReady_melee = false;
		`log("Commit attack");

		ActiveAIPawn.SetRotation(Rotator(ActivePlayerPawn.Location - ActiveAIPawn.Location));

		ActiveAIPawn.startfire(1);


		while(ActiveAIPawn.IsDoingASpecialMove())
			Sleep(0.0);
		 //Sleep(1.4);

		 MoveAwayRandNum = Rand(3);
		 if (MoveAwayRandNum==0)
		 {
			 MoveAwayDir = EMAT_Left;
		 }
		 else  if(MoveAwayRandNum==1)
			 MoveAwayDir = EMAT_Right;
		 else
			 MoveAwayDir =  EMAT_Idle;

        LatentWhatToDoNext();
	}
	else
	{
	//	MoveToward(meleeAttackRetreat, ActivePlayerPawn);
		//ActiveAIPawn.GroundSpeed = 200;
		//MoveTo(ActiveAIPawn.Location + (CalculateMovementDirection() * ActiveAIPawn.other_movementVectorLength * RandRange(0.5, 1.5)), globalPlayerController.Pawn);
		//LatentWhatToDoNext();
       GotoState('MoveAwayFromPlayer');
	}
}


//move towards Player  not move direct
state MoveToPlayer
{
	event BeginState(Name PreviousStateName)
	{
		ActiveAIPawn.GroundSpeed = ActiveAIPawn.speed_outsideMeleeRange;
		ActiveAIPawn.AccelRate = ActiveAIPawn.speed_normalAccel;
		if (AnimationNodeSlot.bIsPlayingCustomAnim)
		{
			AnimationNodeSlot.StopCustomAnim(0.5f);
		}
	}

	simulated function Tick(float DeltaTime)
	{
		global.tick(DeltaTime);

		if (VSize(globalPlayerController.Pawn.Location - Pawn.Location) <ActiveAIPawn.GetCollisionRadius()+ActivePlayerPawn.GetCollisionRadius()+10)
		{
			StopLatentExecution();
		}
        
		performPhysics(DeltaTime);

	}
	function Vector CalculateMovementDirection()
	{
		local Vector destination;
		local Rotator vectorRotation;
		//get random angle in front of pawn
		vectorRotation.Yaw = (FRand() * 60 * 182) - (30*182);
		//get the normalized vector between pawn and player
		destination = Normal(ActivePlayerPawn.Location - ActiveAIPawn.Location);
		//apply the rotation to the vector
		destination = destination << vectorRotation;
		//make the spider face the direction he's walking if it's far from the player
		if(VSize(ActiveAIPawn.Location - ActivePlayerPawn.Location) > ActiveAIPawn.range_movelookAtPlayer)
		{
			ActiveAIPawn.SetRotation(Rotator(destination));
		}
		return destination;
	}

Begin:
	if (attackReady_melee)
	{
		previousState = GetStateName();
	  //	ActiveAIPawn.PlayASound(ActiveAIPawn.sc_Movement);
		//if we're in a certain range, start looking at the player
		if(VSize(ActiveAIPawn.Location - ActivePlayerPawn.Location) < ActiveAIPawn.range_movelookAtPlayer)
		{
			//MoveTo(ActiveAIPawn.Location + (CalculateMovementDirection() * ActiveAIPawn.other_movementVectorLength * RandRange(0.5, 1.5)), ActivePlayerPawn);
			     gotostate('leap');
		}
		else
		{
			MoveTo(ActiveAIPawn.Location + (CalculateMovementDirection() * ActiveAIPawn.other_movementVectorLength * RandRange(0.5, 1.5)), ActiveAIPawn);
		}

      

		 //Sleep(RandRange(0.1, 0.3));
		LatentWhatToDoNext();
	}

	else 
	{
		GotoState('MoveAwayFromPlayer');
	}

}

state Idle
{ 
	event BeginState(Name PreviousStateName)
	{
        moveAwayFinish = false;
	}
    
	event EndState(Name PreviousStateName)
	{
		
	}


	simulated function Tick(float DeltaTime)
	{
		local Vector TotalForce;
		global.tick(DeltaTime);

	//	performPhysics(DeltaTime);

        UpdatePartnerInfo();
		TotalForce += CalcIntraCrowdForce();

		TotalForce.Z = 0.f;

		Pawn.Velocity += 10*TotalForce * DeltaTime;

	}
	function updateTimers(float DeltaTime)
	{
		global.updateTimers(DeltaTime);

		timer_idle += DeltaTime;
		if (timer_idle > ActiveAIPawn.cooldown_seconds_idle)
		{
			idleFinish = true;
			timer_idle = 0;
		}
	}
begin:
	while (!idleFinish)
	{
		//Sleep(0.0);
		MoveTo(Pawn.Location, globalPlayerController.Pawn);
	}
    
	idleFinish = false;

	LatentWhatToDoNext();
}





//move away from player
state MoveAwayFromPlayer
{
	event BeginState(Name PreviousStateName)
	{
		ActiveAIPawn.GroundSpeed = ActiveAIPawn.speed_outsideMeleeRange;
		ActiveAIPawn.AccelRate = ActiveAIPawn.speed_normalAccel;
	}

	function updateTimers(float DeltaTime)
	{
		global.updateTimers(DeltaTime);

		timer_moveaway += DeltaTime;
		if (timer_moveaway > ActiveAIPawn.cooldown_seconds_moveAway)
		{
			moveAwayFinish = true;
			timer_moveaway = 0;
		}
	}
	function Vector CalculateMovementDirection()
	{
		local Vector destination;
		local Rotator vectorRotation;


		//    vectorRotation.Yaw = (FRand() * 180 * 182) - (90*182);
		//    vectorRotation.Yaw -= (-180 * 182);

		if (MoveAwayDir == EMAT_Left)
		{
              vectorRotation.Yaw = 110*182 *(1.1 - VSize(globalPlayerController.Pawn.Location - Pawn.Location)/ActiveAIPawn.range_meleeReady);
			  vectorRotation.Yaw += (2*FRand()-1) * 25 * 182;

		}
		else if (MoveAwayDir == EMAT_Right)
		{
              vectorRotation.Yaw = -110*182 *(1.1 - VSize(globalPlayerController.Pawn.Location - Pawn.Location)/ActiveAIPawn.range_meleeReady);
			   vectorRotation.Yaw += (2*FRand()-1) * 25 * 182;
		}



		destination = Normal(ActivePlayerPawn.Location - ActiveAIPawn.Location);
		destination = destination << vectorRotation;
		//make the spider face the direction he's walking
	     //	ActiveAIPawn.SetRotation(Rotator(destination));
		return destination;
	}

Begin:


	previousState = GetStateName();

	if (MoveAwayDir==EMAT_Idle)
	{
        GotoState('Idle');
	}

	if(!moveAwayFinish)
	{
	//ActiveAIPawn.PlayASound(ActiveAIPawn.sc_Movement);
	MoveTo(ActiveAIPawn.Location + (CalculateMovementDirection() * ActiveAIPawn.other_movementAwayVectorLength * RandRange(0.5, 1.5)), ActivePlayerPawn);


	//Sleep(RandRange(0.1, 0.3));
	LatentWhatToDoNext();
	}
		else
	{
			GotoState('Idle');
	}
	
}



state Hurt
{

	event BeginState(Name PreviousStateName)
	{
		stopLatentExecution();
	}

	event PushedState()
	{
		stopLatentExecution();
	}
begin:

	MoveTo(Pawn.Location, globalPlayerController.Pawn);
	while(ActiveAIPawn.IsDoingASpecialMove())
		Sleep(0.0);

	//LatentWhatToDoNext();
	PopState();
}

//perform leap attack
state Leap
{
	function Vector CalculateLeapPosition()
	{
		local Vector destination;
		//get the normalized vector between pawn and player
		destination = Normal(ActivePlayerPawn.Location - ActiveAIPawn.Location);
		destination *= VSize(ActivePlayerPawn.Location - ActiveAIPawn.Location) * 0.6;
		destination += ActiveAIPawn.Location;
		return destination;
	}

	simulated function Tick(float DeltaTime)
	{
		
		local vector TotalForce;
		global.tick(DeltaTime);

		//performPhysics(DeltaTime);

	//	TotalForce += 1.5*CalcIntraCrowdForce();

	//	TotalForce.Z = 0.f;

	//	Pawn.Velocity += TotalForce * DeltaTime;

		/*
		if(jumpObstacleTest())
		{
				velocity.x = 0;
				velocity.y = 0;
		}*/

	}
begin:

	//face the player
	MoveToward(ActiveAIPawn, ActivePlayerPawn);
	//give it half a second to rotate
	Sleep(0.5); 

	MoveToward(ActiveAIPawn, ActiveAIPawn);
	//execute the leap
	//ActiveAIPawn.DoJump(true);
    
	PendingLeapPosition = CalculateLeapPosition();
	//ActiveAIPawn.setphysics(PHYS_Falling);
	ActiveAIPawn.DoJump(true);
	ActiveAIPawn.velocity = ActiveAIPawn.groundspeed * Normal(PendingLeapPosition - ActiveAIPawn.location);
    ActiveAIPawn.velocity.z= ActiveAIPawn.jumpz;
	MoveTo(PendingLeapPosition, ActiveAIPawn);

	while (Pawn.physics != PHYS_Walking)
	{
		Sleep(0.0);
	}
	LatentWhatToDoNext();
}
///////////////////////////////////////////////////////////////////////////////////////
//////////////////////Functions that run in the background/////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
/**manages all of the timers in this class based on if flags are turned on/off*/
function updateTimers(float DeltaTime)
{
	//Melee Attack Cooldown
	if (attackReady_melee == false)
	{
		timer_melee += DeltaTime;
		if (timer_melee > ActiveAIPawn.cooldown_seconds_meleeAttack)
		{
			attackReady_melee = true;
			timer_melee = 0;
		}
	}
}

simulated function Tick(float DeltaTime)
{
	updateTimers(DeltaTime);

	AwareUpdateFrameCount++;
	if(AwareUpdateFrameCount >= AwareUpdateInterval)
	{
		AwareUpdateFrameCount = 0;
		UpdatePartnerInfo();

	//	performPhysics(DeltaTime);
	}
	
	
}


function UpdatePartnerInfo()
{
	local Actor checked;
	local Vector checkcenter;

	if(NearbyDynamics.Length>0)
	{
		NearbyDynamics.Remove(0,NearbyDynamics.Length);
	}
	checkcenter = Pawn.Location;//+0.5f*AwareRadius*Normal(Velocity);
// Test location is out in front of agent
//FCheckResult* Link = GWorld->Hash->
//RestrictedOverlapCheck(GMainThreadMemStack, this, Location+0.5f*AwareRadius*Velocity.SafeNormal(), AwareRadius);

	foreach OverlappingActors( class'Actor', checked,AwareRadius ,checkcenter)
	{
	NearbyDynamics.AddItem(checked);
/*
	if(AttackPawn(checked)!=none)
	{
		if(AttackPawn(checked).NearbyDynamics.Find(self)==-1)
			AttackPawn(checked).NearbyDynamics.AddItem(self);
	}*/
	}
}


function vector CalcIntraCrowdForce()
{
	local Actor FlockActor;
	local Vector ResultForce;
	local int i;
	local Vector ToFlockActor;
	local FLOAT ToFlockActorMag;
	local FLOAT Overlap;


	local Vector FlockVel;
	local INT FlockCount;


	for(i=0; i<NearbyDynamics.Length; i++)
	{
		FlockActor = NearbyDynamics[i];
		if( FlockActor!=none&& (FlockActor != self) )
		{
			if ( ZombiePawn(FlockActor)!=none)
			{
				// if it isn't an agent, have to be more aggressive about avoidance, since other guy isn't avoiding me
				FlockVel += FlockActor.Velocity;
				ToFlockActor = FlockActor.Location - ActiveAIPawn.Location;
				ToFlockActorMag = VSize(ToFlockActor);

				if( AvoidOtherRadius > ToFlockActorMag )
				{
					ToFlockActorMag = ToFlockActorMag;
					Overlap =AvoidOtherRadius - ToFlockActorMag;
					// normalize
					ToFlockActor /= fMax(0.001f, ToFlockActorMag);

					ResultForce += ((Overlap/AvoidOtherRadius) * (-ToFlockActor) * (AvoidOtherStrength));

					// FIXMESTEVE - also reduce based on velocity component that's toward this guy
				}
				FlockCount++;
			}
		}
	}
	return ResultForce;
}



function performPhysics(FLOAT DeltaTime)
{
  local Vector TotalForce;
// Update forces between crowd members
	TotalForce += CalcIntraCrowdForce();

	TotalForce.Z = 0.f;

	Pawn.Velocity += TotalForce * DeltaTime;
}

function bool jumpObstacleTest()
{
	local vector HitLocation,HitNormal,lStart,lEnd ,VelXY;
	local Actor HitActor;

   if (Pawn.Physics == PHYS_Falling)

   {
	   VelXY = Pawn.velocity;
	   VelXY.z = 0;

	   if(VSize(VelXY) > 0)
	   {
			lStart =   Pawn.location + 1.5 * Pawn.GetcollisionRadius()*Normal(VelXY);
			lEnd =  lStart + vect(0,0,-1000);
		//	 HitActor = Trace(HitLocation, HitNormal, lEnd, lStart, true, ,,PawnOwner.TRACEFLAG_Bullet);
            HitActor = Trace(HitLocation, HitNormal, lEnd, lStart, true, vect(20,20,20));
			if (HitActor != NONE)
			{
					if ( HitLocation.z > Pawn.location.Z - Pawn.Getcollisionheight()
						||(HitLocation.z < (Pawn.location.Z - Pawn.Getcollisionheight()) && Pawn.location.Z - Pawn.Getcollisionheight()>-20) )
					{
						return true;
					}
					
			 }
	   }
   }
   return false;
}
DefaultProperties
{
	WanderRange=1000;

	AvoidOtherRadius=80

		AwareRadius=200

		AvoidOtherStrength=1200.0

		AwareUpdateInterval=30
}

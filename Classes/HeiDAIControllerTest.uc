class HeiDAIControllerTest extends HeiDAIControllerBase;


var ZBAIPawnBase ActiveAIPawn;

var Vector SpawnLocation;

var PathNode JumpDownNode;


function initializeGame()
{
	super.initializeGame();

	if (Pawn == none)
	{
		return;
	}

	//cast the ActiveAIPawn
	ActiveAIPawn = ZBAIPawnBase(Pawn);

	if(ActiveAIPawn.JumpDownNode!=none)
		JumpDownNode = ActiveAIPawn.JumpDownNode;

	SpawnLocation = ActiveAIPawn.location;
	//get the AnimationNode for animations
	AnimationNodeSlot = AnimNodeSlot(Pawn.Mesh.FindAnimNode('CustomSlot'));


	//give the zombie the force weapon
	ActiveAIPawn.AddDefaultInventory();

}

protected event ExecuteWhatToDoNext()
{
//	if(VSize(globalPlayerController.Pawn.Location - Pawn.Location) <70)
//		GotoState('MeleeAttackPlayer');
//	else //if(VSize(globalPlayerController.Pawn.Location - Pawn.Location) <ActiveAIPawn.moveToPlayerUpperRange)
//	{
		GotoState('MoveToPlayer');
//	}
}


/*****************************************
 * **************States*******************
 * ***************************************/

//initialize state, should only be called once at the beginning
auto state initializePlayer
{
Begin:
	initializeGame();
	//LatentWhatToDoNext();
}

state MoveToPathNode
{

begin:

	if (JumpDownNode!=none)
	{
		MoveTo(JumpDownNode.location,JumpDownNode);
	}

	LatentWhatToDoNext();
    
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

	//	ActiveAIPawn.SetRotation(Rotator(ActivePlayerPawn.Location - ActiveAIPawn.Location));
	}

	simulated function Tick(float DeltaTime)
	{
		global.tick(DeltaTime);

		// ActiveAIPawn.velocity.y = 0;

		if (VSize(globalPlayerController.Pawn.Location - Pawn.Location) <ActiveAIPawn.GetCollisionRadius()+ActivePlayerPawn.GetCollisionRadius()+10)
		{
			StopLatentExecution();
		}

	//	performPhysics(DeltaTime);

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

		//MoveTo(ActiveAIPawn.Location + (CalculateMovementDirection() * ActiveAIPawn.other_movementVectorLength * RandRange(0.5, 1.5)), ActiveAIPawn);
		

	ActiveAIPawn.SetRotation(Rotator(ActivePlayerPawn.Location - ActiveAIPawn.Location));
		MoveTo(ActivePlayerPawn.Location,ActivePlayerPawn);
		LatentWhatToDoNext();


}

DefaultProperties
{
}

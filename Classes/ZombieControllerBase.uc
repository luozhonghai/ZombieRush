class ZombieControllerBase extends UDKBot;



var ZombiePC globalPlayerController;  ///<reference to the playerController
var Pawn ActivePlayerPawn;

//animation
var AnimNodeSlot AnimationNodeSlot;

/***************************************
 * ************ Functions***************
 * *************************************/
/**Takes control of a given pawn*
 * \param   NewPawn     The pawn to Possess*/
function SetPawn(ZBAIPawnBase NewPawn)
{
	Possess(NewPawn, false);
	Pawn.SetMovementPhysics();
	`log("AI setPawn");
}



/**Finds the player controller*/
function initializeGame()
{
	//finds the player
	local ZombiePC ZbPC;
	foreach LocalPlayerControllers(class'ZombiePC', ZbPC)
	{
		globalPlayerController = ZbPC;
	}

	//cast the Player Pawn
	if(globalPlayerController != none)
	{
		ActivePlayerPawn = globalPlayerController.Pawn;
	}

	InitNavigationHandle();
}

/**
 * Tries to find a path to the specified location using the NavMesh. Returns true,
 * if the search was successful, storing the resulting path in the pathcache, and
 * false, otherwise.
 * 
 * @param TargetLocation
 *      the location to compute a path to
 * @param Distance
 *      the acceptable distance from that location
 */
function bool FindPathToLocation(Vector TargetLocation, float Distance)
{
	NavigationHandle.ClearConstraints();

	// reset path constraints and goal evaluators
	NavigationHandle.PathConstraintList = none;
	NavigationHandle.PathGoalList = none;

	// find path
	class'NavMeshPath_Toward'.static.TowardPoint(NavigationHandle, TargetLocation);
	class'NavMeshGoal_At'.static.AtLocation(NavigationHandle, TargetLocation, Distance);

	NavigationHandle.SetFinalDestination(TargetLocation);

	return NavigationHandle.FindPath();
}

/**
 * Tries to find a path to the specified target unit using the NavMesh. Returns true,
 * if the search was successful, storing the resulting path in the pathcache, and
 * false, otherwise.
 * 
  * @param Target
 *      the actor to compute a path to
 * @param Distance
 *      the acceptable distance from that location
 */
function bool FindPathToUnit(Actor Target, optional float Distance)
{
//	NavigationHandle.ClearConstraints();

	NavigationHandle.SetFinalDestination(Target.Location);
	// reset path constraints and goal evaluators
	NavigationHandle.PathConstraintList = none;
	NavigationHandle.PathGoalList = none;

	// find path
	class'NavMeshPath_Toward'.static.TowardGoal(NavigationHandle, Target);
	class'NavMeshGoal_At'.static.AtActor(NavigationHandle, Target, Distance);

	

	return NavigationHandle.FindPath();
}


/** Returns the next point in the pathfinding along to a destination Goal, for our NavigationHandle. */
event vector CustomGeneratePathToActor( Actor Goal, optional float WithinDistance, optional bool bAllowPartialPath )
{
	local vector NextDest;
	NextDest = Goal.Location;
	if(FindPathToUnit(Goal,WithinDistance))
	{
		`log("find path!!!!!");
       NavigationHandle.GetNextMoveLocation(NextDest, 10);
	   if(VSize(NextDest) == 0)
	   {
		   //`log(self @ " Invalid path... most likely got off navmesh somehow.");
		 //  ObstructionJump(vect(300,0,0),vect(0,0,0));
		   NextDest = Pawn.Location;
	   }
	}
	else
	{
		`log("Couldn't find path :(");
	}
	//we're all done getting the next point, so clear our constraints for this calculation
//	NavigationHandle.ClearConstraints();

	return NextDest;
}

function bool NavActorReachable(Actor a)
{
	if ( NavigationHandle == None )
		InitNavigationHandle();

	return NavigationHandle.ActorReachable(a);
}
event WhatToDoNext()
{
	DecisionComponent.bTriggered = true;
}

/*****************************************
 * **************States*******************
 * ***************************************/

//initialize state, should only be called once at the beginning
auto state initializePlayer
{
Begin:
	initializeGame();
	LatentWhatToDoNext();
}


DefaultProperties
{
}

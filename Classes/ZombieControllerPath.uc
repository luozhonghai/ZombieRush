class ZombieControllerPath extends ZombieControllerTest;

var ZombieSpawnNodePathSwarmer SwarmerOwner;
var Note NextMoveNode;
var int SwarmerPathIndex;
var int CurrentNodeIndex;
var float AwarePlayerDistance;
// Body...
//initialize state, should only be called once at the beginning
auto state initializePlayer
{
Begin:
	initializeGame();
	SwarmerOwner = ZombieSpawnNodePathSwarmer(ZBAIPawnPath(Pawn).NodeOwner);
	SwarmerPathIndex = ZBAIPawnPath(Pawn).PathIndex;
	GotoState('FollowPath');
}
state FollowPath
{
	event Tick(float deltaTime)
	{
		 distanceToPlayer = VSize(globalPlayerController.Pawn.Location - Pawn.Location);
		 if(distanceToPlayer <= AwarePlayerDistance)
		 {
		 	 StopLatentExecution();
		 	 WhatToDoNext();
		 }
	}
Begin:
  Pawn.SetMovementPhysics();
  while(CurrentNodeIndex < SwarmerOwner.PathList[SwarmerPathIndex].PathNode.Length)
  {
  	NextMoveNode = SwarmerOwner.PathList[SwarmerPathIndex].PathNode[CurrentNodeIndex];
  	if(NextMoveNode!=None)
  		MoveTo(NextMoveNode.Location,NextMoveNode);
  	else
  	{
  		break;
  	}
  	CurrentNodeIndex++;
  }
   LatentWhatToDoNext();
}
defaultproperties
{
	AwarePlayerDistance=300
	CurrentNodeIndex=0
}
class ZBAIControllerBase extends UDKBot
	abstract;


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

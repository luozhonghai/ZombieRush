class ZombieGameInfo extends SimpleGame;


/*
`if(`isdefined(debug))
`endif
*/


// Enum platform
enum EPlatform
{
	P_Auto,
	P_Mobile,
	P_PC		// Also stands for Mac
};



static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	return class'ZGame.ZombieGameInfo'; 
}

event PlayerController Login(string Portal, string Options, const UniqueNetID UniqueID, out string ErrorMessage)
{
	local PlayerController PC;

	PC = super.Login(Portal, Options, UniqueID, ErrorMessage);
	ChangeName(PC, "Player", true);

	return PC;
}

event PostLogin(PlayerController rPlayerController)
{
	local ZombiePawn lPawn;
	//local NXActor lActor;

	super.PostLogin(rPlayerController);

	/* If we're dealing with an NXPlayerController, we
	 * need to initialize it and the pawn it's attached to */
	if (ZombiePC(rPlayerController) != none)
	{
		ZombiePC(rPlayerController).Initialize();
	}

	/* Cycle through all the NXPawn and initialize them as well */
	foreach WorldInfo.AllPawns(class'ZombiePawn', lPawn)
	{
		lPawn.Initialize();
	}

	// Initialize all the actors
	/*ForEach AllActors(class'NXActor', lActor)
	{
		lActor.Initialize();
	}*/

	// Log that we're done
	//LogInternal("NXGameInfo.PostLogin");
}



/**
 * Returns the platform that this game is running as
 *
 * @network			Server
 */
static function EPlatform GetPlatform()
{
	local WorldInfo InstancedWorldInfo;

	// Grab the instanced world info, abort if none
	InstancedWorldInfo = class'WorldInfo'.static.GetWorldInfo();
	if (InstancedWorldInfo == None)
	{
		return P_PC;
	}

	// Auto detect the platform
	if (InstancedWorldInfo.IsConsoleBuild(CONSOLE_Mobile) || InstancedWorldInfo.IsConsoleBuild(CONSOLE_IPhone) || InstancedWorldInfo.IsConsoleBuild(CONSOLE_Android))
	{
		return P_Mobile;
	}

	// In case all else fails
	return P_PC;

}
 
DefaultProperties
{
	DefaultPawnClass=class'ZombiePlayerPawn'
    PlayerControllerClass=class'ZombiePC'
	HUDType=class'ZombieHud'
    
}

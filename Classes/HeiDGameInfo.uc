class HeiDGameInfo extends SimpleGame;

event PostLogin(PlayerController rPlayerController)
{
	local ZombiePawn lPawn;


	super.PostLogin(rPlayerController);
	/* Cycle through all the NXPawn and initialize them as well */
	foreach WorldInfo.AllPawns(class'ZombiePawn', lPawn)
	{
			lPawn.Initialize();
	}
}

DefaultProperties
{
	DefaultPawnClass=class'ZombiePlayerPawn'
	PlayerControllerClass=class'HeiDPC'
}

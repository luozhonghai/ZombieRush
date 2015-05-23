class ZombieParkourGame extends ZombieRushGame;



// Body...
static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	return class'ZGame.ZombieParkourGame'; 
}

defaultproperties
{
	DefaultPawnClass=class'ZombieParkourPawn'
	PlayerControllerClass=class'ZombieParkourPC'
	HUDType=class'ZombieHud'

	CustomGravityZ=-900//2500
  LevelTransFileName="LevelTrans.bin"
}
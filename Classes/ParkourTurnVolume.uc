class ParkourTurnVolume extends TriggerVolume;

// Body...
var bool bActived;  // can only turn once in the volume
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	super.Touch(Other, OtherComp, HitLocation, HitNormal);
	if (ZombieRushPawn(Other) != none)
	{
		//ZombieParkourPC(ZombieRushPawn(Other).Controller).ToggleTurn(true);
	}
}
event untouch(Actor Other)
{
	local vector X,Y,Z;
  local vector ExitLocation;
  local vector ExitDir;
  local vector NewCamDir;
	if (ZombieRushPawn(Other) != none)
	{
		//ZombieParkourPC(ZombieRushPawn(Other).Controller).ToggleTurn(false);
		GetAxes(Rotation, X,Y,Z);
		ExitLocation = ZombieRushPawn(Other).Location;
		ExitDir = Normal(ExitLocation - Location);
		if(abs(ExitDir dot X) > abs(ExitDir dot Y))
		  NewCamDir = (ExitDir dot X) * X;
		else
			NewCamDir = (ExitDir dot Y) * Y;
		ZombieParkourPC(ZombieRushPawn(Other).Controller).TurnCamera(NewCamDir);
	}
}

defaultproperties
{
	
}
class ParkourTurnVolume extends TriggerVolume;

// Body...
var bool bActived;  // can only turn once in the volume
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	super.Touch(Other, OtherComp, HitLocation, HitNormal);
	if (ZombieRushPawn(Other) != none)
	{
		ZombieParkourPC(ZombieRushPawn(Other).Controller).ToggleTurn(true);
	}
}
event untouch(Actor Other)
{
	if (ZombieRushPawn(Other) != none)
	{
		ZombieParkourPC(ZombieRushPawn(Other).Controller).ToggleTurn(false);
	}
}

defaultproperties
{
	
}
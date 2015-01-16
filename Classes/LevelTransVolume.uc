class LevelTransVolume extends TriggerVolume;

// Body...
var() string NextLevelName;
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	super.Touch(Other, OtherComp, HitLocation, HitNormal);
	if(ZombieRushPawn(Other) != none && NextLevelName!="")
	{		
		ZombieRushPC(ZombieRushPawn(Other).Controller).TransNextLevel(NextLevelName);
	}
}
defaultproperties
{
	
}
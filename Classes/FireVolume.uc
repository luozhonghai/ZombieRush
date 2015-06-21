class FireVolume extends TriggerVolume;

// Body...
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
  super.Touch(Other, OtherComp, HitLocation, HitNormal);
  if (ZombieRushPawn(Other) != none)
  {
    ZombieRushPawn(Other).BurnToDeath();
  }
}

defaultproperties
{
  
}
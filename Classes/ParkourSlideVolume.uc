class ParkourSlideVolume extends TriggerVolume;

// Body...
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
  super.Touch(Other, OtherComp, HitLocation, HitNormal);
  if (ZombieRushPawn(Other) != none)
  {
    ZombieParkourPC(ZombieRushPawn(Other).Controller).OnEnterSlideVolume(self);
  }
}

event untouch( Actor Other)
{
  if (ZombieRushPawn(Other) != none)
  {
    ZombieParkourPC(ZombieRushPawn(Other).Controller).OnExitSlideVolume(self);
  }
}

defaultproperties
{
  
}
class ZBCheckpointVolume extends TriggerVolume;

// Body...
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
  if (ZombieRushPawn(Other) != none )
  {
    ZombieRushGame(WorldInfo.Game).LastCheckpoint = self;
  }
}
defaultproperties
{
  
}
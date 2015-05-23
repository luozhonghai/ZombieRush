class ParkourTeleportVolume extends TriggerVolume;

// Body...
var() ParkourTeleportVolume TeleportVolume;
var() bool IsDest;


event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
  local vector Offset;
  local vector DestLoc;
  super.Touch(Other, OtherComp, HitLocation, HitNormal);
  if (ZombieRushPawn(Other) != none && !IsDest && TeleportVolume != none)
  {
    Offset = Other.Location - Location;
    DestLoc = Offset + TeleportVolume.Location;
    Other.SetLocation(DestLoc);
    if(ZombieRushPawn(Other).Controller != None)
    {
      ZombieRushPawn(Other).Controller.OnTeleport(None);
    }
  }
}
defaultproperties
{
  
}
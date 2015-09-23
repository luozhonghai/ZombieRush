class ZBCheckpointVolume extends TriggerVolume;

var(ZBCheckpointVolume) Note Spot;
// Body...

var private Vector SpawnLoc;
var private Rotator SpawnRot;
event PostBeginPlay()
{
  super.PostBeginPlay();
  if (Spot != None)
  {
    SpawnLoc = Spot.Location;
    SpawnRot = Spot.Rotation;
  }
  else
  {
    SpawnLoc = Location;
    SpawnRot = Rotation;
  }
}
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
  if (ZombieRushPawn(Other) != none )
  {
    ZombieRushGame(WorldInfo.Game).LastCheckpoint = self;
  }
}

function GetRespawnLocationAndRotation(out Vector Loc, out Rotator Rot)
{
  Loc = SpawnLoc;
  Rot = SpawnRot;
}
defaultproperties
{
  
}
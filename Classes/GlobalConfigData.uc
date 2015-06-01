class GlobalConfigData extends Object;

// Body...
var(ZombieRushGame) bool bGameDebug;
var(ZombieRushGame) float CustomGravityZ;
var(ZombieRushGame) bool bCheat;
var(ZombieRushGame) float ClimbOverDistance;
var(ZombieRushGame) int PlayerHealth;
var(ZombieRushGame) float KnockDownVelocity;
defaultproperties
{
  bGameDebug=true
  bCheat=false
  CustomGravityZ=-900//2500
  ClimbOverDistance=200
  PlayerHealth=100
  KnockDownVelocity=500
}
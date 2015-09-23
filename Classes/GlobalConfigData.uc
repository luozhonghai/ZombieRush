class GlobalConfigData extends Object;

// Body...
var(ZombieRushGame) bool bGameDebug;
var(ZombieRushGame) float CustomGravityZ;
var(ZombieRushGame) bool bCheat;
var(ZombieRushGame) float ClimbOverDistance;
var(ZombieRushGame) int PlayerHealth;
var(ZombieRushGame) float KnockDownVelocity;

var(ZombieRushGame) float MinHitWallInterval;

var(ZombieRushPC) float SprintSpeed;
var(ZombieRushPC) float RunSpeed;
var(ZombieRushPC) float WalkSpeed;

defaultproperties
{
  bGameDebug=true
  bCheat=false
  CustomGravityZ=-900//2500
  ClimbOverDistance=200
  PlayerHealth=100
  KnockDownVelocity=500

  MinHitWallInterval=10.0

  SprintSpeed=9  //13
  RunSpeed=6.5   //10
  WalkSpeed=3.0
}
class KAssetRope extends KAsset
deprecated;


// Body...
event PostBeginPlay()
{

  super.PostBeginPlay();

}

simulated function OnToggleRopePhysics(SeqAct_ToggleRopePhysics inAction)
{
  SkeletalMeshComponent.BreakConstraint(vect(1,0,0), Location, inAction.BoneName);
}

event Tick(float deltaTime)
{
  local Rotator new_rot;
  super.Tick(deltaTime);

}
defaultproperties
{
}
class PhysicsRopeSkeletalMeshActor extends SkeletalMeshActorMAT;


var UDKSkelControl_MassBoneScaling BreakBoneControl;
var() Name SkelControlSingleBoneName;
// Body...
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
  Super.PostInitAnimTree(SkelComp);

  if (SkelComp == SkeletalMeshComponent)
  {
    BreakBoneControl = UDKSkelControl_MassBoneScaling(SkeletalMeshComponent.FindSkelControl(SkelControlSingleBoneName));
  }
}

simulated function OnToggleRopePhysics(SeqAct_ToggleRopePhysics inAction)
{
  BreakBoneControl.SetSkelControlStrength(1.0, 0.0);
  SkeletalMeshComponent.BreakConstraint(vect(1,0,0), Location, inAction.BoneName);
}

function RopePhysics_Break(name BreakBoneName)
{
  BreakBoneControl.SetSkelControlStrength(1.0, 0.0);
  SkeletalMeshComponent.BreakConstraint(vect(1,0,0), Location, BreakBoneName); 
}
defaultproperties
{
  BlockRigidBody=True
  Begin Object Name=SkeletalMeshComponent0
    AnimTreeTemplate=AnimTree'zombie_physicalresource.rope_anim_tree'
  End Object
  SkelControlSingleBoneName="BreakNode"
}
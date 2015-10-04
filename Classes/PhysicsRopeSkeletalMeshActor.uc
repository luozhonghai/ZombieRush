class PhysicsRopeSkeletalMeshActor extends SkeletalMeshActorMAT;


var UDKSkelControl_MassBoneScaling BreakBoneControl;
var() Name SkelControlSingleBoneName;

/*=====================================
// Grab 
*/
var() bool bGrabable;
var vector HandLoc, FootLoc;
var name HandBoneName, FootBoneName;

function bool CanGrabbed()
{
  return bGrabable;
}

event Tick(float deltaTime)
{
  HandLoc = SkeletalMeshComponent.GetBoneLocation(HandBoneName,0);
  FootLoc = SkeletalMeshComponent.GetBoneLocation(FootBoneName,0);
  
`if(`isdefined(debug))
  Drawdebugsphere(HandLoc, 10, 2, 0, 255, 0);
  Drawdebugsphere(FootLoc, 10, 2, 0, 255, 0);
`endif
}

function vector GetRopeHandLocation()
{
  //return SkeletalMeshComponent.GetBoneLocation('Bone13',0);
  return HandLoc;
}

function vector GetRopeFootLocation()
{
  return FootLoc;
}


function SetHandGrabBoneName(name Hand)
{
  HandBoneName = Hand;
}

function SetFootGrabBoneName(name Foot)
{
  FootBoneName = Foot;
}

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
  bGrabable=True
  BlockRigidBody=True
  Begin Object Name=SkeletalMeshComponent0
    //AnimTreeTemplate=AnimTree'zombie_physicalresource.rope_anim_tree'
  End Object
  SkelControlSingleBoneName="BreakNode"
}
class ZSM_GrabRope extends ZBSpecialMove;

// Body...
var SkeletalMeshComponent RopeMesh;
var  name GrabRopeHandBoneName, GrabRopeFootBoneName;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
  local vector headLoc, footLoc;
  local SkeletalMeshComponent RopeMesh;
  local vector  GrabRopeHandLocation, GrabRopeFootLocation;
  Super.SpecialMoveStarted(bForced, PrevMove);
  PawnOwner.SetPhysics(PHYS_Interpolating);
  PawnOwner.ZeroMovementVariables();
  PawnOwner.Mesh.SetRBChannel(RBCC_Untitled3);
  
  RopeMesh = ZombieParkourPawn(PawnOwner).RopeGrabbed.SkeletalMeshComponent;

  headLoc = PawnOwner.mesh.GetBoneLocation('Bip01-Head',0);
  GrabRopeHandBoneName = RopeMesh.FindClosestBone(headLoc, GrabRopeHandLocation);
  GrabRopeHandBoneName = RopeMesh.GetParentBone(GrabRopeHandBoneName);

  footLoc = PawnOwner.mesh.GetBoneLocation('Bip01-L-Foot',0);
  GrabRopeFootBoneName = RopeMesh.FindClosestBone(footLoc, GrabRopeFootLocation);

  ZombieParkourPawn(PawnOwner).RopeGrabbed.SetHandGrabBoneName(GrabRopeHandBoneName);
  ZombieParkourPawn(PawnOwner).RopeGrabbed.SetFootGrabBoneName(GrabRopeFootBoneName);

  PawnOwner.LeftArmSkelControl.EffectorLocation = GrabRopeHandLocation;
  PawnOwner.RightArmSkelControl.EffectorLocation = GrabRopeHandLocation;
  PawnOwner.LeftFootClimbSkelControl.EffectorLocation = GrabRopeFootLocation;
  PawnOwner.RightFootClimbSkelControl.EffectorLocation = GrabRopeFootLocation;

  PawnOwner.LeftArmSkelControl.SetSkelControlStrength(1.0, 0.3);
  PawnOwner.RightArmSkelControl.SetSkelControlStrength(1.0, 0.3);

  PawnOwner.LeftFootClimbSkelControl.SetSkelControlStrength(1.0, 0.3);
  PawnOwner.RightFootClimbSkelControl.SetSkelControlStrength(1.0, 0.3);

}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
  local vector FaceDir;
  local Rotator FaceRot;
  Super.SpecialMoveEnded(PrevMove, NextMove);
  PawnOwner.SetPhysics(PHYS_Falling);
  PawnOwner.SetBase(None);

  FaceRot = PawnOwner.Rotation;
  FaceRot.Pitch = 0;
  PawnOwner.SetRotation(FaceRot);

  FaceDir = Vector(FaceRot);
  PawnOwner.Velocity = PawnOwner.GroundSpeed * FaceDir;
  ZombieParkourPawn(PawnOwner).DoRushJump();
  ZombieParkourPawn(PawnOwner).DoShakeRope(-1000 * FaceDir);

  PawnOwner.LeftArmSkelControl.SetSkelControlStrength(0.0, 0.2);
  PawnOwner.RightArmSkelControl.SetSkelControlStrength(0.0, 0.2);

  PawnOwner.LeftFootClimbSkelControl.SetSkelControlStrength(0.0, 0.2);
  PawnOwner.RightFootClimbSkelControl.SetSkelControlStrength(0.0, 0.2);

  
}

event tickspecial(float deltaTime)
{
  local vector  GrabRopeHandLocation;
  local vector HandLoc, FootLoc;
  HandLoc = ZombieParkourPawn(PawnOwner).RopeGrabbed.GetRopeHandLocation();
  FootLoc = ZombieParkourPawn(PawnOwner).RopeGrabbed.GetRopeFootLocation();

  PawnOwner.LeftArmSkelControl.EffectorLocation = HandLoc;
  PawnOwner.RightArmSkelControl.EffectorLocation = HandLoc;

  PawnOwner.LeftFootClimbSkelControl.EffectorLocation = FootLoc;
  PawnOwner.RightFootClimbSkelControl.EffectorLocation = FootLoc;

  ZombieParkourPawn(PawnOwner).RopeGrabbed.Drawdebugsphere(HandLoc, 10, 2, 0, 255, 0);
  ZombieParkourPawn(PawnOwner).RopeGrabbed.Drawdebugsphere(HandLoc, 10, 2, 0, 255, 0);
}
defaultproperties
{
  
}
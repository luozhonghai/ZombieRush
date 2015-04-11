class ZSM_ClimbUp extends ZBSpecialMove;

// Body...
var() ZombiePawn.AnimationParaConfig    AnimCfg_ClimbOver;
var vector PostAnimationLocationOffset;
var vector GrabLocationOffset;
var vector ClimbVelocity;

var private Vector lGrabLocation;
var private Vector mLastTraversalCenterMountLocation;
var private Vector mLastTraversalLeftMountLocation;
var private Vector mLastTraversalRightMountLocation;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
  Super.SpecialMoveStarted(bForced, PrevMove);

  PostAnimationLocationOffset = vect(48.54f, 5.0f, 8.86f);
  GrabLocationOffset.x = PawnOwner.GetCollisionRadius() - 15;
  GrabLocationOffset.z = PawnOwner.GetCollisionHeight() - 30;

  ClimbVelocity=vect(20,0,140);
  if (PawnOwner.health > 0)
  {
    PawnOwner.setphysics(PHYS_Custom);
    if(ZombieRushPawn(PawnOwner)!=none)
      ZombieRushPawn(PawnOwner).bHitWall = true;
  //  PawnOwner.SetCollision(false,false);
  //  PawnOwner.CylinderComponent.SetActorCollision(false, false);
    PawnOwner.bCollideWorld = false;
  //  PawnOwner.Mesh.SetActorCollision(false,false);
    PawnOwner.PlayConfigAnim(AnimCfg_ClimbOver);

    lGrabLocation = PawnOwner.Location + TransformVectorByRotation(PawnOwner.Rotation, GrabLocationOffset);
    mLastTraversalCenterMountLocation = lGrabLocation;
    mLastTraversalRightMountLocation = lGrabLocation + PawnOwner.TransformVectorByRotation(PawnOwner.Rotation, vect(0, 24, 0));
    mLastTraversalLeftMountLocation = lGrabLocation + PawnOwner.TransformVectorByRotation(PawnOwner.Rotation, vect(0, -24, 0));

    PawnOwner.LeftArmSkelControl.EffectorLocation = mLastTraversalLeftMountLocation;
    PawnOwner.RightArmSkelControl.EffectorLocation = mLastTraversalRightMountLocation;

    PawnOwner.LeftArmSkelControl.SetSkelControlStrength(1.0, 0.2);
    PawnOwner.RightArmSkelControl.SetSkelControlStrength(1.0, 0.2);
  }
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
  Super.SpecialMoveEnded(PrevMove, NextMove);
  PawnOwner.SetLocation(PawnOwner.Location + TransformVectorByRotation(PawnOwner.Rotation, PostAnimationLocationOffset));
  PawnOwner.setphysics(PHYS_Walking);
  PawnOwner.bCollideWorld = true;
     
  if(ZombieRushPawn(PawnOwner)!=none)
    ZombieRushPawn(PawnOwner).bHitWall = false;
  PawnOwner.SetCollision(true,true);


  //ZombieRushPC(PCOwner).GotoState('PlayerRush');
}

event tickspecial(float deltaTime)
{
  PawnOwner.Move( ClimbVelocity* deltatime);
}

// Anim notify
function HandOff()
{
  PawnOwner.LeftArmSkelControl.SetSkelControlStrength(0.0, 0.1);
  PawnOwner.RightArmSkelControl.SetSkelControlStrength(0.0, 0.1);
}
DefaultProperties
{
//  AnimCfg_TripOver=(AnimationNames=("zhujue-shuaidao"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendintime=0.0,blendouttime=0.3)
  AnimCfg_ClimbOver=(AnimationNames=("actor-climb"),BlendInTime=0.1,BlendOutTime=0.1,PlayRate=0.5,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
  UseCustomRMM=True
  RMMInAction=RMM_Translate
  //bDisableMovement=true
  //bDisableTurn=true
}
class ZSM_JumpStart extends ZBSpecialMove;

enum EJumpStatus
{
	EMT_None,
	EMT_Jump,
	EMT_Rise,
	EMT_Fall,
	EMT_Land,
};

var EJumpStatus CurrentJumpStatus;
var() ZombiePawn.AnimationParaConfig		AnimCfg_JumpStart;
var() ZombiePawn.AnimationParaConfig		AnimCfg_JumpRising;
var() ZombiePawn.AnimationParaConfig		AnimCfg_Jumping;
var() ZombiePawn.AnimationParaConfig		AnimCfg_Landing;


//trace relevant
var Actor FloorActor;
var vector ForwardTraceVector;
var vector BeneathTraceVector;

//sometimes when pawn fall from high place , just use function Landed() to transition special move;
//avoid call function CalCamera() of this SpecialMove in the condition. 
var bool bFullJump; 


//var float jumpStartTime,jumpEndTime;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);
	bFullJump = true;
	PlayJump();
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
	bFullJump = false;
	PawnOwner.bIsLanding = false;
	PawnOwner.bIsJumping = false;
}
function PlayJump()
{
	local Vector HitLocation,HitNormal;
	CurrentJumpStatus = EMT_Jump;
	PawnOwner.PlayConfigAnim(AnimCfg_JumpStart);
	PawnOwner.SetTimer(0.1333,false,'PlayFall');

	FloorActor = PawnOwner.Trace(HitLocation, HitNormal, PawnOwner.location-1000*vect(0,0,1) ,PawnOwner.location);
	ForwardTraceVector = (PawnOwner.GetCollisionRadius()+50) * vector(PawnOwner.Rotation);
	BeneathTraceVector = (PawnOwner.GetCollisionHeight()+50) * Vect(0,0,-1);
}

///落地
event Landed(bool bJumping)
{
	PlayLand();
	//for camera interp when land after jump
	if(bJumping)
	  ZBPlayerCamera(PCOwner.PlayerCamera).CameraOnSpecialMoveEnd(self);

	//PawnOwner.bIsJumping = false;
}

//落地时禁止运动
function PlayLand()
{
	SetMovementLock(TRUE);
	PawnOwner.ZeroMovementVariables();
	CurrentJumpStatus = EMT_Land;
	PawnOwner.PlayConfigAnim(AnimCfg_Landing);
	PawnOwner.bIsLanding = true;
}

function OnAnimEnd(name SeqName)
{
	if(SeqName == AnimCfg_Landing.AnimationNames[0])
  {
  	ZombiePlayerPawn(PawnOwner).KuaipaoNode.SetPosition(0.49, true);
  	ZombiePlayerPawn(PawnOwner).PaoNode.SetPosition(0.0, true);
		PawnOwner.EndSpecialMove();
		SetMovementLock(False);
	  PawnOwner.ClearTimer('PlayFall');	
	  CurrentJumpStatus = EMT_None;
	}	
}

function PlayFall()
{
	CurrentJumpStatus = EMT_Fall;
	PawnOwner.PlayConfigAnim(AnimCfg_Jumping);	
}


event tickspecial(float deltatime)
{
	/*
	local vector transZ;
	local float CylinderSizeZ;
	local Vector boneLoc,actorLoc,headLoc,lFootLoc,rFootLoc;
	boneLoc = PawnOwner.mesh.GetBoneLocation('Bip01-Pelvis',0);// 0 == World, 1 == Local (Component)

	headLoc = PawnOwner.mesh.GetBoneLocation('Bip01-Head',0);
	lFootLoc= PawnOwner.mesh.GetBoneLocation('Bip01-L-Foot',0);
	rFootLoc= PawnOwner.mesh.GetBoneLocation('Bip01-R-Foot',0);

	//modify size of cylinder  bone positon based  every tick
	CylinderSizeZ = (headLoc.z - Fmin(lFootLoc.z,rFootLoc.z)+30)/2;
	PawnOwner.CylinderComponent.SetCylinderSize(30,CylinderSizeZ);*/
	/*
	local vector BodyForwardLoc,FootForwardLoc;
	local Actor TraceActor;
	local Vector HitLocation,HitNormal;

	BodyForwardLoc = PawnOwner.Location + ForwardTraceVector;
	FootForwardLoc = BodyForwardLoc + BeneathTraceVector;
    if(!PawnOwner.fasttrace(BodyForwardLoc, PawnOwner.Location))
    {
        PawnOwner.Velocity.X = 0;
        PawnOwner.Velocity.Y = 0;
    }
    TraceActor = PawnOwner.Trace(HitLocation, HitNormal,FootForwardLoc,BodyForwardLoc);
    if(TraceActor!=none && FloorActor != TraceActor && TraceActor.Tag!='luzhang' && TraceActor.Tag!='jumpable')
    {
        PawnOwner.Velocity.X = 0;
        PawnOwner.Velocity.Y = 0;
    }*/
}

function bool CalcCamera_KeepHeight( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local vector baseLoc;
	if (!bFullJump)
	{
		return false;
	}
	/*
	local rotator rot1,rot2;

	local Quat CameraQuaternion;

	rot1.yaw = out_CamRot.yaw;
	rot2.yaw = PawnOwner.Rotation.yaw;//-25 * DegtoUnrRot;

	// With rotations, we need to lerp with a quaternion so there is no gimble lock
	CameraQuaternion = QuatSlerp(QuatFromRotator(rot1), QuatFromRotator(rot2), 0.05, true);
	rot2 = QuatToRotator(CameraQuaternion);
	out_CamRot.yaw = rot2.yaw;
	out_CamRot.pitch = -15 * DegtoUnrRot;
*/
	baseLoc = PawnOwner.Location;
  baseLoc.Z = PawnOwner.JumpStartHeight;
//	out_CamLoc = VLerp(out_CamLoc,baseLoc + CameraOffsetTarget - Vector(out_CamRot) * CameraDistance,0.1) ;
	out_CamLoc = baseLoc + CameraOffsetTarget - Vector(out_CamRot) * CameraDistance ;

	return true;
}
DefaultProperties
{
	/*
	AnimCfg_JumpStart=(AnimationNames=("HD_heidi_jumpstart"),PlayRate=1.000000,BlendOutTime=0.2,bCauseActorAnimEnd=True,FakeRootMotionMode=RMM_Accel)
		// AnimCfg_JumpRising=(AnimationNames=("AliceW_Jump_Rise"),PlayRate=1.000000,bCauseActorAnimEnd=True,FakeRootMotionMode=RMM_Accel)
		AnimCfg_Jumping=(AnimationNames=("HD_heidi_jumploop"),PlayRate=1.000000,bLoop=True,bCauseActorAnimEnd=True,FakeRootMotionMode=RMM_Accel)
		AnimCfg_Landing=(AnimationNames=("HD_heidi_jumpend"),PlayRate=2.00000,bCauseActorAnimEnd=True,FakeRootMotionMode=RMM_Accel)*/

	//AnimCfg_JumpStart=(AnimationNames=("zhujue-movejumpstart"),PlayRate=1.000000,BlendOutTime=0.05,bCauseActorAnimEnd=True,FakeRootMotionMode=RMM_Accel)
		// AnimCfg_JumpRising=(AnimationNames=("AliceW_Jump_Rise"),PlayRate=1.000000,bCauseActorAnimEnd=True,FakeRootMotionMode=RMM_Accel)
	//AnimCfg_Jumping=(AnimationNames=("zhujue-movejumpair"),PlayRate=1.000000,BlendOutTime=-1,bLoop=false,bCauseActorAnimEnd=True,FakeRootMotionMode=RMM_Accel)

  //  AnimCfg_JumpStart=(AnimationNames=("zhujue_tengkong"),PlayRate=0.5,BlendOutTime=0.2,bCauseActorAnimEnd=True,FakeRootMotionMode=RMM_Accel,bLoop=true)
//	AnimCfg_Landing=(AnimationNames=("zhujue_zhaodi"),PlayRate=1.50000,BlendInTime=0.2,bCauseActorAnimEnd=True,FakeRootMotionMode=RMM_Accel)

//=("zhujue-jumpup")
//"zhujue-luodi"
//"zhujue-jumpdown"
/*
  AnimCfg_JumpStart=(AnimationNames=("actor-jumpup"),PlayRate=1.0,BlendInTime=0.0f,BlendOutTime=-1,bCauseActorAnimEnd=True,FakeRootMotionMode=RMM_Accel)
	AnimCfg_Landing=(AnimationNames=("actor-land"),PlayRate=1.5,BlendInTime=0.15,BlendOutTime=0.15,bCauseActorAnimEnd=True,FakeRootMotionMode=RMM_Accel)
	AnimCfg_Jumping=(AnimationNames=("actor-jumpdown"),PlayRate=2.2,BlendInTime=0.0f,bLoop=false,BlendOutTime=-1,bCauseActorAnimEnd=True,FakeRootMotionMode=RMM_Accel)
*/
  AnimCfg_JumpStart=(AnimationNames=("actor-jumpup-n"),PlayRate=1.0,BlendInTime=0.3f,BlendOutTime=0.0,bCauseActorAnimEnd=True,FakeRootMotionMode=RMM_Accel)
	AnimCfg_Jumping=(AnimationNames=("actor-jumpdown-n"),PlayRate=1.0,BlendInTime=0.0f,bLoop=false,BlendOutTime=0.0,bCauseActorAnimEnd=True,FakeRootMotionMode=RMM_Accel)
	AnimCfg_Landing=(AnimationNames=("actor-land-n"),PlayRate=1.0,BlendInTime=0.1,BlendOutTime=0.1,bCauseActorAnimEnd=True,FakeRootMotionMode=RMM_Accel)

	UseCustomRMM=false

	//bDisableMovement=True
	bDisableTurn=true
  CamType=ECAM_KeepHeight
}

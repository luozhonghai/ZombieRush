class ZBCameraTypeRushFix extends ZBCameraTypeAbstract;

/** Position offset of the camera from the player */
var  Vector CameraOffsetTarget;

var  Vector DesireCamLoc;

var() float CameraTransitionLerp;
var() float PitchDegree;
var  Vector BaseCamLoc;

var  Pawn TargetPawn;
var bool EnableLandLerp;
var bool ResetCam;

var Rotator CameraBaseRot;
var Vector CameraBaseRotX,CameraBaseRotY,CameraBaseRotZ;
var float CameraDeltaYaw, CameraDeltaYawTarget;
var float CameraDeltaPitch, CameraDeltaPitchTarget;

var() float YawTransitionLerp;
var() float PicthTransitionLerp;

var float CameraYawInterpDelay,CameraOffsetInterpDelay;

function Initialize()
{
	CameraStyle = 'FreeCam';
	ResetCam = true;
}

/** Core function use to calculate new camera location and rotation */
function UpdateCamera(Pawn rPawn, ZBPlayerCamera rCameraActor, float rDeltaTime, out TViewTarget rOutVT)
{
	local rotator rot1,rot2;
	local vector dist;
	local Quat CameraQuaternion;

	rot1.yaw = rOutVT.POV.Rotation.yaw;
	rot2.yaw = rPawn.Rotation.yaw;//-25 * DegtoUnrRot;

	if (ResetCam)
	{
		ResetCam = false;
		rOutVT.POV.rotation.yaw = rot2.yaw ;//+ 90 * DegtoUnrRot;
		CameraBaseRot.yaw = rot2.yaw ;
		GetAxes(CameraBaseRot,CameraBaseRotX,CameraBaseRotY,CameraBaseRotZ);
		rOutVT.POV.rotation.pitch = -PitchDegree * DegtoUnrRot;
		BaseCamLoc = rPawn.Location;
		TargetPawn = rPawn;
		//calc CameraOffsetTarget
		CameraOffsetTarget = -100.0 * Vector(CameraBaseRot);
		CameraOffsetTarget.Z = 70.0f;
		CameraOffset = CameraOffsetTarget;
		rOutVT.POV.Location = BaseCamLoc + CameraOffsetTarget - Vector(rOutVT.POV.Rotation) * CameraDistance ;
		return;
	}

//	DesireCamLoc = rPawn.Location + CameraOffsetTarget - Vector(rOutVT.POV.Rotation) * CameraDistance ;
//	rOutVT.POV.Location = VLerp(rOutVT.POV.Location,DesireCamLoc,CameraTransitionLerp);
	rOutVT.POV.rotation.pitch = -PitchDegree * DegtoUnrRot - CameraDeltaPitch;
	rOutVT.POV.rotation.yaw = CameraBaseRot.yaw + CameraDeltaYaw;
	if(EnableLandLerp){
	BaseCamLoc.z = Lerp(BaseCamLoc.z,TargetPawn.Location.z,CameraTransitionLerp);
	BaseCamLoc.x = TargetPawn.Location.x;
	BaseCamLoc.y = TargetPawn.Location.y;
	rOutVT.POV.Location = BaseCamLoc + CameraOffset - Vector(rOutVT.POV.Rotation) * CameraDistance ;

	dist = BaseCamLoc - TargetPawn.Location;
	if(vsize(dist)<1)
		EnableLandLerp = false;
	}
	else

	rOutVT.POV.Location = TargetPawn.Location + CameraOffset - Vector(rOutVT.POV.Rotation) * CameraDistance ;
}

simulated function Tick(float DeltaTime)
{
	// Smoothly transition the camera yaw
	if (CameraDeltaYaw != CameraDeltaYawTarget)
	{     
        // if(CameraYawInterpDelay < 1.0)
        // {
        //   CameraYawInterpDelay += DeltaTime;
        //   return;
        // }
		CameraDeltaYaw = Lerp(CameraDeltaYaw, CameraDeltaYawTarget, YawTransitionLerp);
		if (Abs(CameraDeltaYawTarget - CameraDeltaYaw) < 0.5 * DegtoUnrRot) { //CameraYawInterpDelay = 0.0;
			CameraDeltaYaw = CameraDeltaYawTarget; }

		//PlayerCamera.ClientMessage("Tick dist target:"$CameraDistanceTarget$" current:"$CameraDistance);
	}

		if (CameraDeltaPitch != CameraDeltaPitchTarget)
	{     
		CameraDeltaPitch = Lerp(CameraDeltaPitch, CameraDeltaPitchTarget, PicthTransitionLerp);
		if (Abs(CameraDeltaPitchTarget - CameraDeltaPitch) < 0.5 * DegtoUnrRot) { //CameraYawInterpDelay = 0.0;
			CameraDeltaPitch = CameraDeltaPitchTarget; }

		//PlayerCamera.ClientMessage("Tick dist target:"$CameraDistanceTarget$" current:"$CameraDistance);
	}

		// Smoothly transition the camera offset
	if (CameraOffset != CameraOffsetTarget)
	{
		//CameraOffset = VLerp(CameraOffset, CameraOffsetTarget, CameraTransitionLerp);
		//if (Abs(VSize(CameraOffset - CameraOffsetTarget)) < 0.05f) { CameraOffset = CameraOffsetTarget; }
		// if(CameraOffsetInterpDelay < 1.0)
  //       {
  //         CameraOffsetInterpDelay += DeltaTime;
  //         return;
  //       }
		CameraOffset.X = Lerp(CameraOffset.X, CameraOffsetTarget.X, CameraTransitionLerp);
		if (Abs(CameraOffset.X - CameraOffsetTarget.X) < 0.05f) { CameraOffset.X = CameraOffsetTarget.X; }

		CameraOffset.Y = Lerp(CameraOffset.Y, CameraOffsetTarget.Y, CameraTransitionLerp);
		if (Abs(CameraOffset.Y - CameraOffsetTarget.Y) < 0.05f) { CameraOffset.Y = CameraOffsetTarget.Y; }

		// CameraOffset.Z = Lerp(CameraOffset.Z, CameraOffsetTarget.Z, CameraTransitionLerp);
		// if (Abs(CameraOffset.Z - CameraOffsetTarget.Z) < 0.05f) { CameraOffset.Z = CameraOffsetTarget.Z; }

		//PlayerCamera.ClientMessage("Tick off target:"$CameraOffset$" current:"$CameraOffsetTarget);
	}
	else
	{
		CameraOffsetInterpDelay = 0.0;
	}
}

function TurnLeft()
{
	CameraDeltaYawTarget = - 20 * DegtoUnrRot;
	CameraDeltaPitchTarget = 0;

	CameraOffsetTarget = -100.0 * Vector(CameraBaseRot) - 50 * CameraBaseRotY;
	CameraYawInterpDelay = 0.0;
	CameraOffsetInterpDelay = 0.0;
}

function TurnRight()
{
	CameraDeltaYawTarget = 20 * DegtoUnrRot;
	CameraDeltaPitchTarget = 0;

	CameraOffsetTarget = -100.0 * Vector(CameraBaseRot) + 50 * CameraBaseRotY;
	CameraYawInterpDelay = 0.0;
	CameraOffsetInterpDelay = 0.0;
}

function TurnForward()
{
	CameraDeltaYawTarget = 0;
	CameraDeltaPitchTarget = 0;

	CameraOffsetTarget = -100.0 * Vector(CameraBaseRot);

	CameraYawInterpDelay = 0.0;
	CameraOffsetInterpDelay = 0.0;
}
function TurnBack()
{
	CameraDeltaYawTarget = 0;
	CameraDeltaPitchTarget = 15 * DegtoUnrRot;
	CameraOffsetTarget = -250.0 * Vector(CameraBaseRot);

	CameraYawInterpDelay = 0.0;
	CameraOffsetInterpDelay = 0.0;
}
function TurnFollowParkour(int DirectionFlag, Vector ParkourDirection)
{
	CameraDeltaYawTarget += DirectionFlag * 90 * DegtoUnrRot;
	CameraDeltaPitchTarget = 0;

	//CameraBaseRot.Yaw = Rotator(ParkourDirection).Yaw;
	CameraOffsetTarget = -100.0 * ParkourDirection;

	CameraYawInterpDelay = 0.0;
	CameraOffsetInterpDelay = 0.0;
}


function FollowParkour(vector ParkourDirection)
{
	local rotator TargetRot;
	TargetRot = rotator(ParkourDirection);

	CameraDeltaYawTarget = TargetRot.yaw - CameraBaseRot.yaw;

	CameraDeltaPitchTarget = 0;
	CameraOffsetTarget = -100.0 * ParkourDirection;

	CameraYawInterpDelay = 0.0;
	CameraOffsetInterpDelay = 0.0;
}
/*
function FollowParkour(rotator ParkourDirection, bool bPawnStop)
{
	local rotator TargetRot;
	TargetRot = ParkourDirection;

	if(!bPawnStop)
	CameraDeltaYawTarget = TargetRot.yaw - CameraBaseRot.yaw;
  else
	CameraDeltaYawTarget = CameraDeltaYaw;


	CameraDeltaPitchTarget = 0;
	CameraOffsetTarget = -100.0 * vector(ParkourDirection);

	CameraYawInterpDelay = 0.0;
	CameraOffsetInterpDelay = 0.0;
}
*/

function CameraOnSpecialMoveEnd(ZBSpecialMove SpecialMove)
{
	//if(ZSM_JumpStart(SpecialMove)!=none){
		EnableLandLerp = true;
	  BaseCamLoc.z = ZombiePawn(TargetPawn).JumpStartHeight;
	//}
}

function SwitchPitchDegree(bool bDown)
{
	if (bDown)
	{
		PitchDegree=65;
	}
	else
	{
		PitchDegree=25;
	}
}
DefaultProperties
{
	CameraDistance=400.f 
	CameraTransitionLerp=0.02
	CameraOffsetTarget=(X=0f,Y=100.0f,Z=70.0f)
	bResetCam=false

	PitchDegree=25.0

	CameraDeltaYaw=0.0f
	CameraDeltaPitch=0.0f
	CameraDeltaYawTarget=0.0f
	YawTransitionLerp=0.02f
	PicthTransitionLerp=0.02f

	CameraYawInterpDelay=0.0f
	CameraOffsetInterpDelay=0.0f
}

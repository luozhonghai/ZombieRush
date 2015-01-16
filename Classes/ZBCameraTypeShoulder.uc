class ZBCameraTypeShoulder extends ZBCameraTypeAbstract;


/************************************************************//** 
 * Properties
 *************************************************************/

/** Position offset of the camera from the player */
var  Vector CameraOffsetTarget;

/** Distance offset from the player */
var  float CameraDistanceMin;
var  float CameraDistanceMax;
var  float CameraDistanceTarget;
var  float CameraHeightOffset;
var  float CameraFieldOfView;
var  float CameraAspectRatio;
var  int CameraPitchOffset;

/** Speed at which the player can change the distance */
var  float CameraDistanceSpeed;

/** Speed at which the camera lerps to the desired positions */
var  float CameraMovementLerp;
var  float CameraRotationLerp;
var  float CameraTransitionLerp;

/** Determines if the player can zoom in and out */
var  bool EnableZoom;

/** Position and rotation we want the camera to move to on each update */
var Vector PositionTarget;
var Rotator RotationTarget;


/************************************************************//** 
 * Constructor
 *************************************************************/

function Initialize()
{
	CameraStyle = 'ThirdPerson';

	if (CameraMovementLerp == 0) { CameraMovementLerp = 1.0f; }
	if (CameraRotationLerp == 0) { CameraRotationLerp = CameraMovementLerp; }
	if (CameraTransitionLerp == 0) { CameraTransitionLerp = 0.05f; }
	if (CameraDistanceSpeed == 0) { CameraDistanceSpeed = 10.0f; }
	if (CameraDistanceMin == 0) { CameraDistanceMin = 32; }
	if (CameraDistanceMax == 0) { CameraDistanceMax = 512; }
	if (CameraFieldOfView == 0) { CameraFieldOfView = 90.0f; }
	if (CameraAspectRatio == 0) { CameraAspectRatio = 1.777777f; }
	//if (CameraPitchOffset 
	//if (CameraHeightOffset == 0) { CameraHeightOffset == 
	if (CameraDistanceTarget < CameraDistanceMin || CameraDistanceTarget > CameraDistanceMax) { CameraDistanceTarget = 48; }

	CameraDistance = CameraDistanceTarget;
	CameraOffset = CameraOffsetTarget;
}

/************************************************************//** 
 * Core camera functionality
 *************************************************************/

/** Called when this camera type is activated */
function OnBecomeActive(ZBCameraTypeAbstract rOldCamera)
{
	// Smoothly move into position
	if (rOldCamera != none)
	{
		CameraChange = true;
		CameraOffset = rOldCamera.CameraOffset;
		CameraDistance = rOldCamera.CameraDistance;

	}
}

/** Swaps the shoulder the camera is looking over */
function ChangeShoulder()
{
	CameraOffsetTarget.Y = -CameraOffsetTarget.Y;
}

/** Core function use to calculate new camera location and rotation */
function UpdateCamera(Pawn rPawn, ZBPlayerCamera rCameraActor, float rDeltaTime, out TViewTarget rOutVT)
{
	local Vector CameraOrbitLocation;
	local Vector CameraLocation;
	local Rotator PawnRotation;
	local Rotator CameraRotation;
	local Quat CameraQuaternion;
	local Actor HitActor;
	local Vector HitLocation;
	local Vector HitNormal;

	// If we're coming in from a camera change, we're going to change the
	// rotation of the player character first to match the old view target.
	// Otherwize, we may have a jarring transition between camera types
	if (CameraChange)
	{
		// TODO: Add code to keep the view from jumping on transition
		CameraChange = false;
	}
	
	// First get the pawn's location
	CameraOrbitLocation = rOutVT.Target.Location;
	PawnRotation = PlayerCamera.PlayerOwner.Rotation;
	
	CameraOrbitLocation.Z -= CameraHeightOffset;

	// Adjust the camera location by the offset.  This isn't the camera's 
	// final position, but it's the right angle/orbit based on the
	// rotation and offset.  Transform the camera offset 
	// by the player's rotation
	CameraOrbitLocation = CameraOrbitLocation + (CameraOffset >> PawnRotation);

	// Get the true location of the camera based on the orbit location and distance
	// from the pawn
	CameraLocation = CameraOrbitLocation - (Vector(PawnRotation) * CameraDistance);

	// Set the rotation to how the player is rotated
	CameraRotation = PlayerCamera.PlayerOwner.Rotation;
	
	//PlayerCamera.PlayerOwner.DebugInfo.AddText("Camera Orbit Position: " @ (CameraOrbitLocation.X @ (CameraOrbitLocation.Y @ CameraOrbitLocation.Z)));
//	PlayerCamera.PlayerOwner.DebugInfo.AddText("Camera Position: " @ (CameraLocation.X @ (CameraLocation.Y @ CameraLocation.Z)));
	//PlayerCamera.PlayerOwner.DebugInfo.AddText("Camera Rotation: " @ (CameraRotation.Pitch @ (CameraRotation.Yaw @ CameraRotation.Yaw)));

	// Determine if we've hit a wall.  If so, adjust
	HitActor = PlayerCamera.Trace(HitLocation, HitNormal, CameraLocation, CameraOrbitLocation, false, vect(12,12,12));
	if (HitActor != none) { CameraLocation = HitLocation; }	

	// Set the target position and rotation we'll lerp to
	PositionTarget = CameraLocation;
	RotationTarget = CameraRotation;

	if(RotationTarget.Pitch + CameraPitchOffset < 0)
	{
		RotationTarget.Pitch += (65535 + CameraPitchOffset);
	}
	else if(RotationTarget.Pitch + CameraPitchOffset > 65535)
	{
		RotationTarget.Pitch += (CameraPitchOffset - 65535);
	}
	else
	{
		RotationTarget.Pitch += CameraPitchOffset;
	}

	// Lerp the location with a simple VLerp
	rOutVT.POV.Location = VLerp(rOutVT.POV.Location, PositionTarget, CameraMovementLerp);

	//rOutVT.POV.Location = PositionTarget;
	// With rotations, we need to lerp with a quaternion so there is no gimble lock
	CameraQuaternion = QuatSlerp(QuatFromRotator(rOutVT.POV.Rotation), QuatFromRotator(RotationTarget), CameraRotationLerp, true);
	rOutVT.POV.Rotation = QuatToRotator(CameraQuaternion);
	rOutVT.POV.FOV = CameraFieldOfView;
	rOutVT.AspectRatio = CameraAspectRatio;
	
	// Ensure the camera style matches ours
	if (PlayerCamera.CameraStyle != CameraStyle) { PlayerCamera.CameraStyle = CameraStyle; }
}

function ZoomIn()
{
	if (EnableZoom && CameraDistanceTarget > CameraDistanceMin)
	{
		CameraDistanceTarget = Max(CameraDistanceMin, CameraDistanceTarget - CameraDistanceSpeed);
	}
}

function ZoomOut()
{
	if (EnableZoom && CameraDistanceTarget < CameraDistanceMax)
	{
		CameraDistanceTarget = Min(CameraDistanceMax, CameraDistanceTarget + CameraDistanceSpeed);
	}
}

simulated function Tick(float DeltaTime)
{
	// Smoothly transition the camera distance
	if (CameraDistance != CameraDistanceTarget)
	{

		CameraDistance = Lerp(CameraDistance, CameraDistanceTarget, CameraTransitionLerp);
		if (Abs(CameraDistanceTarget - CameraDistance) < 0.005f) { CameraDistance = CameraDistanceTarget; }

		//PlayerCamera.ClientMessage("Tick dist target:"$CameraDistanceTarget$" current:"$CameraDistance);
	}

	// Smoothly transition the camera offset
	if (CameraOffset != CameraOffsetTarget)
	{
		//CameraOffset = VLerp(CameraOffset, CameraOffsetTarget, CameraTransitionSpeed);
		//if (Abs(VSize(CameraOffset - CameraOffsetTarget)) < 0.05f) { CameraOffset = CameraOffsetTarget; }
		
		CameraOffset.X = Lerp(CameraOffset.X, CameraOffsetTarget.X, CameraTransitionLerp);
		if (Abs(CameraOffset.X - CameraOffsetTarget.X) < 0.05f) { CameraOffset.X = CameraOffsetTarget.X; }

		CameraOffset.Y = Lerp(CameraOffset.Y, CameraOffsetTarget.Y, CameraTransitionLerp);
		if (Abs(CameraOffset.Y - CameraOffsetTarget.Y) < 0.05f) { CameraOffset.Y = CameraOffsetTarget.Y; }

		CameraOffset.Z = Lerp(CameraOffset.Z, CameraOffsetTarget.Z, CameraTransitionLerp);
		if (Abs(CameraOffset.Z - CameraOffsetTarget.Z) < 0.05f) { CameraOffset.Z = CameraOffsetTarget.Z; }

		//PlayerCamera.ClientMessage("Tick off target:"$CameraOffset$" current:"$CameraOffsetTarget);
	}

	//PlayerCamera.ClientMessage("Tick ost:"$CameraOffsetTarget$" dt:"$CameraDistanceTarget);
	//CameraChange = !(CameraDistance == CameraDistanceTarget && CameraOffset == CameraOffsetTarget);
}
DefaultProperties
{

	CameraOffsetTarget=(X=0.0f,Y=36.0f,Z=53.0f)
		CameraFieldOfView=90.0f
		CameraAspectRatio=1.777777f
		CameraHeightOffset=5.0f
		CameraPitchOffset=-1000
		CameraDistanceMin=32.0f
		CameraDistanceMax=100.0f
		CameraDistanceTarget=70.0f
		CameraDistanceSpeed=10.0f
		CameraTransitionLerp=0.2f
		CameraMovementLerp=0.4f
		EnableZoom=false

}

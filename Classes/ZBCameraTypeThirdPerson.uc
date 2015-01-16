class ZBCameraTypeThirdPerson extends ZBCameraTypeAbstract;




/************************************************************//** 
 * Properties
 *************************************************************/

/** Position offset of the camera from the player */
var  Vector CameraOffsetTarget;

/** Distance offset from the player */
var  float CameraDistanceMin;
var  float CameraDistanceMax;
var  float CameraDistanceTarget;

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
	CameraOffset = rOldCamera.CameraOffset;
	CameraDistance = rOldCamera.CameraDistance;
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
								 
	CameraOrbitLocation = rOutVT.Target.Location;
	PawnRotation = rOutVT.Target.Rotation;

	// Adjust the camera location by the offset (that's "reverse vector transformed")
	// with the camera's rotation.
	CameraOrbitLocation += CameraOffset >> PawnRotation;

	// Shift the camera by the distance from the player
	CameraLocation = CameraOrbitLocation - Vector(PawnRotation) * CameraDistance;

	// Set the rotation to how the player is rotated
	CameraRotation = PlayerCamera.PlayerOwner.Rotation;

	// Determine if we've hit a wall.  If so, adjust
	HitActor = PlayerCamera.Trace(HitLocation, HitNormal, CameraLocation, CameraOrbitLocation, false, vect(12,12,12));
	if (HitActor != none) { CameraLocation = HitLocation; }	

	// Set the target position and rotation we'll lerp to
	PositionTarget = CameraLocation;
	RotationTarget = CameraRotation;

	// Lerp the location with a simple VLerp
	rOutVT.POV.Location = VLerp(rOutVT.POV.Location, PositionTarget, CameraMovementLerp);

	// With rotations, we need to lerp with a quaternion so there is no gimble lock
	CameraQuaternion = QuatSlerp(QuatFromRotator(rOutVT.POV.Rotation), QuatFromRotator(RotationTarget), CameraRotationLerp, true);
	rOutVT.POV.Rotation = QuatToRotator(CameraQuaternion);

	// Ensure the camera style matches ours
	if (PlayerCamera.CameraStyle != CameraStyle) { PlayerCamera.CameraStyle = CameraStyle; }
}

function ZoomIn()
{
	if (EnableZoom && CameraDistanceTarget > CameraDistanceMin)
	{
		CameraDistanceTarget = Max(CameraDistanceMin, CameraDistanceTarget - 10.0f);
	}
}

function ZoomOut()
{
	if (EnableZoom && CameraDistanceTarget < CameraDistanceMax)
	{
		CameraDistanceTarget = Min(CameraDistanceMax, CameraDistanceTarget + 10.0f);
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
		//CameraOffset = VLerp(CameraOffset, CameraOffsetTarget, CameraTransitionLerp);
		//if (Abs(VSize(CameraOffset - CameraOffsetTarget)) < 0.05f) { CameraOffset = CameraOffsetTarget; }
		
		CameraOffset.X = Lerp(CameraOffset.X, CameraOffsetTarget.X, CameraTransitionLerp);
		if (Abs(CameraOffset.X - CameraOffsetTarget.X) < 0.05f) { CameraOffset.X = CameraOffsetTarget.X; }

		CameraOffset.Y = Lerp(CameraOffset.Y, CameraOffsetTarget.Y, CameraTransitionLerp);
		if (Abs(CameraOffset.Y - CameraOffsetTarget.Y) < 0.05f) { CameraOffset.Y = CameraOffsetTarget.Y; }

		CameraOffset.Z = Lerp(CameraOffset.Z, CameraOffsetTarget.Z, CameraTransitionLerp);
		if (Abs(CameraOffset.Z - CameraOffsetTarget.Z) < 0.05f) { CameraOffset.Z = CameraOffsetTarget.Z; }

		//PlayerCamera.ClientMessage("Tick off target:"$CameraOffset$" current:"$CameraOffsetTarget);
	}
}

DefaultProperties
{


	CameraOffsetTarget=(X=0.0f,Y=0.0f,Z=48.0f)
		CameraDistanceMin=32.0f
		CameraDistanceMax=100.0f
		CameraDistanceTarget=48.0f
		CameraDistanceSpeed=10.0f
		CameraTransitionLerp=0.2f
		CameraMovementLerp=0.3f
}

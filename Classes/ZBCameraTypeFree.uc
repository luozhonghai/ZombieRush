class ZBCameraTypeFree extends ZBCameraTypeAbstract;



/************************************************************//** 
 * Properties
 *************************************************************/

/** Position offset of the camera from the player */
var  Vector CameraOffsetTarget;

/** Distance offset from the player */
var  float CameraDistanceMin;
var  float CameraDistanceMax;
var  float CameraDistanceTarget;
var  float CameraFieldOfView;
var  float CameraAspectRatio;

/*reserve
var  float MoveBackCameraDistanceTarget;
var  float MoveFaceCameraDistanceTarget;
var  float IdleCameraDistanceTarget;*/

var  float CameraActiveDelay;

var float PawnMoveTime;
/** Speed at which the player can change the distance */
var  float CameraDistanceSpeed;

/** Speed at which the camera lerps to the desired positions */
var  float CameraMovementLerp;
var  float CameraRotationLerp;
var  float CameraTransitionLerp;

/** Determines if the player can zoom in and out */
var  bool EnableZoom;


var float ZoomStartDistance;

var float ZoomSpeedFactor;

/** Position and rotation we want the camera to move to on each update */
var Vector PositionTarget;
var Rotator RotationTarget;

var Vector CameraTargetLocation;


var Rotator  BiasRot;

/************************************************************//** 
 * Constructor
 *************************************************************/

function Initialize()
{
	CameraStyle = 'FreeCam';

	if (CameraMovementLerp == 0) { CameraMovementLerp = 1.0f; }
	if (CameraRotationLerp == 0) { CameraRotationLerp = CameraMovementLerp; }
	if (CameraTransitionLerp == 0) { CameraTransitionLerp = 0.05f; }
	if (CameraDistanceSpeed == 0) { CameraDistanceSpeed = 10.0f; }
	if (CameraDistanceMin == 0) { CameraDistanceMin = 32; }
	if (CameraDistanceMax == 0) { CameraDistanceMax = 512; }
	if (CameraFieldOfView == 0) { CameraFieldOfView = 90.0f; }
	if (CameraAspectRatio == 0) { CameraAspectRatio = 1.777777f; }
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

	//`log("NXCameraTypeFree.OnBecomeActive old_camera:"$rOldCamera.Name$" offset:"$CameraOffset);
}

/** 
 *  Called when this camera type is deactivated and transitions
 *  to the new camera.
 *  @param rNewCamera The camera that replaces this one
 */
function OnBecomeInActive(ZBCameraTypeAbstract rNewCamera)
{
	//`log("NXCameraTypeFree.OnBecomeInActive new_camera:"$rNewCamera.Name$" offset: "$CameraOffset);
}


/** Core function use to calculate new camera location and rotation */
function UpdateCamera(Pawn rPawn, ZBPlayerCamera rCameraActor, float rDeltaTime, out TViewTarget rOutVT)
{
	local Vector CameraOrbitLocation;
	local Vector CameraLocation;
	local Quat CameraQuaternion;
	local Rotator PlayerControllerRotation;
	local Actor HitActor;
	local Vector HitLocation;
	local Vector HitNormal;

	
	if (VSize(rPawn.velocity)<=0.2)
	{
		PawnMoveTime = 0;

		
		
	}

	if (VSize(rPawn.velocity)>0.2&&PawnMoveTime<CameraActiveDelay)
	{
		PawnMoveTime += rDeltaTime;

		return;
	}


	// If we're coming in from a camera change, we're going to change the
	// rotation of the player character first to match the old view target.
	// Otherwize, we may have a jarring transition between camera types
	if (CameraChange)
	{
		// TODO: Add code to keep the view from jumping on transition
		CameraChange = false;
	}

	BiasRot.pitch = -25 * DegtoUnrRot;
	// Deterimine the target we want the camera to be at
	CameraOrbitLocation = rOutVT.Target.Location;
	PlayerControllerRotation = PlayerCamera.PCOwner.Rotation + BiasRot;

//	PlayerControllerRotation = rOutVT.Target.Rotation;

	CameraOrbitLocation += CameraOffsetTarget >> PlayerControllerRotation;
	CameraTargetLocation = CameraOrbitLocation - Vector(PlayerControllerRotation) * CameraDistanceTarget;

	// Determine where the camera will actually be at
	CameraOrbitLocation = rOutVT.Target.Location;

	// Adjust the camera location by the offset (that's "reverse vector transformed")
	// with the camera's rotation.
	CameraOrbitLocation += CameraOffset >> PlayerControllerRotation;

//	PlayerControllerRotation.pitch = -30 * DegtoUnrRot;

	
	CameraLocation = CameraOrbitLocation - Vector(PlayerControllerRotation) * CameraDistance;

	// Determine if we've hit a wall.  If so, adjust
	HitActor = PlayerCamera.Trace(HitLocation, HitNormal, CameraLocation, CameraOrbitLocation, false, vect(12,12,12));
	if (HitActor != none) 
	{ 
		CameraLocation = HitLocation; 
		//`log("NXCameraTypeFree.Update name:"$HitActor.Name$" loc:"$CameraLocation);
	}

	// Set the target position and rotation we'll lerp to
	PositionTarget = CameraLocation;


	     RotationTarget = PlayerControllerRotation;

	//RotationTarget.pitch = -30 * DegtoUnrRot;
	// Lerp the location with a simple VLerp
	rOutVT.POV.Location = VLerp(rOutVT.POV.Location, PositionTarget, CameraMovementLerp);
  //  rOutVT.POV.Location =  PositionTarget;

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

function MobileZoom(float Scale)
{
	CameraDistance = ZoomStartDistance*Scale*ZoomSpeedFactor;

	CameraDistance = FClamp(CameraDistance,CameraDistanceMin,CameraDistanceMax);
}

function RecordZoomStartDistance()
{
    ZoomStartDistance = CameraDistance;
}
simulated function Tick(float DeltaTime)
{
	// Smoothly transition the camera distance
	if (CameraDistance != CameraDistanceTarget)
	{
	//	CameraDistance = Lerp(CameraDistance, CameraDistanceTarget, CameraTransitionLerp);
	//	if (Abs(CameraDistanceTarget - CameraDistance) < 0.005f) { CameraDistance = CameraDistanceTarget; }

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

	//PlayerCamera.ClientMessage("Tick ost:"$CameraOffsetTarget$" dt:"$CameraDistanceTarget);
}


DefaultProperties
{
	CameraOffsetTarget=(X=0f,Y=.0f,Z=47.0f)
		CameraFieldOfView=90.0f
		CameraAspectRatio=1.777777f
		CameraDistanceMin=32.0f
		CameraDistanceMax=512.0f
	CameraDistanceTarget=400.0f
/*
	MoveBackCameraDistanceTarget=400.0f

	MoveFaceCameraDistanceTarget=200.0f

	IdleCameraDistanceTarget=350.0f
*/

	CameraActiveDelay=0.3f


		CameraDistanceSpeed=10.0f
		CameraTransitionLerp=0.05f   //origin 0.05
		CameraMovementLerp=0.1f
		CameraRotationLerp=0.1f
		EnableZoom=false


		ZoomSpeedFactor=0.5
}

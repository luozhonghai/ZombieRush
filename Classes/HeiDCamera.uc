class HeiDCamera extends Camera;

/** Position offset of the camera from the player */
var  Vector CameraOffsetTarget;

var  float CameraDistanceTarget;

var Vector CameraTargetLocation;


var  float CameraFieldOfView;

var  Vector BaseCamRotation;


/** Speed at which the camera lerps to the desired positions */
var  float CameraMovementLerp;


function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{
	local CameraActor lCameraActor;

	// Don't update the outgoing view-target during an interpolation
	if (PendingViewTarget.Target != None && OutVT == ViewTarget && BlendParams.bLockOutgoing )
	{
		return;
	}

	// Default FOV on view-target
	OutVT.POV.FOV = DefaultFOV;

	// If we have a target actor, use it to get the point of view
	// instead of generating it with a camera type
	lCameraActor = CameraActor(OutVT.Target);
	if (lCameraActor != None)
	{
		lCameraActor.GetCameraView(DeltaTime, OutVT.POV);

		// Grab aspect ratio from the CameraActor.
		bConstrainAspectRatio = bConstrainAspectRatio || lCameraActor.bConstrainAspectRatio;
		OutVT.AspectRatio = lCameraActor.AspectRatio;

		// See if the CameraActor wants to override the PostProcess settings used.
		CamOverridePostProcessAlpha = lCameraActor.CamOverridePostProcessAlpha;
		CamPostProcessSettings = lCameraActor.CamOverridePostProcess;
	}
	else
	{
		// Give the pawn view-target a chance to dictate the camera position.
		// If pawn doesn't override the camera view, then we can proceed with the current camera
		if (Pawn(OutVT.Target) == None || !Pawn(OutVT.Target).CalcCamera(DeltaTime, OutVT.POV.Location, OutVT.POV.Rotation, OutVT.POV.FOV))
		{

				// Use the custom type that was set
				CustomUpdateCamera(DeltaTime, OutVT);
			
		}
	}

	ApplyCameraModifiers(DeltaTime, OutVT.POV);

	// Set camera's location and rotation, to handle cases where we are not locked to view target
	SetRotation(OutVT.POV.Rotation);
	SetLocation(OutVT.POV.Location);
}

/** Core function use to calculate new camera location and rotation */
function CustomUpdateCamera(float rDeltaTime, out TViewTarget rOutVT)
{
	local Vector CameraOrbitLocation;
	// Determine where the camera will actually be at
	CameraOrbitLocation = rOutVT.Target.Location;

	CameraOrbitLocation += CameraOffsetTarget >> rotator(BaseCamRotation);
	CameraTargetLocation = CameraOrbitLocation - BaseCamRotation * CameraDistanceTarget;

	// Lerp the location with a simple VLerp
	rOutVT.POV.Location = VLerp(rOutVT.POV.Location, CameraTargetLocation, CameraMovementLerp);

	rOutVT.POV.Rotation = rotator(BaseCamRotation);
	rOutVT.POV.FOV = CameraFieldOfView;

}
DefaultProperties
{
	BaseCamRotation=(X=0f,Y=-1.0f,Z=-0.05f)
	CameraOffsetTarget=(X=0f,Y=15.0f,Z=10.0f)
			CameraFieldOfView=70.0f
			CameraAspectRatio=1.777777f
			CameraDistanceMin=32.0f
			CameraDistanceMax=512.0f
	CameraDistanceTarget=120.0f
			CameraDistanceSpeed=10.0f
			CameraTransitionLerp=0.05f
	CameraMovementLerp=0.15f
}

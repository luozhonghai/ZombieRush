class ZBCameraTypeDarkSider extends ZBCameraTypeAbstract;


/************************************************************//** 
 * Properties
 *************************************************************/

/** Position offset of the camera from the player */
var  Vector CameraOffsetTarget;

/** Distance offset from the player */
var  float CameraDistanceMin;
var  float CameraDistanceMax;
var  float LastCameraDistance;

var Rotator  BiasRot;


var float ZoomScale;
/************************************************************//** 
 * Constructor
 *************************************************************/

function Initialize()
{
	CameraStyle = 'FreeCam';
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





	// If we're coming in from a camera change, we're going to change the
	// rotation of the player character first to match the old view target.
	// Otherwize, we may have a jarring transition between camera types
	if (CameraChange)
	{
		// TODO: Add code to keep the view from jumping on transition
		CameraChange = false;
	}

	BiasRot.pitch = -15 * DegtoUnrRot;
	// Deterimine the target we want the camera to be at
	CameraOrbitLocation = rOutVT.Target.Location;
	PlayerControllerRotation = PlayerCamera.PCOwner.Rotation + BiasRot;

	//	PlayerControllerRotation = rOutVT.Target.Rotation;

	CameraOrbitLocation += CameraOffsetTarget >> PlayerControllerRotation;


	
   if (Vsize(CameraOrbitLocation-rOutVT.POV.Location)>CameraDistanceMax)
          CameraDistance = CameraDistanceMax;
   else if (Vsize(CameraOrbitLocation-rOutVT.POV.Location)<CameraDistanceMin* ZoomScale)
   {
	      CameraDistance = CameraDistanceMin * ZoomScale;
   }
   else if(PlayerCamera.bStrafeMove) 
          CameraDistance = LastCameraDistance;
   else
   {
	      CameraDistance = VSize(CameraOrbitLocation-rOutVT.POV.Location);
          LastCameraDistance = CameraDistance;
   }
   
 
  

	CameraLocation = CameraOrbitLocation - Vector(PlayerControllerRotation) * CameraDistance ;

	// Determine if we've hit a wall.  If so, adjust
	HitActor = PlayerCamera.Trace(HitLocation, HitNormal, CameraLocation, CameraOrbitLocation, false, vect(12,12,12));
	if (HitActor != none) 
	{ 
		CameraLocation = HitLocation; 
		//`log("NXCameraTypeFree.Update name:"$HitActor.Name$" loc:"$CameraLocation);
	}


	//RotationTarget.pitch = -30 * DegtoUnrRot;
	
	rOutVT.POV.Location = CameraLocation;

	rOutVT.POV.Rotation = Rotator(CameraOrbitLocation - CameraLocation);//PlayerControllerRotation;


	// Ensure the camera style matches ours
	if (PlayerCamera.CameraStyle != CameraStyle) { PlayerCamera.CameraStyle = CameraStyle; }
}


function MobileZoom(float Scale)
{
    ZoomScale = Scale;
	//CameraDistance = ZoomStartDistance*Scale*ZoomSpeedFactor;

	//CameraDistance = FClamp(CameraDistance,CameraDistanceMin,CameraDistanceMax);
}

function RecordZoomStartDistance()
{
	//ZoomStartDistance = CameraDistance;
}

/************************
//ÏÞÖÆpitch   ZombiePC.ProcessViewRotation():
//	out_ViewRotation	 = LimitViewRotation(out_ViewRotation, -8383, 16383 );
*************************/
DefaultProperties
{
	CameraDistance=300.f 
	CameraDistanceMin=170.f
	CameraDistanceMax=320.f

	CameraOffsetTarget=(X=0f,Y=.0f,Z=70.0f)

	ZoomScale=1.3
}

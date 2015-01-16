class ZBCameraTypeRush extends ZBCameraTypeAbstract;

/** Position offset of the camera from the player */
var  Vector CameraOffsetTarget;

var  Vector DesireCamLoc;

var() float CameraTransitionLerp;

var  Vector BaseCamLoc;

var  Pawn TargetPawn;
var bool EnableLandLerp;
var bool ResetCam;
function Initialize()
{
	CameraStyle = 'FreeCam';
	ResetCam = true;
	//PawnLocZ = 
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
		rOutVT.POV.rotation.yaw = rot2.yaw;
		rOutVT.POV.rotation.pitch = -15 * DegtoUnrRot;
		BaseCamLoc = rPawn.Location;
		TargetPawn = rPawn;
		rOutVT.POV.Location = BaseCamLoc + CameraOffsetTarget - Vector(rOutVT.POV.Rotation) * CameraDistance ;
		return;
	}
	// With rotations, we need to lerp with a quaternion so there is no gimble lock
	CameraQuaternion = QuatSlerp(QuatFromRotator(rot1), QuatFromRotator(rot2), 0.05, true);
	rot2 = QuatToRotator(CameraQuaternion);
	rOutVT.POV.rotation.yaw = rot2.yaw;
	rOutVT.POV.rotation.pitch = -15 * DegtoUnrRot;

//	DesireCamLoc = rPawn.Location + CameraOffsetTarget - Vector(rOutVT.POV.Rotation) * CameraDistance ;
//	rOutVT.POV.Location = VLerp(rOutVT.POV.Location,DesireCamLoc,CameraTransitionLerp);
	
	if(EnableLandLerp){
	BaseCamLoc.z = Lerp(BaseCamLoc.z,TargetPawn.Location.z,CameraTransitionLerp);
	BaseCamLoc.x = TargetPawn.Location.x;
	BaseCamLoc.y = TargetPawn.Location.y;
	rOutVT.POV.Location = BaseCamLoc + CameraOffsetTarget - Vector(rOutVT.POV.Rotation) * CameraDistance ;

	dist = BaseCamLoc - TargetPawn.Location;
	if(vsize(dist)<1)
		EnableLandLerp = false;

	}
	else

	rOutVT.POV.Location = TargetPawn.Location + CameraOffsetTarget - Vector(rOutVT.POV.Rotation) * CameraDistance ;
}

simulated function Tick(float DeltaTime)
{
	//
}

function OnSpecialMoveEnd(ZBSpecialMove SpecialMove){

	if(ZSM_JumpStart(SpecialMove)!=none){
		EnableLandLerp = true;
	   BaseCamLoc.z = ZSM_JumpStart(SpecialMove).baseLoc.z;
	}
}
DefaultProperties
{
	CameraDistance=300.f 
	CameraTransitionLerp=0.1
	CameraOffsetTarget=(X=0f,Y=.0f,Z=70.0f)
	bResetCam=false
}

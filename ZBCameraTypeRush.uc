class ZBCameraTypeRush extends ZBCameraTypeAbstract;



/** Core function use to calculate new camera location and rotation */
function UpdateCamera(Pawn rPawn, ZBPlayerCamera rCameraActor, float rDeltaTime, out TViewTarget rOutVT)
{
	local rotator rot1,rot2;

	local Quat CameraQuaternion;

	rot1.yaw = rOutVT.POV.Rotation.yaw;
	rot2.yaw = rPawn.Rotation.yaw;//-25 * DegtoUnrRot;

	// With rotations, we need to lerp with a quaternion so there is no gimble lock
	CameraQuaternion = QuatSlerp(QuatFromRotator(rot1), QuatFromRotator(rot2), 0.05, true);
	rot2 = QuatToRotator(CameraQuaternion);
	rOutVT.POV.yaw = rot2.yaw;

	rOutVT.POV.Location = rPawn.Location - Vector(rOutVT.POV.Rotation) * CameraDistance ;
}


DefaultProperties
{
	CameraDistance=300.f 
}

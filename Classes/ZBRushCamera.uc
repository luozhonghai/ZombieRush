class ZBRushCamera extends ZBPlayerCamera;


event PostBeginPlay()
{
	local class<ZBCameraTypeAbstract> lCameraType;

	Super.PostBeginPlay();

	ClientMessage("PostBeginPlay:"$CameraStyle);

	CurrentCameraType = CreateCamera(class 'ZBCameraTypeRushFix');


}

function CameraPitchToggle(bool bDown)
{
	ZBCameraTypeRushFix(CurrentCameraType).SwitchPitchDegree(bDown);
}
DefaultProperties
{
	DefaultCameraType="ZGame.ZBCameraTypeRushFix"
}

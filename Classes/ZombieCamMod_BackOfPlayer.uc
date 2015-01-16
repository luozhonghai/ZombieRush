class ZombieCamMod_BackOfPlayer extends CameraModifier;


var const int	BaseRotSpeed;
var const int RealRotPitchSpeed;

var float FacingTime; // Young 20091112
var const float FacingWaitTime; 

//相机重置
var float ResetDelayTime; 
var const float ResetDelay;

var float ResetPitchDelayTime; 
var const float ResetPitchDelay;

var bool bRunning;

function bool IsInRotationRange(float angle)
{
	/*local int piby8, piby4, piby2, pi;
	piby8 = 32768 / 8;
	piby4 = 32678 / 4;
	piby2 = 32678 / 2;	
	pi = 32768;

	if((angle> piby8 && angle < (piby8 + piby4)) || (angle > (piby8 + piby2) && angle < (piby8 + piby2 + piby4)))
	{
		return true;
	}

	return false;*/

	return true;
}



function int CalcRealBaseRotSpeed(float angle)
{
	local int piby4, pi3by4, piby2;
	local int Ret;
	local float factor;

	piby4 = 32678 / 4;
	piby2 = 32678 / 2;
	pi3by4 = piby2 + piby4;

//	if(angle < piby2)
//	{
		factor = abs(piby2 - angle) / piby2;
		Ret = (1 - factor ) * BaseRotSpeed;
//	}
	/*
	else if(angle < pi3by4)
	{
		Ret = BaseRotSpeed;
	}
	else // [else] added by Young 20091111
	{
		Ret = BaseRotSpeed;
	}*/


	return Ret;
}


function RotateView(bool bForced, bool bFaceCam, int DeltaAngle, float DeltaTime, out Rotator out_DeltaRot)
{
	local int DeltaRot;
	local int	RealRotSpeed;

	//if(!bForced)
	//{
	RealRotSpeed = CalcRealBaseRotSpeed(abs(DeltaAngle));
	//if(bFaceCam && !bForced)
	//	RealRotSpeed = 0;

	if(abs(DeltaAngle) > 0 && IsInRotationRange(abs(DeltaAngle)))
	{
		DeltaRot = RealRotSpeed  * DeltaTime * DeltaAngle / abs(DeltaAngle);

		//invert the turning direction if the angle between viewtarget and camera is more than PI / 2
		//if(abs(DeltaAngle) > 65535 / 4)
		//	DeltaRot *= -1;

		//clamp
		if(abs(DeltaRot) > abs(DeltaAngle))
			DeltaRot = DeltaAngle;

		out_DeltaRot.Yaw = DeltaRot;			

		//`alog("new out_DeltaRot.Yaw ="@out_DeltaRot.Yaw@", deltaAngle ="@DeltaAngle);
	}

}

function RotatePitchView(int DeltaAngle, float DeltaTime, out Rotator out_DeltaRot)
{
	local int DeltaRot;
	local int	RealRotSpeed;

	
	RealRotSpeed = CalcRealBaseRotSpeed(abs(DeltaAngle));


	if(abs(DeltaAngle) > 0 && IsInRotationRange(abs(DeltaAngle)))
	{
		DeltaRot = RealRotPitchSpeed  * DeltaTime * DeltaAngle / abs(DeltaAngle);

		//invert the turning direction if the angle between viewtarget and camera is more than PI / 2
		//if(abs(DeltaAngle) > 65535 / 4)
		//	DeltaRot *= -1;

		//clamp
		if(abs(DeltaRot) > abs(DeltaAngle))
			DeltaRot = DeltaAngle;

		out_DeltaRot.pitch = DeltaRot;			

		//`alog("new out_DeltaRot.Yaw ="@out_DeltaRot.Yaw@", deltaAngle ="@DeltaAngle);
	}

}


event float CalcAngleBetweenVectors(vector v1, vector v2)
{
	local vector		vLeft;
	local float		fAngle, fLeftPct;

	if(VSize(v2) == 0 && VSize(v1) == 0)
	{
		fAngle = 0;
	}
	else if(VSize(v2) > 0 && VSize(v1) > 0)
	{
		v2	= Normal(v2);
		v1	= Normal(v1);

		fAngle = ACos(v1 dot v2);

		vLeft = v1 cross vect(0,0,1);
		vLeft = Normal(vLeft);

		fLeftPct = vLeft dot v2;
		if(fLeftPct > 0)
			fAngle *= -1;
	}
	else
	{
		fAngle = 0;
	}

	return fAngle;
}

function float GetDeltaAngle(Actor ViewTarget, float DeltaTime, Rotator out_ViewRotation)
{
	local int DeltaAngle;
	local vector TarDir, CamDir;
	local rotator TarRot, CamRot;

	TarRot = (ViewTarget.Rotation);
	TarRot.Pitch = 0;
	TarRot.Roll = 0;
	CamRot = (out_ViewRotation);
	CamRot.Pitch = 0;
	CamRot.Roll = 0;

	TarDir = vector(TarRot);
	CamDir = vector(CamRot);

	//CameraOwner.PCOwner.DrawDebugLine( CameraOwner.PCOwner.Pawn.Location, CameraOwner.PCOwner.Pawn.Location + CamDir * 1000, 255, 0, 0 );
	//CameraOwner.PCOwner.DrawDebugLine( CameraOwner.PCOwner.Pawn.Location, CameraOwner.PCOwner.Pawn.Location + TarDir * 1000, 0, 255, 0 );

	DeltaAngle = CalcAngleBetweenVectors(CamDir, TarDir) / PI * 32767;//TargetRot - CamRot;

	return DeltaAngle;
}

function float GetPitchDeltaAngle(Actor ViewTarget, float DeltaTime, Rotator out_ViewRotation)
{
	local int DeltaAngle;
	local vector TarDir, CamDir;
	local rotator TarRot, CamRot;

	TarRot = (ViewTarget.Rotation);
	TarRot.yaw = 0;
	TarRot.Roll = 0;
	CamRot = (out_ViewRotation);
	CamRot.yaw = 0;
	CamRot.Roll = 0;

	TarDir = vector(TarRot);
	CamDir = vector(CamRot);

	//CameraOwner.PCOwner.DrawDebugLine( CameraOwner.PCOwner.Pawn.Location, CameraOwner.PCOwner.Pawn.Location + CamDir * 1000, 255, 0, 0 );
	//CameraOwner.PCOwner.DrawDebugLine( CameraOwner.PCOwner.Pawn.Location, CameraOwner.PCOwner.Pawn.Location + TarDir * 1000, 0, 255, 0 );

	DeltaAngle = CalcAngleBetweenVectors(CamDir, TarDir) / PI * 32767;//TargetRot - CamRot;

	return DeltaAngle;
}


simulated function bool ProcessViewRotation( Actor ViewTarget, float DeltaTime, out Rotator out_ViewRotation, out Rotator out_DeltaRot )
{
	local ZBPlayerInput PlayerInput;
	local float	SpeedThresholdToRotateCam;
	local float TargetSpeed;
	local float DeltaAngle, StickEpsilon;
	local bool bFaceCam;
    local rotator rot1,rot2;

	local Quat CameraQuaternion;

	PlayerInput = ZBPlayerInput(CameraOwner.PCOwner.PlayerInput);

	StickEpsilon = 1.0f;

	if(ViewTarget != None)
	{
		if(PlayerInput!= None)
		{
			if(Pawn(ViewTarget) != None)
			{
				SpeedThresholdToRotateCam = 400;
			}

			TargetSpeed = VSize2D(ViewTarget.Velocity);

			if(TargetSpeed >= 0.2f)
			{
				ResetDelayTime = 0.0f;
				bRunning = TRUE;
			}
		//	else
				//dont rotate camera when idle
	//		return false;

			if(TargetSpeed > SpeedThresholdToRotateCam && out_DeltaRot.Yaw == 0)
			{
				DeltaAngle = GetDeltaAngle(ViewTarget, DeltaTime, out_ViewRotation);
				bFaceCam = JudgeFacingControl(abs(DeltaAngle), DeltaTime); // Young 20091112
				RotateView(FALSE, bFaceCam, DeltaAngle, DeltaTime, out_DeltaRot);
				//AlicePawn(ViewTarget).CamEyeRotDelay = 0;
				/*if(bFaceCam)
				{
					AlicePawn(ViewTarget).CamDistScale = AlicePawn(ViewTarget).CamDistScaleWhenFacingCam;
				}*/
				
				//reset pitch delay
				ResetPitchDelayTime+=DeltaTime;
				if (ResetPitchDelayTime>ResetPitchDelay)
				{
					//DeltaAngle = GetPitchDeltaAngle(ViewTarget, DeltaTime, out_ViewRotation);
				//	RotatePitchView(DeltaAngle,DeltaTime,out_DeltaRot);

					rot1.pitch = out_ViewRotation.pitch;
					rot2.pitch = ViewTarget.Rotation.pitch;//-25 * DegtoUnrRot;
					// With rotations, we need to lerp with a quaternion so there is no gimble lock
				CameraQuaternion = QuatSlerp(QuatFromRotator(rot1), QuatFromRotator(rot2), 0.05, true);
					 rot2 = QuatToRotator(CameraQuaternion);
					 out_ViewRotation.pitch = rot2.pitch;
				}

			}
			else 
			{
				ResetPitchDelayTime = 0;

				if(abs(PlayerInput.aTurn) <= StickEpsilon && abs(PlayerInput.aLookup) <= StickEpsilon && bRunning  &&TargetSpeed < 0.0001f)
				{
					DeltaAngle = GetDeltaAngle(ViewTarget, DeltaTime, out_ViewRotation);
					bFaceCam = JudgeFacingControl(abs(DeltaAngle), DeltaTime); // Young 20091112
					if(ResetDelayTime > ResetDelay)
					//	RotateView(TRUE, bFaceCam, DeltaAngle, DeltaTime, out_DeltaRot);

					//AlicePawn(ViewTarget).CamEyeRotDelay = 0;
					ResetDelayTime += DeltaTime;
				}
				else
				{
					if (bRunning&&TargetSpeed < 0.0001f)  //停止的时 手动调整视角，则重置 brunning 不再自动旋转至角色背后 
					{
						bRunning = false;
					}

					
				}
			}

		}
	}

	return false;
}


function bool JudgeFacingControl(float angle, float DeltaTime)
{
	local int piby4, pi3by4, piby2;
	local bool bFaceCam;

	piby4 = 32678 / 4;
	piby2 = 32678 / 2;
	pi3by4 = piby2 + piby4;

	bFaceCam = false;

	if(angle < pi3by4)
	{
		  FacingTime = 0.0f;

	}
	else
	{
		
		FacingTime += DeltaTime;
		
		
		bFaceCam = true;
	}

	return bFaceCam;
}

DefaultProperties
{
	BaseRotSpeed=27000  //20000
	ResetDelay=2.500000

	RealRotPitchSpeed =17000

	ResetPitchDelay=0.2

}

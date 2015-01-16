class ZBPlayerCamera extends Camera;



/************************************************************//** 
 * Properties
 *************************************************************/

/** Player controller that owns this camera */
var ZombiePC PlayerOwner;

var float ClosestCameraThreshold;
/** Camera type that dictates how the camera actually behaves */
var ZBCameraTypeAbstract CurrentCameraType;
var ZBCameraTypeAbstract LastCameraType;

/** Simple string grabbed from DefaultCamera.ini that defines the default behavior */
var string DefaultCameraType;

var bool bStrafeMove;   //set by controller
var CameraModifier CamMod_BackOfPlayer;

/************************************************************//** 
 * Called when the camera is activated in the game
 *************************************************************/
event PostBeginPlay()
{
	local class<ZBCameraTypeAbstract> lCameraType;

	Super.PostBeginPlay();

	ClientMessage("PostBeginPlay:"$CameraStyle);

	CurrentCameraType = CreateCamera(class 'ZBCameraTypeDarkSider');

	// Ensure we have a default camera type identified
	if (DefaultCameraType == "") { DefaultCameraType = "ZGame.ZBCameraTypeFree"; }
   
	// Load the default camera (if needed)
	if ((CurrentCameraType == None))
	{
		// Get the default camera class to use
		lCameraType = class<ZBCameraTypeAbstract>(DynamicLoadObject(DefaultCameraType, class'Class'));
      
		// Create and set the default camera
		CurrentCameraType = CreateCamera(lCameraType);
		LastCameraType = none;
	}




	CamMod_BackOfPlayer = CreateCameraModifier(class'ZombieCamMod_BackOfPlayer');
	CamMod_BackOfPlayer.AddCameraModifier(Self);

	
}


/************************************************************//** 
 * Core camera functionality
 *************************************************************/

/************************************************************//** 
 * Initialize the PlayerCamera for the owning PlayerController
 *************************************************************/
function InitializeFor(PlayerController rPlayerController)
{
   // Parent initialization
   Super.InitializeFor(rPlayerController);

   // Set PlayerOwner to player controller
   PlayerOwner = ZombiePC(rPlayerController);
}



/************************************************************//** 
 * Function for switching to a different camera by class
 *************************************************************/
exec function ZBCameraTypeAbstract ChangeCameraType(string rClassName)
{
	local ZBCameraTypeAbstract lCameraTemp;
	local class<ZBCameraTypeAbstract> lCameraType;

	// Get the camera type
	lCameraType = class<ZBCameraTypeAbstract>(DynamicLoadObject(rClassName, class'Class'));

	// No need to change if we are using the camera we expect
	if (CurrentCameraType != none)
	{
		if (CurrentCameraType.Class == lCameraType)
		{
			return CurrentCameraType;
		}
	}

	// If the last camera type matches the new one, reuse it.
	if (LastCameraType != none && LastCameraType.Class == lCameraType)
	{
		// Flag each of the camera type's new states
		CurrentCameraType.OnBecomeInactive(LastCameraType);
		LastCameraType.OnBecomeActive(CurrentCameraType);

		// Swap the camera types
		lCameraTemp = CurrentCameraType;
		CurrentCameraType = LastCameraType;
		LastCameraType = lCameraTemp;
	}
	else if (lCameraType != none)
	{
		// Create a new camera of the specified type
		LastCameraType = CurrentCameraType;
		CurrentCameraType = CreateCamera(lCameraType);
	}

	return CurrentCameraType;
}

/************************************************************//** 
 * Creates and initializes a new camera type to be used by this
 * camera.  
 *************************************************************/
function ZBCameraTypeAbstract CreateCamera(class<ZBCameraTypeAbstract> rCameraClass)
{
   local ZBCameraTypeAbstract lNewCamera;

   // Create new camera type and initialize is
   lNewCamera = new(Outer) rCameraClass;
   lNewCamera.PlayerCamera = self;
   lNewCamera.Initialize();

   // Call active/inactive functions on new/old cameras
   if (CurrentCameraType != none)
   {
      CurrentCameraType.OnBecomeInactive(lNewCamera);
      lNewCamera.OnBecomeActive(CurrentCameraType);
   }
   else
   {
      lNewCamera.OnBecomeActive(None);
   }

   // Set new camera as current
   CurrentCameraType = lNewCamera;

   return lNewCamera;
}

/************************************************************//** 
 * Core function of the camera that generates the point of view
 * for the camera based on the camera type.
 *
 * @param   OutVT      ViewTarget to use.
 * @param   DeltaTime   Delta Time since last camera update (in seconds).
 *************************************************************/
function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{
	local CameraActor lCameraActor;

	local Actor ShootTarget;
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
			if (CurrentCameraType != none)
			{
				// Use the custom type that was set
				if(Pawn(OutVT.Target)!=none)
				{
					CurrentCameraType.Tick(DeltaTime);
					CurrentCameraType.UpdateCamera(Pawn(OutVT.Target), self, DeltaTime, OutVT);
				}    	
              /*
				if(ZombiePlayerPawn(OutVT.Target).WeaponType == 2)//hold gun
				{
                    ShootTarget = CheckAvaliableTarget(OutVT.POV.Location,OutVT.POV.Rotation);
				}*/
			}
			else
			{
				ClientMessage("NXPlayerCamera.UpdateViewTarget(): No NXCameraType set");
			}
		}
   }

   ApplyCameraModifiers(DeltaTime, OutVT.POV);
  if(ZombieRushPC(PCOwner)!=none && PCOwner.IsInState('FallingHole')){}
  else
	 PreventCameraPenetration(PlayerOwner, OutVT.POV.Location, OutVT.POV.Rotation);
   // Set camera's location and rotation, to handle cases where we are not locked to view target
   SetRotation(OutVT.POV.Rotation);
   SetLocation(OutVT.POV.Location);
}
//check shoot target
/*
function Actor CheckAvaliableTarget(vector start, rotator dir)
{
	local vector	TargetLoc, CamPos, out_CamLoc, HitLocation, HitNormal, Rot, Proj;
	local rotator   out_CamRot;
	local Actor		HitActor;

	TargetLoc = start + 1200*
  	HitActor = Trace(HitLocation, HitNormal, start, TargetLoc, FALSE, vect(50,50,50));
}*/

/************************************************************//** 
 * Sets the view target to the specified player controller
 *****************************************************************/
simulated function BecomeViewTarget(PlayerController rPlayerController)
{
   CurrentCameraType.BecomeViewTarget(ZombiePC(rPlayerController));
}

/************************************************************//** 
 * Pass zoom in through to camera type
 *****************************************************************/
function ZoomIn()
{
   CurrentCameraType.ZoomIn();
}

/************************************************************//** 
 * Pass zoom out through to camera type
 *****************************************************************/
function ZoomOut()
{
   CurrentCameraType.ZoomOut();
}

/************************************************************//** 
 * Pass mobile zoom through to camera type
 *****************************************************************/
function MobileZoom(float Scale)
{
	CurrentCameraType.MobileZoom(Scale);
}

function RecordZoomStartDistance()
{
    CurrentCameraType.RecordZoomStartDistance();
}
/************************************************************//** 
 * Pass the tick onto the camera type
 *****************************************************************/
simulated function Tick(float rDeltaTime)
{
	//CurrentCameraType.Tick(rDeltaTime);
}

/************************************************************//** 
 * Used to display a message on the screen.  Primarily for 
 * debugging purposes
 *****************************************************************/
function ClientMessage(coerce String rMsg)
{
	local PlayerController lPlayerController;
	foreach LocalPlayerControllers(class'PlayerController', lPlayerController)
	{
		lPlayerController.ClientMessage(rMsg);
	}
}


function PreventCameraPenetration(ZombiePC ZPC, out vector vLocation, out rotator rRotation)
{
	local vector	TargetLoc, CamPos, out_CamLoc, HitLocation, HitNormal, Rot, Proj;
	local rotator   out_CamRot;
	local Actor		HitActor;
	/*local TraceHitInfo HitInfo;*/
	local vector	vUp;
	local float fZ, fT;

	TargetLoc = ZPC.Pawn.GetPawnViewLocation();

	CamPos = vLocation;
	out_CamLoc = vLocation;
	out_CamRot = rRotation;

	if( VSize(out_CamLoc - TargetLoc) <= ClosestCameraThreshold )
	{
		Rot = Vector(out_CamRot);
		CamPos = TargetLoc - Rot*ClosestCameraThreshold;
		out_CamLoc = CamPos;
	}

	////HitActor = Trace(HitLocation, HitNormal, CamPos, TargetLoc, TRUE, vect(12,12,12), HitInfo,TRACEFLAG_Blocking);
	HitActor = Trace(HitLocation, HitNormal, CamPos, TargetLoc, FALSE, vect(12,12,12));
	if( HitActor != None )
	{
		if(HitActor.IsA('BlockingVolume'))
		{
			if(BlockingVolume(HitActor).bBlockCamera)
			{
				out_CamLoc = HitLocation + HitNormal*2;
			}
		}
		else if(HitActor.IsA('WorldInfo'))
		{
			out_CamLoc = HitLocation + HitNormal*2;
		}
		else if( HitActor.IsA('Terrain') )//&& Terrain(HitActor).CanBlockCamera )
		{
			out_CamLoc = HitLocation + HitNormal*2;
		}
		else if( HitActor.IsA('StaticMeshActor') && StaticMeshActor(HitActor).CollisionComponent.CanBlockCamera 
			|| HitActor.IsA('StaticMeshCollectionActor'))
		{
			out_CamLoc = HitLocation + HitNormal*2;
		}
		else
		{
			// out_CamLoc = HitLocation + HitNormal*2;
		}

		if( VSize(out_CamLoc - TargetLoc) < ClosestCameraThreshold )
		{
			if(!(VSize( HitNormal - vect(0.0f, 0.0f, 1.0f) ) < 0.001f))
			{
				//`log("Put Camera above player");

				vUp = HitNormal Cross vect(0.0f, 0.0f, 1.0f);
				vUp = Normal( vUp Cross HitNormal );

				Proj = TargetLoc - out_CamLoc;
				fT = Proj Dot vUp;
				Proj = out_CamLoc + fT * vUp;
				fZ = VSize( Proj - TargetLoc );
				fT = sqrt( ClosestCameraThreshold * ClosestCameraThreshold - fZ * fZ );
				out_CamLoc += vUp * fT;

				/*Rot = TargetLoc - out_CamLoc;
				Rot = Normal(Rot);
				out_CamRot = rotator(Rot);*/
			}
		}
	}

	// find hit actors between camera & Pal.
	/*for(i = 0; i < HideActors.Length; i++)
	{
		 HideActors[i].SetHidden(false);
	}
	HideActors.Length = 0;

	foreach TraceActors(class'Actor',HitActor,HitLocation,HitNormal,CamPos,TargetLoc,vect(12,12,12))//(CamPos+TargetLoc)/2, CamPos)
	{
		// by yjh
		//if( HitActor.bIgnoreCameraHide )
		//{
		//	continue;
		//}
	   if(Pawn(HitActor) == none)// && !HitActor.bHiddenByLD)
	   {
			HideActors.AddItem(HitActor);
			HitActor.SetHidden(true);
			`log("Hide hit actor");
	   }
	}*/
	////

	vLocation = out_CamLoc;
	rRotation = out_CamRot;
}

function OnSpecialMoveEnd(ZBSpecialMove SpecialMove){
	CurrentCameraType.OnSpecialMoveEnd(SpecialMove);
}
DefaultProperties
{
	DefaultCameraType="ZGame.ZBCameraTypeDarkSider"

		ClosestCameraThreshold=50.000000   //20 origin
}

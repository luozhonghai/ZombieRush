class ZombiePC extends SimplePC;

var(Debug) bool GameDebug;
var(Debug) bool bCheat;

var() name NormalStateName;

var float SwipeTolerance;
var float SwipeVelocityTolerance;
var float CheckSwipeInterval;


var bool bSwipeCapturePlayer;
var int SwipeCounter;
var int TargetSwipeNum;
/** Maximum distance an Actor can be to be picked */
var float PickDistance;

var ZBAIPawnBase InteractZombie,LastInteractZombie;
var ZBAIPawnBase AvailableShootZombie,LastAvailableShootZombie;

var Actor AvailableShootTarget;
//For ios touch
struct STouchEvent 
{
	var int Handle;

	var int ButtonId;

	// True if this touch has already been processed or not
	var bool HasBeenProcessed;

	var Vector2D ScreenLocation;

	var float LastTouchTime;

	var Vector2D TouchBeginLocation;

	var float SwipeDistance;

	var float SwipeVelocity;
	//var float TouchDuration;
};

// Array of all touch events
var array<STouchEvent> TouchEvents;

//For Zoom Touch

var float TwoFingerOldDistance;
var float TwoFingerSampleDistance;
var float ZoomScale;
var float FingerMoveSampleInterval;
/**Melee
*/

var() float MinMeleeAdhesionDotValue;
var ZombiePawn ForcedAdhesionTarget;

var bool	bCanTurn;
var bool	bCanMove;


/** cached result of GetPlayerViewPoint() */
var Actor CalcViewActor;
var vector CalcViewActorLocation;
var rotator CalcViewActorRotation;
var vector CalcViewLocation;
var rotator CalcViewRotation;

var float CalcEyeHeight;

var float LastCameraTimeStamp; /** Used during matinee sequences */



var bool mActionCameraMode;



var bool bCameraFocusIsLocked;
var bool bCameraIsTransitioning;


exec function ToggleCamera()
{

   ZBPlayerCamera(PlayerCamera).ChangeCameraType("ZGame.ZBCameraTypeFree");

}

event PostBeginPlay()
{
	super.PostBeginPlay();
}
/** Initialization function called from the GameInfo class.  Any initialization
 *  should be done here.  I thought we could use PostPlayBegin, but in looking
 *  through the root objects, not everything is initialized for us by then.  This
 *  function will be called once the default UDK initialization is complete. */
event Initialize()
{
	//ConsoleCommand("show collision");
}
/**
 * Initializes the input system
 *
 * @network		Client
 */
event InitInputSystem()
{
	local MobilePlayerInput MobilePlayerInput;

	Super.InitInputSystem();
 
	// Assign the touch delegate
	MobilePlayerInput = MobilePlayerInput(PlayerInput);
	if (MobilePlayerInput != None)
	{
		MobilePlayerInput.OnInputTouch = InternalOnInputTouch;
	}
}
function SetupZones()
{ 
//	super.SetupZones();
	//cancel inputzone move
	 MPI = MobilePlayerInput(PlayerInput);

	FreeLookZone  = MPI.FindZone("UberLookZone");
	StickMoveZone = MPI.FindZone("ZBUberStickMoveZone");
	LocalPlayer(Player).ViewportClient.GetViewportSize(ViewportSize);


	StickMoveZone.bCenterOnEvent = false;
	StickMoveZone.ActiveSizeX = StickMoveZone.SizeX;
	StickMoveZone.ActiveSizeY = StickMoveZone.SizeY;

//	StickLookZone.bCenterOnEvent = false;

//	StickMoveZone.SizeX *=1.5;
//	StickMoveZone.SizeY = StickMoveZone.SizeX;
//	StickMoveZone.X = 0.4*StickMoveZone.SizeX;
//	StickMoveZone.Y = ViewportSize.Y - 1.5*StickMoveZone.SizeY;

    ClientMessage("SetupZones");
	if (class'ZombieGameInfo'.static.GetPlatform() == P_Mobile)

	{
		ClientMessage("P_Mobile");
		FreeLookZone.VertMultiplier =-0.0007 * 15.75;
		FreeLookZone.HorizMultiplier =0.001 * 23.25;
		FreeLookZone.Acceleration =12.0 * 0.3;
		FreeLookZone.EscapeVelocityStrength=0.1;
	}
	else if (class'ZombieGameInfo'.static.GetPlatform() == P_PC)

	{
		ClientMessage("P_PC");
		FreeLookZone.VertMultiplier = -0.0007 * 1.75;
		FreeLookZone.HorizMultiplier =0.001 *5.25;
		FreeLookZone.Acceleration =12.0 * 0.5;
		FreeLookZone.EscapeVelocityStrength=0.0;
	}

}
exec function SZ()
{
   SetupZones();
}
function UpdateRotation( float DeltaTime )
{
	local Rotator	DeltaRot, newRotation, ViewRotation;

	ViewRotation = Rotation;
	if (Pawn!=none)
	{
		Pawn.SetDesiredRotation(ViewRotation);
	}

	// Calculate Delta to be applied on ViewRotation
	DeltaRot.Yaw	= PlayerInput.aTurn;
	DeltaRot.Pitch	= PlayerInput.aLookUp;

	//需修改为Pawn rotation改变 20121221
	//ApplyAdhesion(DeltaTime, DeltaRot.Yaw, DeltaRot.Pitch);

	ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
	SetRotation(ViewRotation);

	ViewShake( deltaTime );

	NewRotation = ViewRotation;
	NewRotation.Roll = Rotation.Roll;

	if ( Pawn != None )
		Pawn.FaceRotation(NewRotation, deltatime);// 判断 InFreeCam()  CameraStyle= 'FreeCam' 返回
}

function ProcessViewRotation( float DeltaTime, out Rotator out_ViewRotation, Rotator DeltaRot )
{
	super.ProcessViewRotation(DeltaTime,out_ViewRotation,DeltaRot);

	out_ViewRotation	 = LimitViewRotation(out_ViewRotation, -8383, 16383 );
/*
	if( PlayerCamera != None )
	{
		PlayerCamera.ProcessViewRotation( DeltaTime, out_ViewRotation, DeltaRot );
	}

	if ( Pawn != None )
	{	// Give the Pawn a chance to modify DeltaRot (limit view for ex.)
		Pawn.ProcessViewRotation( DeltaTime, out_ViewRotation, DeltaRot );
	}
	else
	{
		// If Pawn doesn't exist, limit view

		// Add Delta Rotation
		out_ViewRotation	+= DeltaRot;
		out_ViewRotation	 = LimitViewRotation(out_ViewRotation, -16384, 16383 );
	}
*/

}
//call from startFire() and MeleeAutoFire()
final function ApplyAdhesion()
{
	local ZombiePawn WP;
	local Rotator NewRotation;
	local Rotator DeltaRot;
	WP = ZombiePawn(Pawn);
	if (WP == None )//|| !PlayerInput.bUsingGamepad)
	{
		return;
	}
	if (ForcedAdhesionTarget != None && !ForcedAdhesionTarget.bDeleteMe)
	{
		NewRotation = rotator(ForcedAdhesionTarget.GetBaseTargetLocation() - WP.Location);
		//NewRotation = RInterpTo(Normalize(Rotation), Normalize(NewRotation), DeltaTime, 8);
		//DeltaRot = NewRotation - Rotation;
		//out_YawRot = DeltaRot.Yaw;
		NewRotation.pitch = 0;
		Pawn.SetRotation(NewRotation);
	}
}
function Vector GetDesiredRotation()
{
};

/** State used for normal player walking, running, etc.  These functions
 *  are used when the player is on something solid */

function ProcessInputAccel(float InputStrength,float deltatime, out Vector InputAccel)
{
	local bool bPawnInjury;
/*
	if (ZombiePlayerPawn(Pawn).PlayerPower <= 0)
	{
		ZombiePlayerPawn(Pawn).DoSpecialMove(SM_Player_Exhausted,true);
	}
*/

	// deal with bump move
	/*
	if(ZombiePlayerPawn(Pawn).bBumping && InputStrength>0.1 && StaticMeshComponent(ZombiePlayerPawn(Pawn).BumpPrimitive)!=none)
	{
	   ZombiePlayerPawn(Pawn).RestorePower(20*deltaTime);
	   InputAccel = vect(0,0,0);

	   return;
	}

	else 
	{
		ZombiePlayerPawn(Pawn).bBumping = false;
	}
*/

	bPawnInjury = ZombiePlayerPawn(Pawn).IsInjuried();


  if(!ZombiePlayerPawn(Pawn).bOverrideGroundSpeedKismet)
  {
	if (InputStrength>2100)
	{
		SetDashSpeed(true,bPawnInjury);

      //待修改，撞上物体也会消耗体力
		ZombiePlayerPawn(Pawn).ConsumePower(20*deltaTime);

	}
	else if(InputStrength>1000)
		SetDashSpeed(false,bPawnInjury);
	else if(InputStrength>10) //walk
	{
		//Pawn.GroundSpeed = 250;  //5m/s
		Pawn.GroundSpeed = 160;   //3m/s
	}
	else //only restore power when idle 
		ZombiePlayerPawn(Pawn).RestorePower(20*deltaTime);
  }

	ZombiePlayerPawn(Pawn).SaveInputStrength(InputStrength);

	
}

state PlayerWalking
{
	/** Called when the controller first enters this state.  This means we need
	 *  to initialize any action that will set the player up for mounting.  This
	 *  could be jumping...*/
	event BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);		

		// Reset the pawn state From injury

		if (ZombiePlayerPawn(Pawn).IsInjuried())
		{
			ZombiePlayerPawn(Pawn).SetInjuryState(true);
		}

		else
		{
			ZombiePlayerPawn(Pawn).SetInjuryState(false);
		}

	}

	/** Called when the controller leaves this state for another */
	event EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);
	};
	
	/** Called to determine the acceleration and rotation based
	 *  on the input.  In this implementation, we want to leverage
	 *  the joy stick's analog capabilities */
	function PlayerMove(float rDeltaTime)
	{
		local vector			X,Y,Z, NewAccel;
		local eDoubleClickDir	DoubleClickMove;
		local rotator			OldRotation;
		local Rotator lDesiredPawnRotation;
		local Rotator lRotationDelta;
        local Vector2D ZombieScrLoc;
		
		
		//local bool Blocked;
		//local bool GrabLedge;
		//local int lBlockedRayIndex;

		if (bCinematicMode || ( ZombiePlayerPawn(Pawn)!=none && ZombiePlayerPawn(Pawn).bPlayerIsDead))
		{
			return;
		}

		// ReceiveDamage is already being called in PlayerTick
		//ReceiveDamage();



		// Assume the desired rotation is exactly where the pawn is facing.
		lDesiredPawnRotation = Pawn.Rotation;

		if(bCanTurn)
		{
		// Set the yaw-rotation based on how hard the player
		//  pushes the joystick.  This allows us to rotate slower than normal 
		if (PlayerInput.RawJoyUp > 0.0)
		{
			lDesiredPawnRotation.Yaw = PlayerCamera.Rotation.Yaw + (8192 * PlayerInput.RawJoyRight);
		}
		else if (PlayerInput.RawJoyUp < 0.0)
		{
			lDesiredPawnRotation.Yaw = PlayerCamera.Rotation.Yaw + 32768 - (8192 * PlayerInput.RawJoyRight);
		}
		else if (PlayerInput.RawJoyUp == 0.0)
		{
			if (PlayerInput.RawJoyRight > 0.0)
			{
				lDesiredPawnRotation.Yaw = PlayerCamera.Rotation.Yaw + (16384);
			}
			else if (PlayerInput.RawJoyRight < 0.0)
			{
				lDesiredPawnRotation.Yaw = PlayerCamera.Rotation.Yaw - (16384);
			}
		}

		// If the pawn's rotation needs to change, do it within the rate
		// of change that's allowed.
		if (lDesiredPawnRotation != Pawn.Rotation)
		{
			lRotationDelta = lDesiredPawnRotation - Pawn.Rotation;
			//Ensure Rotation is Between 32767 and -32768
			while (lRotationDelta.Yaw > 32767.0f)
			{
				lRotationDelta.Yaw -= 65536.0f;
			}
			while (lRotationDelta.Yaw < -32768.0f)
			{
				lRotationDelta.Yaw += 65536.0f;
			}
			lDesiredPawnRotation = Pawn.Rotation + (lRotationDelta / 5.0f);
			Pawn.SetRotation(lDesiredPawnRotation);
		}
		}
		// If there is a pawn, process the movement
		if (Pawn != None)
		{
			// By default this is Pawn instead of PlayerCamera
			GetAxes(PlayerCamera.Rotation,X,Y,Z); 

			// Update acceleration.
			NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
			
			 if(abs(PlayerInput.aStrafe) >1.0 && abs(PlayerInput.aForward) <1.0) 
			 {
                //`log(PlayerCamera.PCOwner.PlayerInput.aForward);`log(PlayerCamera.PCOwner.PlayerInput.aStrafe);
				 ZBPlayerCamera(PlayerCamera).bStrafeMove=true;
			 }
			 else
				 ZBPlayerCamera(PlayerCamera).bStrafeMove=false;
			NewAccel.Z	= 0;

			 ZombieHud(myHud).InputAccel=VSize(NewAccel);

			 ProcessInputAccel(VSize(NewAccel),rDeltaTime,NewAccel);
			
			/*
			//Animation for Jumping In Place
			if (bPressedJump && NewAccel == vect(0.0f, 0.0f, 0.0f))
			{
				bPressedJump = false;
				ActivePawn.AnimationPlayerFullBody.PlayCustomAnim('Chris_inplacejump_plot', 1.0f, 0.1f, 0.1f, false, false);
				return;
			}
			//Do Not Move if We're Jumping In Place
			if (ActivePawn.AnimationPlayerFullBody.GetPlayedAnimation() == 'Chris_inplacejump_plot')
			{
				return;
			}
			*/

			// This line was removed to allow for analog movement
			//NewAccel = Pawn.AccelRate * Normal(NewAccel);

			DoubleClickMove = PlayerInput.CheckForDoubleClickMove(rDeltaTime / WorldInfo.TimeDilation);

			// Update rotation.
			OldRotation = Rotation;

			if(!bCameraFocusIsLocked && !bCameraIsTransitioning)
			{
				UpdateRotation(rDeltaTime);
			}

			bDoubleJump = false;

			// Debug only
			//Blocked = ActivePawn.IsAbleToGrabLedge(mTraversalForwardOffset, mTraversalForwardRange, 0, 50, 8);
			//DebugInfo.AddText("Grabbable:"$Blocked, 10);

			// If the player pressed jump, we need to see if they are actually
			// trying to mount an obstacle.  This would be the start state to climbing.
	//		DebugInfo.AddText(bPressedJump$" "$ActivePawn$" "$PlayerInput.RawJoyUp$" "$PlayerInput.RawJoyRight, 4);

		

			// Actually process the movement that is occuring (this will occur in any
			// state that is current)
		
			
			ProcessMove(rDeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		    
			if(ZombiePlayerPawn(Pawn).WeaponType == 2){
			AvailableShootZombie = CheckAvaliableTarget();
			if(AvailableShootZombie!=none)
			{
				if(LastAvailableShootZombie != AvailableShootZombie)
				   LastAvailableShootZombie = AvailableShootZombie;
				ZombieScrLoc = LocalPlayer(Player).Project(AvailableShootZombie.location);
				ZombieHud(myHud).ShowFireTargetHint(ZombieScrLoc);
			}
			else
                ZombieHud(myHud).HideFireTargetHint();
			}

		}
		// Since there is no pawn, assume that the controller
		// pawn is dead and move to that state
		else
		{
			GotoState('Dead');
		}

		// Remove the current jumping flag
		bPressedJump = false;
	};

	/** Now that we know how the player should move, we need to make it
	 *  happen.  Here, we apply the movement information to the pawn */
/*	function ProcessMove(float rDeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		

		// If there is no pawn, there is nothing to do
		if( Pawn == None ) { return; }

		// Check if the player is pressing the "traversal action" button (jump)
		if (bPressedJump)
		{
			CheckJumpOrDuck();
		}

		// Process the actual pawn movement based on it's current
		// physics state.  This will determine how the pawn moves.
		if (Pawn.Physics == PHYS_Walking)
		{
			Pawn.Velocity.X = NewAccel.X;
			Pawn.Velocity.Y = NewAccel.Y;

			//DeadZone 100 Stopping - To Stop Unwanted Motion
			if (Pawn.Velocity.X > -100 && Pawn.Velocity.X < 100) { Pawn.Velocity.X /= 2; Pawn.Acceleration.X = 0; };
			if (Pawn.Velocity.Y > -100 && Pawn.Velocity.Y < 100) { Pawn.Velocity.Y /= 2; Pawn.Acceleration.Y = 0; };
		}
		else if (Pawn.Physics == PHYS_Falling)
		{
			Pawn.Acceleration = Pawn.AccelRate * Normal(NewAccel);

			//DeadZone 100 Stopping - To Stop Unwanted Motion
	//		if (Pawn.Velocity.X > -100 && Pawn.Velocity.X < 100) {Pawn.Velocity.X /= 2; Pawn.Acceleration.X = 0;};
	//		if (Pawn.Velocity.Y > -100 && Pawn.Velocity.Y < 100) {Pawn.Velocity.Y /= 2; Pawn.Acceleration.Y = 0;}; 
		}
		else
		{
			// This way, we get back to the behaviour of the default implementation
			Pawn.Acceleration = Pawn.AccelRate * Normal(NewAccel);
		}

	}*/
}

state PlayerAttacking
{
	function ProcessInputAccel(float InputStrength,float deltatime, out Vector InputAccel)
	{
	}
	function UpdateRotation(float deltatime)
	{
		
	}
	/*
	function PlayerTick(float rDeltaTime)
	{
	}*/

	exec function StartFire( optional byte FireModeNum )
{
	/*
	if (ZombiePlayerPawn(Pawn).PlayerPower<=0||ZombiePlayerPawn(Pawn).IsDoingSpecialMove(SM_Player_Exhausted)){
		return;
	}
     heidi
      if(FireModeNum==1 || FireModeNum==2)
	      ApplyAdhesion();
		  
         ApplyAdhesion();
	  if(!ZombiePlayerPawn(Pawn).IsDoingSpecialMove(SM_Combat_GetHurt)&&Pawn.physics!=PHYS_Falling)
		  super.StartFire(FireModeNum);
	  else if (ZombiePlayerPawn(Pawn).IsDoingSpecialMove(SM_PHYS_Trans_Jump))
	  {
		  super.StartFire(2);
	  }*/
}
}

state PlayerExhausting
{
	event BeginState(name pre)
	{
     //  Pawn.zeromovementvariables();
	  // Pawn.GroundSpeed=0;
	   Pawn.setphysics(PHYS_Custom);
	}
	event EndState(name next)
	{
		//  Pawn.zeromovementvariables();
		// Pawn.GroundSpeed=0;
		Pawn.setphysics(PHYS_Walking);
	}
	function ProcessInputAccel(float InputStrength,float deltatime, out Vector InputAccel)
	{
		
	}
	function PlayerTick(float rDeltaTime)
	{
		ZombiePlayerPawn(Pawn).RestorePower(20*rDeltaTime);
	}
}
function TapActionButton()
{

}

function CaptureActTimeEnd()
{

}
function TakeCaptureExDamage()
{
}
state EatByZombie
{
begin:
   HurtByZombieEat();
};
state CaptureByZombie
{
	exec function StartFire( optional byte FireModeNum ){}
	event BeginState(Name PreviousStateName)
	{
		local Vector OrientDir;
		Pawn.ZeroMovementVariables();
		bSwipeCapturePlayer = true;
		SwipeCounter = 0;

    ZombiePlayerPawn(Pawn).CustomTakeDamage(10);
		OrientDir = InteractZombie.location-Pawn.location;
    OrientDir.z = 0;
		if (ZombiePlayerPawn(Pawn).GetCustomHealth()<=0)
		{
			ZombiePlayerPawn(Pawn).InitPosEatByZombie(rotator(OrientDir),InteractZombie);
			CaptureActTimeEnd();
		}
    else
    {
      ZombiePlayerPawn(Pawn).HurtByZombie(rotator(OrientDir),InteractZombie);
    }


		ZombieHud(myhud).SetActionFunction(TapActionButton);


		SetTimer(5.0,false,'CaptureActTimeEnd');

		SetTimer(3.0,false,'TakeCaptureExDamage');
	}

	event EndState(Name NextStateName)
	{
		Pawn.ZeroMovementVariables();
		bSwipeCapturePlayer = true;
		SwipeCounter = 0;

		ZombieHud(myhud).RestoreActionFunction();

		
	}

	function TakeCaptureExDamage()
	{
		ZombiePlayerPawn(Pawn).CustomTakeDamage(40);

		clearTimer('TakeCaptureExDamage');

		if (ZombiePlayerPawn(Pawn).GetCustomHealth()<=0)
		{
			CaptureActTimeEnd();
		}
	}

	function CaptureActTimeEnd()
	{
	   clearTimer('CaptureActTimeEnd');
       gotoState('EatByZombie');   
	}

	function TapActionButton()
	{
		SwipeCounter += 1;

		if (SwipeCounter>=TargetSwipeNum)
		{
			clearTimer('CaptureActTimeEnd');
			clearTimer('TakeCaptureExDamage');
			HurtByZombieCinematicPreRecover();
		}
	}
	function InternalOnInputTouch(int Handle, ETouchType Type, Vector2D TouchLocation, float DeviceTimestamp, int TouchpadIndex)
	{
		 local Actor PickedActor;
			local STouchEvent TouchEvent;
			local int Index;


			ZombieHud(myHud).HudCheckTouchEvent_CaptureByZombie(Handle,Type,TouchLocation,ViewportSize);


			//LocalPlayer(Player).ViewportClient.GetViewportSize(ViewportSize);
			// Handle new touch events
			if (Type == Touch_Began)
		{
				// Ensure that this is a new touch event
				if (TouchEvents.Find('Handle', Handle) != INDEX_NONE)
				{
					return;
				}

				// Setup the touch event
				TouchEvent.Handle = Handle;
				TouchEvent.ScreenLocation = TouchLocation;
				TouchEvent.TouchBeginLocation = TouchLocation;
				TouchEvent.LastTouchTime = worldinfo.timeseconds;
				TouchEvent.HasBeenProcessed = false;

				// Add the touch event to the TouchEvents array
				TouchEvents.AddItem(TouchEvent);
			}
			else if (Type == Touch_Moved)
			{
				Index = TouchEvents.Find('Handle', Handle);
				if (Index == INDEX_NONE)
				{
					return;
				}

				if ((worldinfo.timeseconds - TouchEvents[Index].LastTouchTime) > CheckSwipeInterval)
				{
					PickedActor = PickActor(TouchLocation);

					if (ZBAIPawnBase(PickedActor)==none)
					{
						bSwipeCapturePlayer = true;
					}
					TouchEvents[Index].SwipeVelocity = CustomVSize2D(TouchLocation,TouchEvents[Index].ScreenLocation)/(worldinfo.timeseconds - TouchEvents[Index].LastTouchTime);

					// Update the screen location
					TouchEvents[Index].ScreenLocation = TouchLocation;
					TouchEvents[Index].LastTouchTime = worldinfo.timeseconds;
					TouchEvents[Index].HasBeenProcessed = false;

					TouchEvents[Index].swipedistance = CustomVSize2D(TouchLocation,TouchEvents[Index].TouchBeginLocation);


					if (TouchEvents[Index].swipedistance>SwipeTolerance )
					{
						// ClientMessage("time stamp"@DeviceTimestamp);
						//ClientMessage("swipe velocity"@ TouchEvents[Index].SwipeVelocity);
						if(TouchEvents[Index].SwipeVelocity > SwipeVelocityTolerance)
						{
							
							if (ZBAIPawnBase(PickedActor)!=none&&bSwipeCapturePlayer&&ZBAIPawnBase(PickedActor)==InteractZombie)
							{
								bSwipeCapturePlayer = false;
								//ClientMessage("check swipe success!"@"swipe velocity"@ TouchEvents[Index].SwipeVelocity@ PickedActor);
								SwipeCounter += 1;

								if (SwipeCounter>=TargetSwipeNum)
								{
								   HurtByZombieCinematicPreRecover();
								}
							}
							

						}
					}
					
					
				}
			}
			// Handle existing touch events
			else if (Type == Touch_Ended || Type == Touch_Cancelled)
			{			
				Index = TouchEvents.Find('Handle', Handle);
				if (Index == INDEX_NONE)
				{
					return;
				}


				//	ClientMessage("ZombiePC.TouchEvents"@TouchLocation.x@TouchLocation.y);
				// Remove the touch event from the TouchEvents array
				TouchEvents.Remove(Index, 1);
			}
		}
};
/**
exec function

*/

/** Enables the action (over-the-shoulder) camera */
exec function ToggleActionCamera()
{
	// No need to set the camera if we're already using the right onw
	if (ZBPlayerCamera(PlayerCamera).CurrentCameraType.Class.Name == 'ZBCameraTypeShoulder') { return; }

		mActionCameraMode = true;
		//NXPlayerPawn(Pawn).SetAnimTargeting(true);
		ZBPlayerCamera(PlayerCamera).ChangeCameraType("ZGame.ZBCameraTypeShoulder");
}



exec function SwitchCameraMode()
{
/*
	if(ZBPlayerCamera(PlayerCamera).CurrentCameraType.Class == class 'ZBCameraTypeFree')

		ZBPlayerCamera(PlayerCamera).ChangeCameraType("ZGame.ZBCameraTypeShoulder");

	else if(ZBPlayerCamera(PlayerCamera).CurrentCameraType.Class == class 'ZBCameraTypeShoulder')

			ZBPlayerCamera(PlayerCamera).ChangeCameraType("ZGame.ZBCameraTypeFree");*/

}

exec function CommitMeleeAttack()
{
	ClientSetWeapon(class'ZBWeaponForce');	
}


/* ClientSetWeapon:
	Forces client to switch to this weapon if it can be found in loadout
*/
reliable client function ClientSetWeapon( class<Weapon> WeaponClass )
{
    local Inventory Inv;

	if ( Pawn == None )
		return;

	Inv = Pawn.FindInventoryType( WeaponClass );
	if ( Weapon(Inv) != None )
		Pawn.SetActiveWeapon( Weapon(Inv) );
}


exec function NextWeapon()
{
	super.NextWeapon();
}

function MeleeAutoFire(optional byte FireModeNum)
{
	super.StartFire(FireModeNum);
	ApplyAdhesion();
}
exec function StartFire( optional byte FireModeNum )
{
    //when PlayerPower<=0 can`t fire
	/*
	if (ZombiePlayerPawn(Pawn).PlayerPower<=0||ZombiePlayerPawn(Pawn).IsDoingSpecialMove(SM_Player_Exhausted)){
		return;
	}*/


	 if (ZombiePlayerPawn(Pawn).IsDoingSpecialMove(SM_PushCase))
		 return;
     /*heidi
      if(FireModeNum==1 || FireModeNum==2)
	      ApplyAdhesion();
		  */
         
	if(!ZombiePlayerPawn(Pawn).IsDoingSpecialMove(SM_Combat_GetHurt)&&Pawn.physics!=PHYS_Falling){
		  super.StartFire(FireModeNum);
		  ApplyAdhesion();
	}
	  else if (ZombiePlayerPawn(Pawn).IsDoingSpecialMove(SM_PHYS_Trans_Jump))
	  {
		 // super.StartFire(2);
	  }
}


function ZombiePawn ()
{
	
}

/**Melee attack relative
*/


simulated function ZombiePawn AttemptMeleeAdhesion()
{
	local ZombiePawn ZP;

	local ZombiePawn TestZP;
	local Vector ToTestWPNorm;
	local float ToTestWPDist;
	local ZombiePawn BestTarget;
	local float BestTargetScore;
	local float DotToTarget;
	local float DistScore;
	local float DirScore;
	local float TotalScore;
	local float SearchRadius;
    local float CheckRadius;

	ZP = ZombiePawn(Pawn);
	SearchRadius = ZP.GetMeleeAttackRange();
	BestTargetScore = -99999;
	BestTarget = None;

	foreach ZP.CollidingActors(Class'ZombiePawn', TestZP, ZBWeaponForce(Pawn.Weapon).CheckRadius)
	{
		if (ZP.IsValidMeleeTarget(TestZP)
			&&!ZP.IsDoingSpecialMove(SM_Combat_GetHurt))
		{
			ToTestWPNorm = TestZP.Location - ZP.Location;
			ToTestWPDist = VSize(TestZP.Location - ZP.Location);
			ToTestWPNorm /= ToTestWPDist;
			DistScore = SearchRadius - ToTestWPDist;
			DotToTarget = ToTestWPNorm Dot Vector(ZP.Rotation);/*
			if (DotToTarget < MinMeleeAdhesionDotValue)
			{
				continue;
			}*/

			DirScore = DotToTarget * SearchRadius;
			TotalScore = DirScore + DistScore;
			if (TotalScore > BestTargetScore)
			{
				BestTarget = TestZP;
				BestTargetScore = TotalScore;
			}
		}
	}

	return BestTarget;

}

simulated function StopMeleeAdhesion()
{
	StopForcedAdhesion();
}

simulated function ForceAdhesionTo(ZombiePawn P)
{
	ForcedAdhesionTarget = P;
}

simulated function StopForcedAdhesion()
{
	ForcedAdhesionTarget = None;
}


//fire Projectile
function ZBAIPawnBase CheckAvaliableTarget()
{
		local ZombiePawn ZP;

	local ZombiePawn TestZP;
	local Vector ToTestWPNorm;
	local float ToTestWPDist;
	local ZombiePawn BestTarget;
	local float BestTargetScore;
	local float DotToTarget;
	local float DistScore;
	local float DirScore;
	local float TotalScore;
	local float SearchRadius;

	local vector cameraLoc;
	local rotator cameraRot;
    local float DotToCamera;
	ZP = ZombiePawn(Pawn);
	SearchRadius = ZP.GetMeleeAttackRange();
	BestTargetScore = -99999;
	BestTarget = None;

	GetPlayerViewPoint(cameraLoc, cameraRot);

	foreach ZP.CollidingActors(Class'ZombiePawn', TestZP, 2000)
	{
		if (ZP.IsValidMeleeTarget(TestZP)
			&&!ZP.IsDoingSpecialMove(SM_Combat_GetHurt))
		{
			DotToCamera = (TestZP.location-cameraLoc) dot Vector(cameraRot);
			// returns true if did not hit world geometry
			if(!FastTrace(TestZP.location,ZP.location)||DotToCamera<0)
				continue;

			ToTestWPNorm = TestZP.Location - ZP.Location;
			ToTestWPDist = VSize(TestZP.Location - ZP.Location);
			ToTestWPNorm /= ToTestWPDist;
			DistScore = SearchRadius - ToTestWPDist;
			DotToTarget = ToTestWPNorm Dot Vector(ZP.Rotation);
			if (DotToTarget < 0.8)
			{
				continue;
			}
          //mainly consider dir score
			DirScore = 10*DotToTarget * SearchRadius;
			TotalScore = DirScore + DistScore;
			if (TotalScore > BestTargetScore)
			{
				BestTarget = TestZP;
				BestTargetScore = TotalScore;
			}
		}
	}

	return ZBAIPawnBase(BestTarget);
}




//UI Relax


/**
	 * Called when the game receives a touch event from the touch pad
	 *
	 * @param		Handle					Touch handle
	 * @param		Type					Touch type
	 * @param		TouchLocation			Screen space coordinates where the touch occured on the touch pad
	 * @param		DeviceTimestamp			When the touch event occured according to the device
	 * @param		TouchpadIndex			Which touch pad was touched
	 * @network								Local client
	 */
function InternalOnInputTouch(int Handle, ETouchType Type, Vector2D TouchLocation, float DeviceTimestamp, int TouchpadIndex)
{
		local STouchEvent TouchEvent;
		local int Index;
        local Actor PickedActor;

		ZombieHud(myHud).HudCheckTouchEvent(Handle,Type,TouchLocation,ViewportSize);


		//LocalPlayer(Player).ViewportClient.GetViewportSize(ViewportSize);
		// Handle new touch events
		if (Type == Touch_Began)
		{
			// Ensure that this is a new touch event
			if (TouchEvents.Find('Handle', Handle) != INDEX_NONE)
			{
				return;
			}

			// Setup the touch event
			TouchEvent.Handle = Handle;
			TouchEvent.ScreenLocation = TouchLocation;
			TouchEvent.TouchBeginLocation = TouchLocation;
			TouchEvent.LastTouchTime = worldinfo.timeseconds;
			TouchEvent.HasBeenProcessed = false;
            
			// Add the touch event to the TouchEvents array
			TouchEvents.AddItem(TouchEvent);

			PickedActor = PickActor(TouchLocation);
			if (ITouchable(PickedActor)!=none)
			{
				ITouchable(PickedActor).OnTouch();
			}
			//Check Zoom
			if (TouchEvents.length==2)
			{
				ZBPlayerCamera(PlayerCamera).RecordZoomStartDistance();
				TwoFingerOldDistance = CustomVSize2D(TouchEvents[0].TouchBeginLocation,TouchEvents[1].TouchBeginLocation);
			}



		}
		else if (Type == Touch_Moved)
		{
			Index = TouchEvents.Find('Handle', Handle);
			if (Index == INDEX_NONE)
			{
				return;
			}

			if ((worldinfo.timeseconds - TouchEvents[Index].LastTouchTime) > FingerMoveSampleInterval)
			{
			// Update the screen location
				TouchEvents[Index].ScreenLocation = TouchLocation;
				TouchEvents[Index].LastTouchTime = worldinfo.timeseconds;
				TouchEvents[Index].HasBeenProcessed = false;
	
				TouchEvents[Index].swipedistance = CustomVSize2D(TouchLocation,TouchEvents[Index].TouchBeginLocation);


			

				///zoom cam
				if (Index==2)
				{
					TwoFingerSampleDistance = CustomVSize2D(TouchEvents[0].ScreenLocation,TouchEvents[1].ScreenLocation);
					ZoomScale = TwoFingerSampleDistance / TwoFingerOldDistance;
					ZBPlayerCamera(PlayerCamera).MobileZoom(ZoomScale);
				}
			}	
			
		}
		// Handle existing touch events
		else if (Type == Touch_Ended || Type == Touch_Cancelled)
		{			
			Index = TouchEvents.Find('Handle', Handle);
			if (Index == INDEX_NONE)
			{
				return;
			}

			
		//	ClientMessage("ZombiePC.TouchEvents"@TouchLocation.x@TouchLocation.y);
			// Remove the touch event from the TouchEvents array
			TouchEvents.Remove(Index, 1);
		}
}


function SetDashSpeed(bool bDash,optional bool bInjuryPawn)
{
	if (bInjuryPawn)
	{
	//	Pawn.GroundSpeed = 400;        //8m/s
		Pawn.GroundSpeed = 245;        //4.8m/s
		return;
	}
	
     if (bDash&&ZombiePlayerPawn(Pawn).GetPower()>0)
     {
		// Pawn.GroundSpeed = 1050;       //20m/s
		  Pawn.GroundSpeed = 525;		//10 m/s
     }
	 else if(ZombiePlayerPawn(Pawn).GetPower()>0)
		// Pawn.GroundSpeed = 525;		//10 m/s
	     Pawn.GroundSpeed = 325;		//6 m/s
	 else   // only can walk
		 Pawn.GroundSpeed = 160;   //3m/s
}
 
function CustomJump()
{
    //自定义jump
	//ZombiePlayerPawn(Pawn).DoCustomJump();

	 //默认的jump
	if (!ZombiePlayerPawn(Pawn).IsDoingASpecialMove())
	{
		ZombiePlayerPawn(Pawn).DoJump(true);
	}
	
}

//function SetCinematicMode( bool bInCinematicMode, bool bHidePlayer, bool bAffectsHUD, bool bAffectsMovement, bool bAffectsTurning, bool bAffectsButtons )
//function SetCollision( optional bool bNewColActors, optional bool bNewBlockActors, optional bool bNewIgnoreEncroachers );
// primitiveComponent :
//native final function SetActorCollision(bool NewCollideActors, bool NewBlockActors, optional bool NewAlwaysCheckCollision);

// for cinematic action
function HurtByZombieCinematic(ZBAIPawnBase zombie)
{
	  InteractZombie = zombie;
    SetCinematicMode(true,false,false,true,false,true);  
    gotoState('CaptureByZombie',,true); 
}

// do correspond special move ,just play push success animation...:)
function HurtByZombieCinematicPreRecover()
{
	InteractZombie.PrePushedByPlayer();
	ZombiePlayerPawn(Pawn).PushZombie();
}
function HurtByZombieCinematicRecover()
{
    ZombiePlayerPawn(Pawn).HurtByZombieRecover();
    SetCinematicMode(false,false,false,true,false,true);

	//cancel reference to zombie when push zombie ,save it for recover its state in
	//HurtByZombieZombieRecover()
	//LastInteractZombie = InteractZombie;
	InteractZombie = none; 

	gotoState('PlayerWalking');
}

/*
function HurtByZombieZombieRecover()
{
	LastInteractZombie.PushedByPlayer();   //先处理 zombie 状态恢复 再处理playerpawn

	//InteractZombie = none;             //取消zombie引用
}
*/

function HurtByZombieEat()
{
	InteractZombie.EatPlayer();
	ZombiePlayerPawn(Pawn).EatedByZombie();
}

//Weapon Action Function

function SetActionTapFunction_Axe()
{
	//wait for myhud instance during GameInit
	if (myhud==none)
	{
		SetTimer(0.1,false,'SetActionTapFunction_Axe');
	}
     else
	 ZombieHud(myhud).SetActionFunction(TapActionButton_Axe);
}

function TapActionButton_Axe()
{
	StartFire(1);
}
function SetActionTapFunction_Gun()
{
	//wait for myhud instance during GameInit
	if (myhud==none)
	{
		SetTimer(0.1,false,'SetActionTapFunction_Axe');
	}
	else
		ZombieHud(myhud).SetActionFunction(TapActionButton_Gun);
}

function TapActionButton_Gun()
{
	StartFire(0);
}

function RestoreActionTapFunction()
{
    ZombieHud(myhud).RestoreActionFunction();
}

//MISC FUNCTION 
function float CustomVSize2D(vector2d a, vector2d b)
{
	local vector aa,bb;
	aa.x = a.x;
 	aa.y = a.y;

	bb.x = b.x;
	bb.y = b.y;
	return vsize(aa-bb);
}

function Actor PickActorWithExtent(Vector2D PickLocation, Vector Extent)
{
	local Vector TouchOrigin, TouchDir;
	local Vector HitLocation, HitNormal;
	local Actor PickedActor;

	PickLocation.X = PickLocation.X / ViewportSize.X;
	PickLocation.Y = PickLocation.Y / ViewportSize.Y;
	LocalPlayer(Player).Deproject(PickLocation, TouchOrigin, TouchDir);
	PickedActor = Trace(HitLocation, HitNormal, TouchOrigin + (TouchDir * PickDistance), TouchOrigin, true,Extent);
	return PickedActor;
}
function Actor PickActor(Vector2D PickLocation)
{
	local Vector TouchOrigin, TouchDir;
	local Vector HitLocation, HitNormal;
	local Actor PickedActor;

	//Transform absolute screen coordinates to relative coordinates
	PickLocation.X = PickLocation.X / ViewportSize.X;
	PickLocation.Y = PickLocation.Y / ViewportSize.Y;

	//Transform to world coordinates to get pick ray
	LocalPlayer(Player).Deproject(PickLocation, TouchOrigin, TouchDir);

	//Perform trace to find touched actor
	PickedActor = Trace(HitLocation, HitNormal, TouchOrigin + (TouchDir * PickDistance), TouchOrigin, true,,,TRACEFLAG_Bullet);

	//Casting to ITouchable determines if the touched actor can indeed be touched
//	if(ZombiePlayerPawn(PickedActor) != none)
//	{
		//Call the OnTouch() function on the touched actor
		//Itouchable(PickedActor).OnTouch(ZoneEvent_Touch, PickLocation.X, PickLocation.Y);

		return PickedActor;
//	}

	//Return the touched actor for good measure
	//return NONE;
}
exec function DebugOff ()
{
	// body...;
	GameDebug = false;
}
exec function DebugOn ()
{
	// body...;
	GameDebug = true;
}
exec function CheatOn ()
{
	// body...;
	bCheat = true;
}
exec function CheatOff ()
{
	// body...;
	bCheat = false;
}
DefaultProperties
{
	CameraClass=class'ZBPlayerCamera'

		InputClass=class'ZBPlayerInput'
		bCanMove=true
        bCanTurn=true

		MinMeleeAdhesionDotValue=0.1


		SwipeTolerance=5.0
		SwipeVelocityTolerance=50.0
		CheckSwipeInterval=0.01


		FingerMoveSampleInterval=0.01

		PickDistance=12000


		TargetSwipeNum=5

		ZoomScale=1.0
		NormalStateName=PlayerWalking
		GameDebug=false
}


/**
 * Trace a line and see what it collides with first.
 * Takes this actor's collision properties into account.
 * Returns first hit actor, Level if hit level, or None if hit nothing.
 */
/*
native(277) noexport final function Actor Trace
(
	out vector					HitLocation,
	out vector					HitNormal,
	vector						TraceEnd,
	optional vector				TraceStart,
	optional bool				bTraceActors,
	optional vector				Extent,
	optional out TraceHitInfo	HitInfo,
	optional int				ExtraTraceFlags
);*/


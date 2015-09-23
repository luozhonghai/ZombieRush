class ZombieParkourPC extends ZombieRushPC;

// Body...

enum EParkourMoveType
{
	EPM_Normal,
	EPM_StrafeLeft,
	EPM_StrafeRight,
	EPM_TurnLeft,
	EPM_TurnRight,
};



var(ZombieParkourPC) bool bCanParkourTurn;
var(ZombieParkourPC) float SlidePitch;
var float InputJoyUp;
var float InputJoyRight;
var Vector InputJoyVectorProjectToWorld;


//delegate OnSpecialMoveEnd();


/** Construct a vector2d variable */
static final function vector  vect3d( float InX, float InY, float InZ )
{
  local vector  NewVect;

  NewVect.X = InX;
  NewVect.Y = InY;
  NewVect.Z = InZ;
  return NewVect;
}

function LatentClimbBlockade(Vector ClimbPoint, Actor BlockadeActor, Vector ClimbDir)
{
  //should clear move speed
  OnFingerSlideEnd(0);
  super.LatentClimbBlockade(ClimbPoint, BlockadeActor,ClimbDir );
}

state PlayerRush
{
	event BeginState(name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
	}

  event EndState(Name NextStateName)
  {
    super.EndState(NextStateName);
    OnFingerSlideEnd(0);
  }

  event bool IsCheckTouchEvent(int Handle, ETouchType Type, Vector2D TouchLocation, float DeviceTimestamp, int TouchpadIndex)
  {
      //super call
        if(ZombieRushPawn(Pawn).IsDoingASpecialMove() && !ZombieRushPawn(Pawn).IsDoingSpecialMove(SM_PushCase))
           // comment this for push case can be interrupt by input 
           // || !bReceiveInput) 
        {
              //clear slide date
              OnFingerSlideEnd(0);
              return false;
        }
        if( ZombieHud(myHUD).HudCheckTouchEvent(Handle,Type,TouchLocation,ViewportSize))
            return false;

        return true;
  }

    function PlayerMove(float DeltaTime)
    {
        local vector X,Y,Z, NewAccel;
        local rotator     OldRotation;
        local Rotator lDesiredPawnRotation;
        local Rotator lRotationDelta;
        local Rotator CameraRot;
        local float InputStrength;

        if(ZombieRushPawn(Pawn)!=none && ZombieRushPawn(Pawn).bCaptureCase)
        {
            return;
        }

        
        if(ZombieRushPawn(Pawn)!=none && ZombieRushPawn(Pawn).bHitWall)
        {
         // stop when stay on front of blocade/wall, and unable jump forward
`if(`isdefined(debug))
            if(ZombieRushPawn(Pawn).bIsJumping)
            {
                ClientMessage("cant Jump forward when hit wall");
            }
`endif          
          //  Pawn.Acceleration = vect(0,0,0);
         // restore power when blocked(2/s)
            ZombieRushPawn(Pawn).RestorePower(2 * DeltaTime);
            Pawn.Acceleration = vect(0,0,0);
            bPressedJump =false;
            return;
        }
        
        // consume power when run
        if(VSize(Pawn.Velocity) > 10)
           ZombieRushPawn(Pawn).ConsumePower(1.67 * DeltaTime);

        
        
        // Set the yaw-rotation based on how hard the player
        //  pushes the joystick.  This allows us to rotate slower than normal 
        /*
        if (InputJoyUp > 0.0)
        {
          lDesiredPawnRotation.Yaw = PlayerCamera.Rotation.Yaw + (8192 * InputJoyRight);
        }
        else if (InputJoyUp < 0.0)
        {
          lDesiredPawnRotation.Yaw = PlayerCamera.Rotation.Yaw + 32768 - (8192 * InputJoyRight);
        }
        else if (InputJoyUp == 0.0)
        {
          if (InputJoyRight > 0.0)
          {
            lDesiredPawnRotation.Yaw = PlayerCamera.Rotation.Yaw + (16384);
          }
          else if (InputJoyRight < 0.0)
          {
            lDesiredPawnRotation.Yaw = PlayerCamera.Rotation.Yaw - (16384);
          }
        }*/

        if (InputJoyUp != 0.0 || InputJoyRight != 0.0)
        {
          CameraRot = PlayerCamera.Rotation;
          CameraRot.Pitch = 0;
          GetAxes(CameraRot,X,Y,Z); 
          lDesiredPawnRotation = rotator(X*InputJoyUp + Y*InputJoyRight);
        }
        else
        {
          lDesiredPawnRotation = Pawn.Rotation;
        }

        //Pawn.SetRotation(lDesiredPawnRotation);
        
        //=========================================
        // Process pawn rotation
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
          //ClientMessage("lDesiredPawnRotation"@lDesiredPawnRotation.yaw);
          Pawn.SetRotation(lDesiredPawnRotation);
        }

        // set ground speed
        if(!ZombieRushPawn(Pawn).bIsJumping)
        {
            SetDashSpeed(true); 

            GetAxes(PlayerCamera.Rotation,X,Y,Z); 
            
            // Update acceleration.
            NewAccel = InputJoyUp*X + InputJoyRight*Y;
            NewAccel.Z  = 0;
            InputStrength = VSize(NewAccel);
            InputStrength = FClamp(InputStrength/200, 0, 1);
              
            if(ZombieRushPawn(Pawn).PlayerPower>0) {
              Pawn.Acceleration = 512 * Normal(NewAccel) * InputStrength;
            }
            else
              PlayerExhausted();    
        }
        else if(!ZombieRushPawn(Pawn).bIsLanding)
        {
           // Pawn.Velocity.X = ForwardVel * RushDir.x;
           // Pawn.Velocity.Y = ForwardVel * RushDir.y;
        }
        else
        {
            Pawn.Velocity.X = 0;
            Pawn.Velocity.Y = 0;
          //  Pawn.Velocity.X = ForwardVel * RushDir.x;
         //   Pawn.Velocity.Y = ForwardVel * RushDir.y;
        } 

        //UpdateRotation( deltaTime );


        if (bPressedJump)
        {
          CheckJumpOrDuck();
        }

        // Remove the current jumping flag
        bPressedJump =false;

    }
    event OnFingerSwipe(ESwipeDirection SwipeDirection, float SwipeDistance, int TouchIndex)
    {
        global.OnFingerSwipe(SwipeDirection, SwipeDistance, TouchIndex);
        if(TouchIndex == 0)
          return;
        switch (SwipeDirection)
        {
            case ESD_Right:
                if(!bCanParkourTurn)
                {
                    ParkourMove(EPM_StrafeRight, SwipeDistance);
                }
                else
                {
                    // ReCalcOrientVector();
                    // OrientIndex = 0;
                    // RushDir = OrientVect[OrientIndex];
                    // DominentRushRot = Rotator(RushDir);
                    // ZBCameraTypeRushFix(ZBPlayerCamera(PlayerCamera).CurrentCameraType).TurnFollowParkour(1, RushDir); 
                    // ParkourMove(EPM_TurnRight);
                }
                break;
        
            case ESD_Left:
                if(!bCanParkourTurn)
                {
                    ParkourMove(EPM_StrafeLeft, SwipeDistance);
                }
                else
                {
                    // ReCalcOrientVector();
                    // OrientIndex = 2;
                    // RushDir = OrientVect[OrientIndex];
                    // DominentRushRot = Rotator(RushDir);
                    // ZBCameraTypeRushFix(ZBPlayerCamera(PlayerCamera).CurrentCameraType).TurnFollowParkour(-1, RushDir); 
                    // ParkourMove(EPM_TurnLeft);
                }
                break;
                
            case ESD_Up: //jump
                if(!ZombieRushPawn(Pawn).IsDoingASpecialMove())
                {
                    if (ZombieRushPawn(Pawn).bHitWall)
                    {
                        ZombieRushPawn(Pawn).bHitWall = false;
                        if (TryClimb())
                        {
                            return;
                        }
                    }
                    else
                    {
                        CustomJump();
                    }    
                }
                return;

            case ESD_Down: //stop
               // ZombieRushPawn(Pawn).bHitWall = true;
               // Pawn.SetRotation(Rotator(RushDir));
              //  SetRotation(Pawn.rotation);
                return;
            default:
                
        }
        // auto move foward after jump strafe
        //ZombieRushPawn(Pawn).bHitWall = false;
    }

    event OnFingerSlide(Vector2D value, int Index)
    {
      local Vector value_bias;
      local vector X,Y,Z;
      super.OnFingerSlide(value, Index);

      if (Index != 0)
      {
        return;
      }
      value_bias.x = value.x;
      value_bias.y = value.y;
      value_bias = Normal(value_bias);
      //InputJoyUp =  FClamp(value.Y / 10, -1, 1);
      //InputJoyRight = FClamp(value.X / 10, -1, 1);
      InputJoyRight = value_bias.x;
      InputJoyUp = value_bias.y;

      GetAxes(PlayerCamera.Rotation,X,Y,Z); 
      InputJoyVectorProjectToWorld = X*InputJoyUp + Y*InputJoyRight;
      ZombieRushPawn(Pawn).bHitWall = false;

      //ClientMessage("OnFingerSlide"@InputJoyRight@InputJoyUp);
    }

    event OnFingerSlideEnd(int Index)
    {
       if (Index != 0)
       {  
         return;
       }
       InputJoyUp = 0;
       InputJoyRight = 0;
       InputJoyVectorProjectToWorld = vect(0,0,0);
       //ZombieRushPawn(Pawn).bHitWall = true;
    }

    exec function ParkourLeft ()
    {
      // body...;
      ParkourMove(EPM_StrafeLeft, 100);
    }

    exec function ParkourRight ()
    {
      // body...;
      ParkourMove(EPM_StrafeRight, 100);
    }
}

function CheckJumpOrDuck()
{
    if(!ZombieRushPawn(Pawn).IsDoingASpecialMove())
  {
      if (ZombieRushPawn(Pawn).bHitWall)
      {
          ZombieRushPawn(Pawn).bHitWall = false;
          if (TryClimb())
          {
              return;
          }
      }
      else
      {
          CustomJump();
      }    
  }
}
state PlayerParkourStop extends PlayerRush
{
    event BeginState(Name PreviousStateName)
    {
        Pawn.ZeroMovementVariables();
    }
    function PlayerMove( float DeltaTime )
    {
        if(ZombiePlayerPawn(Pawn).PlayerPower >= 60)
          GotoState('PlayerRush');

        ZombiePlayerPawn(Pawn).RestorePower(6 * DeltaTime);
    }
    function ParkourMove(EParkourMoveType NewMove, optional float SwipeDistance = 0.0)
    {

    }
}
state PlayerTurn
{
	event EndState(Name NextStateName)
    {
    	super.EndState(NextStateName);
    }
    // can only turn once in turn volume
 //    function InternalOnInputTouch(int Handle, ETouchType Type, Vector2D TouchLocation, float DeviceTimestamp, int TouchpadIndex)
	// {

	// }
}

state PlayerParkourMove extends PlayerRush
{
	event BeginState(name PreviousStateName)
	{
	}
	function PlayerMove( float DeltaTime )
	{
		ViewShake( deltaTime );
	}
  event OnFingerSwipe(ESwipeDirection SwipeDirection, float SwipeDistance, int TouchIndex)
  {
  }
  exec function ParkourLeft ()
  {
  }
  exec function ParkourRight ()
  {
  }
}

state PlayerGrabRopeMove extends PlayerRush
{
  event BeginState(name PreviousStateName)
  {
  }

  event bool IsCheckTouchEvent(int Handle, ETouchType Type, Vector2D TouchLocation, float DeviceTimestamp, int TouchpadIndex)
  {
    return true;
  }

   function PlayerMove(float DeltaTime)
  {
    ZombieParkourPawn(Pawn).DoShakeRope(1000 * InputJoyVectorProjectToWorld);
    ViewShake( deltaTime );
  }

  event OnFingerSwipe(ESwipeDirection SwipeDirection, float SwipeDistance, int TouchIndex)
  {
    global.OnFingerSwipe(SwipeDirection, SwipeDistance, TouchIndex);
    if(TouchIndex == 0)
      return;
    switch (SwipeDirection)
    {
      case ESD_Up:
        // jump off rope
        ZombieParkourPawn(Pawn).EndSpecialMove();
      default:
    }
  }
}

state PlayerKnockingDown
{
	function PlayerMove( float DeltaTime )
	{
		ViewShake( deltaTime );
	}
}

function ParkourMove(EParkourMoveType NewMove, optional float SwipeDistance = 0.0)
{
    local float StrafeMagnitude;
	switch (NewMove)
	{
		case EPM_StrafeLeft:
            StrafeMagnitude = CalcStrafeMagnitude(SwipeDistance);
			ZombieParkourPawn(Pawn).DoParkourStrafeLeft(OnStrafeEnd, StrafeMagnitude);
			PushState('PlayerParkourMove');
			break;
	
		case EPM_StrafeRight:
            StrafeMagnitude = CalcStrafeMagnitude(SwipeDistance);
			ZombieParkourPawn(Pawn).DoParkourStrafeRight(OnStrafeEnd, StrafeMagnitude);
			PushState('PlayerParkourMove');
	        break;

	    case EPM_TurnLeft:
	    	GotoState('PlayerTurn','TurnLeft');

	    	break;

	    case EPM_TurnRight: 
	    	GotoState('PlayerTurn','TurnRight');

	    	break;

		default:
			
	}
}

function float CalcStrafeMagnitude(float SwipeDistance)
{
  //MinSwipeDistance=25 ZombieRushPC
  local float Result;
  Result = (SwipeDistance - 25) * 5;
  Result = FClamp(Result, 100, 600);
  return Result;
}

function OnStrafeEnd(ZBSpecialMove SpecialMoveObject)
{
	if(!IsInstate('CaptureByZombie') && !IsInstate('FallingHole') 
    && !IsInstate('TransLevel') && !IsInstate('EatByZombie'))
		//PopState('PlayerRush');
    PopState();
}

function ToggleTurn(bool bEnable)
{
  bCanParkourTurn = bEnable;
}

function TurnCamera(Vector NewDir)
{
  ZBCameraTypeRushFix(ZBPlayerCamera(PlayerCamera).CurrentCameraType).FollowParkour(NewDir); 
}
//called in ZombieParkourPawn as delegate
function OnKonckDownEnd(ZBSpecialMove SpecialMoveObject)
{
	ZombieParkourPawn(Pawn).DoParkourGetUp(OnGetUpEnd);
	GotoState('PlayerKnockingDown');
}
//called in ZombieParkourPawn as delegate
function OnHitByFallingWall(ZBSpecialMove SpecialMoveObject)
{
    ZombieRushGame(WorldInfo.Game).PawnDied();
}

function OnGetUpEnd(ZBSpecialMove SpecialMoveObject)
{
	GotoState('PlayerRush');
}

exec function ParkourLeft ()
{
  // body...;
  //ClientMessage("ParkourLeft");
}

exec function ParkourRight ()
{
  // body...;
  //ClientMessage("ParkourRight");
}




/*===============================================
//Notify from volume
*/
function OnEnterSlideVolume(ParkourSlideVolume volume)
{
  ZombieParkourPawn(Pawn).EnterSlide();
}

function OnExitSlideVolume(ParkourSlideVolume volume)
{
  ZombieParkourPawn(Pawn).ExitSlide();
}

/*===============================================
//Grab Rope
*/
function OnGrabRope()
{
  GotoState('PlayerGrabRopeMove');
}

//Todo: from input
function OnShakeRope(vector Strength)
{
  ZombieParkourPawn(Pawn).DoShakeRope(Strength);
}
function OnJumpOffRope(ZBSpecialMove SpecialMoveObject)
{
  GotoState('PlayerRush');
}

/* epic ===============================================
* ::NotifyHitWall
*
* Called when our pawn has collided with a blocking
* piece of world geometry, return true to prevent
* HitWall() notification on the pawn.
*
* =====================================================
*/
// event bool NotifyHitWall(vector HitNormal, actor Wall)
// {
// 	if(IsInState('FallingHole'))
// 	  return;
// 	//avoid endless hit wall loop
// 	if(ZombieRushPawn(Pawn).bHitWall)
// 	   return true;

// 	ZombieRushPawn(Pawn).bHitWall = true;
// 	ZombieParkourPawn(Pawn).DoParkourKnockDown(OnKonckDownEnd);
// 	return true;
// }


defaultproperties
{
    PlayerStopStateName=PlayerParkourStop

    SlidePitch=-30
}
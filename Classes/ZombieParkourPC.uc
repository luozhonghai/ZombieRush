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

delegate OnSpecialMoveEnd();
state PlayerRush
{
	event BeginState(name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
	}
    event OnFingerSwipe(ESwipeDirection SwipeDirection, float SwipeDistance)
    {
        OldOrientIndex = OrientIndex;
        Pawn.Velocity = vect(0,0,0);
        switch (SwipeDirection)
        {
            case ESD_Right:
                if(!bCanParkourTurn)
                {
                    ParkourMove(EPM_StrafeRight, SwipeDistance);
                }
                else
                {
                    ReCalcOrientVector();
                    OrientIndex = 0;
                    RushDir = OrientVect[OrientIndex];
                    ZBCameraTypeRushFix(ZBPlayerCamera(PlayerCamera).CurrentCameraType).TurnFollowParkour(1, RushDir); 
                    ParkourMove(EPM_TurnRight);
                }
                break;
        
            case ESD_Left:
                if(!bCanParkourTurn)
                {
                    ParkourMove(EPM_StrafeLeft, SwipeDistance);
                }
                else
                {
                    ReCalcOrientVector();
                    OrientIndex = 2;
                    RushDir = OrientVect[OrientIndex];
                    ZBCameraTypeRushFix(ZBPlayerCamera(PlayerCamera).CurrentCameraType).TurnFollowParkour(-1, RushDir); 
                    ParkourMove(EPM_TurnLeft);
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
                ZombieRushPawn(Pawn).bHitWall = true;
                Pawn.SetRotation(Rotator(RushDir));
                SetRotation(Pawn.rotation);
                return;
            default:
                
        }
        // auto move foward after jump strafe
        //ZombieRushPawn(Pawn).bHitWall = false;
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
          Pawn.SetRotation(Rotator(RushDir));
          SetRotation(Pawn.rotation);
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
		Pawn.SetRotation(Rotator(RushDir));
		SetRotation(Pawn.rotation);
		ViewShake( deltaTime );
	}
}

state PlayerKnockingDown
{
	function PlayerMove( float DeltaTime )
	{
		Pawn.SetRotation(Rotator(RushDir));
		SetRotation(Pawn.rotation);
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
			GotoState('PlayerParkourMove');
			break;
	
		case EPM_StrafeRight:
            StrafeMagnitude = CalcStrafeMagnitude(SwipeDistance);
			ZombieParkourPawn(Pawn).DoParkourStrafeRight(OnStrafeEnd, StrafeMagnitude);
			GotoState('PlayerParkourMove');
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
		GotoState('PlayerRush');
}

function ToggleTurn(bool bEnable)
{
	bCanParkourTurn = bEnable;
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
}
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


var bool bCanTurn;

delegate OnSpecialMoveEnd();
state PlayerRush
{
	event BeginState(name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
	}
}
state PlayerTurn
{
	event EndState(Name NextStateName)
    {
    	super.EndState(NextStateName);
    	//ReCalcOrientVector();
    }
    // can only turn once in turn volume
    function InternalOnInputTouch(int Handle, ETouchType Type, Vector2D TouchLocation, float DeviceTimestamp, int TouchpadIndex)
	{

	}
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
function DoSwipeMove(Vector2D startLocation, Vector2D endLocation)
{
	local ESwipeDirection SwipeDirection; 
     
    if (!IsInState('PlayerRush'))
    {
    	return;
    }

    SwipeDirection = CheckSwipeDirection(StartLocation, EndLocation);
	OldOrientIndex = OrientIndex;
	Pawn.Velocity = vect(0,0,0);
	switch (SwipeDirection)
	{
		case ESD_Right:
			if(!bCanTurn)
 			{
				ParkourMove(EPM_StrafeRight);
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
			if(!bCanTurn)
 			{
				ParkourMove(EPM_StrafeLeft);
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
			
	
		default:
			
	}

	ZombieRushPawn(Pawn).bHitWall = false;		
	return;
}

function ParkourMove(EParkourMoveType NewMove)
{
	switch (NewMove)
	{
		case EPM_StrafeLeft:
			ZombieParkourPawn(Pawn).DoParkourStrafeLeft(OnStrafeEnd);
			GotoState('PlayerParkourMove');
			break;
	
		case EPM_StrafeRight:
			ZombieParkourPawn(Pawn).DoParkourStrafeRight(OnStrafeEnd);
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

function OnStrafeEnd(ZBSpecialMove SpecialMoveObject)
{
	if(!IsInstate('CaptureByZombie') && !IsInstate('FallingHole') 
    && !IsInstate('TransLevel') && !IsInstate('EatByZombie'))
		GotoState('PlayerRush');
}

function ToggleTurn(bool bEnable)
{
	bCanTurn = bEnable;
}


function OnKonckDownEnd(ZBSpecialMove SpecialMoveObject)
{
	ZombieParkourPawn(Pawn).DoParkourGetUp(OnGetUpEnd);
	GotoState('PlayerKnockingDown');
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
	
}
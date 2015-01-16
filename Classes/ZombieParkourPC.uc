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

var EParkourMoveType ParkourMoveType;
var bool bCanTurn;

delegate OnSpecialMoveEnd();
state PlayerRush
{
	event BeginState(name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		ParkourMoveType = EPM_Normal;
	}
}
state PlayerTurn
{
	event EndState(Name NextStateName)
    {
    	super.EndState(NextStateName);
    	ReCalcOrientVector();
    	ParkourMoveType = EPM_Normal;
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
function DoSwipeMove(Vector2D startLocation, Vector2D endLocation)
{
     local float deltaX,deltaY,absDeltaY,absDeltaX;
	 local Vector HitLocation,HitNormal,TraceLoc;
     local Actor HitActor;
     
     if (ParkourMoveType != EPM_Normal)
     {
     	return;
     }

     TraceLoc = SwipeTraceDistance * RushDir + Pawn.location;
	 ////HitActor = Trace(HitLocation, HitNormal, CamPos, TargetLoc, TRUE, vect(12,12,12), HitInfo,TRACEFLAG_Blocking);
	 HitActor = Trace(HitLocation, HitNormal, TraceLoc ,Pawn.location, FALSE, vect(12,12,12));
	 deltaY = endLocation.Y - startLocation.Y;
	 deltaX = endLocation.X - startLocation.X;
	 absDeltaX = abs(deltaX);
	 absDeltaY = abs(endLocation.Y - startLocation.Y);

	 OldOrientIndex = OrientIndex;
 	if (deltaX > 0.1 && absDeltaX > absDeltaY ) //swipe right
 	{
 		if(!bCanTurn)
 		{
 			ParkourMoveType = EPM_StrafeRight; 
 		}
 		else
 		{
 			ParkourMoveType = EPM_TurnRight; 
 			ReCalcOrientVector();
 			OrientIndex = 0;
 			RushDir = OrientVect[OrientIndex];
 			ZBCameraTypeRushFix(ZBPlayerCamera(PlayerCamera).CurrentCameraType).TurnFollowParkour(1, RushDir); 
 		}
	}
	 else if(deltaX < -0.1 && absDeltaX > absDeltaY) //swipe left
	 {
 		if(!bCanTurn)
 		{
	 		ParkourMoveType = EPM_StrafeLeft;
	 	}
	 	else
	 	{
	 		ParkourMoveType = EPM_TurnLeft;
	 		ReCalcOrientVector();
	 		OrientIndex = 2;
	 		RushDir = OrientVect[OrientIndex];
	 		ZBCameraTypeRushFix(ZBPlayerCamera(PlayerCamera).CurrentCameraType).TurnFollowParkour(-1, RushDir); 
	 	}
	}
	 
	Pawn.Velocity = vect(0,0,0);
	if (GetStateName()=='PlayerRush')
	{
	 	// if hitwall just turn instantly,including shoot gun
	 	// but if doing pushcase special move turn around and continue rush
	 	if(!ZombieRushPawn(Pawn).bHitWall || ZombieRushPawn(Pawn).IsDoingSpecialMove(SM_PushCase))
	 	{
	 		ParkourMove(ParkourMoveType);
	 	}
	 	else
	 	{
	 		ParkourMoveType = EPM_Normal;
	 	}
	} 
	else 
	{
	 	ParkourMoveType = EPM_Normal;
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
	ParkourMoveType = EPM_Normal;
	GotoState('PlayerRush');
	SpecialMoveObject.OnSpecialMoveEnd = none;
}

function ToggleTurn(bool bEnable)
{
	bCanTurn = bEnable;
}
defaultproperties
{
	
}
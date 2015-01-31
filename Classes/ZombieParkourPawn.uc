class ZombieParkourPawn extends ZombieRushPawn;

// Body...
enum EStrafeDirection
{
	ESD_Left,
	ESD_Right,
};

var EStrafeDirection StrafeDirection;
var float StrafeVelocityDirection[2];


event Landed(vector HitNormal, Actor FloorActor)
{
	if (SpecialMove == SM_Parkour_StrafeLeft ||
		SpecialMove == SM_Parkour_StrafeRight)
	{
		bIsJumping=false;
		EndSpecialMove();
		return;
	}
	super.Landed(HitNormal, FloorActor);
}

//called in hitwall
function DoDirectHitWallMove()
{
	//DoSpecialMove(SM_RunIntoWall,true);
	DoParkourKnockDown(ZombieParkourPC(Controller).OnKonckDownEnd);
}


//for parkour mode
function DoParkourStrafeLeft(optional delegate<ZombiePawn.OnSpecialMoveEnd> SpecialMoveEndNotify)
{
	DoSpecialMove(SM_Parkour_StrafeLeft, true, None, 0, SpecialMoveEndNotify);
	//SpecialMoves[SpecialMove].OnSpecialMoveEnd = SpecialMoveEndNotify;

	SetStrafeVelocity(ESD_Left);
}

function DoParkourStrafeRight(optional delegate<ZombiePawn.OnSpecialMoveEnd> SpecialMoveEndNotify)
{
	DoSpecialMove(SM_Parkour_StrafeRight, true, None, 0, SpecialMoveEndNotify);
	//SpecialMoves[SpecialMove].OnSpecialMoveEnd = SpecialMoveEndNotify;
	
	SetStrafeVelocity(ESD_Right);
}

function DoParkourKnockDown(optional delegate<ZombiePawn.OnSpecialMoveEnd> SpecialMoveEndNotify)
{
	DoSpecialMove(SM_Parkour_KnockDown, true, None, 0, SpecialMoveEndNotify);
	//SpecialMoves[SpecialMove].OnSpecialMoveEnd = SpecialMoveEndNotify;
	SetKnockDownVelocity();
}

//in fact called in DoSpecialMove(SM_None)
function DoParkourGetUp(optional delegate<ZombiePawn.OnSpecialMoveEnd> SpecialMoveEndNotify)
{
	DoSpecialMove(SM_Parkour_GetUp, true, None, 0, SpecialMoveEndNotify); // ->PendingSpecialMoveStruct
	//SpecialMoves[SpecialMove].OnSpecialMoveEnd = SpecialMoveEndNotify;
	Velocity = vect(0.0, 0.0, 0.0);
}

function SetStrafeVelocity(EStrafeDirection PendingStrafeDirection)
{
	local Vector X,Y,Z;
	GetAxes(Rotation, X, Y, Z);
	Velocity = StrafeVelocityDirection[PendingStrafeDirection] * 600 * Y;
	Velocity.Z = 0.35*Sqrt(1 * 1060 * Abs(GetGravityZ()));//JumpZ;  WorldInfo.WorldGravityZ 
	SetPhysics(PHYS_Falling);
	bIsJumping = true;
}

function SetKnockDownVelocity()
{
	local Vector X,Y,Z;
	GetAxes(Rotation, X, Y, Z);
	Velocity = - 1200 * X;
	if(physics != PHYS_Falling)
	{
		SetPhysics(PHYS_Falling);
	}
	bIsJumping = false;
}




event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp )
{
	//ignore hit wall when doing parkour strafe move
	if (SpecialMove == SM_Parkour_StrafeLeft ||
		SpecialMove == SM_Parkour_StrafeRight)
	{
		return;
	}
	super.HitWall(HitNormal, Wall, WallComp);
}

defaultproperties
{
	StrafeVelocityDirection[0]=-1
	StrafeVelocityDirection[1]=1
	bDirectHitWall=true
}
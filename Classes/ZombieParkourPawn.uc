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

//for parkour mode
function DoParkourStrafeLeft(optional delegate<ZBSpecialMove.OnSpecialMoveEnd> SpecialMoveEndNotify)
{
	DoSpecialMove(SM_Parkour_StrafeLeft,true);
	SpecialMoves[SpecialMove].OnSpecialMoveEnd = SpecialMoveEndNotify;

	SetStrafeVelocity(ESD_Left);
}

function DoParkourStrafeRight(optional delegate<ZBSpecialMove.OnSpecialMoveEnd> SpecialMoveEndNotify)
{
	DoSpecialMove(SM_Parkour_StrafeRight,true);
	SpecialMoves[SpecialMove].OnSpecialMoveEnd = SpecialMoveEndNotify;
	
	SetStrafeVelocity(ESD_Right);
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

event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp )
{
	bHitWall = true;
}
defaultproperties
{
	StrafeVelocityDirection[0]=-1
	StrafeVelocityDirection[1]=1
}
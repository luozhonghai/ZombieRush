class ZombieParkourPawn extends ZombieRushPawn
	implements(IPhysicsInterface);

// Body...
enum EStrafeDirection
{
	ESD_Left,
	ESD_Right,
};

enum EFloor_Type
{
	EFT_Normal,
	EFT_Slide,
	EFT_Rope
};

var EStrafeDirection StrafeDirection;
var float StrafeVelocityDirection[2];


var AnimNodeBlendList FloorBlendList;
var SkelControlSingleBone RootBodyControl;
var SkelControlFootPlacement LeftFootControl;
var SkelControlFootPlacement RightFootControl;

var(AnimNode) name FloorBlendListName;
var(SkelControl) name RootBodyControlName;
var(SkelControl) name LeftFootControlName;
var(SkelControl) name RightFootControlName;

//rope
var PhysicsRopeSkeletalMeshActor RopeGrabbed;
var  name RopeBoneName;
var vector RopeBoneLocation;

simulated function CacheAnimNodes()
{
  Super.CacheAnimNodes();
  LeftArmSkelControl = SkelControlLimb(Mesh.FindSkelControl(LeftArmSkelControlName));
  RightArmSkelControl = SkelControlLimb(Mesh.FindSkelControl(RightArmSkelControlName));
  LeftFootClimbSkelControl = SkelControlLimb(Mesh.FindSkelControl(LeftFootClimbSkelControlName));
  RightFootClimbSkelControl = SkelControlLimb(Mesh.FindSkelControl(RightFootClimbSkelControlName));

  RootBodyControl = SkelControlSingleBone(Mesh.FindSkelControl(RootBodyControlName));
  LeftFootControl = SkelControlFootPlacement(Mesh.FindSkelControl(LeftFootControlName));
  RightFootControl = SkelControlFootPlacement(Mesh.FindSkelControl(RightFootControlName));
  FloorBlendList = AnimNodeBlendList(Mesh.FindAnimNode(FloorBlendListName));
}

event Landed(vector HitNormal, Actor FloorActor)
{
	//recover jump off rope rb state
  Mesh.SetRBChannel(RBCC_Default);


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
//called in hitwall
function DoHitByFallingWall()
{
	DoParkourKnockDown(ZombieParkourPC(Controller).OnHitByFallingWall, true);
}

//grab rope
function DoGrabRope(PhysicsRopeSkeletalMeshActor rope)  
{
	local vector FaceDir, headLoc, relativeLoc;
	local SkeletalMeshComponent RopeMesh;
	local Rotator relativeRot;
	if(rope != none)
	{
		`log("DoGrabRope");
		ZombieParkourPC(Controller).OnGrabRope();
		RopeGrabbed = rope;
		RopeMesh = rope.SkeletalMeshComponent;
		FaceDir = Vector(Rotation);
		//Mesh.SetRBDominanceGroup(RopeMesh.RBDominanceGroup+1);
		headLoc = Mesh.GetBoneLocation('Bip01-Head',0);
		RopeBoneName = RopeMesh.FindClosestBone(headLoc, RopeBoneLocation);

    Mesh.SetRBChannel(RBCC_Untitled3);
    
    Mesh.SetTranslation(vect(-100,0,-170));
    relativeRot.Pitch = -25 * DegToUnrRot;
    Mesh.SetRotation(relativeRot);
		SetLocation(RopeBoneLocation);
		SetBase(rope, vect(0,0,0), RopeMesh,RopeBoneName);
    
    //relativeRot = RelativeRotation;
		// relativeRot.Pitch = 70 * DegToUnrRot;
		// relativeLoc.X = 40;
		//SetRelativeRotation(relativeRot);
		//SetRelativeLocation(relativeLoc);
		DoSpecialMove(SM_GrabRope, true, None, 0, ZombieParkourPC(Controller).OnJumpOffRope);

		RopeMesh.AddImpulse(10000 * FaceDir, RopeBoneLocation, RopeBoneName );
	}
		
}

function DoShakeRope(Vector strength)
{
	local SkeletalMeshComponent RopeMesh;
	RopeMesh = RopeGrabbed.SkeletalMeshComponent;
	RopeMesh.AddImpulse(strength, RopeBoneLocation, RopeBoneName );
}

//for parkour mode
function DoParkourStrafeLeft(optional delegate<ZombiePawn.OnSpecialMoveEnd> SpecialMoveEndNotify, optional float StrafeMagnitude)
{
	DoSpecialMove(SM_Parkour_StrafeLeft, true, None, 0, SpecialMoveEndNotify);
	//SpecialMoves[SpecialMove].OnSpecialMoveEnd = SpecialMoveEndNotify;

	SetStrafeVelocity(ESD_Left, StrafeMagnitude);
}

function DoParkourStrafeRight(optional delegate<ZombiePawn.OnSpecialMoveEnd> SpecialMoveEndNotify, optional float StrafeMagnitude)
{
	DoSpecialMove(SM_Parkour_StrafeRight, true, None, 0, SpecialMoveEndNotify);
	//SpecialMoves[SpecialMove].OnSpecialMoveEnd = SpecialMoveEndNotify;
	
	SetStrafeVelocity(ESD_Right, StrafeMagnitude);
}

function DoParkourKnockDown(optional delegate<ZombiePawn.OnSpecialMoveEnd> SpecialMoveEndNotify, bool bDead = false)
{
	if(bDead)
		DoSpecialMove(SM_Parkour_KnockDown, true, None, 1, SpecialMoveEndNotify);
	else
		DoSpecialMove(SM_Parkour_KnockDown, true, None, 0, SpecialMoveEndNotify);

	//SpecialMoves[SpecialMove].OnSpecialMoveEnd = SpecialMoveEndNotify;
	//deprecated hwen use physics effect
	//SetKnockDownVelocity();
}

//in fact called in DoSpecialMove(SM_None)
function DoParkourGetUp(optional delegate<ZombiePawn.OnSpecialMoveEnd> SpecialMoveEndNotify)
{
	DoSpecialMove(SM_Parkour_GetUp, true, None, 0, SpecialMoveEndNotify); // ->PendingSpecialMoveStruct
	//SpecialMoves[SpecialMove].OnSpecialMoveEnd = SpecialMoveEndNotify;
	Velocity = vect(0.0, 0.0, 0.0);
}

function SetStrafeVelocity(EStrafeDirection PendingStrafeDirection, optional float StrafeMagnitude = 600)
{
	local Vector X,Y,Z;
	GetAxes(Rotation, X, Y, Z);
	Velocity = StrafeVelocityDirection[PendingStrafeDirection] * StrafeMagnitude * Y;
	Velocity.Z = 0.35*Sqrt(1 * 1060 * Abs(GetGravityZ()));//JumpZ;  WorldInfo.WorldGravityZ 
	SetPhysics(PHYS_Falling);
	bIsJumping = true;
}
//deprecated hwen use physics effect
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

//AnimNotify
function AnimNotify_HandOff()
{
	if(IsDoingSpecialMove(SM_ClimbUp))
	  ZSM_ClimbUp(SpecialMoves[SpecialMove]).HandOff();
}

function AnimNotify_KickStart()
{
	if(IsDoingSpecialMove(SM_Kick))
    ZSM_Kick(SpecialMoves[SpecialMove]).KickStart();
}


//physics interface

function SimulatingPhysics()
{
  `log("PhysicsUtil: SimulatingPhysics");
}



//slide state
function EnterSlide()
{
	RootBodyControl.SetSkelControlActive(true);
	LeftFootControl.SetSkelControlActive(true);
	RightFootControl.SetSkelControlActive(true);
	FloorBlendList.SetActiveChild(EFT_Slide, 0.2);
}
function ExitSlide()
{
	RootBodyControl.SetSkelControlActive(false);
	LeftFootControl.SetSkelControlActive(false);
	RightFootControl.SetSkelControlActive(false);
	FloorBlendList.SetActiveChild(EFT_Normal, 0.2);
}
defaultproperties
{
	StrafeVelocityDirection[0]=-1
	StrafeVelocityDirection[1]=1
	bDirectHitWall=true

	LeftArmSkelControlName="LeftArmControl"
	RightArmSkelControlName="RightArmControl"
	RootBodyControlName="RootBodyControl"
	LeftFootControlName="LeftFootControl"
	RightFootControlName="RightFootControl"
	FloorBlendListName="FloorBlendList"
	LeftFootClimbSkelControlName="LeftFootClimbControl"
	RightFootClimbSkelControlName="RightFootClimbControl"
}
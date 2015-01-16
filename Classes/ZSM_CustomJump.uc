class ZSM_CustomJump extends ZBSpecialMove;

var() ZombiePawn.AnimationParaConfig		AnimCfg_JumpStand;
var() ZombiePawn.AnimationParaConfig		AnimCfg_JumpDash;

var   ZombiePawn.AnimationParaConfig  LastAnimCfg;

var vector OriginCylinderLoc;
var vector PreVelocity;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	PawnOwner.setphysics(PHYS_Custom);
	OriginCylinderLoc = PawnOwner.CylinderComponent.translation;
	PreVelocity = PawnOwner.Velocity;

	PreVelocity.z = 0;
	if (VSize(PawnOwner.Velocity) > 10)
	{
		
		PawnOwner.PlayConfigAnim(AnimCfg_JumpDash);
		LastAnimCfg = AnimCfg_JumpDash;
	//	PawnOwner.CylinderComponent.SetCylinderSize(30,55);
	}
	else
	{
		PawnOwner.PlayConfigAnim(AnimCfg_JumpStand);
		LastAnimCfg = AnimCfg_JumpStand;
	//	PawnOwner.CylinderComponent.SetCylinderSize(30,55);
	}
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);

	if (PawnOwner.health > 0)
	{
		PawnOwner.setphysics(PHYS_Walking);
	//	PawnOwner.ZeroMovementVariables();
	//Keep previous velocity;
		PawnOwner.velocity = PreVelocity;
	//	PawnOwner.StopConfigAnim(LastAnimCfg, 0);
	// reset cylinder;
		PawnOwner.CylinderComponent.SetCylinderSize(30,86);
		PawnOwner.CylinderComponent.SetTranslation(OriginCylinderLoc);
	}
}

//Bip01-L-Foot
//Bip01-Head
//Bip01-R-Foot

event tickspecial(float deltatime)
{
	local vector transZ;
	local float CylinderSizeZ;
    local Vector boneLoc,actorLoc,headLoc,lFootLoc,rFootLoc;
	boneLoc = PawnOwner.mesh.GetBoneLocation('Bip01-Pelvis',0);// 0 == World, 1 == Local (Component)

	headLoc = PawnOwner.mesh.GetBoneLocation('Bip01-Head',0);
	lFootLoc= PawnOwner.mesh.GetBoneLocation('Bip01-L-Foot',0);
	rFootLoc= PawnOwner.mesh.GetBoneLocation('Bip01-R-Foot',0);

//modify size of cylinder  bone positon based  every tick
	CylinderSizeZ = (headLoc.z - Fmin(lFootLoc.z,rFootLoc.z)+30)/2;
    PawnOwner.CylinderComponent.SetCylinderSize(30,CylinderSizeZ);

//modify translation of cylinder 
	actorLoc = PawnOwner.location;
	transZ = boneLoc - actorLoc;
	PawnOwner.CylinderComponent.SetTranslation(OriginCylinderLoc+transZ);

// move pawn on X-Y direction ignore Z direction(extract from animation )
    PawnOwner.move(PreVelocity*deltatime);

   
}

DefaultProperties
{
	AnimCfg_JumpStand=(AnimationNames=("zombie01-yuanditiao"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false)
	AnimCfg_JumpDash=(AnimationNames=("zhujue-kuaipaotiao"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendouttime=0.15)
	bDisableMovement=True
//	UseCustomRMM=True
	RMMInAction=RMM_Velocity
	bDisableTurn=true
}


/*
enum ERootMotionMode
{
	RMM_Translate,	// move actor with root motion
	RMM_Velocity,	// extract magnitude from root motion, and limit max Actor velocity with it.
	RMM_Ignore,		// do nothing
	RMM_Accel,		// extract velocity from root motion and use it to derive acceleration of the Actor
	RMM_Relative,	// if bHardAttach is used, then affect relative location instead of location.
};*/



class ZBAIPawnBase extends ZombiePawn
	placeable;


//Heidi3D
//var ZBAIControllerBase NPCController;
//var() class<ZBAIControllerBase> NPCControllerType;

//HeiDi
//var HeiDAIControllerBase NPCController;
//var() class<HeiDAIControllerBase> NPCControllerType;

//Zombie
var ZombieControllerBase NPCController;
var() class<ZombieControllerBase> NPCControllerType;

/**The length of the movement vector*/
var() int other_movementVectorLength;
var() int direct_movementVectorLength;
var() int other_movementAwayVectorLength;

var() int speed_outsideMeleeRange;
var() int speed_normalAccel;

var() int lookAtPlayerUpperRange;

var() int moveToPlayerCancelRange;
var() int moveToPlayerUpperRange;
var() int moveToPlayerNearRange;
var() int meleePrepareRange;

var() int range_movelookAtPlayer;   //range to start looking at playing when Zombie is moving
var() int range_meleeReady;

//timers
var() float cooldown_seconds_meleeAttack;          ///<length between melee attacks

var() float cooldown_seconds_moveAway;          ///<length for move away  

var() float cooldown_seconds_idle;              ///<length for idle
 

//AnimNode
var AnimNodeSlot Slot_FullBody;
var AnimNodeSequence IdleNode,MoveNode,RunNode;
var AnimNodeSlot CustomAnimNodes[2], CurrentActiveCustomAnimNode;
var AnimNodeBlend CustomAnimBlender;
var int LastCustomAnimNodePlayIndex;
//jump


var float LastJumpHeight;

//capture player 
var vector LastLocation;
var rotator LastRotation;

//scene relative

var() PathNode JumpDownNode;

//reference to my Spawn Node;
var ZombieSpawnNodeDistance NodeOwner;
//var bool bInitAnimFromSpawnNode;
simulated function OnInitJumpAIPawn(SeqAct_InitJumpAIPawn inAction)
{
	`log("OnInitJumpAIPawn");

	//HeiDAIControllerTest(Controller).GotoState('MoveToPathNode');
	HeiDAIControllerTest(Controller).WhatToDoNext();
}
event PostBeginPlay()
{
		super.PostBeginPlay();
}
function SpawnController(class<ZombieControllerBase> ControllerType)
{
				//set the existing ControllerClass to our new NPCController class
			NPCController = Spawn(ControllerType);
			NPCController.SetPawn(self);
}
simulated function CacheAnimNodes()
{
	super.CacheAnimNodes();
	//Slot_FullBody=AnimNodeSlot(Mesh.FindAnimNode('CustomSlot'));

	CustomAnimBlender = AnimNodeBlend(Mesh.FindAnimNode('CustomAnimBlender'));
	CustomAnimNodes[0] = AnimNodeSlot(Mesh.FindAnimNode('CustomSlot1'));
	CustomAnimNodes[1] = AnimNodeSlot(Mesh.FindAnimNode('CustomSlot2'));

	IdleNode = AnimNodeSequence(Mesh.FindAnimNode('IdleSequence'));
	MoveNode = AnimNodeSequence(Mesh.FindAnimNode('MoveSequence'));
	//RunNode = AnimNodeSequence(Mesh.FindAnimNode('RunSequence'));

//	MoveNode.SetAnim('zombie03-move');
	IdleNode.SetPosition(RandRange(0.0,IdleNode.GetAnimPlaybackLength()),false);
	MoveNode.SetPosition(RandRange(0.0,MoveNode.GetAnimPlaybackLength()),false);
	//RunNode.SetPosition(RandRange(0.0,RunNode.GetAnimPlaybackLength()),false);
	//bInitAnimFromSpawnNode = true;
}

event tick(float deltaTime)
{
	super.Tick(deltaTime);
	/* for test
	if(bInitAnimFromSpawnNode && NodeOwner!=none)
	{
		bInitAnimFromSpawnNode = false;
		NodeOwner.InitZombieAnim();
	}*/
}
function AddDefaultInventory()
{
	local Weapon lWeaponCG;

	lWeaponCG = Spawn(class'ZBWeaponForce', , , self.Location);
	if (lWeaponCG != none) 
	{
		lWeaponCG.GiveTo(self);
		lWeaponCG.bCanThrow = false; // don't allow default weapon to be thrown out
	}
}

//jump

//定时器函数for ASM_JumpStart
function PlayFall()
{
	if(SpecialMove==SM_PHYS_Trans_Jump)
	{
		ZSM_JumpStart(SpecialMoves[SpecialMove]).PlayFall();
	}
}
event Landed(vector HitNormal, Actor FloorActor)
{
	if(SpecialMove==SM_PHYS_Trans_Jump)
	{
		ZSM_JumpStart(SpecialMoves[SpecialMove]).Landed(true);
	}

	bIsJumping=false;
	super.Landed(HitNormal,FloorActor);
}


function bool DoJump( bool bUpdating )
{
	local float OldVelocityZ;

	//	if( PalPlayerInput(PalPlayerController(Controller).PlayerInput).bDisableInputInCinematic )
	//		return false;

	//if( PalPlayerController(Controller).IsInState('PlayerSlide') )
	//	return false;

	if(IsDoingSpecialMove(SM_Combat_GetHurt))
		return false;
	if (bJumpCapable && !bIsCrouched && !bWantsToCrouch &&
		(Physics == PHYS_Walking || Physics == PHYS_Ladder || Physics == PHYS_Spider ))//Physics == PHYS_Slide || Physics == PHYS_TrackSlide))
	{
		if ( Physics == PHYS_Spider )
			Velocity = JumpZ * Floor;
		else if ( Physics == PHYS_Ladder )
		{
		}
		else if ( bIsWalking )
			Velocity.Z = Default.JumpZ;
		else
		{
			PendingVelocity = Velocity;
			OldVelocityZ = Velocity.Z;
			PendingVelocity.Z = Sqrt(4 * JumpZ * Abs(GetGravityZ()));//JumpZ;
			Velocity = vect(0,0,0);


			if(DoSpecialMove(SM_PHYS_Trans_Jump, true))
			{
				//		WeaponForXingJi( Weapon ).NotifyFireSpecialMoveFinished();
				//清除Combo定时器
				//		WeaponForXingJi( Weapon ).clearTimer('CheckEndMeleeCombo');
				Velocity = PendingVelocity;
				//Velocity.Z = OldVelocityZ;
				PendingVelocity = vect(0,0,0);
			}
		}

		if (Base != None && !Base.bWorldGeometry && Base.Velocity.Z > 0.f)
		{
			Velocity.Z += Base.Velocity.Z;
		}

		SetPhysics(PHYS_Falling);
		bIsJumping = true;
		LastJumpHeight = Location.Z;

		return true;
	}

	return false;
}


function JumpOffPawn()
{
   local vector LastVelocity, velDir, toPawnDir;
   local Pawn BasePawn;
   BasePawn = Pawn(Base);
   LastVelocity = Velocity;
   LastVelocity.z = 0;

   velDir = Normal(LastVelocity);
   toPawnDir = normal(BasePawn.location - Location);

   controller.stoplatentexecution();
   if (velDir dot toPawnDir >0)
   {
	   Velocity.x=0;
	   velocity.y=0;
        Velocity -=   1600* velDir  ;
   }
   else
		Velocity +=   1600* velDir  ; 

   setphysics(PHYS_Falling);
}

function PlayConfigAnim( const  AnimationParaConfig AnimConfig, optional int blendnodeindex = 0, optional int configtype = -1 )
{
	local AnimNodeSequence SeqNode;
	local int index;

	LastCustomAnimNodePlayIndex = (LastCustomAnimNodePlayIndex + 1)%2;

	//play the custom animation on this new blender
	CustomAnimBlender.SetBlendTarget(LastCustomAnimNodePlayIndex,0.0);
  //  CustomAnimNodes[LastCustomAnimNodePlayIndex].StopCustomAnim(0.0);
	CustomAnimNodes[LastCustomAnimNodePlayIndex].PlayCustomAnim(AnimConfig.AnimationNames[0],AnimConfig.PlayRate,AnimConfig.BlendInTime,AnimConfig.BlendOutTime,AnimConfig.bLoop,true);

    CurrentActiveCustomAnimNode = CustomAnimNodes[LastCustomAnimNodePlayIndex];

//	Slot_FullBody.PlayCustomAnim(AnimConfig.AnimationNames[0],AnimConfig.PlayRate,AnimConfig.BlendInTime,AnimConfig.BlendOutTime,AnimConfig.bLoop,true);

	//	if(SpecialMove!=SM_PHYS_Trans_Jump)
	//	{
		SeqNode=CustomAnimNodes[LastCustomAnimNodePlayIndex].GetCustomAnimNodeSeq();
	//打开根骨骼运动
	for(index=0;index<2;index++)
	{
		//		SeqNode.RootBoneOption[index]=RBA_Translate;
	}

	//	SeqNode.SetRootBoneAxisOption(RBA_Translate, RBA_Translate, RBA_Translate);

	if(Mesh.RootMotionMode == RMM_Translate)
	{
		SeqNode.SetRootBoneAxisOption(RBA_Translate, RBA_Translate, RBA_Default);
		SeqNode.bCauseActorAnimEnd=true;
		//Mesh.RootMotionMode = RMM_Translate;
		Mesh.bRootMotionModeChangeNotify = TRUE;
	}
	//    SeqNode.bCauseActorAnimEnd=true;
	//	Mesh.RootMotionMode = RMM_Translate;
	//	Mesh.bRootMotionModeChangeNotify = TRUE;
	//	}
	//	else
	//	{
	//		SeqNode=Slot_FullBody.GetCustomAnimNodeSeq();
	//打开根骨骼运动
	//		for(index=0;index<2;index++)
	//		{
	//			SeqNode.RootBoneOption[index]=RBA_Default;
	//		}
	//	}
}

/*
enum ERootBoneAxis
{
// the default behaviour, leave root translation from animation and do no affect owning Actor movement. 
RBA_Default,
// discard any root bone movement, locking it to the first frame's location. 
RBA_Discard,
// discard root movement on animation, and forward its velocity to the owning actor. 
//RBA_Translate,
};
*/
function StopConfigAnim(const  AnimationParaConfig AnimConfig, float BlendOutTime)
{
	CurrentActiveCustomAnimNode.StopCustomAnim(AnimConfig.BlendOutTime);
}

simulated event RootMotionModeChanged(SkeletalMeshComponent SkelComp)
{
   /**
    * 根骨骼运动将会在下一帧会进行
    * 所以我们可以销毁Pawn运动，并让根骨骼运动来接管
    */
   if( SkelComp.RootMotionMode == RMM_Translate )
   {
      Velocity = Vect(0.f, 0.f, 0.f);
      Acceleration = Vect(0.f, 0.f, 0.f);
   }

   //禁用通知
   Mesh.bRootMotionModeChangeNotify = false;
}

simulated event OnAnimEnd(AnimNodeSequence SeqNode,float PlayedTime, float ExcessTime)
{
	//完成跳跃

	//丢弃根骨骼运动。以便网格物体仍然锁定在原位置。
	//我们需要这个来正确地混合到另一个动画
	SeqNode.SetRootBoneAxisOption(RBA_Discard,RBA_Discard,RBA_Default);
//	SeqNode.SetRootBoneAxisOption(RBA_Default,RBA_Default,RBA_Default);


	//告诉网格物体停止使用根骨骼运动
	Mesh.RootMotionMode = RMM_Ignore;
}


//melee attack

function Vector GetMeleeSwingLocation()
{
	local Vector SwingLocation;
	local Rotator SwingRotation;

	Mesh.GetSocketWorldLocationAndRotation(WeaponSocket,SwingLocation,SwingRotation);

	return SwingLocation;
}


//deal with damage melee and fire

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	//Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	//only play hurt animation if being knocked back
	//if(Mesh != None && abs(Mesh.FakeRootMotionScale) > 0 && Mesh.FakeRootMotionTotalTime > 0  )
    EndSpecialMove();
	  SetRotation(rotator(ZombiePlayerPawn(NPCController.ActivePlayerPawn).location-location));
	   Health -= Damage;
	   if(DamageType == class'DmgType_Gun_Fire')
	     DoSpecialMove(SM_Combat_GetHurt, true, none,1);
	   else
	     DoSpecialMove(SM_Combat_GetHurt, true);
	//	DoSpecialMove(SM_Zombie_CutDown, true);
	   if(Health>0)
	    NPCController.GotoState('Hurt');
	   else
	    NPCController.GotoState('Hurt','NoFocus'); //死亡不朝向玩家
}

//from ZombieController
function PlayerHurtByMe(vector loc,rotator rot)
{
	local int rotDeltaYaw;
	rotDeltaYaw = abs(-rot.Yaw - NPCController.ActivePlayerPawn.rotation.Yaw);
	//Controller.ClientSetLocation(loc,rot);
	setphysics(PHYS_None);
	//setphysics(PHYS_Walking);
//	CylinderComponent.SetCylinderSize(15,86);
	SetCollision(false,false);	
	// ClientSetLocation(ActivePlayerPawn.location,rotator(pawn.location - ActivePlayerPawn.location));
	ClientSetRotation(rot);
	if(ZombieType == EZT_Walk && rotDeltaYaw >= 90* DegToUnrRot)
  {
		DoSpecialMove(SM_MeleeAttack1, true, ZombiePlayerPawn(NPCController.ActivePlayerPawn),1);
	}
	else
	{
		DoSpecialMove(SM_MeleeAttack1, true);
	}
}
//called in SpecialMove: NSM_Pushed
function RecoverCollision()
{
	SetCollision(true,true);
}
//zheng zha
function PrePushedByPlayer()
{
    DoSpecialMove(SM_Zombie_Pushed, true);
  //  SetTimer(1.8,false,'RecoverCollision');
}
// called form SpecialmoveEnded() of NSM_Pushed
function PushedByPlayer()
{
   setphysics(PHYS_Falling);
   ZombieControllerTest(Controller). gotoState('MeleeAttackCold');
}

function SaveLastRot()
{	
	LastLocation = Location ;
	LastRotation = Rotation;
}
//temparaily use for get up anim
function RestoreFixedLocAndRot()
{	   
   Controller.ClientSetLocation(LastLocation,LastRotation);
}

function EatPlayer()
{
	EndSpecialMove();
   DoSpecialMove(SM_Zombie_EatPre, true);
}

function KnockBack()
{
	EndSpecialMove();
	DoSpecialMove(SM_Combat_GetHurt, true);
	NPCController.GotoState('Hurt');
}

function TakeExDamage()
 {
	 EndSpecialMove();
    DoSpecialMove(SM_Zombie_CutDown, true);
    //NPCController.GotoState('Hurt');
	NPCController.GotoState('Hurt','NoFocus');

 }
DefaultProperties
{
    ZombieType=EZT_Walk

    MaxStepHeight=26.0
	  GroundSpeed=50    //320 normal
	  drawscale=1.0

	Begin Object  Name=CollisionCylinder
		CollisionRadius=+0034.000000        NORMAL
		CollisionHeight=+0086.000000        NORMAL  //cat = 46

		//CollisionRadius=+0009.000000
		//CollisionHeight=+0018.00000

		//Translation=(Z=90.0)
		//BlockRigidBody=TRUE
		//	BlockZeroExtent=True
		//	BlockNonZeroExtent=True

		//	blockactors=false
		//	RBChannel=RBCC_Pawn
		//	RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,Pawn=true)
		End Object


		Begin Object Class=UDKSkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
	Translation=(Z=-90.0)
		BlockRigidBody=true;
	CollideActors=true;
	BlockZeroExtent=true;
//	bUseRawData=true
//	AnimRotationOnly=EARO_ForceDisabled
//	RootMotionRotationMode=RMRM_RotateActor
	//PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
	//	AnimSets(0)=AnimSet'UN_Heidi.Anim.HD_heidi_skin_Anims'
		//AnimSets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
	//	AnimTreeTemplate=AnimTree'UN_Heidi.Anim.AT_heidi_01'
	//	SkeletalMesh=SkeletalMesh'UN_Heidi.Mesh.HD_heidi_skin'
         AnimSets(0)=AnimSet'ZOMBIE_animation.zombie01_Anims'
         AnimSets(1)=AnimSet'ZOMBIE_animation.zombie01_Anims_new'
		 AnimTreeTemplate=AnimTree'ZOMBIE_animation.AT_Zombie01'
		 SkeletalMesh=SkeletalMesh'Zombie.Character.zombie01'
		  LightingChannels=(Dynamic=TRUE,Cinematic_1=FALSE,bInitialized=TRUE)
		  bAcceptsDynamicDominantLightShadows=FALSE
		  bNoModSelfShadow=true
		 // AbsoluteRotation=true
		//DepthPriorityGroup=SDPG_Foreground
		End Object

		Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);


	NPCControllerType=class'ZombieControllerTest'

//	NPCControllerType=class'ZBAIControllerTest'

//	NPCControllerType=class'HeiDAIControllerTest'
		
    direct_movementVectorLength=10


		other_movementVectorLength=200

		other_movementAwayVectorLength = 60
		speed_outsideMeleeRange=400   //normal 400
		speed_normalAccel=1000


		range_movelookAtPlayer=800
		lookAtPlayerUpperRange=900


		moveToPlayerUpperRange=1000  //600 normal  direct see player
		moveToPlayerNearRange=700   //move directly, no spline move, notice player when back face player
		moveToPlayerCancelRange=2500  //900 normal

		meleePrepareRange = 300 //200 init

		range_meleeReady=300

		cooldown_seconds_meleeAttack=12.5 //3.5

    cooldown_seconds_moveAway = 1.8

    cooldown_seconds_idle = 2.0


		// default bone names
		WeaponSocket=WeaponPoint

		InventoryManagerClass=class'ZBInventoryManager'
		SpecialMoveClasses(0)=None
		SpecialMoveClasses(1)=none
		SpecialMoveClasses(2)=Class'ZGame.NSM_Hit'
		SpecialMoveClasses(3)=Class'ZGame.ZSM_Hit_Two'
		SpecialMoveClasses(4)=Class'ZGame.ZSM_Hit_Thr'
    SpecialMoveClasses(5)=class'ZGame.ZSM_JumpStart'
		SpecialMoveClasses(6)=class'ZGame.NSM_GetHurt'
		SpecialMoveClasses(7)=none
		SpecialMoveClasses(8)=none
    SpecialMoveClasses(9)=none
		SpecialMoveClasses(10)=class'ZGame.NSM_Pushed'
		SpecialMoveClasses(11)=none
		SpecialMoveClasses(12)=class'ZGame.NSM_EatPre'
		SpecialMoveClasses(13)=class'ZGame.NSM_Eat'
		SpecialMoveClasses(14)=none
		SpecialMoveClasses(15)=class'ZGame.NSM_CutDown'
		SpecialMoveClasses(16)=class'ZGame.NSM_HitPre'

}

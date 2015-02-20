class ZombiePlayerPawn extends ZombiePawn
	placeable;

//just for Weapon blend anim
var byte WeaponType;
//health

var int PlayerHealth;

var float PlayerPower;

//Bump move
var bool bBumping;
var Vector BumpNormal;
var PrimitiveComponent BumpPrimitive;
//jump

var float LastJumpHeight;

var bool bPlayerIsDead;


//AnimNode
var AnimNodeSlot Slot_FullBody;
var AnimNodeBlendList BlendListByHealth[2];

var AnimNodeSlot CustomAnimNodes[2], CurrentActiveCustomAnimNode;
var AnimNodeBlend CustomAnimBlender;
var int LastCustomAnimNodePlayIndex;
var ZBAnimNode_IdleBlendByPower  AnimNodeExhausted1,AnimNodeExhausted2;

//Melee Socket
var name MeleeSocket;
//Gun Socket
var name GunSocket;
//Jump distance
var() float WalkJumpScale;
var float PCInputStrength;

//Override groundspeed from kismtet SpecialmovesHelper
var bool bOverrideGroundSpeedKismet;

struct TraversalRay
{
	var string Key;
	var Vector Start;
	var Vector Length;
};
/** Rays used to determine if an object is blocking the pawn as they move */
var array<TraversalRay> TraversalRays;
var Actor InteractCase;
var(Case) vector CaseTraceVector,CaseTraceExtent; 
/** Initialization function called from the GameInfo class.  Any initialization
 *  should be done here.  I thought we could use PostPlayBegin, but in looking
 *  through the root objects, not everything is initialized for us by then.  This
 *  function will be called once the default UDK initialization is complete. */
event Initialize()
{
	// Ensure NXPawn initializes first
	super.Initialize();

	// Give the player thier initial gear
	//Already call AddInventory in invManger
//	AddDefaultInventory();

	//SetActiveWeapon( Weapon(Inv) );
}

//damage

function CustomTakeDamage(int damage)
{
      PlayerHealth-=damage;
}

function int GetCustomHealth()
{
		return PlayerHealth;
}
function RestoreHealth(float amount)
{
	 	PlayerHealth+=amount;
		if (PlayerHealth>=100)
		{
			PlayerHealth=100;
		}
}
function SetInjuryState(bool bInjury)
{
	if(bInjury){
   BlendListByHealth[0].SetActiveChild(1,0.1);
	 BlendListByHealth[1].SetActiveChild(1,0.1);
	}
	else{
	 BlendListByHealth[0].setActiveChild(0,0.1);
	 BlendListByHealth[1].setActiveChild(0,0.1);
	}
}

function bool IsInjuried()
{
	return GetCustomHealth()<=21;
}


function ConsumePower(float amount)
{
	if (ZombiePC(Controller).bCheat)
    {
        return;
    }
	PlayerPower-=amount;

	if (PlayerPower<=0)
	{
	   PlayerPower=0;
	   AnimNodeSetExhausted();
	}
}

function RestorePower(float amount)
{
	PlayerPower+=amount;

	if (PlayerPower>=100)
	{
		PlayerPower=100;
	}
}
function int GetPower()
{
	return PlayerPower;
}


///BUmp

event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
{
	super.Bump(Other,OtherComp,HitNormal);
	//`log("Bumping");
	ZombiePC(controller).clientmessage("Bump!!!");
    bBumping = true;
	BumpPrimitive = OtherComp;
	BumpNormal = HitNormal;
}


event RanInto( Actor Other ){
	`log("RanInto");
}
event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp )
{
	`log("HitWall");
	TriggerEventClass(class'SeqEvent_HitWall', Wall);
}


// Encroachment
event bool EncroachingOn( actor Other )
{
	if ( Other.bWorldGeometry || Other.bBlocksTeleport )
		return true;

	if ( ((Controller == None) || !Controller.bIsPlayer) && (Pawn(Other) != None) )
		return true;

	return false;
}

event EncroachedBy( actor Other )
{
	// Allow encroachment by Vehicles so they can push the pawn out of the way
	if ( Pawn(Other) != None && Vehicle(Other) == None )
		gibbedBy(Other);
}


////Jump

//¶¨Ê±Æ÷º¯Êýfor ASM_JumpStart
function PlayFall()
{
	if(SpecialMove==SM_PHYS_Trans_Jump)
	{
		ZSM_JumpStart(SpecialMoves[SpecialMove]).PlayFall();
	}
}
event Landed(vector HitNormal, Actor FloorActor)
{
	if (!bIsJumping)
    {
        return;
    }
	if(SpecialMove==SM_PHYS_Trans_Jump)
	{
		ZSM_JumpStart(SpecialMoves[SpecialMove]).Landed(true);
		return;
	}

	
	if(VerifySMHasBeenInstanced(SM_PHYS_Trans_Jump))
	{
		if (SpecialMove == SM_None)  //µ¥¶ÀÂäµØÊ± SpecialMove = SM_None
		{ 
			SpecialMove=SM_PHYS_Trans_Jump;
		}
       ZSM_JumpStart(SpecialMoves[SM_PHYS_Trans_Jump]).Landed(false);
       return;
	}

	//CylinderComponent.SetCylinderSize(30,46);  cat
  //  CylinderComponent.SetCylinderSize(35,86);
    bIsJumping=false;
	EndSpecialMove();
	super.Landed(HitNormal,FloorActor);
}


function DoCustomJump()
{
	DoSpecialMove(SM_Custom_Jump, true);
}

function SaveInputStrength(float InputStrength){
       PCInputStrength = InputStrength;
}
function float GetJumpFowardScale()
{
	if (PCInputStrength>1800)
	{
        return WalkJumpScale*6; 
	}
	else if(PCInputStrength>800)
		return WalkJumpScale*3;
	else if(PCInputStrength>10) //walk
	{
        return WalkJumpScale; //0.5m
	}
	return 0;
}
function bool DoJump( bool bUpdating )
{
	local float OldVelocityZ;

//	if( PalPlayerInput(PalPlayerController(Controller).PlayerInput).bDisableInputInCinematic )
//		return false;

	//if( PalPlayerController(Controller).IsInState('PlayerSlide') )
	//	return false;

	//if(IsDoingSpecialMove(SM_Combat_GetHurt)||IsDoingSpecialMove(SM_MeleeAttack1))
	//	return false;

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
			PendingVelocity = GetJumpFowardScale()*Normal(Velocity);
			OldVelocityZ = Velocity.Z;
			PendingVelocity.Z = 0.7*Sqrt(1 * JumpZ * Abs(GetGravityZ()));//JumpZ;
			Velocity = vect(0,0,0);


			if(DoSpecialMove(SM_PHYS_Trans_Jump, false))
			{
		//		WeaponForXingJi( Weapon ).NotifyFireSpecialMoveFinished();
				//Çå³ýCombo¶¨Ê±Æ÷
		//		WeaponForXingJi( Weapon ).clearTimer('CheckEndMeleeCombo');
				Velocity = PendingVelocity;
				//Velocity.Z = OldVelocityZ;
				PendingVelocity = vect(0,0,0);


				if (Base != None && !Base.bWorldGeometry && Base.Velocity.Z > 0.f)
				{
					Velocity.Z += Base.Velocity.Z;
				}

				SetPhysics(PHYS_Falling);
				bIsJumping = true;
				LastJumpHeight = Location.Z;

				return true;
			}
		}

		
	}

	return false;
}

function DoRushJump()
{
	DoSpecialMove(SM_PHYS_Trans_Jump, true);
    Velocity.Z = 0.65*Sqrt(1 * 1060 * Abs(GetGravityZ()));//JumpZ;  WorldInfo.WorldGravityZ 
	SetPhysics(PHYS_Falling);
	bIsJumping = true;
}
function JumpOffPawn()
{
	local vector LastVelocity, velDir, toPawnDir;
	local Pawn BasePawn;
	BasePawn = Pawn(Base);
//	LastVelocity = Velocity;

	LastVelocity = vector(rotation);
	LastVelocity.z = 0;

	velDir = Normal(LastVelocity);
	toPawnDir = normal(BasePawn.location - Location);

	if (velDir dot toPawnDir >0)
	{
		Velocity.x=0;
		velocity.y=0;
		Velocity -=   120* velDir  ;
	}
	else
		Velocity +=   120* velDir  ; 

	Velocity.Z = 50;

	setphysics(PHYS_Falling);



}


/************************************************************//** 
 * Gives the player any initial objects he should have.  In
 * this case, we're giving him the physics gun and then 
 * switching to it.
 *************************************************************/
function AddDefaultInventory()
{
	/*
	local Weapon lWeaponCG;

	lWeaponCG = Spawn(class'ZBWeaponAxe', , , self.Location);
	if (lWeaponCG != none) 
	{
		lWeaponCG.GiveTo(self);
		lWeaponCG.bCanThrow = false; // don't allow default weapon to be thrown out
	}*/
/*
	lWeaponCG = Spawn(class'ZBWeaponForce', , , self.Location);
	if (lWeaponCG != none) 
	{
	//	lWeaponCG.GiveTo(Controller.Pawn);
		InvManager.AddInventory( lWeaponCG,true );
		lWeaponCG.bCanThrow = false; // don't allow default weapon to be thrown out
	}*/

}
function AddZBInventory()
{
	local Weapon lWeaponCG;
	lWeaponCG = Spawn(class'ZBWeaponGun', , , self.Location);
	if (lWeaponCG != none) 
	{
	//	lWeaponCG.GiveTo(self);
		InvManager.AddInventory( lWeaponCG,true );
		lWeaponCG.bCanThrow = false; // don't allow default weapon to be thrown out
	}
	lWeaponCG = Spawn(class'ZBWeaponAxe', , , self.Location);
	if (lWeaponCG != none) 
	{
		lWeaponCG.GiveTo(self);
		lWeaponCG.bCanThrow = false; // don't allow default weapon to be thrown out
	}

	SetActiveWeapon(lWeaponCG);
	//InvManager.NextWeapon();
}
simulated function OnAddZBWeapon(SeqAct_AddZBWeapon inAction)
{
	//`log("OnInitJumpAIPawn");

	//HeiDAIControllerTest(Controller).GotoState('MoveToPathNode');
	AddZBInventory();
}
//call from Weapon.uc when start to hold weapon
function SetWeaponType(int WeaponId)
{
	WeaponType = WeaponId;
}


simulated function CacheAnimNodes()
{
	super.CacheAnimNodes();
//	Slot_FullBody=AnimNodeSlot(Mesh.FindAnimNode('CustomSlot'));
	BlendListByHealth[0] = AnimNodeBlendList(Mesh.FindAnimNode('HealthBlendList_0'));
	BlendListByHealth[1] = AnimNodeBlendList(Mesh.FindAnimNode('HealthBlendList_1'));

	CustomAnimBlender = AnimNodeBlend(Mesh.FindAnimNode('CustomAnimBlender'));
	CustomAnimNodes[0] = AnimNodeSlot(Mesh.FindAnimNode('CustomSlot1'));
	CustomAnimNodes[1] = AnimNodeSlot(Mesh.FindAnimNode('CustomSlot2'));

	AnimNodeExhausted1 = ZBAnimNode_IdleBlendByPower(Mesh.FindAnimNode('ExhaustedNode1'));
	AnimNodeExhausted2 = ZBAnimNode_IdleBlendByPower(Mesh.FindAnimNode('ExhaustedNode2'));
}

 function AnimNodeSetExhausted()
{
	AnimNodeExhausted1.bExhausted =true;
	AnimNodeExhausted2.bExhausted =true;
}

function PlayConfigAnim( const  AnimationParaConfig AnimConfig, optional int blendnodeindex = 0, optional int configtype = -1 )
{
	local AnimNodeSequence SeqNode;
	local int index;


	//CustomAnimNodes[LastCustomAnimNodePlayIndex].StopCustomAnim(0.0);
	//increment our last-animation-node index to the next one, modulus of the total number custom animation blenders we're using
	LastCustomAnimNodePlayIndex = (LastCustomAnimNodePlayIndex + 1)%2;

	//play the custom animation on this new blender
	CustomAnimBlender.SetBlendTarget(LastCustomAnimNodePlayIndex,0.0);

	CustomAnimNodes[LastCustomAnimNodePlayIndex].PlayCustomAnim(AnimConfig.AnimationNames[0],AnimConfig.PlayRate,AnimConfig.BlendInTime,AnimConfig.BlendOutTime,AnimConfig.bLoop,true);

    CurrentActiveCustomAnimNode = CustomAnimNodes[LastCustomAnimNodePlayIndex];

		SeqNode=CustomAnimNodes[LastCustomAnimNodePlayIndex].GetCustomAnimNodeSeq();
		SeqNode.bCauseActorAnimEnd=true;

		if(Mesh.RootMotionMode == RMM_Translate)
		{
			SeqNode.SetRootBoneAxisOption(RBA_Translate, RBA_Translate, RBA_Default);
			
			//Mesh.RootMotionMode = RMM_Translate;
			Mesh.bRootMotionModeChangeNotify = TRUE;
		}

        if(Mesh.RootMotionRotationMode == RMRM_RotateActor)
        {
        	SeqNode.SetRootBoneRotationOption(RRO_Default, RRO_Default, RRO_Extract);
        }
        else
        {
        	SeqNode.SetRootBoneRotationOption(RRO_Default, RRO_Default, RRO_Default);
        }
}

function StopConfigAnim(const  AnimationParaConfig AnimConfig, float BlendOutTime)
{
	CustomAnimNodes[LastCustomAnimNodePlayIndex].StopCustomAnim(AnimConfig.BlendOutTime);
}

simulated event RootMotionModeChanged(SkeletalMeshComponent SkelComp)
{
   /**
    * ¸ù¹Ç÷ÀÔË¶¯½«»áÔÚÏÂÒ»Ö¡»á½øÐÐ
    * ËùÒÔÎÒÃÇ¿ÉÒÔÏú»ÙPawnÔË¶¯£¬²¢ÈÃ¸ù¹Ç÷ÀÔË¶¯À´½Ó¹Ü
    */
   if( SkelComp.RootMotionMode == RMM_Translate )
   {
      Velocity = Vect(0.f, 0.f, 0.f);
      Acceleration = Vect(0.f, 0.f, 0.f);
   }

   //½ûÓÃÍ¨Öª
   Mesh.bRootMotionModeChangeNotify = false;
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
simulated event OnAnimEnd(AnimNodeSequence SeqNode,float PlayedTime, float ExcessTime)
{
   //Íê³ÉÌøÔ¾
   
   //¶ªÆú¸ù¹Ç÷ÀÔË¶¯¡£ÒÔ±ãÍø¸ñÎïÌåÈÔÈ»Ëø¶¨ÔÚÔ­Î»ÖÃ¡£
   //ÎÒÃÇÐèÒªÕâ¸öÀ´ÕýÈ·µØ»ìºÏµ½ÁíÒ»¸ö¶¯»­
   if(Mesh.RootMotionMode == RMM_Translate)
	{
   SeqNode.SetRootBoneAxisOption(RBA_Discard,RBA_Discard,RBA_Default);
    // SeqNode.SetRootBoneAxisOption(RBA_Default,RBA_Default,RBA_Default);

   //¸æËßÍø¸ñÎïÌåÍ£Ö¹Ê¹ÓÃ¸ù¹Ç÷ÀÔË¶¯
   Mesh.RootMotionMode = RMM_Ignore;
   }

   if(IsDoingSpecialMove(SM_PHYS_Trans_Jump))
      SpecialMoves[SpecialMove].OnAnimEnd(SeqNode.AnimSeqName);
/*
   if (ZombiePC(Controller).isinstate('PlayerAttacking'))
   {
	   if (IsDoingSpecialMove(SM_MeleeAttack2))
	   {
		   	 //  EndSpecialMove();
	   }
      ZombiePC(Controller).gotostate('PlayerWalking');
   }*/
}



//Melee attack

function Vector GetMeleeSwingLocation()
{
	local Vector SwingLocation;
	local Rotator SwingRotation;

	Mesh.GetSocketWorldLocationAndRotation(MeleeSocket,SwingLocation,SwingRotation);

	return SwingLocation;
}

function Vector GetMeleeSwingLocation2()
{
	local Vector SwingLocation;
	local Rotator SwingRotation;

	Mesh.GetSocketWorldLocationAndRotation('MeleePoint2',SwingLocation,SwingRotation);

	return SwingLocation;
}
function GetFirSocketLocationAndDir(out vector loc,out vector dir)
{
	local Rotator FirRot;
    Mesh.GetSocketWorldLocationAndRotation(GunSocket,loc,FirRot);
	dir = vector(FirRot);
	return ;
}
//deal with damage

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
//	Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	//only play hurt animation if being knocked back
	//if(Mesh != None && abs(Mesh.FakeRootMotionScale) > 0 && Mesh.FakeRootMotionTotalTime > 0  )

	DoSpecialMove(SM_Combat_GetHurt, true);
	
}



function HurtByZombie(Rotator rot,ZBAIPawnBase zombie)
{
	local int rotDeltaYaw;
	local Vector NewLocation;
	rotDeltaYaw = abs(rot.Yaw - rotation.Yaw);
	ZeroMovementVariables();
	setphysics(PHYS_None);
	SetCollision(true,false);
   // cylindercomponent.setactorcollision(false,false,false);
  EndSpecialMove();
  
  if(zombie.ZombieType == EZT_Walk && rotDeltaYaw >= 90* DegToUnrRot)
  {
  	ClientSetRotation(rotator(-vector(rot)));
		DoSpecialMove(SM_Combat_GetHurt, true, zombie,1); //hurt from back
  }
	else if(zombie.ZombieType == EZT_Walk)
	{
		ClientSetRotation(rot);
	  DoSpecialMove(SM_Combat_GetHurt, true);
	}
	else if(zombie.ZombieType == EZT_Creep)
	{
		ClientSetRotation(rot);
	  DoSpecialMove(SM_Combat_GetHurt, true,zombie,2);//bao tui
	}
	NewLocation = Location;
	NewLocation.Z = zombie.Location.Z;
	SetLocation(NewLocation);
}

function InitPosEatByZombie(Rotator rot,ZBAIPawnBase zombie)
{
	local Vector NewLocation;
	ZeroMovementVariables();
	setphysics(PHYS_None);
	SetCollision(true,false);
	ClientSetRotation(rot);
	NewLocation = Location;
	NewLocation.Z = zombie.Location.Z;
	SetLocation(NewLocation);
}
///////////////////////////////////
function PushZombie()
{
	//EndSpecialMove();
    DoSpecialMove(SM_Player_Push, true);

	PushForwardZombies(ZombiePC(Controller).InteractZombie);
}
function PushForwardZombies(Actor IgnoredZombie)
{
		local ZombiePawn ZP;
		local ZombiePawn TestZP;
		local Vector ToTestWPNorm,TestDir;
		local float ToTestWPDist;
		local float DotToTarget;
		local float SearchRadius;

		ZP = self;
		SearchRadius = 175; //1.5 m
		//clear list
	//	AdhesionForwardZombies.Remove(0,AdhesionForwardZombies.Length);
    TestDir = -Vector(IgnoredZombie.Rotation);
		foreach ZP.CollidingActors(Class'ZombiePawn', TestZP, SearchRadius)
		{
			if (ZP.IsValidMeleeTarget(TestZP) && TestZP != IgnoredZombie)
			{
				ToTestWPNorm = TestZP.Location - ZP.Location;
				ToTestWPDist = VSize(TestZP.Location - ZP.Location);
				ToTestWPNorm /= ToTestWPDist;
				DotToTarget = ToTestWPNorm Dot TestDir;
				if (DotToTarget < -0.5)  //120du
				{
					continue;
				}
				//TestZP.DoSpecialMove(SM_Zombie_Pushed, true);
				ZombieControllerTest(TestZP.Controller).PushedIndirect(); 
			}
		}

}
////////////////////////////////////
function HurtByZombieRecover()
{
	
	//setRotation(faceRot);
	EndSpecialMove();
	SetCollision(true,true);
	setphysics(PHYS_Walking);
  //  ZombiePC(Controller).HurtByZombieCinematicRecover();
	//DoSpecialMove(SM_Combat_GetHurt, true);
}


function EatedByZombie()
{
   local int rotDeltaYaw;
   local Vector NewLocation;
   rotDeltaYaw = abs(ZombiePC(Controller).InteractZombie.Rotation.Yaw - rotation.Yaw);
   //from back
   if(ZombiePC(Controller).InteractZombie.ZombieType == EZT_Walk && rotDeltaYaw >= 90* DegToUnrRot)
   {
     DoSpecialMove(SM_Player_Eated, true ,none,1);
   }
   else
   {
   	DoSpecialMove(SM_Player_Eated, true);
   }
}

//kismet handler
simulated function OnSpecialMovesHelper(SeqAct_SpecialMovesHelper inAction)
{
	local GfxZombie_Hud gfxHud;
	super.OnSpecialMovesHelper(inAction);
	gfxHud = ZombieHud(ZombiePC(Controller).myhud).GetGfxHud();
	if(inAction.bDisableDashBtn)
		gfxHud.DisbaleDashBtn();
	else
		gfxHud.EnbaleDashBtn();
	if(inAction.bDisableActBtn)
		gfxHud.DisbaleActBtn();
	else
		gfxHud.EnbaleActBtn();
	if(inAction.bDisableJumpBtn)
		gfxHud.DisbaleJumpBtn();
	else
		gfxHud.EnbaleJumpBtn();

	if (inAction.bOverrideGroundSpeed)
	{
		groundSpeed = inAction.GroundSpeed;
		bOverrideGroundSpeedKismet = true;
	}
	else
       bOverrideGroundSpeedKismet = false;
}

simulated function OnSetTransitInfo(SeqAct_SetTransitInfo inAction)
{
	if(ZombieRushPC(Controller) != none)
	   ZombieRushPC(Controller).TransitToActor(inAction.PickRandomDest());
}



//Push Cases
function bool PushCase()
{
	local Vector lStart;
	local Vector lEnd;
	local Vector lHitLocation;
	local Vector lHitNormal;
	local Actor lHitActor;

	// Determine the start and end points
	lStart = TransformVectorByRotation(Rotation, TraversalRays[0].Start);
	lStart = Location + lStart;

	lEnd = TransformVectorByRotation(Rotation, vect(65,0,0));
	lEnd = lStart + lEnd;

	// Test if we collide with anything.  Some things may collide, but we want to test
	// thier collision type before it's official.
	lHitActor = Trace(lHitLocation, lHitNormal, lEnd, lStart, true, , , TRACEFLAG_Bullet);
  
	//drawdebugline(lStart,lEnd,255,0,0,true);
	if (InterpActor(lHitActor) != none && (lHitActor.tag=='Case' || lHitActor.tag=='xiangzi_01'))
	{
		 SetRotation(rotator(-lHitNormal));
		InteractCase = lHitActor;
		//InteractCase.setphysics(PHYS_Interpolating);
		InteractCase.setBase(self);
		InteractCase.sethardattach(true);
		DoSpecialMove(SM_PushCase,true);
		return true;
	}
	else
		return false;
} 
function bool TraceCaseBlocked()
{
	local Vector lStart;
	local Vector lEnd;
	local vector Zoffset;
	local bool res1_left,res2_right,res3_mid;

	Zoffset = vect(0,0,10);
    if (InteractCase != none)
    {
		lStart = InteractCase.Location;
		lStart.z += 60;
		lEnd = TransformVectorByRotation(Rotation, CaseTraceVector);
		lEnd = lStart + lEnd;
`if(`isdefined(debug))
		drawdebugline(lStart,lEnd,255,0,0,true);
`endif	
		// returns true if did not hit world geometry
        res3_mid=InteractCase.FastTrace(lEnd,lStart,CaseTraceExtent);

		lStart = InteractCase.Location + Zoffset + TransformVectorByRotation(Rotation, vect(0,-60,0));
		lEnd = TransformVectorByRotation(Rotation, CaseTraceVector);
		lEnd = lStart + lEnd;
`if(`isdefined(debug))
		drawdebugline(lStart,lEnd,255,0,0,true);
`endif	
		// returns true if did not hit world geometry
		res1_left=InteractCase.FastTrace(lEnd,lStart);

		lStart = InteractCase.Location + Zoffset + TransformVectorByRotation(Rotation, vect(0,60,0));
		lEnd = TransformVectorByRotation(Rotation, CaseTraceVector);
		lEnd = lStart + lEnd;
`if(`isdefined(debug))
		drawdebugline(lStart,lEnd,255,0,0,true);
`endif	
		// returns true if did not hit world geometry
		res2_right=InteractCase.FastTrace(lEnd,lStart);

		return !(res1_left && res2_right && res3_mid);
    }

	return false;
}
function StopPushCase()
{
	if (IsDoingSpecialMove(SM_PushCase))
	{
		InteractCase.setBase(none);
		//InteractCase.setphysics(PHYS_Rigidbody);
		EndSpecialMove();
	}
}


function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local bool bSpecialMoveOverride;
	super.CalcCamera(fDeltaTime,out_CamLoc,out_CamRot,out_FOV);
	if (IsDoingASpecialMove())
	{
		bSpecialMoveOverride = SpecialMoves[SpecialMove].CalcCamera(fDeltaTime,out_CamLoc,out_CamRot,out_FOV);
		return bSpecialMoveOverride;
	}
	else
	  return false;
}
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal ){
	`log("Touch( Actor");
}
DefaultProperties
{


	Begin Object  Name=CollisionCylinder
		CollisionRadius=+0046.000000        NORMAL   //30
		CollisionHeight=+0086.000000        NORMAL  //cat = 46

		//CollisionRadius=+0009.000000
		//CollisionHeight=+0018.00000


		//Translation=(Z=90.0)
		//BlockRigidBody=TRUE
		//	BlockZeroExtent=True
		//	BlockNonZeroExtent=True

		//	blockactors=false
			RBChannel=RBCC_Pawn
			RBCollideWithChannels=(Default=FALSE,BlockingVolume=TRUE,Pawn=FALSE,Untitled1=true)
		End Object

/*
	Begin Object Class=CylinderComponent Name=CollisionCylinder1
	    CollisionRadius=+0056.000000        NORMAL   //30
	    CollisionHeight=+0086.000000        NORMAL  //cat = 46
		HiddenGame=FALSE
		CollideActors=TRUE
		BlockActors=FALSE
		BlockRigidBody=FALSE
		BlockZeroExtent=FALSE
		BlockNonZeroExtent=FALSE
		AlwaysCheckCollision=TRUE
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,FracturedMeshPart=FALSE)
	End Object
	Components.Add(CollisionCylinder1)*/
   // CollisionComponent=CollisionCylinder1

	Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
	    Translation=(Z=-90.0)             ////cat = -50
	BlockRigidBody=true;
	CollideActors=true;
	BlockZeroExtent=true;
	//BlockActors=true
	//PhysicsAsset=PhysicsAsset'UN_Heidi.Mesh.HD_heidi_skin_Physics'
	/*
		AnimSets(0)=AnimSet'UN_Heidi.Anim.HD_heidi_skin_Anims'
		AnimTreeTemplate=AnimTree'UN_Heidi.Anim.AT_heidi_01'
		SkeletalMesh=SkeletalMesh'UN_Heidi.Mesh.HD_heidi_skin'*/

		AnimSets(0)=AnimSet'ZOMBIE_animation.zhujuemengpi_Anims'
		AnimSets(1)=AnimSet'ZOMBIE_animation.zhujue_Anims'
		AnimSets(2)=AnimSet'ZOMBIE_animation.zhujue_level_00_indoor_Anims'
		AnimSets(3)=AnimSet'ZOMBIE_animation.zhujue_Anims_test'
		AnimSets(4)=AnimSet'ZOMBIE_animation.zhujue_Anims_new'
		AnimTreeTemplate=AnimTree'ZOMBIE_animation.AT_ZombieRole_01'
		SkeletalMesh=SkeletalMesh'zombie.Character.actor_01'
        PhysicsAsset=PhysicsAsset'zombie.Character.zhujuemengpi_2_Physics'
		LightingChannels=(Dynamic=TRUE,Cinematic_1=FALSE,bInitialized=TRUE)
		bAcceptsDynamicDominantLightShadows=FALSE
		bNoModSelfShadow=true
	//	bHasPhysicsAssetInstance=true
		//DepthPriorityGroup=SDPG_Foreground
		End Object

		Mesh=InitialSkeletalMesh;
	    Components.Add(InitialSkeletalMesh);
	//CollisionComponent=InitialSkeletalMesh


	InventoryManagerClass=class'ZBInventoryManager'


		// default bone names
		WeaponSocket=WeaponPoint
		MeleeSocket=MeleePoint
		GunSocket=GunPoint
		GunHoldSocket=GunHoldPoint
        WeaponType=0

		GroundSpeed=1000  // for RushPC
     //   GroundSpeed=525   //Normal
		drawscale=1.0

		//bCanCombat=true
		SpecialMoveClasses(0)=None
		SpecialMoveClasses(1)=none
		SpecialMoveClasses(2)=Class'ZGame.ZSM_Hit_One'
		SpecialMoveClasses(3)=Class'ZGame.ZSM_Hit_Two'
		SpecialMoveClasses(4)=Class'ZGame.ZSM_Hit_Thr'
		SpecialMoveClasses(5)=Class'ZGame.ZSM_JumpStart'
		SpecialMoveClasses(6)=class'ZGame.ZSM_GetHurt'
		SpecialMoveClasses(7)=class'ZGame.ZSM_Hit_Air'
		SpecialMoveClasses(8)=class'ZGame.ZSM_CustomJump'
		SpecialMoveClasses(9)=class'ZGame.ZSM_Push'
		SpecialMoveClasses(10)=none
		SpecialMoveClasses(11)=class'ZGame.ZSM_Eated'
		SpecialMoveClasses(12)=none
		SpecialMoveClasses(13)=none
		SpecialMoveClasses(14)=class'ZGame.ZSM_Exhausted'
		SpecialMoveClasses(15)=none
		SpecialMoveClasses(16)=none
		SpecialMoveClasses(17)=class'ZGame.ZSM_GunFire'
		SpecialMoveClasses(18)=class'ZGame.ZSM_KickDoor'
		SpecialMoveClasses(19)=class'ZGame.ZSM_PushCase'
		SpecialMoveClasses(20)=class'ZGame.ZSM_TripOver'
		SpecialMoveClasses(21)=class'ZGame.ZSM_ClimbBlocade'
		SpecialMoveClasses(22)=class'ZGame.ZSM_RunTurn'
		SpecialMoveClasses(23)=class'ZGame.ZSM_Gun_Reload'
		SpecialMoveClasses(24)=class'ZGame.ZSM_RunIntoWall'
		SpecialMoveClasses(25)=class'ZGame.ZSM_Parkour_StrafeLeft'
		SpecialMoveClasses(26)=class'ZGame.ZSM_Parkour_StrafeRight'
        SpecialMoveClasses(27)=class'ZGame.ZSM_Parkour_KnockDown'
        SpecialMoveClasses(28)=class'ZGame.ZSM_Parkour_GetUp'
   //  MaxStepHeight=20    //35 normal
	 //  MaxJumpHeight=0.0   //96 normal
	  // WalkableFloorZ=0.001		   // 0.7 ~= 45 degree angle for floor
	  WalkableFloorZ=0.78
	  MaxStepHeight=26.0
	  MaxJumpHeight=49.0



       WalkJumpScale=100       //45
	  
	   AirSpeed=440.0

	//   bAllowLedgeOverhang=FALSE
	//   bStopAtLedges=true
	//   bAvoidLedges=true


	PlayerHealth=100

	PlayerPower=400

//	JumpZ=1060  //normal 420

    JumpZ=420
	TraversalRays(0)=(Key="forward_origin",Start=(X=0,Y=0,Z=0),Length=(X=65,Y=0,Z=0))
	//as collision radius
	TraversalRays(1)=(Key="forward_left",Start=(X=0,Y=-46,Z=0),Length=(X=65,Y=0,Z=0))
	TraversalRays(2)=(Key="forward_right",Start=(X=0,Y=46,Z=0),Length=(X=65,Y=0,Z=0))
	CaseTraceVector=(X=85,Y=0,Z=0)
	CaseTraceExtent=(X=10,Y=30,Z=20)
	bDirectHitWall=true
	
	bCanBeFrictionedTo=false

}

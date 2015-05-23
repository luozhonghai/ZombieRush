class ZombiePawn extends UDKPawn
dependson(ZombieSpawnNodeDistance)
implements(IDebugInterface);

/** Defines the pawn's light environment */
var DynamicLightEnvironmentComponent LightEnvironment;



var() EZombieType ZombieType;
var() EZombieAnimType ZombieAnimType;
/** WeaponSocket contains the name of the socket used for attaching weapons to this pawn. */
var name WeaponSocket,GunHoldSocket;

var bool bIsJumping;

var float JumpStartHeight;

//是否meleeattack
var bool bDoingMeleeAttack;

//jump use
var bool bIsLanding;

struct PhysConfig
{
  var(HitReaction) name Actor_Tag;

  var(HitReaction) vector BumpDir;

  var(HitReaction) array<Name> EnabledSpringBodyNames;
    // Linear bone spring strength to use when hit reaction is simulated
  var(HitReaction) float LinearBoneSpringStrength;
  // Angular bone spring strength to use when hit reaction is simulated
  var(HitReaction) float AngularBoneSpringStrength;
  // Radius of the force to apply
  var(HitReaction) float ForceRadius;

  var(HitReaction) int DamageAmount;
  // Force amplification
  var(HitReaction) float ForceAmplification;
  // Maximum amount of force that can be applied 
  var(HitReaction) float MaximumForceThatCanBeApplied;
  // Blend in time for the hit reaction
  var(HitReaction) float PhysicsBlendInTime;
  // Physics simulation time for the hit reaction
  var(HitReaction) float PhysicsTime;
  // Blend out time for the hit reaction
  var(HitReaction) float PhysicsBlendOutTime;

  var(HitReaction) float PhysicWeightScale;

  //deprecated
  var bool	bForceZeroPhysicsWeightStart;
  //deprecated
	var bool	bForceZeroPhysicsWeightEnd;

	var(HitReaction) bool	bCallPreMesh;

	var(HitReaction) bool	bCallPostMesh;

	structdefaultproperties
	{
		bCallPreMesh=true;
		bCallPostMesh=true;
	}
};

enum ESpecialMove
{
	SM_None,
	SM_COMBO_begin,// just a signal for we in combo sp range
	SM_MeleeAttack1,
	SM_MeleeAttack2,
	SM_MeleeAttack3,
	SM_PHYS_Trans_Jump,
	SM_Combat_GetHurt,
	SM_AirAttack,
	SM_Custom_Jump,
	SM_Player_Push,
	SM_Zombie_Pushed,
	SM_Player_Eated,
	SM_Zombie_EatPre,
	SM_Zombie_Eat,
	SM_Player_Exhausted,
	SM_Zombie_CutDown,
	SM_Zombie_MeleeAttackPre,
	SM_GunAttack,
	SM_KickDoor,
	SM_PushCase,
	SM_TripOver,
	SM_ClimbBlocade,
	SM_RunTurn,
	SM_Gun_Reload,
	SM_RunIntoWall,
	SM_Parkour_StrafeLeft,
	SM_Parkour_StrafeRight,
	SM_Parkour_KnockDown,
	SM_Parkour_GetUp,
	SM_ClimbUp,
	SM_Kick,
};

//AnimConfig
//Animation
enum EConfigAnimPlayType
{
	ECAPT_RandomPickupOne,
	ECAPT_OneByOne,// not implement
};

enum EAnimConfigType
{
	EACT_None,
	EACT_Arbitrary,
	EACT_TakeDamage,
};

enum EAnimBlendNodeIndex
{
	EABLIdx_Slot_FullBody_Main,
	EABLIdx_Slot_HalfBody_Upper_Main,
	EABLIdx_PerBone_BlendUpperLower_Main,
};

struct  AnimationParaConfig
{
	//var int pad; //pad to avoid align problem
	var()   array<name> AnimationNames;
	var()	  EAnimBlendNodeIndex  BlendNodeIndex;
	var()   int	AnimType;//EAnimConfigType for Alice, N for NPC
	var()   float BlendInTime;
	var()   float BlendOutTime;
	var()   float PlayRate;
	var()   bool bLoop;
	var()   bool bCauseActorAnimEnd;
	var()   bool bTriggerFakeRootMotion;
	var()   bool bNotExtendAnimTimeForFakeRootMotion;
	var()   EConfigAnimPlayType AnimPlayType;
	var()   ERootBoneAxis RootBoneTransitionOption[3];
	var()   ERootRotationOption RootBoneRotationOption[3];
	var()   ERootMotionMode FakeRootMotionMode;
	var()  editoronly string         AnimationDescName;

	structdefaultproperties
	{
		AnimationNames.Empty();
		BlendNodeIndex = EABLIdx_Slot_FullBody_Main;
		AnimType	   = EACT_None;
		AnimPlayType = ECAPT_RandomPickupOne;

		RootBoneTransitionOption[0] = RBA_Default;
		RootBoneTransitionOption[1] = RBA_Default;
		RootBoneTransitionOption[2] = RBA_Default;

		RootBoneRotationOption[0] = RRO_Default;
		RootBoneRotationOption[1] = RRO_Default;
		RootBoneRotationOption[2] = RRO_Default;

		FakeRootMotionMode = RMM_Accel;

		bLoop=false;
		bCauseActorAnimEnd = true;
		bTriggerFakeRootMotion = false;
		bNotExtendAnimTimeForFakeRootMotion = false;
		BlendInTime=0.15f;
		BlendOutTime=0.15f;
		PlayRate=1.0f;
	}
};





struct  SMStruct
{
	/** Special Move Enum being performed. */
	var ESpecialMove	SpecialMove;
	/** Interaction Pawn */
	var ZombiePawn		InteractionPawn;
	/** Additional Replicated Flags */
	var INT				Flags;

	var delegate <OnSpecialMoveEnd> OnSpecialMoveEndFun;
};


/** Special move currently performed by Pawn. SM_None, when doing none. */
var	ESpecialMove					SpecialMove, PreviousSpecialMove;
/** Special move pending, activated after the current one terminates. */
var SMStruct						PendingSpecialMoveStruct;
/** Are we currently in the process of ending a special move, and should force new moves to delay? */
var transient bool					bEndingSpecialMove;


/** Array matching above enumeration. List of classes to Instance */
var Array<class<ZBSpecialMove> >	SpecialMoveClasses;


//For Archetypes(原型)
var() Array<ZBSpecialMove> SpecialMovesArche;

/** Array of instanced special moves */
var Array<ZBSpecialMove> SpecialMoves;

/**Array of disable flags*/
var Array<bool> SpecialMovesDisableFlags;
/** INT to pack any additional data into special moves, and get it replicated so it's consistent across network. */
var				INT					SpecialMoveFlags;


/**for some physics state transition, we utilize this pending physics mechanism to support playing a custom animation in this transition*/

var	vector	PendingVelocity;

var(SkelControl) Name LeftArmSkelControlName;
var(SkelControl) Name RightArmSkelControlName;

var SkelControlLimb LeftArmSkelControl;
var SkelControlLimb RightArmSkelControl;

var PhysConfig PhysicsEffectData;
var Actor InteractingLevelActor;
var Rotator RotationCached;
var float BaseTranslationOffset;

delegate OnSpecialMoveEnd(ZBSpecialMove SpecialMoveObject);

/** Any initialization should be done here.  
 *  I thought we could use PostPlayBegin, but in looking
 *  through the root objects, not everything is initialized for us by then.  This
 *  function will be called once the default UDK initialization is complete. */
event Initialize()
{
	local int j;
	for(j=0;j < SpecialMoveClasses.length;j++)
	 SpecialMovesDisableFlags[j] = false;
	BaseTranslationOffset = Mesh.Translation.Z;
}
/**
 *   Calculate camera view point, when viewing this pawn.
 *
 * @param   fDeltaTime   delta time seconds since last update
 * @param   out_CamLoc   Camera Location
 * @param   out_CamRot   Camera Rotation
 * @param   out_FOV      Field of View
 *
 * @return   true if Pawn should provide the camera point of view.
 */
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
   //return false to allow custom camera to control its location and rotation
      return false;
}



event tick(float deltaTime)
{
	super.tick(deltaTime);
	if(SpecialMove!=SM_None)
		SpecialMoves[SpecialMove].tickspecial(deltaTime);
}
/**Speical Moves */
/** Make sure a special move has been instanced */
simulated final function bool VerifySMHasBeenInstanced(ESpecialMove AMove)
{
	if( AMove != SM_None )
	{
		if( AMove >= SpecialMoves.Length || SpecialMoves[AMove] == None )
		{
			if( AMove < SpecialMoveClasses.Length && SpecialMoveClasses[AMove] != None )
			{
				if( AMove < SpecialMovesArche.Length && SpecialMovesArche[AMove] != None )
				{
				 SpecialMoves[AMove]=new(Outer) SpecialMoveClasses[AMove](SpecialMovesArche[AMove]);
				}
				else
				{
				 SpecialMoves[AMove] = new(Outer) SpecialMoveClasses[AMove];
				}

				// Cache a reference to the owner to avoid passing parameters around.
				SpecialMoves[AMove].PawnOwner = Self;
			}
			else
			{
				//LogInternal(GetFuncName() @ "Failed with special move:" @ AMove @ "class:" @ SpecialMoveClasses[AMove] @ Self);
				SpecialMoves[AMove] = None;
				return FALSE;
			}
		}
		return TRUE;
	}
	return FALSE;
}

/**
 * Convenience function which takes special move params and returns a SMStruct.
 */
simulated final function SMStruct FillSMStructFromParams(ESpecialMove InSpecialMove, optional ZombiePawn InInteractionPawn, optional INT InSpecialMoveFlags=0, optional delegate<OnSpecialMoveEnd> SpecialMoveEndNotify)
{
	local SMStruct	OutSpecialMoveStruct;

	OutSpecialMoveStruct.SpecialMove = InSpecialMove;
	OutSpecialMoveStruct.InteractionPawn = InInteractionPawn;
	OutSpecialMoveStruct.Flags = InSpecialMoveFlags;

	if (InSpecialMove != SM_None)
	{
		OutSpecialMoveStruct.OnSpecialMoveEndFun = SpecialMoveEndNotify;
		SpecialMoves[InSpecialMove].OnSpecialMoveEnd = SpecialMoveEndNotify;
	}


	return OutSpecialMoveStruct;
}
/** Convenience function to spit out a SpecialMoveStruct into a String */
simulated final function String SMStructToString(SMStruct InSMStruct)
{
	return "[SpecialMove:" @ InSMStruct.SpecialMove $ ", InteractionPawn:" @ InSMStruct.InteractionPawn $ ", SpecialMoveFlags:" @ InSMStruct.Flags$"]";
}

simulated final function String SpecialMoveToString(ESpecialMove InSpecialMove, ZombiePawn InInteractionPawn, INT InSpecialMoveFlags)
{
	return "[SpecialMove:" @ InSpecialMove $ ", InteractionPawn:" @ InInteractionPawn $ ", SpecialMoveFlags:" @ InSpecialMoveFlags $ "]";
}

/**
 * Request to abort/stop current SpecialMove
 * This is not replicated to owning client. See ClientEndSpecialMove() below for this.
 */
final simulated exec function EndSpecialMove(optional ESpecialMove SpecialMoveToEnd)
{
	;

	if( IsDoingASpecialMove() )
	{
		// clear the pending move
		if( SpecialMoveToEnd != SM_None && PendingSpecialMoveStruct.SpecialMove == SpecialMoveToEnd )
		{
			PendingSpecialMoveStruct = FillSMStructFromParams(SM_None);
		}

		// if no move specified, or it matches the current move
		if( SpecialMoveToEnd == SM_None || IsDoingSpecialMove(SpecialMoveToEnd) )
		{
			// force it to end
			DoSpecialMove(SM_None, TRUE);
		}
	}
}

simulated event bool DoSpecialMove(ESpecialMove NewMove, optional bool bForceMove, optional ZombiePawn InInteractionPawn, optional INT InSpecialMoveFlags, optional delegate<OnSpecialMoveEnd> SpecialMoveEndNotify)
{
	local ESpecialMove	PrevMove;
	local SMStruct		NewMoveStruct;

	;
	/*
     if(SpecialMovesDisableFlags[NewMove])
		 return false;*/

	// ignore redundant calls to the same move
	if( NewMove == SpecialMove && !SpecialMoves[NewMove].bCanRepeat )
	{
		;
		return false;
	}

	// Make sure NewMove is instanced.
	if( NewMove != SM_None && !VerifySMHasBeenInstanced(NewMove) )
	{
	//	WarnInternal(WorldInfo.TimeSeconds @ Self @ GetFuncName() @ "couldn't instance special move" @ NewMove);
		return false;
	}

	// Create struct for new move.
	NewMoveStruct = FillSMStructFromParams(NewMove, InInteractionPawn, InSpecialMoveFlags,SpecialMoveEndNotify);

	// If we're currently in the process of ending the current move
	if( bEndingSpecialMove )
	{
		// Then force the new request to pending
		;
		PendingSpecialMoveStruct = NewMoveStruct;
		return true;
	}

	// if currently doing a special move and not a normal end or is a forced move
	if( SpecialMove != SM_None && !bForceMove && NewMove != SM_None )
	{
		// See if we can override current special move, otherwise just queue new one until current is finished.
		if( SpecialMoves[SpecialMove].CanOverrideMoveWith(NewMove) || SpecialMoves[NewMove].CanOverrideSpecialMove(SpecialMove) )
		{
			bForceMove = TRUE;
			;
		}
		else
		{
			// extra check to see if we can chain since non-owning clients can call DoSpecialMove directly in certain cases
			if( SpecialMoves[SpecialMove].CanChainMove(NewMove) )
			{
				;
				PendingSpecialMoveStruct = NewMoveStruct;
				return true;
			}
			else
			{
				//WarnInternal(WorldInfo.TimeSeconds @ Self @ GetFuncName() @ "Cannot override, cannot chain." @ NewMove @ "is lost! SpecialMove:" @ SpecialMove @ "Pending:" @ SMStructToString(PendingSpecialMoveStruct));
				return false;
			}
		}
	}

	// Check that we can do special move and special move has been/can be instanced
	if( NewMove != SM_None && !bForceMove && !CanDoSpecialMove(NewMove) )
	{
		//WarnInternal(WorldInfo.TimeSeconds @ Self @ GetFuncName() @ "cannot do requested special move" @ NewMove);
		return false;
	}

	PrevMove = SpecialMove;

	// Stop previous special move
	if( SpecialMove != SM_None )
	{
		;
		bEndingSpecialMove = TRUE;
		// clear the special move so that checks like IsDoingSpecialMove and IsEvading no longer pass
		SpecialMove = SM_None;
		SpecialMoveEnded(PrevMove, NewMove);
		bEndingSpecialMove = FALSE;
	}

	// Set new special move
	;
	SpecialMove = NewMove;

	

	SpecialMoveFlags = InSpecialMoveFlags;
// 	ScriptTrace();

	// Notification of a special move state change.
	SpecialMoveAssigned(NewMove, PrevMove);

	// if it's a valid special move
	if( NewMove != SM_None )
	{
		// notify the special move it should start
		SpecialMoveStarted(NewMove, PrevMove, bForceMove,InSpecialMoveFlags);

		// if this was a forced move clear any pending moves since this was an interrupt of the current move
		if( bForceMove )
		{
			PendingSpecialMoveStruct = FillSMStructFromParams(SM_None, None, 0);
		}
	}
	else
	// otherwise start the pending special move
	if( PendingSpecialMoveStruct.SpecialMove != SM_None )
	{
		;
		NewMoveStruct = PendingSpecialMoveStruct;
		PendingSpecialMoveStruct = FillSMStructFromParams(SM_None, None, 0);
		DoSpecialMoveFromStruct(NewMoveStruct, FALSE);
	}

	return true;
}
/**
 * Convenience function that takes a SpecialMoveStruct, and calls DoSpecialMove() from its parameters.
 */
simulated final function DoSpecialMoveFromStruct(SMStruct InSpecialMoveStruct, optional bool bForceMove)
{
	DoSpecialMove(InSpecialMoveStruct.SpecialMove, bForceMove, InSpecialMoveStruct.InteractionPawn, InSpecialMoveStruct.Flags, InSpecialMoveStruct.OnSpecialMoveEndFun);
}

/** Event called when A new special move has started */
simulated final function SpecialMoveStarted(ESpecialMove NewMove, ESpecialMove PrevMove, bool bForced, optional INT InSpecialMoveFlags)
{
	local ZombiePC	PC;
	if( NewMove != SM_None )
	{
		// notify controller that special move started.
		PC = ZombiePC(Controller);
		if( PC != None )
		{
		//	PC.SpecialMoveStarted(NewMove);
		}
		// forward notification to special move instance
		if( SpecialMoves[NewMove] != None )
		{
			SpecialMoves[NewMove].SpecialMoveStarted(bForced,PrevMove,InSpecialMoveFlags);
		}

		else
		{
		//	LogInternal("No class for special move:" @ NewMove @ self);
		}

	}
}


/** Event called when A new special move has stopped */
simulated final function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	if( PrevMove != SM_None )
	{
		if( SpecialMoves[PrevMove] != None )
		{
			SpecialMoves[PrevMove].SpecialMoveEnded(PrevMove, NextMove);
		}

		else
		{
			;
		}
	}
}

/* Notification called when SpecialMove enum changes. */
simulated function SpecialMoveAssigned(ESpecialMove NewMove, ESpecialMove PrevMove)
{
	;

	PreviousSpecialMove = PrevMove;
}


/**
 * Return TRUE if Special Move can be performed
 * @param bForceCheck - Allows you to skip the single frame condition (which will be incorrect on clients since LastCanDoSpecialMoveTime isn't replicated)
 */
simulated final event bool CanDoSpecialMove(ESpecialMove AMove, optional bool bForceCheck)
{

	/////luo 20150518
	// comment Physics != PHYS_RigidBody for physics blend
	// if it is a valid move and we have a class for the move
	if (/*Physics != PHYS_RigidBody &&*/ AMove != SM_None && SpecialMoveClasses.length > AMove && SpecialMoveClasses[AMove] != None)
	{
		// Make sure special move is instanced
		if( VerifySMHasBeenInstanced(AMove) )
		{
			// and check the instance
			return (CanChainSpecialMove(AMove) && SpecialMoves[AMove].CanDoSpecialMove(bForceCheck));
		}
	//	LogInternal(GetFuncName() @ "Failed with special move:" @ AMove @ "class:" @ SpecialMoveClasses[AMove] @ Self);
	}
	return FALSE;
}

/** Returns TRUE if the pawn can chain this special move after the current one finishes (or if there currently isn't a special move) */
simulated final function bool CanChainSpecialMove(ESpecialMove NextMove)
{
	return (SpecialMove == SM_None || SpecialMoves[SpecialMove].CanChainMove(NextMove) || SpecialMoves[SpecialMove].CanOverrideMoveWith(NextMove) || SpecialMoves[NextMove].CanOverrideSpecialMove(SpecialMove));
}




/** Returns TRUE if player is current performing AMove. */
simulated final  function bool IsDoingSpecialMove(ESpecialMove AMove) 
	{
      return (SpecialMove == AMove && !bEndingSpecialMove);
	}

simulated final  function bool IsDoingASpecialMove() 
{
	return (SpecialMove != SM_None && !bEndingSpecialMove);
}


function PlayConfigAnim( const  AnimationParaConfig AnimConfig, optional int blendnodeindex = 0, optional int configtype = -1 )
{
 
    
}

function StopConfigAnim(const  AnimationParaConfig AnimConfig, float BlendOutTime)
{
}


///////////////////////////////////
//
//动画回调函数（AnimNotify）
//For Battle
//
////////////////////////////////////
//simulated function AnimCfg_AnimEndNotify()
/** Event called when body stance animation finished playing */
simulated function AnimCfg_AnimEndNotify()
{
	//	if(bDebug)
		//`log("AnimCfg_AnimEndNotify");
	// Forward notification to Special Move if doing any.
	if( SpecialMove != SM_None )
	{
		;
		SpecialMoves[SpecialMove].AnimCfg_AnimEndNotify();

        //ZombiePC(Controller).ClientMessage("AnimCfg_AnimEndNotify");
		if( ZBWeaponForce(Weapon) != None && Weapon.IsFiring() )//temp condition
		{
			SetTimer(0.01,false,'ZBWeaponCombo');
			
			//ZBWeaponForce(Weapon).NotifyFireSpecialMoveFinished();
		}
	}
}
function ZBWeaponCombo()
{
	ZBWeaponForce(Weapon).ComboInputAcceptStart();
	TimerNotifyComboBlendingStart();
}
//from timer set notify strategy 
function TimerNotifyComboBlendingStart()
{
    ZBWeaponForce(Weapon).NotifyComboBlendingStart();
	SetTimer(0.5,false,'TimerComboInputAcceptFinish');
}
function TimerComboInputAcceptFinish()
{
    ZBWeaponForce(Weapon).ComboInputAcceptFinish();
	ZBWeaponForce(Weapon).NotifyFireSpecialMoveFinished();
}

function EndComboInputTimer()
{
	ClearTimer('TimerComboInputAcceptFinish');
}
function NotifyComboBlendingStart()
{
	//	if(bDebug)
		//`log("NotifyComboBlendingStart");
   //ZBWeaponForce(Weapon).NotifyComboBlendingStart();
}

/**
 * Message from Animation , means we don't accept more input for combo
 */
 function ComboInputAcceptFinish()
{
	//if(bDebug)
		//`log("ComboInputAcceptFinish");
//	 ZBWeaponForce(Weapon).ComboInputAcceptFinish();

}
/**
 * Message from Animation , means we begin accept more input for combo
 */
 function ComboInputAcceptStart()
{
	//if(bDebug)
		//`log("ComboInputAcceptStart");
	// ZBWeaponForce(Weapon).ComboInputAcceptStart();
}

 //anim notify, let the AI know to begin attack traces when we're playing melee animation
 event MeleeSwingStart()
 {
	 ZBWeaponForce(Weapon).StartMeleeSwing();
 }

 //anim notify, let the AI know to end attack traces when we're playing melee animation
 event MeleeSwingEnd()
 {
	 ZBWeaponForce(Weapon).EndMeleeSwing();
 }

 function CrushedBy(Pawn OtherPawn)
 {
	 return;
 }















 /**
    Melee attack
 */

 function Vector GetMeleeSwingLocation();
 function Vector GetMeleeSwingLocation2();
 function GetFirSocketLocationAndDir(out vector loc,out vector dir);
 simulated function Vector GetBaseTargetLocation()
 {
	 return Location;
 }
 simulated function float GetMeleeAttackRange()
 {
	 local ZBWeaponForce WW;
	 WW = ZBWeaponForce(Weapon);

	 if (WW!= None)
	 {
		return WW.MeleeAttackRange;
	 }
	 else
		 return 0;
	// return ((WW!= None)? WW.MeleeAttackRange : 0);
 }

 simulated function bool IsValidMeleeTarget(ZombiePawn WP)
 {
	 return WP != self && WP.Health > 0 ;
 }


 simulated function MeleeAttackStarted(ZBWeapon Weap)
 {
	 local ZombiePC WPC;
	 local ZombiePawn AdhesionTarget;

	 bDoingMeleeAttack = true;

	 WPC = ZombiePC(Controller);


	 if (WPC != None)
	 {

	    AdhesionTarget = WPC.AttemptMeleeAdhesion();
		 
	 }
 }

 simulated function MeleeAttackEnded(ZBWeapon Weap)
 {
	 local ZombiePC PC;
	   // LastMeleeAttackTime = WorldInfo.TimeSeconds;
	    bDoingMeleeAttack = false;
	 PC = ZombiePC(Controller);
	 if (PC != None)
	 {
		 PC.StopMeleeAdhesion();
	 }
 }

 function KnockBack()
 {
 }



 //dela with die
 function CustomDie()
 {
	 Controller.PawnDied(self);
	 Destroy();
 }

 //deal with ex damage like cut down by axe
 function TakeExDamage();

/***********
 Kismet
*/
 simulated function OnDoSpecialMove(SeqAct_DoSpecialMove inAction)
 {
	 DoSpecialMove(inAction.SpecialMove, true);
 }
 simulated function OnEndSpecialMove(SeqAct_EndSpecialMove inAction)
 {
	EndSpecialMove();
 }

simulated function OnSpecialMovesHelper(SeqAct_SpecialMovesHelper inAction)
 {
	 local int length,i;
	 local ESpecialMove j;
	 local bool bDisable;
	 length = inAction.SpecialMovesConfig.length;
	 for(i=0;i<length;i++)
	 {
		 j = inAction.SpecialMovesConfig[i].SpecialMove;
		 bDisable = inAction.SpecialMovesConfig[i].bDisable;
		 SpecialMovesDisableFlags[j] = bDisable;
	 }
 }


 //physics

//call from special move
function ActivePhysicsEffect(PhysConfig data)
{
	PhysicsEffectData = data;
	TakePhysicsamage(PhysicsEffectData.DamageAmount, GetALocalPlayerController(), Location, Normal(PhysicsEffectData.BumpDir) >> Rotation, class'DamageType');
}

function PrePhysicsEffectMesh()
{
	
	RotationCached = Rotation;
	PreRagdollCollisionComponent = CollisionComponent;
	CollisionComponent = Mesh;
  
// Turn collision on for skelmeshcomp and off for cylinder
	CylinderComponent.SetActorCollision(false, false);
	Mesh.SetActorCollision(true, true);
	Mesh.SetTraceBlocking(true, true);
  SetPawnRBChannels(True);


// Move into post so that we are hitting physics from last frame, rather than animated from this
	Mesh.SetTickGroup(TG_PostAsyncWork);
	SetPhysics(PHYS_RigidBody);
  Mesh.PhysicsWeight = 0.f;
	//if(PhysicsEffectData.bForceZeroPhysicsWeightStart)
  //	Mesh.PhysicsWeight = 0.f;
}

function DebugPrePhysicsEffectMesh()
{
	
	RotationCached = Rotation;
	PreRagdollCollisionComponent = CollisionComponent;
	CollisionComponent = Mesh;
  
// Turn collision on for skelmeshcomp and off for cylinder
	CylinderComponent.SetActorCollision(false, false);
	Mesh.SetActorCollision(true, true);
	Mesh.SetTraceBlocking(true, true);
  SetPawnRBChannels(True);


// Move into post so that we are hitting physics from last frame, rather than animated from this
	Mesh.SetTickGroup(TG_PostAsyncWork);
	SetPhysics(PHYS_RigidBody);
	Mesh.PhysicsWeight = 1.0f;
	Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
	Mesh.bUpdateKinematicBonesFromAnimation=FALSE;
	Mesh.WakeRigidBody();
	//SetPhysics(PHYS_None);

	//SetRotation(RotationCached);
	settimer(1.0,false,'RecoverRot');
}

function RecoverRot()
{
	local Vector TraceEnd,HitLocation,HitNormal;
	local Actor TracedActor;
	local float AdjustOffset;
	`log("recover rot  in");
	/*
	CollisionComponent = PreRagdollCollisionComponent;
	TraceEnd = Location - vect(0,0,1) * 10 *GetCollisionHeight();

	TracedActor = Trace(HitLocation, HitNormal, TraceEnd, Location, true);//GetCollisionExtent());
	//Drawdebugline(Location, HitLocation,0,255,0,TRUE);
	if (TracedActor != None )
	{
		`log("move offset"@TracedActor@HitLocation.z);
		HitLocation.z = HitLocation.z +  GetCollisionHeight();
		`log("move offset"@TracedActor@HitLocation.z @Location.z);
		//SetLocation(HitLocation);
    AdjustOffset = Location.z - HitLocation.z - 5;
    if(AdjustOffset > 2)
		  //moveSmooth(vect(0,0,-1) * AdjustOffset);
	}
  CollisionComponent = Mesh;*/
  
	SetPhysics(PHYS_None);
	SetRotation(RotationCached);
	//setPhysics(PHYS_Falling);
}

function PostPhysicsEffectMesh()
{
	//CollisionComponent = CylinderComponent;
	CylinderComponent.SetActorCollision(true, true);
	Mesh.SetActorCollision(false, false);
	Mesh.SetTraceBlocking(false, false);

	Mesh.SetTickGroup(TG_PreAsyncWork);

	//setPhysics(PHYS_Falling);
	RestorePreRagdollCollisionComponent();
	SetPawnRBChannels(FALSE);
	Mesh.bUpdateKinematicBonesFromAnimation=TRUE;
	//if(PhysicsEffectData.bForceZeroPhysicsWeightEnd)
	//	Mesh.PhysicsWeight = 0.f;
	//SetRotation(RotationCached);
}

simulated function SetPawnRBChannels(bool bRagdollMode)
{
	if(bRagdollMode)
	{
		Mesh.SetRBChannel(RBCC_Pawn);
		Mesh.SetRBCollidesWithChannel(RBCC_Default,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_Pawn,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,TRUE);
	}
	else
	{
		Mesh.SetRBChannel(RBCC_Untitled3);
		Mesh.SetRBCollidesWithChannel(RBCC_Default,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_Pawn,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,FALSE);
	}
}


//call from special move
function ProcessPhysicsEffectTick(float DeltaTime)
{
	local Vector RootLocation;
	local Rotator RootRotation;
	local rotator NewRotation;
	Super.Tick(DeltaTime);

	if (IsTimerActive(NameOf(SimulatingPhysicsBlendIn)))
	{
		// Blending in physics
		//`log("0->1");
		Mesh.PhysicsWeight = PhysicsEffectData.PhysicWeightScale * GetTimerCount(NameOf(SimulatingPhysicsBlendIn)) / GetTimerRate(NameOf(SimulatingPhysicsBlendIn));
	}
	else if(IsTimerActive(NameOf(Fix_SimulatingPhysics)))
  {
  	// 	RootLocation = SkeletalMeshComponent.GetBoneLocation('Bip01',0);
  	// 	RootLocation.z = Location.z;
			// SetLocation(RootLocation);
			// RootRotation = QuatToRotator(SkeletalMeshComponent.GetBoneQuaternion('Bip01',0));
			// RootRotation.pitch = 0;
			// SetRotation(RootRotation);
			//`log("blending in");
  } 
	else if (IsTimerActive(NameOf(SimulatedPhysicsBlendOut)))
	{
		// Blending out physics
		//`log("1->0");
		Mesh.PhysicsWeight = PhysicsEffectData.PhysicWeightScale * (1.f - (GetTimerCount(NameOf(SimulatedPhysicsBlendOut)) / GetTimerRate(NameOf(SimulatedPhysicsBlendOut))));
	}
  
  /*
  NewRotation = Controller.Rotation;
  NewRotation.yaw = RotationCached.yaw;
  Controller.SetRotation(NewRotation);
  SetRotation(RotationCached);
	*/
}

function DrawDebug(HUD myHud)
{
	  local Canvas can;
	  can = myHud.canvas;
	  can.SetPos(400,170);
    can.DrawText("SimulatingPhysicsBlendIn:"@IsTimerActive(NameOf(SimulatingPhysicsBlendIn)));
    can.SetPos(400,190);
    can.DrawText("Fix_SimulatingPhysics:"@IsTimerActive(NameOf(Fix_SimulatingPhysics)));
    can.SetPos(400,210);
    can.DrawText("SimulatedPhysicsBlendOut:"@IsTimerActive(NameOf(SimulatedPhysicsBlendOut)));
}
 event TakePhysicsamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if (IsTimerActive(NameOf(SimulatingPhysicsBlendIn)) || IsTimerActive(NameOf(Fix_SimulatingPhysics)) || IsTimerActive(NameOf(SimulatedPhysicsBlendOut)))
	{
			return;
	}
	if(PhysicsEffectData.bCallPreMesh)
		TurnOnRagdoll(Normal(Momentum) * FMin(DamageAmount * PhysicsEffectData.ForceAmplification, PhysicsEffectData.MaximumForceThatCanBeApplied));
	 BlendInPhysics();
}

function TurnOnRagdoll(Vector RBLinearVelocity)
{
	// Force update the skeleton
	Mesh.ForceSkelUpdate();
	Mesh.PhysicsAssetInstance.SetAllBodiesFixed(false);
		// Enable springs on bodies that are required in the physical hit reaction
	if (PhysicsEffectData.EnabledSpringBodyNames.Length > 0)
	{
	//	Mesh.PhysicsAssetInstance.SetNamedRBBoneSprings(true, PhysicsEffectData.EnabledSpringBodyNames, PhysicsEffectData.LinearBoneSpringStrength, PhysicsEffectData.AngularBoneSpringStrength, Mesh);
	}
	Mesh.bUpdateKinematicBonesFromAnimation = false;
	`log(RBLinearVelocity);
	Mesh.SetRBLinearVelocity(RBLinearVelocity, true);
	Mesh.SetTranslation(vect(0,0,1) * BaseTranslationOffset);
	Mesh.WakeRigidBody();
}


function BlendInPhysics()
{
	// Set the timer for the physics to blend in
	if (PhysicsEffectData.PhysicsBlendInTime > 0.f)
	{
		SetTimer(PhysicsEffectData.PhysicsBlendInTime, false, NameOf(SimulatingPhysicsBlendIn));
	}
	else 
	{
		Mesh.PhysicsWeight = PhysicsEffectData.PhysicWeightScale * 1.f;
		SimulatingPhysicsBlendIn();
	}
}

function SimulatingPhysicsBlendIn()
{
	`log("SimulatingPhysicsBlendIn");
	if (PhysicsEffectData.PhysicsTime == 0.f)
	{
		RecoverRot();
		SetTimer(PhysicsEffectData.PhysicsBlendOutTime, false, NameOf(SimulatedPhysicsBlendOut));
	}
	else
	{
		// Set the timer for the physics to stay
		SetTimer(PhysicsEffectData.PhysicsTime, false, NameOf(Fix_SimulatingPhysics));
	}
}

// for debug
function PhysicsBlendOut_Fix()
{
	`log("PhysicsBlendOut");
	//ClearTimer(NameOf(Fix_SimulatingPhysics));
	SetTimer(PhysicsEffectData.PhysicsBlendOutTime, false, NameOf(SimulatedPhysicsBlendOut));
	RecoverRot();
}
function Fix_SimulatingPhysics()
{
	local AnimNodeSequence AnimNodeSequence;
	local rotator NewRotation;
	local vector RootLocation;
	local bool GetUpFromBack;
  `log(GetFuncName()@ "PhysicsEffectData.PhysicsBlendOutTime" @ PhysicsEffectData.PhysicsBlendOutTime);
	// Set the timer for the physics to blend out
	if(PhysicsEffectData.PhysicsBlendOutTime > 0) // -1 no blend out
	{
		if(IsDoingSpecialMove(SM_Parkour_KnockDown))
			ZSM_Parkour_KnockDown(SpecialMoves[SpecialMove]).CalCurrentFace();
	  SetTimer(PhysicsEffectData.PhysicsBlendOutTime, false, NameOf(SimulatedPhysicsBlendOut));
	  RecoverRot();
	}
	else
	{
		//clear current timer right now! to TakePhysicsamage(new)
		ClearTimer(NameOf(Fix_SimulatingPhysics));
		EndSpecialMove();
	}
}

function SimulatedPhysicsBlendOut()
{
	// Set physics weight to zero
	Mesh.PhysicsWeight = 0.f;
	Mesh.ForceSkelUpdate();
  Mesh.PhysicsAssetInstance.SetAllBodiesFixed(true);
	Mesh.bUpdateKinematicBonesFromAnimation = true;


		// Disable springs on bodies that were required in the physical hit reaction
	if (PhysicsEffectData.EnabledSpringBodyNames.Length > 0)
	{
	//	Mesh.PhysicsAssetInstance.SetNamedRBBoneSprings(false, PhysicsEffectData.EnabledSpringBodyNames, 0.f, 0.f, Mesh);
	}
	
	// Put the rigid body to sleep
	//Mesh.PutRigidBodyToSleep();
	PostPhysicsEffectMesh();
	ZeroMovementVariables();
	ClearTimer(NameOf(SimulatedPhysicsBlendOut));
	EndSpecialMove();
}

DefaultProperties
{

	Begin Object  Name=CollisionCylinder
		CollisionRadius=+0030.000000        NORMAL
		CollisionHeight=+0046.000000        NORMAL

		//CollisionRadius=+0009.000000
		//CollisionHeight=+0018.00000

		//Translation=(Z=90.0)
		BlockRigidBody=TRUE
		BlockZeroExtent=True
		BlockNonZeroExtent=True

	//	blockactors=false
		End Object



//	Components.Remove(Sprite)

		Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=true
		bIsCharacterLightEnvironment=true
		bUseBooleanEnvironmentShadowing=false
		InvisibleUpdateTime=1.f
		MinTimeBetweenFullUpdates=0.2f
		End Object
		LightEnvironment=MyLightEnvironment
		Components.Add(MyLightEnvironment)


		  MaxStepHeight=10    //35 normal
		 MaxJumpHeight=0.0   //96 normal
		// WalkableFloorZ=0.001		   // 0.7 ~= 45 degree angle for floor


			drawscale=0.4
		GroundSpeed=180

		JumpZ=+00220.000000   //420 normal
		// GroundSpeed=440.0


}

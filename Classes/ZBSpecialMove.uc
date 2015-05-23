class ZBSpecialMove extends Object
	dependson(ZombiePawn);



var ZombiePawn PawnOwner;

var	ZombiePC	PCOwner;

//var	HeiDPC	PCOwner;

enum CameraOverideType
{
	ECAM_Default,
	ECAM_KeepHeight
};

var CameraOverideType CamType;
/**
 * Can we do the current special move?
 */
var private bool bLastCanDoSpecialMove;

var bool bCanRepeat;

/**
 * Last time CanDoSpecialMove was called.
 */
var transient float LastCanDoSpecialMoveTime;

// root motion mode
var const bool UseCustomRMM;
var ERootMotionMode	RMMInAction;
var bool	RMMChangedInAction;


var bool bDisableLook;
var bool bDisableMovement;
var bool bDisableTurn;

var private			bool	bMovementDisabled;


var bool bEnablePhysicsEffect;
var bool bPhysicsEffectEnabled;
var ZombiePawn.PhysConfig PhysConfigData;

var Vector CameraOffsetTarget;
var float CameraDistance;
var vector baseLoc;

var delegate <ZombiePawn.OnSpecialMoveEnd> OnSpecialMoveEnd;
/**
 * Can the special move be chained after the current one finishes?
 */
function bool CanChainMove(ESpecialMove NextMove)
{
	return true;
}

/**
 * Can a new special move override this one before it is finished?
 * This is only if CanDoSpecialMove() == TRUE && !bForce when starting it.
 */
function bool CanOverrideMoveWith(ESpecialMove NewMove)
{
	return TRUE;
}

/**
 * Can this special move override InMove if it is currently playing?
 */
function bool CanOverrideSpecialMove(ESpecialMove InMove)
{
	return FALSE;
}

/**
 * Public accessor to see if this special move can be done, handles
 * caching the results for a single frame.
 * @param bForceCheck - Allows you to skip the single frame condition (which will be incorrect on clients since LastCanDoSpecialMoveTime isn't replicated)
 */
final function bool CanDoSpecialMove( optional bool bForceCheck )
{
	if( PawnOwner != None )
	{
		// update the cached value if outdated
		if( bForceCheck || PawnOwner.WorldInfo.TimeSeconds != LastCanDoSpecialMoveTime )
		{
			bLastCanDoSpecialMove		= InternalCanDoSpecialMove();
			LastCanDoSpecialMoveTime	= PawnOwner.WorldInfo.TimeSeconds;
		}
		// return the cached value
		return bLastCanDoSpecialMove;
	}

	return FALSE;
}

/**
 * Checks to see if this Special Move can be done.
 */
protected function bool InternalCanDoSpecialMove()
{
	return TRUE;
}

/**
 * Event called when Special Move is started.
 */
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	if(ZombiePC(PawnOwner.Controller)!=none)
		PCOwner = ZombiePC(PawnOwner.Controller);
   //  if(HeiDPC(PawnOwner.Controller)!=none)
	//    PCOwner = HeiDPC(PawnOwner.Controller);
	if( PCOwner != None )
	{
		if( bDisableLook )
		{
			PCOwner.IgnoreLookInput(TRUE);
		}
	}

	if(UseCustomRMM)
	{
		PawnOwner.Mesh.RootMotionMode = RMMInAction;
		RMMChangedInAction = true;
	}

    if( bDisableMovement )
	{
		SetMovementLock(TRUE);
		if( PCOwner != None )
		PCOwner.bCanMove=false;
	}
     
	if(bDisableTurn)
	{
		if( PCOwner != None )
	   PCOwner.bCanTurn=false; 
	}
  
  if(CamType == ECAM_KeepHeight)
  {
  	if(PawnOwner.physics != PHYS_Falling)
      PawnOwner.JumpStartHeight = PawnOwner.Location.Z;
    CameraOffsetTarget = ZBCameraTypeRushFix(ZBPlayerCamera(ZombiePC(PawnOwner.Controller).PlayerCamera).CurrentCameraType).CameraOffset;
  }
  
	if(bEnablePhysicsEffect)
	{	  
  	PhysConfigData = class'PhysicsUtil'.static.ActivePhysicsInteract(PawnOwner, 
  		ZombieRushGame(PawnOwner.WorldInfo.Game).GetPlayerPyhsicsDataInstance(), PawnOwner.SpecialMove, PawnOwner.InteractingLevelActor.tag);
			if(PhysConfigData.PhysicWeightScale > 0 ) {
				bPhysicsEffectEnabled = true;
				if(PhysConfigData.bCallPreMesh)
        	PawnOwner.PrePhysicsEffectMesh();
				PawnOwner.ActivePhysicsEffect(PhysConfigData);
			} else {
			//try find data of nil tag 
			PhysConfigData = class'PhysicsUtil'.static.ActivePhysicsInteract(PawnOwner, 
  		ZombieRushGame(PawnOwner.WorldInfo.Game).GetPlayerPyhsicsDataInstance(), PawnOwner.SpecialMove, 'nil');
				if(PhysConfigData.PhysicWeightScale > 0) {
				bPhysicsEffectEnabled = true;
				if(PhysConfigData.bCallPreMesh)
        	PawnOwner.PrePhysicsEffectMesh();
				PawnOwner.ActivePhysicsEffect(PhysConfigData);
			}
		}
	}

}
/**
 * Event called when Special Move is finished.
 */
function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{

	if( PCOwner != None )
	{
		if( bDisableLook )
		{
			PCOwner.IgnoreLookInput(FALSE);
		}
	}


	if(RMMChangedInAction)
	{
	//	PawnOwner.Mesh.RootMotionMode = RMM_Translate;
		PawnOwner.Mesh.RootMotionMode = RMM_Ignore;
		RMMChangedInAction = false;
	}

	// If movement was disabled, toggle it back on
	if( bMovementDisabled )
	{
		SetMovementLock(FALSE);
		if( PCOwner != None )
		PCOwner.bCanMove=true;
	}

    if(bDisableTurn)
	{
		if( PCOwner != None )
	      PCOwner.bCanTurn=true; 
	}

	if (OnSpecialMoveEnd != none)
	{
		OnSpecialMoveEnd(self);
	}

	if(bEnablePhysicsEffect)
	{
		bPhysicsEffectEnabled = false;
		if(PhysConfigData.bCallPostMesh)
			PawnOwner.PostPhysicsEffectMesh();
	}
}

/**
 * Notification called when body stance animation finished playing.
 * @param	SeqNode		- Node that finished playing. You can get to the SkeletalMeshComponent by looking at SeqNode->SkelComponent
 * @param	PlayedTime	- Time played on this animation. (play rate independant).
 * @param	ExcessTime	- how much time overlapped beyond end of animation. (play rate independant).
 */
function AnimCfg_AnimEndNotify()
{
	// By default end this special move.
	if(!bEnablePhysicsEffect)// || PhysConfigData.bCallPostMesh)
		PawnOwner.EndSpecialMove();
}

function OnAnimEnd(name SeqName)
{
}
final function SetMovementLock(bool bEnable)
{
	if( bMovementDisabled != bEnable )
	{
		bMovementDisabled = bEnable;

		if( PCOwner != None )
		{
			PCOwner.IgnoreMoveInput(bEnable);
		}

		// Set acceleration to zero
		if( bEnable )
		{
			PawnOwner.Acceleration = Vect(0,0,0);
		}
	}
}

event tickspecial(float deltaTime) {
	if (bPhysicsEffectEnabled)
	{
		PawnOwner.ProcessPhysicsEffectTick(deltaTime);
	}
}




final function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	if (CamType == ECAM_Default)
	{
		return false;
	}
	else if(CamType == ECAM_KeepHeight)
	{
		return CalcCamera_KeepHeight(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
	}
	
}


function bool CalcCamera_KeepHeight( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	baseLoc = PawnOwner.Location;
  baseLoc.Z = PawnOwner.JumpStartHeight;
//	out_CamLoc = VLerp(out_CamLoc,baseLoc + CameraOffsetTarget - Vector(out_CamRot) * CameraDistance,0.1) ;
	out_CamLoc = baseLoc + CameraOffsetTarget - Vector(out_CamRot) * CameraDistance ;
	return true;
}

DefaultProperties
{
	bEnablePhysicsEffect=false
	CameraDistance=400.f 
	CameraOffsetTarget=(X=0f,Y=100.0f,Z=70.0f)
	CamType=ECAM_Default
}

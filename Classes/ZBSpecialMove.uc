class ZBSpecialMove extends Object
	dependson(ZombiePawn);



var ZombiePawn PawnOwner;

var	ZombiePC	PCOwner;

//var	HeiDPC	PCOwner;


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

//var delegate<ZombieRushPawn.OnSpecialMoveEnd> OnSpecialMoveEnd;

delegate OnSpecialMoveEnd(ZBSpecialMove SpecialMoveObject);
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
	OnSpecialMoveEnd(self);

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

event tickspecial(float deltaTime);

function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	return false;
}
DefaultProperties
{
}

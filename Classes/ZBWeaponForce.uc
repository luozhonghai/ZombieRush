class ZBWeaponForce extends ZBWeapon;




//近战有效范围
var() float MeleeAttackRange;
var() int MeleeDamageAmount;
var() float MeleeDamageMomentum;
/** The trace extents to use when doing melee collision check */
var() Vector MeleeSwingExtent;

var Vector PreviousMeleeSwingLocation;
/** Array of Actors that have been marked hit by this distinct melee-swing, 
 *  so that an Actor doesn't get hit twice within the same swing. */
var array<Actor> SwingHurtList;
var bool IsInMeleeSwing;


/**adjusts the impulse applied to the player when hit with a melee attack*/
var() int strength_meleeAttackImpulseMultiplier;


const AIR_FIRE_MODE = 2;
const MELEE_FIRE_MODE = 1;
const RANGE_FIRE_MODE = 0;

var const array< ESpecialMove >        WeaponMeleeAnimation;

var ESpecialMove WeaponAirMeleeAnimation;

enum WeaponComboAttackState
{
	WCAS_NONE_PROCESSING,//0  default state nono of attack is processing.
	WCAS_X_1_PROCESSING,//1
	WCAS_X_2_PROCESSING,//2
	WCAS_X_3_PROCESSING,//3
	WCAS_X_4_PROCESSING,//4
	WCAS_X_5_PROCESSING,//5
	WCAS_X_6_PROCESSING,//6
	WCAS_X_Max,//7
};

//Combo logic
var WeaponComboAttackState         CurrentComboState;       //the value record currentCombo state.
var bool                           bCanAcceptNextComboState;   //true, we can accept NextCombo input.//false we didn't accept any more x input to blent next attack.
var bool                           FlagComboBlendingStart;      //true begin accept comboBlending.
var bool                           FlagHasComboInputBeforeBlendingStart;    //as his name
var bool                           FlagComboInputAcceptStart;              //false mean I don't accept any input , true accept input to blending.
var bool                           FlagComboInputAcceptFinish;              //true mean I don't accept any input , fal

var bool bAutoAttack;
var() float CheckRadius;
simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{

}

simulated function DetachWeapon()
{
}
/**
 * ReSet all flag to default value, ready accept combo input
 */
function ReSetAllFlag()
{
	FlagComboBlendingStart = false;
	FlagHasComboInputBeforeBlendingStart =false;
	FlagComboInputAcceptFinish = false;
	FlagComboInputAcceptStart = false;
}



/**
 * Message from Animation , means we accept ComboBlending, we will blending after this message
 */
simulated function NotifyComboBlendingStart()
{
	FlagComboBlendingStart = true;
	if( FlagHasComboInputBeforeBlendingStart == true )
	{
		BeginFire( CurrentFireMode );
		ReSetAllFlag();
	}
}
/**
 * Message from Animation , means we don't accept more input for combo
 */
simulated function ComboInputAcceptFinish()
{
	FlagComboInputAcceptFinish = true;
	FlagComboInputAcceptStart = false;
}
/**
 * Message from Animation , means we begin accept more input for combo
 */
simulated function ComboInputAcceptStart()
{
	FlagComboInputAcceptStart = true;
	FlagComboInputAcceptFinish = false;

}




simulated function StartFire(byte FireModeNum)
{
	if ( FireModeNum == AIR_FIRE_MODE)
	{
		super.StartFire( FireModeNum );
		return;
	}

	if( FireModeNum == MELEE_FIRE_MODE)
	{
	
	if(  CurrentComboState == WCAS_NONE_PROCESSING )
		{
	
			super.StartFire( FireModeNum );
			return;
		}else
		{
			//we are in combo case here

			if(UpdateMeleeComboInputState())
			{
				//For Timer Combo Notify. we should Clear Iunput Valid Timer 
				//in ZombiePawn->TimerNotifyComboBlendingStart()
				ZombiePawn(Instigator).EndComboInputTimer();
				super.StartFire( FireModeNum );
			}
				return;
		}
	}
}

/**********************************************************************************************
 * State code
 ********************************************************************************************/
State   XFWeaponMeleeFire
{
	simulated event bool IsFiring()
	{
		return true;
	}
	simulated event EndState( Name NextStateName )
	{
		MeleeAttackEnded();
	}

	simulated event BeginState( Name PreviousStateName )
	{
		if( CurrentFireMode == MELEE_FIRE_MODE )// this is inital start
		{
			MeleeAttackStarted();
			ReSetAllFlag();

		}
	}
	simulated function BeginFire(byte FireModeNum)
	{
		local ZombiePawn Xpawn;
		if( !bDeleteMe && Instigator != None )
		{
			Xpawn = ZombiePawn(Instigator);
			Global.BeginFire(FireModeNum);
		}

	    ZombiePC(Instigator.Controller).ApplyAdhesion();
        ZombiePawn(Instigator).MeleeAttackStarted(self);
		Xpawn.DoSpecialMove( WeaponMeleeAnimation[ int(CurrentComboState) ], True);
		CurrentComboState = WeaponComboAttackState(int(CurrentComboState) + 1);	
		ReSetAllFlag();
	}
}

/**********************************************************************************************
 * State code
 ********************************************************************************************/


State   XFWeaponAirFire
{
	simulated event bool IsFiring()
	{
		return true;
	}

	simulated event EndState( Name NextStateName )
	{
		//MeleeAttackEnded();
	}

	simulated event BeginState( Name PreviousStateName )
	{
		local ZombiePawn Zpawn;
		Zpawn = ZombiePawn(Instigator);

		Zpawn.DoSpecialMove( WeaponAirMeleeAnimation, false);
	}
}
function bool UpdateMeleeComboInputState()
{
	// CurrentComboState = WeaponComboAttackState(int(CurrentComboState) + 1);
	if( CurrentComboState == WCAS_X_3_PROCESSING ) // combo is end action
	{
		CurrentComboState = WCAS_NONE_PROCESSING;
		return true;
	}

    if(bAutoAttack)
    	return true;

	if( FlagComboInputAcceptStart == false || FlagComboInputAcceptFinish == true )
	{
		return false;
	}

	//input not allow accept yet
	if( FlagComboBlendingStart == false ) 
	{
		FlagHasComboInputBeforeBlendingStart = true; // mark we had input before blending start.
		return false;
	}
	return true;
}

////** Event called when body stance animation finished playing */
 //XFGamePawn->AnimCfg_AnimEndNotify()

simulated function NotifyFireSpecialMoveFinished()
{
	//if(  CurrentComboState != WCAS_NONE_PROCESSING )
//	{
		CurrentComboState = WCAS_NONE_PROCESSING;
		MeleeAttackEnded();
		GotoState('Active');
//	}
}

/**
 * Event called when melee attack begins.
 * This means when weapon is entering melee attacking state on local player
 * When Pawn.FiringMode == MELEE_FIRE_MODE is replicated on remote clients.
 */
simulated function MeleeAttackStarted()
{
	local ZombiePawn Zpawn;
	Zpawn = ZombiePawn(Instigator);
	if(  CurrentComboState == WCAS_NONE_PROCESSING )//necessary special here? ljb
	{
//Find a melee target:
 		if(!bAutoAttack)
			ZombiePawn(Instigator).MeleeAttackStarted(self);

		SetTimer(0.001, true, 'MeleeAttackImpact');

		Zpawn.DoSpecialMove( WeaponMeleeAnimation[0], true);
		CurrentComboState = WeaponComboAttackState(int(CurrentComboState) + 1);
	}
}

simulated function MeleeAttackEnded()
{
	ClearPendingFire( CurrentFireMode );

    ZombiePawn(Instigator).MeleeAttackEnded(self);
	ClearTimer('MeleeAttackImpact');
}

function StartMeleeSwing()
{
	PreviousMeleeSwingLocation = ZombiePawn(instigator).GetMeleeSwingLocation();
	IsInMeleeSwing = true;
}

/** Clear out our swing-hurt list, so that we have it fresh for the next swing. */
function EndMeleeSwing()
{
	IsInMeleeSwing=false;
	SwingHurtList.Remove(0,SwingHurtList.Length);
}

/**
MeleeDamage
*/

simulated function bool MeleeAttackImpact()
{
	local Vector slapLocation;

	local TraceHitInfo hitInfo;
	local Vector HitNormal;
	local Vector HitLocation;
	local Actor Traced;

	if(IsInMeleeSwing)
	{
		slapLocation = ZombiePawn(instigator).GetMeleeSwingLocation();

	//	DrawDebugLine(slapLocation,PreviousMeleeSwingLocation,255,0,0,true);

		foreach TraceActors(class'Actor', Traced, HitLocation, HitNormal, slapLocation, PreviousMeleeSwingLocation,MeleeSwingExtent)
		{
			
			if(Traced != self && AddToSwingHurtList(Traced))

			    GiveMeleeDamageTo(Traced,MeleeDamageAmount);
			//Traced.TakeDamage(MeleeDamageAmount,self,HitLocation,Normal((Traced.Location - Pawn.Location))*MeleeDamageMomentum,class'DamageType',hitInfo,Pawn);
		}

		PreviousMeleeSwingLocation = slapLocation;
	}

	return true;
}

function GiveMeleeDamageTo(Actor Victim, float Damage)
{ 
  `log("Damaged"@Damage);
	if(Victim.class != mOwner.class && ZombiePawn(Victim)!=none)
	  Victim.TakeDamage(MeleeDamageAmount, mOwner.controller, Victim.Location, (-vector(ZombiePawn(Victim).GetViewRotation())*strength_meleeAttackImpulseMultiplier), class'DmgType_Axe_Fire');  
	 // Victim.
}


	/** Checks whether an Actor is already on the swing hurt list, returns false if so. Adds and returns true if not already on the list. 
	 *  Used to determine if an Actor has already taken damage from this swing. */
function bool AddToSwingHurtList(Actor newEntry)
{
		local int i;

		for(i=0; i < SwingHurtList.Length;i++)
			{
				if(SwingHurtList[i] == newEntry)
					return false;
			}

		SwingHurtList.AddItem(newEntry);

		return true;
}

function bool CanDoFire()
{
	local Actor MeleeTarget;
	MeleeTarget = ZombiePC(Instigator.Controller).ForcedAdhesionTarget;
	if(MeleeTarget == none)
		return false;
	else
		return VSize(Instigator.location - MeleeTarget.Location) < CheckRadius;
}

function bool CanDoFireTo(ZombiePawn P)
{
	return VSize(Instigator.location - P.Location) < CheckRadius;
}
DefaultProperties
{

	    MeleeDamageAmount=10

	    WeaponMeleeAnimation(0)=SM_MeleeAttack1
		WeaponMeleeAnimation(1)=SM_MeleeAttack2
		WeaponMeleeAnimation(2)=SM_MeleeAttack3


		WeaponAirMeleeAnimation=SM_AirAttack

		FiringStatesArray(0)="XFWeaponRangeFire"
		FiringStatesArray(1)="XFWeaponMeleeFire"
		FiringStatesArray(2)="XFWeaponAirFire"
		WeaponFireTypes(0)=EWFT_Projectile
		WeaponFireTypes(1)=EWFT_InstantHit
        WeaponFireTypes(2)=EWFT_InstantHit
 
		MeleeAttackRange=200
		MeleeSwingExtent=(X=30,Y=30,Z=30)

		strength_meleeAttackImpulseMultiplier=1000

		bAutoAttack=true
		CheckRadius=500
}

class ZBWeapon extends UDKWeapon;


/** Tracks the Pawn the Weapon is Assigned to */


var ZombiePawn mOwner;

var const int RELOAD_AMMO;
/*
* Called to attach the weapon's mesh to a socket on the player.  The UTWeapon class has
* some additional functionality, but since we're not using any visible weapons, we don't
* sweat truly attaching meshes.
*****************************************************************/
simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
	//NOTE - This Adds a Restriction for the Instigator to Be an NX Pawn
	mOwner = ZombiePawn(Instigator);

	// Attach 1st Person Muzzle Flashes, etc,
	if ( Instigator.IsFirstPerson() )
	{
		//AttachComponent(Mesh);
		//EnsureWeaponOverlayComponentLast();
		SetHidden(False);
		if (mOwner != None)
		{
			Mesh.SetLightEnvironment(mOwner.LightEnvironment);
			mOwner.Mesh.AttachComponentToSocket(Mesh, mOwner.WeaponSocket);
			EnsureWeaponOverlayComponentLast();
		}
	}
	else
	{
		//SetHidden(True);
		if (mOwner != None)
		{
			Mesh.SetLightEnvironment(mOwner.LightEnvironment);
			mOwner.Mesh.AttachComponentToSocket(Mesh, mOwner.WeaponSocket);
		}
	}
	ZombiePlayerPawn(mOwner).SetWeaponType(2);
	ZombiePC(mOwner.controller).SetActionTapFunction_Gun();
}

simulated function DetachWeapon()
{
	//local UTPawn P;

	mOwner.mesh.DetachComponent( Mesh );
	ZombiePC(mOwner.controller).RestoreActionTapFunction();
}

/************************************************************//** 
 *****************************************************************/
simulated state WeaponEquipping
{
	simulated event BeginState(Name PreviousStateName)
	{
		AttachWeaponTo(Instigator.Mesh);
		Super.BeginState(PreviousStateName);
	}
}


simulated function Projectile ProjectileFire()
{

	local vector		StartTrace, EndTrace, RealStartLoc, AimDir;

	local ImpactInfo	TestImpact;

	local Projectile	SpawnedProjectile;


/*
	if( Role == ROLE_Authority )
	{
		// this is the location where the projectile is spawned.
		//RealStartLoc = Instigator.location + vector(Instigator.rotation)*50;

		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc();

		// Spawn projectile
		SpawnedProjectile = Spawn(class'ZBProjectile',,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
		//	SpawnedProjectile.Init( Vector(GetAdjustedAim( RealStartLoc )) );

			SpawnedProjectile.Init( vector(GetAdjustedAim(RealStartLoc)));
		}

		// Return it up the line
		return SpawnedProjectile;
	}

*/

	if( Role == ROLE_Authority )
	{
		// This is where we would start an instant trace. (what CalcWeaponFire uses)
		StartTrace = Instigator.GetWeaponStartTraceLocation();

		AimDir = Vector(GetAdjustedAim( StartTrace ));

		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc(AimDir);

		if( StartTrace != RealStartLoc )
		{
			// if projectile is spawned at different location of crosshair,
			// then simulate an instant trace where crosshair is aiming at, Get hit info.
			EndTrace = StartTrace + AimDir * GetTraceRange();
			TestImpact = CalcWeaponFire( StartTrace, EndTrace );

			// Then we realign projectile aim direction to match where the crosshair did hit.
			AimDir = Normal(TestImpact.HitLocation - RealStartLoc);
		}

		// Spawn projectile
		SpawnedProjectile = Spawn(class'ZBProjectile', Self,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.Init( AimDir );
		}

		// Return it up the line
		return SpawnedProjectile;
	}



}

function bool CanDoFire()
{
	return true;
}
DefaultProperties
{

	FiringStatesArray(0)="WeaponFiring"
	FiringStatesArray(1)="WeaponFiring"

	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_Projectile


	WeaponRange=22000


	// Weapon SkeletalMesh
	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
	//bOwnerNoSee=true
	bOnlyOwnerSee=false
	CollideActors=false
	AlwaysLoadOnClient=true
	AlwaysLoadOnServer=true
	MaxDrawDistance=4000
	bForceRefPose=1
	bUpdateSkelWhenNotRendered=false
	bIgnoreControllersWhenNotRendered=true
	bOverrideAttachmentOwnerVisibility=true
	bAcceptsDynamicDecals=FALSE
	Animations=MeshSequenceA
	SkeletalMesh=SkeletalMesh'KismetGame_Assets.Anims.SK_JazzGun'
	CastShadow=true
	bCastDynamicShadow=true
	MotionBlurScale=0.0
	bAllowAmbientOcclusion=false
	End Object
	Mesh=SkeletalMeshComponent0



	FireInterval(0)=+0.16
    FireInterval(1)=+1.16

	Spread(0)=0.0
	Spread(1)=0.0

	RELOAD_AMMO=0

}

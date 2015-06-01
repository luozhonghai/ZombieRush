class ZBWeaponGun extends ZBWeapon;


var StaticMeshComponent StaticMeshComponent;

var ESpecialMove WeaponFirAnimation;

// Archetype of the projectile to use
var(FireMode) const ZBProjectile ProjectileArchetype;

var Actor TargetActor;
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
			mOwner.Mesh.AttachComponentToSocket(StaticMeshComponent, mOwner.GunHoldSocket);
			EnsureWeaponOverlayComponentLast();
		}
	}
	else
	{
		//SetHidden(True);
		if (mOwner != None)
		{
			Mesh.SetLightEnvironment(mOwner.LightEnvironment);
			mOwner.Mesh.AttachComponentToSocket(StaticMeshComponent, 'GunPoint');
		}
	}
	ZombiePlayerPawn(mOwner).SetWeaponType(2);
	ZombiePC(mOwner.controller).SetActionTapFunction_Gun();
}

simulated function DetachWeapon()
{
	//local UTPawn P;

	//ZombieHud(ZombiePC(mOwner.controller).myhud).HideFireTargetHint();
	mOwner.mesh.DetachComponent( StaticMeshComponent );
	ZombiePC(mOwner.controller).RestoreActionTapFunction();
}

State   ZBWeaponFire
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

		Zpawn.DoSpecialMove( WeaponFirAnimation, false);
		
	}
}

simulated function Projectile CustomProjectileFire(optional Actor ShootTargetActor = none)
{
	TargetActor = ShootTargetActor;
	return ProjectileFire();
}
simulated function Projectile ProjectileFire()
{
    local vector		StartTrace, EndTrace, RealStartLoc, AimDir;
	local ImpactInfo	TestImpact;
 	local Projectile	SpawnedProjectile;
  

  ZombieRushPawn(instigator).AmmoNum[EWT_Pistol] -= 1;

	ZombiePawn(instigator).GetFirSocketLocationAndDir(RealStartLoc,AimDir);
	RealStartLoc.z = ZombiePawn(instigator).location.z + 20;

	if(TargetActor != none)
	{
		AimDir = TargetActor.location - RealStartLoc;
	}
	else
	{
	  AimDir = Vector(ZombiePawn(instigator).rotation);
	  AimDir.z = 0;
  }
	// Spawn projectile
	SpawnedProjectile = Spawn(class'ZBGunProjectile', Self,, RealStartLoc);
	if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
	{
		//dynamicload object Ò²¿ÉÐÐ
		//ZBPro = ZBProjectile(DynamicLoadObject("Goud_Projectile.Archetype.Arche_TestProjectile",class 'ZBProjectile'));
		//	SpawnedProjectile = Spawn(ZBPro.class, ,, RealStartLoc,, ZBPro);
		//	SpawnedProjectile = Spawn(class 'ZBProjectile',,,RealStartLoc);
		SpawnedProjectile.Init( AimDir );
	}
	// Return it up the line
	return SpawnedProjectile;
}

function bool CanDoFire()
{
	return ZombieRushPawn(instigator).AmmoNum[2]>0;
}
DefaultProperties
{
	FiringStatesArray(0)="ZBWeaponFire"
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFirAnimation=SM_GunAttack
	RELOAD_AMMO=12
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		BlockRigidBody=false
		LightEnvironment=MyLightEnvironment
		bUsePrecomputedShadows=FALSE
		StaticMesh=StaticMesh'zombie.Weapon.short_gun_01'
	End Object
	//CollisionComponent=StaticMeshComponent0
	StaticMeshComponent=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)
	//ProjectileArchetype=ZBProjectile'Goud_Projectile.Archetype.Arche_TestProjectile'
}

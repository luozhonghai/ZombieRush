class ZBWeaponAxe extends ZBWeaponForce;

var StaticMeshComponent StaticMeshComponent;

var array<Actor> AdhesionForwardZombies;

var vector PreviousMeleeSwingLocation2;
/*
* Called to attach the weapon's mesh to a socket on the player.  The UTWeapon class has
* some additional functionality, but since we're not using any visible weapons, we don't
* sweat truly attaching meshes.
*****************************************************************/
simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
	//NOTE - This Adds a Restriction for the Instigator to Be an NX Pawn
	mOwner = ZombiePawn(Instigator);


		//SetHidden(True);
	if (mOwner != None)
	{
			Mesh.SetLightEnvironment(mOwner.LightEnvironment);
			mOwner.Mesh.AttachComponentToSocket(StaticMeshComponent, mOwner.WeaponSocket);
	}
	
	ZombiePlayerPawn(mOwner).SetWeaponType(1);
	ZombiePC(mOwner.controller).SetActionTapFunction_Axe();
}

simulated function DetachWeapon()
{
	//local UTPawn P;

	mOwner.mesh.DetachComponent( StaticMeshComponent );
	ZombiePC(mOwner.controller).RestoreActionTapFunction();
}

/**
MeleeDamage
*/

simulated function bool MeleeAttackImpact()
{
	local Vector slapLocation,slapLocation2;

	local TraceHitInfo hitInfo;
	local Vector HitNormal;
	local Vector HitLocation;
	local Actor Traced;

	if(IsInMeleeSwing)
	{
		slapLocation = ZombiePawn(instigator).GetMeleeSwingLocation();
        slapLocation2 = ZombiePawn(instigator).GetMeleeSwingLocation2();
		//	DrawDebugLine(slapLocation,PreviousMeleeSwingLocation,255,0,0,true);
      //      DrawDebugLine(slapLocation2,PreviousMeleeSwingLocation2,255,0,0,true);
		foreach TraceActors(class'Actor', Traced, HitLocation, HitNormal, slapLocation, PreviousMeleeSwingLocation,MeleeSwingExtent)
		{

			//对第一个目标造成伤害
			if(ZombiePawn(Traced)!=none&&SwingHurtList.Length==0&&Traced != self 
				&&ZBAIPawnBase(Traced).ZombieType==EZT_Walk
				&&( !ZombiePawn(Traced).IsDoingASpecialMove()||ZombiePawn(Traced).IsDoingSpecialMove(SM_Zombie_MeleeAttackPre)))
			{
				if(AddToSwingHurtList(Traced))
				{
					GiveMeleeDamageTo(Traced,MeleeDamageAmount);
					KnockAdhesionForward(Traced);
				//	ZombiePC(mOwner.controller).clientmessage("traced!!!");
				}			
			}
			//Traced.TakeDamage(MeleeDamageAmount,self,HitLocation,Normal((Traced.Location - Pawn.Location))*MeleeDamageMomentum,class'DamageType',hitInfo,Pawn);
		}
     //   DrawDebugLine(slapLocation2+2*(slapLocation2-slapLocation), slapLocation,255,0,0,true);
		foreach TraceActors(class'Actor', Traced, HitLocation, HitNormal, slapLocation2+2*(slapLocation2-slapLocation), slapLocation+2*(slapLocation-slapLocation2),MeleeSwingExtent)
		{
            
			//对第一个目标造成伤害
			if(ZombiePawn(Traced)!=none&&SwingHurtList.Length==0&&Traced != self 
				&&ZBAIPawnBase(Traced).ZombieType==EZT_Walk
				&&( !ZombiePawn(Traced).IsDoingASpecialMove()||ZombiePawn(Traced).IsDoingSpecialMove(SM_Zombie_MeleeAttackPre)))
			{
				if(AddToSwingHurtList(Traced))
				{
				GiveMeleeDamageTo(Traced,MeleeDamageAmount);
				KnockAdhesionForward(Traced);
				//	ZombiePC(mOwner.controller).clientmessage("traced!!!");
				}
			}
		}

		foreach TraceActors(class'Actor', Traced, HitLocation, HitNormal, slapLocation2, PreviousMeleeSwingLocation2,MeleeSwingExtent)
		{
            
			//对第一个目标造成伤害
			if(ZombiePawn(Traced)!=none&&SwingHurtList.Length==0&&Traced != self 
				&&ZBAIPawnBase(Traced).ZombieType==EZT_Walk
				&&( !ZombiePawn(Traced).IsDoingASpecialMove()||ZombiePawn(Traced).IsDoingSpecialMove(SM_Zombie_MeleeAttackPre)))
			{
				if(AddToSwingHurtList(Traced))  //只有在满足以上条件才加入swinglist
				{
				GiveMeleeDamageTo(Traced,MeleeDamageAmount);
				KnockAdhesionForward(Traced);
			//		ZombiePC(mOwner.controller).clientmessage("traced!!!");
				}
			}
		}

		//for one melee point
		PreviousMeleeSwingLocation = slapLocation;
		PreviousMeleeSwingLocation2 = slapLocation2;
	}

	return true;
}

simulated function  KnockAdhesionForward(Actor Ignored)
{
	local ZombiePawn ZP;

	local ZombiePawn TestZP;
	local Vector ToTestWPNorm;
	local float ToTestWPDist;
	local ZombiePawn BestTarget;
	local float BestTargetScore;
	local float DotToTarget;
	local float DistScore;
	local float DirScore;
	local float TotalScore;
	local float SearchRadius;

	ZP = ZombiePawn(instigator);
	SearchRadius = 75; //1.5 m
	BestTargetScore = -99999;
	BestTarget = None;
//clear list
	AdhesionForwardZombies.Remove(0,AdhesionForwardZombies.Length);

	foreach ZP.CollidingActors(Class'ZombiePawn', TestZP, SearchRadius)
	{
		if (ZP.IsValidMeleeTarget(TestZP) && TestZP != Ignored)
		{
			ToTestWPNorm = TestZP.Location - ZP.Location;
			ToTestWPDist = VSize(TestZP.Location - ZP.Location);
			ToTestWPNorm /= ToTestWPDist;
			DotToTarget = ToTestWPNorm Dot Vector(ZP.Rotation);
			if (DotToTarget < -0.5)  //120du
			{
				continue;
			}
           if(!TestZP.IsDoingASpecialMove()
			   ||TestZP.IsDoingSpecialMove(SM_Zombie_MeleeAttackPre))
		   {
			TestZP.KnockBack();
			AdhesionForwardZombies.AddItem(TestZP);
		   } 
		}
	}

}

function StartMeleeSwing()
{
	super.StartMeleeSwing();
	PreviousMeleeSwingLocation2 = ZombiePawn(instigator).GetMeleeSwingLocation2();
}

function GiveMeleeDamageTo(Actor Victim, float Damage)
{
	if (CurrentComboState == WCAS_X_3_PROCESSING)
	{
		ZombiePawn(Victim).TakeExDamage();
	}
	else
		super.GiveMeleeDamageTo(Victim,Damage);
  HitLevelEntity(Victim);
	// Victim.
}


function HitLevelEntity(Actor Wall)
{
  if(ZBLevelEntity_OilDrum(Wall)!=none)
    ZBLevelEntity_OilDrum(Wall).HitBy(class'DmgType_Axe_Fire');
  else if(ZBLevelEntity_Fractured(Wall)!=none)
  	ZBLevelEntity_Fractured(Wall).HitBy(class'DmgType_Axe_Fire');
}
DefaultProperties
{
	// Weapon SkeletalMesh
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'KismetGame_Assets.Anims.SK_JazzGun'
	End Object

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
	BlockRigidBody=false
	LightEnvironment=MyLightEnvironment
	bUsePrecomputedShadows=FALSE
	StaticMesh=StaticMesh'zombie.Weapon.futou_01'
	End Object
	//CollisionComponent=StaticMeshComponent0
	StaticMeshComponent=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)

	MeleeDamageAmount=10
	MeleeAttackRange=250


}

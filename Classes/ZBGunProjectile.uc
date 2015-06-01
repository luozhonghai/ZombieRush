class ZBGunProjectile extends Projectile;

//HideCategories(Movement, Display, Attachment, Physics, Advanced, Debug, Object, Projectile);

//HWProjectile


/** The particle system that is shown on the flying projectile. */
var(GoudProjectile) ParticleSystemComponent	ProjFlightEffects;

/** The template of the particle system to show on the flying projectile. */
//var(GoudProjectile) ParticleSystem ProjFlightTemplate;  直接在 ProjFlightEffects中定义 flight effect

/** The template of the particle system to show at this projectile's explosion. */
var(GoudProjectile) ParticleSystem ProjExplosionTemplate;

// for decal
// Impact material instance time varying to use for decals. This assumes the linear scalar data is setup for fading away
var(GoudProjectile) const MaterialInstanceTimeVarying ImpactDecalMaterialInstanceTimeVarying;
// Impact opacity scalar parameter name
var(GoudProjectile) const Name ImpactDecalOpacityScalarParameterName;
// Impact decal life time
var(GoudProjectile) const float ImpactDecalLifeSpan;
// Impact decal minimum size
var(GoudProjectile) const Vector2D ImpactDecalMinSize;
// Impact decal maximum size
var(GoudProjectile) const Vector2D ImpactDecalMaxSize;
// If true, then the size of the decal is always uniform
var(GoudProjectile) const bool AlwaysUniformlySized;



var(GoudProjectile)	float GoudSpeed<DisplayName=Speed>;
// Limit on speed of projectile (0 means no limit).
var(GoudProjectile)	float GoudMaxSpeed<DisplayName=MaxSpeed>;
/** The sound that is played when this projectile is fired. */
var(GoudProjectile) SoundCue SoundFire<DisplayName=SpawnSound>;

/** The sound that is played when this projectile explodes. */
var(GoudProjectile) SoundCue SoundExplosion<DisplayName=ImpactSound>;


// If true, then the explosion effects have been triggered
var ProtectedWrite bool HasExploded;


var() int FireDamageAmount;
simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	Speed = GoudSpeed;
	MaxSpeed = GoudMaxSpeed;
	SpawnSound = SoundFire;
	ImpactSound = SoundExplosion;
	

	// Play the spawn sound if there is one
	if (SpawnSound != None)
	{
		PlaySound(SpawnSound, true);
	}
	/*

	SpawnFlightEffects();
	if (!AudioComponentFire.IsPlaying())
	{
		AudioComponentFire.Location = Location;
		AudioComponentFire.SoundCue = SoundFire;
		AudioComponentFire.Play();
	}*/
}




/**
 * Called when the projectile is destroyed
 *
 * @network		All
 */
simulated event Destroyed()
{
	Super.Destroyed();

	SpawnExplosionEffects(Location, Vect(0.f, 0.f, 1.f));
}


/**
 * Process the touch event
 *
 * @param		Other			Actor that this projectile touched
 * @param		HitLocation		World location where the touch occurred
 * @param		HitNormal		Surface normal of the touch
 * @network						Server and client
 */
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
		DealEnemyDamage();
		if(ZombiePawn(Other)!=none&&ZombiePawn(Other).health>0 && ZBAIPawnBase(Other).ZombieType==EZT_Walk
			&& (ZombiePawn(Other).Controller.IsInState('MeleeAttackPreparing')||
				ZombiePawn(Other).Controller.IsInState('MovetoPlayerNoNav')||
				ZombiePawn(Other).Controller.IsInState('Patrol')))
		{
		  Explode(HitLocation, HitNormal);	
			Other.TakeDamage(FireDamageAmount, none, Other.Location, vect(0,0,0), class'DmgType_Gun_Fire');
		}
		else if(HitLevelEntity(Other))
		{
			Explode(HitLocation, HitNormal);
		}

}
/**
 * Called when the projectile touchs an actor that is defined as a wall
 *
 * @param		HitNormal		Surface normal of the wall
 * @param		Wall			Actor which represents the wall
 * @param		WallComp		Actor's primitive component that is the wall
 * @network						Server and client
 */
simulated singular event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
	// Abort if I did not touch the enemy
	
		DealEnemyDamage();
		Explode(Location, HitNormal);
		HitLevelEntity(Wall);
}


function bool HitLevelEntity(Actor Wall)
{
  if(ZBLevelEntity_OilDrum(Wall)!=none) 
  {
    ZBLevelEntity_OilDrum(Wall).HitBy(class'DmgType_Gun_Fire');
    return true;
  }
  else if(ZBLevelEntity_Fractured(Wall)!=none)
  {
  	ZBLevelEntity_Fractured(Wall).HitBy(class'DmgType_Gun_Fire');
  	return true;
  }
  return false;
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	// Create the explosion effects
	SpawnExplosionEffects(HitLocation, HitNormal);

	// Destroy the projectile
	Destroy();
}


/**
 * Deals damage to the enemy
 * 
 * @network		Server and client
 */
simulated function DealEnemyDamage()
{
	`log("DealHitWallEnemyDamage");
}
/**
 * Spawns any effects needed for the flight of this projectile.
 * 
 * (Taken from UTProjectile::SpawnFlightEffects().)
 */
/*直接在 component中定义了
simulated function SpawnFlightEffects()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && ProjFlightTemplate != None)
	{
		ProjEffects = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(ProjFlightTemplate);
		ProjEffects.SetAbsolute(false, false, false);
		ProjEffects.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
	//	ProjEffects.OnSystemFinished = MyOnParticleSystemFinished;
		ProjEffects.bUpdateComponentInTick = true;
		AttachComponent(ProjEffects);
	}
}*/


/**
 * Create the explosion effects
 *
 * @param		HitLocation		World location where the touch occurred
 * @param		HitNormal		Surface normal of the touch
 * @network						Server and client
 */
simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local MaterialInstanceTimeVarying MaterialInstanceTimeVarying;
	local float Width, Height;
	local Vector TraceHitLocation, TraceHitNormal;
	local Actor HitActor;

	if (HasExploded)
	{
		return;
	}

	HasExploded = true;	

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		// Play the impact sound if there is one
		if (ImpactSound != None)
		{
			PlaySound(ImpactSound, true);
		}
	
		// Spawn the impact particle effect if there is one
		if (ProjExplosionTemplate != None && WorldInfo.MyEmitterPool != None)
		{
			WorldInfo.MyEmitterPool.SpawnEmitter(ProjExplosionTemplate, HitLocation, Rotator(HitNormal));
		}
	
		// Spawn the impact decal effect if there is one
		if (ImpactDecalMaterialInstanceTimeVarying != None && WorldInfo.MyDecalManager != None)
		{
			HitNormal = Normal(HitNormal);
			HitActor = Trace(TraceHitLocation, TraceHitNormal, HitLocation - HitNormal * 256.f, HitLocation + HitNormal * 256.f);		
			if (HitActor != None && HitActor.bWorldGeometry)
			{
				MaterialInstanceTimeVarying = new () class'MaterialInstanceTimeVarying';
				if (MaterialInstanceTimeVarying != None)
				{
					// Figure out the decal width and height
					Width = RandRange(ImpactDecalMinSize.X, ImpactDecalMaxSize.X);
					Height = (AlwaysUniformlySized) ? Width : RandRange(ImpactDecalMinSize.Y, ImpactDecalMaxSize.Y);
			
					// Set up the MaterialInstanceTimeVarying
					MaterialInstanceTimeVarying.SetParent(ImpactDecalMaterialInstanceTimeVarying);
			
					// Spawn the decal
					WorldInfo.MyDecalManager.SpawnDecal(MaterialInstanceTimeVarying, TraceHitLocation + TraceHitNormal * 8.f, Rotator(-TraceHitNormal), Width, Height, 32.f, false);
			
					// Set the scalar start time; so that the decal doesn't start fading away immediately
					MaterialInstanceTimeVarying.SetScalarStartTime(ImpactDecalOpacityScalarParameterName, ImpactDecalLifeSpan);
				}
			}
		}
	}
}

DefaultProperties
{
	bCollideWorld=true
	bCollideActors=true

	//bCollideComplex=true

	

	//for decal
	ImpactDecalLifeSpan=24.f
	ImpactDecalOpacityScalarParameterName="DissolveAmount"
	ImpactDecalMinSize=(X=192.f,Y=192.f)
	ImpactDecalMaxSize=(X=256.f,Y=256.f)
	AlwaysUniformlySized=true
		

	// all clients have to be able to see projectiles
	bAlwaysRelevant=true
	bNetTemporary=false
	RemoteRole = ROLE_SimulatedProxy;


	GoudSpeed=+2000.0000
	GoudMaxSpeed=+2000.0000

		Begin Object Class=ParticleSystemComponent Name=MyParticleSystemComponent
		  Template=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketTrail'
		//  Template=ParticleSystem'Testa.P_Line_1'
		End Object
		Components.Add(MyParticleSystemComponent)
		ProjFlightEffects=MyParticleSystemComponent


		//ProjFlightTemplate=ParticleSystem'KismetGame_Assets.Projectile.P_BlasterMuzzle_02'
		ProjExplosionTemplate=ParticleSystem'KismetGame_Assets.Projectile.P_BlasterHit_01'
		SoundFire=SoundCue'KismetGame_Assets.Sounds.S_Blast_05_Cue'

		FireDamageAmount=50

		MyDamageType=class'DamageType'

		//drawscale=10
}

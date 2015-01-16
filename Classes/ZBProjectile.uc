class ZBProjectile extends Projectile;

//HWProjectile


/** The particle system that is shown on the flying projectile. */
var ParticleSystemComponent	ProjEffects;

/** The template of the particle system to show on the flying projectile. */
var ParticleSystem ProjFlightTemplate;

/** The template of the particle system to show at this projectile's explosion. */
var ParticleSystem ProjExplosionTemplate;



/** The audio component used for playing the fire sound of this projectile. */
var AudioComponent AudioComponentFire;

/** The audio component used for playing the explosion sound of this projectile. */
var AudioComponent AudioComponentExplosion;

/** The sound that is played when this projectile is fired. */
var SoundCue SoundFire;

/** The sound that is played when this projectile explodes. */
var SoundCue SoundExplosion;

/** The maximum distance the explosion effect of this projectile can be seen from. */
var float MaxEffectDistance;

/** The class of the explosion lights of this projectile. */
var class<UDKExplosionLight> ExplosionLightClass;

/** The maximum distance from a player's viewport explosion lights will be created in. */
var float MaxExplosionLightDistance;


simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	SpawnFlightEffects();

	if (!AudioComponentFire.IsPlaying())
	{
		AudioComponentFire.Location = Location;
		AudioComponentFire.SoundCue = SoundFire;
		AudioComponentFire.Play();
	}
}

/**
 * Spawns any effects needed for the flight of this projectile.
 * 
 * (Taken from UTProjectile::SpawnFlightEffects().)
 */
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
}
DefaultProperties
{
	bCollideWorld=false
		MaxEffectDistance=7000.0
	//	ImpactOffset = 100;

	RemoteRole = ROLE_SimulatedProxy;

	// all clients have to be able to see projectiles
	bAlwaysRelevant=true

		Begin Object Class=AudioComponent name=NewAudioComponentFire
		End Object
		AudioComponentFire=NewAudioComponentFire
		Components.Add(NewAudioComponentFire)

		Begin Object Class=AudioComponent name=NewAudioComponentExplosion
		End Object
		AudioComponentExplosion=NewAudioComponentExplosion
		Components.Add(NewAudioComponentExplosion)

		ProjFlightTemplate=ParticleSystem'KismetGame_Assets.Projectile.P_BlasterMuzzle_02'
		ProjExplosionTemplate=ParticleSystem'KismetGame_Assets.Projectile.P_BlasterHit_01'
		SoundFire=SoundCue'KismetGame_Assets.Sounds.S_Blast_05_Cue'

		LifeSpan=+0034.000000

}

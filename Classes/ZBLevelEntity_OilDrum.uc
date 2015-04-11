class ZBLevelEntity_OilDrum extends ZBLevelEntity;

var() int DamageRadius;
var() float DamageMomentum;
var() ParticleSystem ExplosionTemplate;
var() SoundCue SelfDestructSoundCue;


simulated function DrumExplode()
{
	`log("DrumExplode");
	Explode(Location);
}

simulated function Explode(vector HitLocation)
{
	if (DamageRadius>0)
	{
	  ExplodeHurtRadius(HitLocation);
	  SpawnExplosionEffects(HitLocation);
	  ShutDown();
	}
}

simulated function Shutdown()
{
	SetPhysics(PHYS_None);
	SetCollision(false,false);
}

/*
simulated function bool HurtRadius
(
	float				BaseDamage,
	float				DamageRadius,
	class<DamageType>	DamageType,
	float				Momentum,
	vector				HurtOrigin,
	optional Actor		IgnoredActor,
	optional Controller InstigatedByController = Instigator != None ? Instigator.Controller : None,
	optional bool       bDoFullDamage
)
*/
function ExplodeHurtRadius(vector HitLocation)
{
	HurtRadius(600,600, class 'DmgType_Drum', DamageMomentum, location, Getalocalplayercontroller().Pawn);
	PlaySound(SelfDestructSoundCue);
}

function SpawnExplosionEffects(vector HitLocation)
{
	local ParticleSystemComponent ProjExplosion;
	local Actor EffectAttachActor;

  EffectAttachActor = none;
	ProjExplosion = WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionTemplate, HitLocation, rot(0,0,0), EffectAttachActor);
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=BulletPickUpComp
		//model of OilDrum
		StaticMesh=StaticMesh'Pickups.Armor_ShieldBelt.Mesh.S_UN_Pickups_Shield_Belt'
		Scale3D=(X=1.0,Y=1.0,Z=1.0)
		AlwaysLoadOnClient=TRUE
		AlwaysLoadOnServer=TRUE

		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Dynamic=FALSE,Static=TRUE,CompositeDynamic=TRUE)
		LightEnvironment=DroppedPickupLightEnvironment
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)

		CollideActors=FALSE
		MaxDrawDistance=7000
	End Object
	EnitityMesh=BulletPickUpComp
	CollisionComponent=BulletPickUpComp
	Components.Add(BulletPickUpComp)

	bBlockActors=true
	Physics=PHYS_RigidBody
	bStatic=false
	//bMovable=false
	bCollideActors=true
	bWorldGeometry=false


	ExplosionTemplate=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketExplosion'
	SelfDestructSoundCue=SoundCue'A_Vehicle_Goliath.SoundCues.A_Vehicle_Goliath_Fire'
	DamageRadius=100
	DamageMomentum=200

}
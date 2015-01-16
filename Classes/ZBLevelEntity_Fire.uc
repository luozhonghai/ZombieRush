class ZBLevelEntity_Fire extends ZBLevelEntity;


var ZombieRushPawn BurnPawn;
var bool bBurn;

var float IntervalTime;
event tick(float deltaTime)
{
	if(bBurn&&BurnPawn!=None)
	{
		IntervalTime+=deltaTime;
		if(IntervalTime>=1.0f)
		{
			IntervalTime=0.0f;
		  BurnPawn.CustomTakeDamage(30);
		  if(BurnPawn.GetCustomHealth()<=0)
		    BurnPawn.BurnToDeath();
		}
	}
}
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local ZombieRushPawn P;
	P = ZombieRushPawn(Other);
	if( P != None )
	{
	    BurnPawn = ZombieRushPawn(Other);
	    bBurn = true;
	 }
	   // givebullettopanw();
}
event UnTouch( Actor Other )
{
	if(BurnPawn!=none&&BurnPawn==Other)
	{
	     BurnPawn = None;
	     bBurn = false;
	 }
}
defaultproperties
{
	IntervalTime=0.0f
	Begin Object Class=StaticMeshComponent Name=BulletPickUpComp
		//model of bullet
		StaticMesh=StaticMesh'Pickups.Armor_ShieldBelt.Mesh.S_UN_Pickups_Shield_Belt'
		Scale3D=(X=1.5,Y=1.5,Z=1.5)
		AlwaysLoadOnClient=TRUE
		AlwaysLoadOnServer=TRUE

		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Dynamic=FALSE,Static=TRUE,CompositeDynamic=TRUE)
		LightEnvironment=DroppedPickupLightEnvironment

		CollideActors=FALSE
		MaxDrawDistance=7000
	End Object
	EnitityMesh=BulletPickUpComp
	Components.Add(BulletPickUpComp)
	
	Begin Object Class=ParticleSystemComponent Name=MyParticleSystemComponent
		//fire effect
		Template=ParticleSystem'Pickups.Berserk.Effects.P_Pickups_Berserk_Idle'
		bAutoActivate=true
		SecondsBeforeInactive=1.0f
	Translation=(X=0.0,Y=0.0,Z=+5.0)
	End Object
	Components.Add(MyParticleSystemComponent)
	ParticleEffect=MyParticleSystemComponent

}
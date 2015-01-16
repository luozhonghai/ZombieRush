class ZBLevelEntity_HealthMedKit extends ZBLevelEntity;

var() int HealthAmount;
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local ZombiePlayerPawn P;
	P = ZombiePlayerPawn(Other);
	if( P != None )
	{
	  P.RestoreHealth(HealthAmount);
	   Destroy();
	}
}

defaultproperties
{
	HealthAmount=20
	CollisionComponent=CollisionCylinder0
	Begin Object Class=StaticMeshComponent Name=BulletPickUpComp
		//model of power medcine
		StaticMesh=StaticMesh'supplies.firstaid.firstaid_small'
		Scale3D=(X=1.0,Y=1.0,Z=1.0)
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
}
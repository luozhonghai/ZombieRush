class ZBLevelEntity_BlockadeDamageable extends ZBLevelEntity;


var() int BlockHealth;

function DestructBlockade(int damage)
{
	BlockHealth-=damage;
	if(BlockHealth<=0)
	{
	   //Spawn Emitter?
	   Destroy();
	}	   
}
defaultproperties
{
	   BlockHealth=30
		Begin Object Class=StaticMeshComponent Name=BulletPickUpComp
		//model of BlockadeDamageable
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
	CollisionComponent=BulletPickUpComp
	Components.Add(BulletPickUpComp)

	bBlockActors=true
	Physics=PHYS_RigidBody
	//bStatic=true
	//bMovable=false
	bCollideActors=true
	bWorldGeometry=true

}
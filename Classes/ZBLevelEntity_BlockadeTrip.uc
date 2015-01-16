class ZBLevelEntity_BlockadeTrip extends ZBLevelEntity;


/**
1.	zhangai_01
2.	zhangai_02
3.	luzhang_01
4.  luzhang_03
5.	luzhang_03a
6.	bike_01
7.	xiaofangshuan_01
*/

//blockade that trip player
// 0  normal
// 1  climbable   4\5
var() int BlockadeType;
defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=BulletPickUpComp
		//model of BlockadeTrip
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
	
	BlockadeType=0
}
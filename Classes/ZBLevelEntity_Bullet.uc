class ZBLevelEntity_Bullet extends ZBLevelEntity
   dependson(ZombieRushPawn);

var() int BulletNum;

//0 pistol
//1 rifle
//2 scatter gun
var() EWeaponType BulletType;

event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local ZombieRushPawn P;
	P = ZombieRushPawn(Other);
	if( P != None )
	{
	   // P.AddWeaponAmmo(BulletType,BulletNum);
	    P.AddSharedWeaponAmmo(BulletNum);
	    Destroy();
	}
}
defaultproperties
{
	BulletNum=15
	BulletType=EWT_Pistol
	CollisionComponent=CollisionCylinder0
	Begin Object Class=StaticMeshComponent Name=BulletPickUpComp
		//model of bullet
		StaticMesh=StaticMesh'supplies.Ammo.ammo_small'
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
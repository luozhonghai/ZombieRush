class ZBLevelEntity_Weapon extends ZBLevelEntity
     dependson(ZombieRushPawn);


//0 axe
//1 pistol
//2 rifle
//3 scatter gun
//var() int WeaponType;

var() EWeaponType WeaponType;
//add health instant
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local ZombieRushPawn P;
	P = ZombieRushPawn(Other);
	if( P != None )
	{
	   // givebullettopanw();
	   P.SetActiveWeaponByType(WeaponType);
	   Destroy();
	}
}


defaultproperties
{
	WeaponType=EWT_Axe
	Begin Object Class=StaticMeshComponent Name=BulletPickUpComp
		//model of Weapon
		StaticMesh=StaticMesh'zombie.Weapon.futou_01'
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
}
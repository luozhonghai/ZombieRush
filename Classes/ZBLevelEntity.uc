class ZBLevelEntity extends Actor
    placeable;



var() ParticleSystemComponent ParticleEffect;

var LightEnvironmentComponent MyLightEnvironment;

var() PrimitiveComponent EnitityMesh;

var PrimitiveComponent CollisionCylinder;

// When touched by an actor.
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{/*
		local Pawn P;
		// If touched by a player pawn, let him pick this up.
		P = Pawn(Other);
		if( P != None && ValidTouch(P) )
		{
			GiveTo(P);
		}*/
}


defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=DroppedPickupLightEnvironment
		bDynamic=FALSE
		bCastShadows=FALSE
		AmbientGlow=(R=0.2,G=0.2,B=0.2,A=1.0)
	End Object
	MyLightEnvironment=DroppedPickupLightEnvironment
	Components.Add(DroppedPickupLightEnvironment)

    Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Inventory'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Inventory"
	End Object
	Components.Add(Sprite)

	Begin Object Class=CylinderComponent Name=CollisionCylinder0
		CollisionRadius=+000100.000000
		CollisionHeight=+00050.000000
		CollideActors=true
		bAlwaysRenderIfSelected=true
	End Object
	//CollisionComponent=CollisionCylinder0
	CollisionCylinder=CollisionCylinder0
	Components.Add(CollisionCylinder0)

    bHidden=false
	bCollideActors=true
	bCollideWorld=true
    bBlockActors=false
    Physics=PHYS_Falling
}

/*
simulated event SetPickupMesh(PrimitiveComponent NewPickupMesh)
{
	if (NewPickupMesh != None && WorldInfo.NetMode != NM_DedicatedServer )
	{
		PickupMesh = new(self) NewPickupMesh.Class(NewPickupMesh);
		if ( class<UTWeapon>(InventoryClass) != None )
		{
			PickupMesh.SetScale(PickupMesh.Scale * 1.2);
		}
		PickupMesh.SetLightEnvironment(MyLightEnvironment);
		AttachComponent(PickupMesh);
	}
}

simulated event SetPickupParticles(ParticleSystemComponent NewPickupParticles)
{
	if (NewPickupParticles != None && WorldInfo.NetMode != NM_DedicatedServer )
	{
		PickupParticles = new(self) NewPickupParticles.Class(NewPickupParticles);
		AttachComponent(PickupParticles);
		PickupParticles.SetActive(true);
	}
}
*/
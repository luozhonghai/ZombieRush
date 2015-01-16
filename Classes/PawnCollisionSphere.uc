class PawnCollisionSphere extends Actor;


event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	`log("Touch(Actor");
}
event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp )
{
	`log("HitWall");
	TriggerEventClass(class'SeqEvent_HitWall', Wall);
}
// Encroachment
event bool EncroachingOn( actor Other )
{
	if ( Other.bWorldGeometry || Other.bBlocksTeleport )
		return true;


	return false;
}

event EncroachedBy( actor Other )
{
	`log("Touch(Actor");
}
DefaultProperties
{
	Begin Object Class=DrawSphereComponent Name=DrawSphere0
		SphereColor=(B=255,G=70,R=64,A=255)
		SphereRadius=250.000000
		CollideActors=true
		Translation=(Z=3)
	End Object
		CollisionComponent=DrawSphere0
		Components.Add(DrawSphere0)

		Physics=PHYS_Projectile

		bCollideActors=true
		bCollideWorld=true
		bStatic=false
		bMovable=true
		bEdShouldSnap=True
}

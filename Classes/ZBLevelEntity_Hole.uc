class ZBLevelEntity_Hole extends ZBLevelEntity;

// Body...
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local ZombiePawn P;
	P = ZombiePawn(Other);
	if( P != None )
	{
	    if(ZombieRushPawn(P)!=none)
	    {
	    	ZombieRushPC(P.Controller).FallIntoHole(Location);
	    }
	    else if(ZBAIPawnBase(P)!=none)
	    {
	    	ZombieControllerTest(P.Controller).FallIntoHole(Location);
	    }
	}
}
defaultproperties
{
	CollisionComponent=CollisionCylinder0
}
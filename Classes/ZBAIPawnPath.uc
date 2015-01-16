class ZBAIPawnPath extends ZBAIPawnBase;


var() int PathIndex;
// Body...
function CustomDie()
{
	super.CustomDie();
	ZombieSpawnNodePathSwarmer(NodeOwner).RemoveChild(self);
}
defaultproperties
{
	
}
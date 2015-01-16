class ZombieSpawnZone extends Info
	placeable;

var() array<ZombieSpawnNode> SpawnNodeList;

simulated function OnCreateZombie(SeqAct_CreateZombie inAction)
{
	local ZombieSpawnNode SpawnNode;
	foreach SpawnNodeList(SpawnNode)
		SpawnNode.SpawnZombie();
}

simulated function OnKillZombie(SeqAct_KillZombie inAction)
{ 
	local ZombieSpawnNode SpawnNode;
	foreach SpawnNodeList(SpawnNode)
		SpawnNode.KillZombie();
}
DefaultProperties
{
}

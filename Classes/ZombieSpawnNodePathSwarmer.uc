class ZombieSpawnNodePathSwarmer extends ZombieSpawnNodeDistance;

struct PathNodeList
{
	var() array<Note> PathNode;
};

var(PropertySwarmer) array<PathNodeList> PathList;
var(PropertySwarmer) int SpawnInterval;
var(PropertySwarmer) int SpawnMaxNum;
var(PropertySwarmer) float FirstSpawnDelay;

var private array<ZBAIPawnBase> ZombieList;
var private int PathCount;
var private int ZombieCount;
var private float SpawnTimer;
var private bool bFirstSpawn;
// Body...

event CustomInitialize()
{
	PlayerPawn = ZombieRushPawn(GetALocalPlayerController().Pawn);
	PathCount = PathList.Length;
}
function SpawnZombie()
{
	myZombie = Spawn(class'ZBAIPawnPath',self,,Location,Rotation);
	if(ZBAIPawnPath(myZombie) != none)
	{
		myZombie.NodeOwner = self;
		InitZombieProperty();
		InitZombieAnim();
		ZombieList.AddItem(myZombie);
		ZombieCount++;
		ZBAIPawnPath(myZombie).PathIndex = Rand(PathCount);
		myZombie.SpawnController(ZombieControllerType);
	}
}

event tick(float deltaTime)
{
	local int index;
	if(PlayerPawn == none)
		return;
	if(ActiveDist <=0 || GetDistanceFromPlayer() <= ActiveDist)
	{
		if(!bFirstSpawn)
		{
			SpawnTimer += deltaTime;
			if(SpawnTimer >= FirstSpawnDelay)
			{
				bFirstSpawn = true;
				SpawnTimer = 0.0;
				SpawnZombie();
			}
		}
		if(ZombieCount < SpawnMaxNum)
		{
			SpawnTimer += deltaTime;
			if(SpawnTimer >= SpawnInterval)
			{
				if(!FastTrace(Location,PlayerPawn.Location))
				{
					SpawnTimer = 0;
					SpawnZombie();
				}
				else
				  SpawnTimer = SpawnInterval;
			}
		}
	}
	else if(GetDistanceFromPlayer() >= InActiveDist && ZombieCount > 0)
	{
		for(index = 0; index < ZombieList.Length; index++)
		{
			ZombieList[index].CustomDie();
		}
		//ZombieCount = 0;
	  //ZombieList.Remove(0,ZombieList.Length-1);
	}
}
function RemoveChild(ZBAIPawnPath Zombie)
{
	ZombieList.RemoveItem(Zombie);
	ZombieCount--;
}
defaultproperties
{
	SpawnMaxNum=10
	SpawnInterval=20
	ZombieControllerType=class'ZombieControllerPath'
	FirstSpawnDelay=0.0
}
class ZombieSpawnNodeDistance extends Info placeable;

enum EZombieAppear{
	EZA01,
	EZA_02,
	EZA_03,
	EZA_04,
	EZA_04a,
	EZA_05,
	EZA_01,
	EZA_01a
};
enum EZombieAnimType{
	EZAT_Walk01,
	EZAT_Walk02,
	EZAT_Walk03,
	EZAT_Creep01,
	EZAT_Creep02
};
enum EZombieType
{
	EZT_Walk,
	EZT_Creep,
};
struct AnimationNameConfig{
  var() name IdleAnim;
  var() name MoveAnim;
  StructDefaultProperties{
  	IdleAnim='zombie01-daiji';
  	MoveAnim='zombie01-move';
  }
};
var(Property) EZombieType ZombieType;
var(Property) EZombieAppear ZombieAppear;
var(Property) EZombieAnimType ZombieAnimType;
/** -1: always active. */
var(Property) float ActiveDist;
var(Property) float InActiveDist;
var(Property) class<ZombieControllerTest> ZombieControllerType;
var ZBAIPawnBase myZombie;
var array<SkeletalMesh> MeshList;
var array<AnimationNameConfig> AnimationList;

var ZombieRushPawn PlayerPawn;
var bool bCanSpawn;
// Body...
event CustomInitialize()
{
	PlayerPawn = ZombieRushPawn(GetALocalPlayerController().Pawn);
  if( ActiveDist <=0 || GetDistanceFromPlayer() <= ActiveDist )
  	SpawnZombie();
}
function float GetDistanceFromPlayer()
{
	return VSize(PlayerPawn.Location - Location);
}
function SpawnZombie()
{
  myZombie = Spawn(class'ZBAIPawnBase',self,,Location,Rotation);
	if(myZombie != none)
	{
		myZombie.NodeOwner = self;
		InitZombieProperty();
		InitZombieAnim();
		myZombie.SpawnController(ZombieControllerType);
	}
}

event tick(float deltaTime)
{
	if(PlayerPawn == none || ActiveDist <=0)
	{
		PlayerPawn = ZombieRushPawn(GetALocalPlayerController().Pawn);
		return;
	}
		
	if(myZombie == none && GetDistanceFromPlayer() <= ActiveDist && bCanSpawn)
	{
		bCanSpawn = false;
		SpawnZombie();
	}
	else if(GetDistanceFromPlayer() >= InActiveDist)
	{
		bCanSpawn = true;
		if(myZombie != none)
		{
			myZombie.CustomDie();
			myZombie = none;
		}
	}
}

function InitZombieProperty()
{
	myZombie.ZombieType = ZombieType;
	myZombie.ZombieAnimType = ZombieAnimType;
  myZombie.Mesh.SetSkeletalMesh(MeshList[ZombieAppear]);
}

// call from ZBAIPawnBase when init AnimTree
function InitZombieAnim()
{
	myZombie.IdleNode.SetAnim(AnimationList[ZombieAnimType].IdleAnim);
	myZombie.MoveNode.SetAnim(AnimationList[ZombieAnimType].MoveAnim);
}

function ForceKillZombie()
{
	if(myZombie != none)
	{
		myZombie.CustomDie();
		myZombie = none;
	}
}
defaultproperties
{
	MeshList(0)=SkeletalMesh'zombie.Character.zombie01'
	MeshList(1)=SkeletalMesh'zombie.Character.zombie_02'
	MeshList(2)=SkeletalMesh'zombie.Character.zombie_03'
	MeshList(3)=SkeletalMesh'zombie.Character.zombie_04'
	MeshList(4)=SkeletalMesh'zombie.Character.zombie_04a'
	MeshList(5)=SkeletalMesh'zombie.Character.zombie_05'
	MeshList(6)=SkeletalMesh'zombie.Character.zombie_01'
	MeshList(7)=SkeletalMesh'zombie.Character.zombie_01a'

	AnimationList(0)=(IdleAnim="zombie01-daiji",MoveAnim="zombie01-move")
	AnimationList(1)=(IdleAnim="zombie01-daiji",MoveAnim="zombie02-move")
	AnimationList(2)=(IdleAnim="zombie01-daiji",MoveAnim="zombie03-move")
	AnimationList(3)=(IdleAnim="zombie-paxing",MoveAnim="zombie-paxing")
	AnimationList(4)=(IdleAnim="zombie-paxingdaiji",MoveAnim="zombie-paxing_02")

	ActiveDist=5000.0f
	InActiveDist=6000.0f
	bSpawnActive=true

	ZombieControllerType=class'ZombieControllerTest'

	bCanSpawn=true
}
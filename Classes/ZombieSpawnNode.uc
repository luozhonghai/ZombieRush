class ZombieSpawnNode extends Info placeable;

var Float Length;
var float Width;
var() Const EditConst DrawBoxComponent BoxComponent;

var(Zombie) int MinNumber;
var(Zombie) int MaxNumber;


var int SpawnNum;
var array<ZBAIPawnBase>  ZombieList;
function PreBeginPlay()
{
	Width = BoxComponent.BoxExtent.X;
	Length = BoxComponent.BoxExtent.Y;
	Super.PreBeginPlay();
}

function SpawnZombie()
{
	local int num;
	local ZBAIPawnBase ZB;
	local vector SpawnLoc;
  //  SpawnNum = randRange(MinNumber,MaxNumber);//float
	SpawnNum = MinNumber + rand(MaxNumber-MinNumber+1);//int
    
    while (SpawnNum>0&&num<SpawnNum){
		 SpawnLoc = Location + (2*frand()-1)*Width*vect(1,0,0)+(2*frand()-1)*Length*vect(0,1,0);
         ZB = Spawn(class'ZBAIPawnBase',,,SpawnLoc);
		 if(ZB!=NONE){
             num++;
             ZombieList.addItem(ZB);
		 }
    }
}

function KillZombie()
{
	local ZBAIPawnBase SpawnedZB;
	foreach ZombieList(SpawnedZB)
	{
		ZombieList.RemoveItem(SpawnedZB);
		SpawnedZB.CustomDie();
       //  SpawnedZB.Destroy();
	}
    
}
DefaultProperties
{
	Begin Object Class=DrawBoxComponent Name=DrawBox0

	End Object
	BoxComponent=DrawBox0
	Components.Add(DrawBox0);

	MinNumber=0 

	MaxNumber=2
}

class ZBEffectBuffer extends Actor;

var ZombieRushPC MyPCOwner;
var ZombieRushPawn MyPawn;
var float VelocityScale;
var bool bActive;
event PostBeginPlay()
{
	MyPCOwner = ZombieRushPC(Owner);	
	VelocityScale = 1.0;
}
function AddDingciEffect()
{
	if(IsTimerActive('RemoveDingciEffect'))
	 return;
	 
	if(MyPawn == None)
	  MyPawn = ZombieRushPawn(MyPCOwner.Pawn);

	///////Set Corresponding Anim

	///////////
	MyPawn.CustomTakeDamage(10);
	bActive = true;
	VelocityScale = 0.5;
	SetTimer(20,false,'RemoveDingciEffect');
}
function RemoveDingciEffect()
{
	///////Reset Corresponding Anim

	///////////

   	VelocityScale = 1.0;
   	bActive = false;
}
event Destroyed()
{
	super.Destroyed();
	ClearTimer('RemoveDingciEffect');
}
DefaultProperties
{
}
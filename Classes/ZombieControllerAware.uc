class ZombieControllerAware extends ZombieControllerTest;

var AnimNodeSequence AnimNode;
var name IdleAnimName;
var float AnimLength;
var ZombiePawn.AnimationParaConfig AnimCfg_GetUp;//, AnimCfg_Lie;

var float AwarePlayerDistance;
function initializeGame()
{
	super.initializeGame();
	IdleAnimName = ActiveAIPawn.IdleNode.AnimSeqName;
}
function SetIdleAnim()
{
	ActiveAIPawn.IdleNode.SetAnim(IdleAnimName);
  ActiveAIPawn.IdleNode.Rate = 1.0;
}
/*****************************************
 * **************States*******************
 * ***************************************/

//initialize state, should only be called once at the beginning
auto state initializePlayer
{
Begin:
	initializeGame();
	GotoState('Lying');
}
state Lying
{
	event BeginState(Name PreviousStateName)
	{

	}
	event Tick(float deltaTime)
	{
		 distanceToPlayer = VSize(globalPlayerController.Pawn.Location - Pawn.Location);
		 if(distanceToPlayer <= AwarePlayerDistance)
		   GotoState('GetUp');
	}
begin:
		ActiveAIPawn.IdleNode.SetAnim('zombie-pushaway');
		AnimLength = ActiveAIPawn.IdleNode.GetAnimPlaybackLength();
		ActiveAIPawn.IdleNode.SetPosition(AnimLength-0.05, false);
	  ActiveAIPawn.IdleNode.Rate = 0.0; 
}
state GetUp
{
	begin:
     ActiveAIPawn.PlayConfigAnim(AnimCfg_GetUp);
     AnimNode = ActiveAIPawn.CurrentActiveCustomAnimNode.GetCustomAnimNodeSeq();
     SetTimer(0.4,false,'SetIdleAnim');
     FinishAnim(AnimNode);
     LatentWhatToDoNext();
}

defaultproperties
{
	AwarePlayerDistance=300
//	AnimCfg_Lie=(AnimationNames=("zombie-pushaway"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendouttime=-1.0)
	AnimCfg_GetUp=(AnimationNames=("zombie-getup"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendouttime=0.15)
}
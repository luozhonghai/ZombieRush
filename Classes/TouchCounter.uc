class TouchCounter extends Actor implements(ITouchable)
	placeable;

// accept several touches then trigger Seq_event and disable; 
var(TouchCounter) int TouchNum;
var(TouchCounter) float FinishDelayTime;
var(TouchCounter) bool bLatentTrigger;
var(TouchCounter)	editconst const	ParticleSystemComponent ParticleSystemComponent;

var bool Enabled;

var bool bDestroyed;
event PostBeginPlay()
{
	if (!Enabled)
	{
		SetHidden(true);
	}
	//ParticleSystemComponent.ActivateSystem(true);
}
function EnableTouchCounter()
{
	if(bDestroyed)
		return;
   Enabled = true;
  // ParticleSystemComponent.SetActive(true);
   ParticleSystemComponent.ActivateSystem(true);
   SetHidden(false);
}
function DisableTouchCounter()
{
   Enabled = false;
   ParticleSystemComponent.SetActive(false);
   SetHidden(true);
}
function OnTouch()
{
	//`log("TouchCounter on touch!");
	if (!Enabled)
	{
		return;
	}

	if(TouchNum == 1)
	{
	   if(bLatentTrigger)
         setTimer(FinishDelayTime,false,'TriggerFinishEvent');
	   else
         TriggerFinishEvent();
	   DisableTouchCounter();
	   TriggerEventClass(class 'SeqEvent_TouchCounterOnce',self);
	}
	else
	{
	   TriggerEventClass(class 'SeqEvent_TouchCounterOnce',self);
       TouchNum--;
	}
}

simulated function OnToggleTouchCounter(SeqAct_ToggleTouchCounter inAction)
{
	if(inAction.bEnable)
	  EnableTouchCounter();
	else
	  DisableTouchCounter();
}

function TriggerFinishEvent()
{
    TriggerEventClass(class 'SeqEvent_TouchCounterFinish',self);
	bDestroyed=true;
}
DefaultProperties
{
	Enabled = false
	bLatentTrigger=false
	bCollideActors=true
	bStatic=false
	bBlockActors=true
    TouchNum=1
	FinishDelayTime=0.0

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent0
	  Template=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_3P_Beam_MF_Blue'
	  SecondsBeforeInactive=1.000000
	  bAutoActivate=true
	  Scale=10
	End Object
	ParticleSystemComponent=ParticleSystemComponent0
	Components.Add(ParticleSystemComponent0)


	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		StaticMesh=StaticMesh'Zombie_Intity.Touchable.Sphere'
		HiddenGame=TRUE
		CollideActors=TRUE
		BlockActors=TRUE
		AlwaysCheckCollision=TRUE
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,FracturedMeshPart=FALSE)
	End Object
	Components.Add(StaticMeshComponent1)
	
	SupportedEvents(4)=class 'SeqEvent_TouchCounterFinish'
    SupportedEvents(5)=class 'SeqEvent_TouchCounterOnce'

	//ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_3P_Beam_MF_Blue'
}

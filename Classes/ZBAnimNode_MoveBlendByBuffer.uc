class ZBAnimNode_MoveBlendByBuffer extends UDKAnimBlendBase;

// Body...
var ZombieRushPawn ZP;
var ZombieRushPC ZPC;

var bool bInterpEnd;
var float  InterpTime;
var() float InterpAnimEndTime;
event OnBecomeRelevant()
{
	//  SetPosition(0.0,false);
	//PlayAnim(bLooping,Rate,0.0);
	ZP = ZombieRushPawn(SkelComponent.Owner);
	
}



event TickAnim(Float DeltaSeconds)
{
	if (ZP!=none)
	{
		ZPC = ZombieRushPC(ZP.Controller);
		if(ZPC != none)
		{
			if(ZPC.EntityBuffer.bActive && VSize(ZP.Velocity)>0 && InterpTime < InterpAnimEndTime)
			{
				SetActiveChild(1,0.1);
				InterpTime += DeltaSeconds;
			}
			else if(ZPC.EntityBuffer.bActive && VSize(ZP.Velocity)>0 && InterpTime >= InterpAnimEndTime)
				SetActiveChild(2,0.1);
			else
			{
				SetActiveChild(0,0.1);
				if(!ZPC.EntityBuffer.bActive)
					InterpTime = 0.0;
			}
		}
	}
}
defaultproperties
{	
	bTickAnimInScript=true
	bCallScriptEventOnBecomeRelevant=true
	InterpAnimEndTime=1.0
}
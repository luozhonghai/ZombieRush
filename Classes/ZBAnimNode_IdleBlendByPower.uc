class ZBAnimNode_IdleBlendByPower extends UDKAnimBlendBase;

var bool bExhausted;
var ZombiePlayerPawn ZPP;
event OnBecomeRelevant()
{
	//  SetPosition(0.0,false);
	//PlayAnim(bLooping,Rate,0.0);
	ZPP = ZombiePlayerPawn(SkelComponent.Owner);
	
}



event TickAnim(Float DeltaSeconds)
{
	if (ZPP!=none)
	{
		if(ZPP.GetPower()>60)
			bExhausted = false;
		if(ZPP.GetPower()>0 && !bExhausted)
		  SetActiveChild(0,0.1);
		else
		{
		  SetActiveChild(1,0.1);
		  bExhausted = true;
		}
	}
}
DefaultProperties
{
	bTickAnimInScript=true
    Children(0)=(Name="Normal")
    Children(1)=(Name="Exhausted")
    bFixNumChildren=True

	bCallScriptEventOnBecomeRelevant=true
	bExhausted=false
}

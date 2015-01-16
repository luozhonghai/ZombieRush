class SeqAct_SetTransitInfo extends SequenceAction;


var() array<Object> Dests;

var int  DestLength;
event Activated()
{
}

function Actor PickRandomDest()
{
	//local SeqVar_Object TargetVar;
	local Actor Dest;
	local int index;
	index = rand(Dests.Length);
	/*
	foreach LinkedVariables(class 'SeqVar_Object',TargetVar,"Target")
	{
		`log(TargetVar.GetObjectValue());
          Dest = TargetVar.GetObjectValue();
		  if(Dest != none)
		  {
			KDInfo(GetWorldInfo().Game).Dest = KDClaw(Claw);

		  }
	}*/
    Dest = Actor(Dests[index]);
    return Dest;
}
defaultproperties
{
	ObjName="SeqAct_SetTransitInfo"
	ObjCategory="ZGame Actions"
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Dest",PropertyName=Dests)
}

// extend UIAction if this action should be UI Kismet Action instead of a Level Kismet Action
class SeqAct_ToggleTouchCounter extends SequenceAction;

var() bool bEnable;
event Activated()
{
}

defaultproperties
{
	bEnable=true
	ObjName="SeqAct_ToggleTouchCounter"
	ObjCategory="ZGame Actions"
}

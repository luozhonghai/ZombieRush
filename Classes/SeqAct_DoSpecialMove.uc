// extend UIAction if this action should be UI Kismet Action instead of a Level Kismet Action
class SeqAct_DoSpecialMove extends SequenceAction
	dependson(ZombiePawn);

var()	ZombiePawn.ESpecialMove					SpecialMove;
event Activated()
{
}

defaultproperties
{
	ObjName="DoSpecialMove"
	ObjCategory="ZGame Actions"
}

// extend UIAction if this action should be UI Kismet Action instead of a Level Kismet Action
class SeqAct_SpecialMovesHelper extends SequenceAction;


struct  SpecialMoveConfig
{
	var()	ZombiePawn.ESpecialMove					SpecialMove;
	var()   bool bDisable;
};

var() array<SpecialMoveConfig> SpecialMovesConfig;

var() bool bDisableDashBtn;
var() bool bDisableJumpBtn;
var() bool bDisableActBtn;

var() bool bOverrideGroundSpeed;
var() int GroundSpeed;
event Activated()
{
}

defaultproperties
{
	ObjName="SpecialMovesHelper"
	ObjCategory="ZGame Actions"
}

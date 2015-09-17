class SeqCond_IsDoingSpecialMove extends SequenceCondition;

var() Controller PawnObject;
var() ZombiePawn.ESpecialMove         SpecialMove;

// Body...
event Activated()
{
  if (ZombiePawn(PawnObject.Pawn) != None &&  ZombiePawn(PawnObject.Pawn).IsDoingSpecialMove(SpecialMove))
  {
    OutputLinks[0].bHasImpulse = true;
  }
  else
  {
    OutputLinks[1].bHasImpulse = true;
  }
}
defaultproperties
{
  ObjName="SeqCond_IsDoingSpecialMove"
  ObjCategory="ZBGame"

  InputLinks(0)=(LinkDesc="In")
  OutputLinks(0)=(LinkDesc="True")
  OutputLinks(1)=(LinkDesc="False")

  VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Pawn",PropertyName=PawnObject)
}
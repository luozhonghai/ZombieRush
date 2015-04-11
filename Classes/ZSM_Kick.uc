class ZSM_Kick extends ZBSpecialMove;

// Body...
var() ZombiePawn.AnimationParaConfig AnimCfg_Kick;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
  Super.SpecialMoveStarted(bForced, PrevMove);
  PawnOwner.PlayConfigAnim(AnimCfg_Kick);
}
function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
  Super.SpecialMoveEnded(PrevMove, NextMove);
}

function KickStart()
{
  ZombieRushPC(PawnOwner.Controller).ImplPushDrum();
}
defaultproperties
{
  AnimCfg_Kick=(AnimationNames=("actor-kick"),BlendInTime=0.1,BlendOutTime=0.1,PlayRate=0.5,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
  UseCustomRMM=True
  RMMInAction=RMM_Translate
}
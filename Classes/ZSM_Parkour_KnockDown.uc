class ZSM_Parkour_KnockDown extends ZBSpecialMove;

// Body...

var() ZombiePawn.AnimationParaConfig		AnimCfg_Animation;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);
	PawnOwner.PlayConfigAnim(AnimCfg_Animation);
}
function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
}

function bool CanOverrideMoveWith(ESpecialMove NewMove)
{
	//cant be interrupt when i konecked back
	return false;
}

defaultproperties
{
	AnimCfg_Animation=(AnimationNames=("actor-Knockdown"),BlendInTime=0.05,BlendOutTime=0.0,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[2]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
	bDisableMovement=True
}
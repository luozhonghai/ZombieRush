class ZSM_Hit_Thr extends ZSM_WeaponMeleeBase;



var() ZombiePawn.AnimationParaConfig		AnimCfg_Animation;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	//ZombiePlayerPawn(PawnOwner).Slot_FullBody.StopCustomAnim(0);
	Super.SpecialMoveStarted(bForced, PrevMove);
    PCOwner.gotoState('PlayerAttacking');
	//PawnOwner.SoundGroupClass.static.PlayATKSoundOne(PawnOwner);

}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
  //  ZombiePlayerPawn(PawnOwner).ConsumePower(8);
    /*
	if (ZombiePlayerPawn(PawnOwner).PlayerPower <= 0)
	{
		PawnOwner.DoSpecialMove(SM_Player_Exhausted,true);

	}
	else*/
    if(PCOwner.InteractZombie==none)
    {
		PCOwner.gotoState(PCOwner.NormalStateName);
	}
	ZBWeaponForce(PawnOwner.Weapon).NotifyFireSpecialMoveFinished();
	//PawnOwner.StopConfigAnim(AnimCfg_Animation, AnimCfg_Animation.BlendOutTime);
}

simulated function Inner_StartPlayComboAnimation()
{
	PawnOwner.PlayConfigAnim(AnimCfg_Animation);
}


DefaultProperties
{
	//gongji01(1)
	//	gongji03
	AnimCfg_Animation=(AnimationNames=("zhujue_gongji_futou03"),BlendInTime=0.1,BlendOutTime=0.1,PlayRate=0.700000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[2]=RBA_Translate,FakeRootMotionMode=RMM_Accel)

//	AnimCfg_Animation=(AnimationNames=("HD_heidi_att_03"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[2]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
}
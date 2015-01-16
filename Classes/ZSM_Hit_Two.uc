class ZSM_Hit_Two extends ZSM_WeaponMeleeBase;


var bool startmove;
var() ZombiePawn.AnimationParaConfig		AnimCfg_Animation;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	//动画混合阶段还未结束时 需要首先停止上一个动画 
	//Anim_endNotify之后接下一个SpecialMove
//	ZombiePlayerPawn(PawnOwner).Slot_FullBody.StopCustomAnim(0);
	Super.SpecialMoveStarted(bForced, PrevMove);
    PCOwner.gotoState('PlayerAttacking');
	startmove =true;
	//PawnOwner.SoundGroupClass.static.PlayATKSoundOne(PawnOwner);

}


function bool CanChainMove(ESpecialMove NextMove)
{
	if ( NextMove == SM_MeleeAttack3)
	{
		return true;
	}
	else

		return false;
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
	  // PCOwner.gotoState(PCOwner.NormalStateName);
	    PCOwner.MeleeAutoFire(1);
	}
	else
	{
		ZBWeaponForce(PawnOwner.Weapon).NotifyFireSpecialMoveFinished();
	}


	//PawnOwner.StopConfigAnim(AnimCfg_Animation, AnimCfg_Animation.BlendOutTime);
}

simulated function Inner_StartPlayComboAnimation()
{
	//PawnOwner.StopConfigAnim(AnimCfg_EatPre, 0);
//	ZombiePlayerPawn(PawnOwner).Slot_FullBody.StopCustomAnim(0);
	PawnOwner.PlayConfigAnim(AnimCfg_Animation);
}

event tickspecial(float deltatime)
{
    if (startmove
		&& ZombiePlayerPawn(PawnOwner).CustomAnimNodes[ZombiePlayerPawn(PawnOwner).LastCustomAnimNodePlayIndex].GetCustomAnimNodeSeq().GetNormalizedPosition()>0.95)
    {
		//PawnOwner.CustomAnimCfg_AnimEndNotify();
    }
}

DefaultProperties
{
	//gongji01(1)
	//	gongji03
	AnimCfg_Animation=(AnimationNames=("zhujue_gongji_futou02"),BlendInTime=0.1,BlendOutTime=0.1,PlayRate=0.8500000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[2]=RBA_Translate,FakeRootMotionMode=RMM_Accel)

//	AnimCfg_Animation=(AnimationNames=("HD_heidi_att_02"),BlendInTime=0.1,BlendOutTime=0.1,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[2]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
}
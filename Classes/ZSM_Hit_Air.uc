class ZSM_Hit_Air extends ZSM_WeaponMeleeBase;


var() ZombiePawn.AnimationParaConfig		AnimCfg_Animation;

var float beginTime;
var() float upTime;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	PawnOwner.StopConfigAnim(AnimCfg_Animation, AnimCfg_Animation.BlendOutTime);
	Super.SpecialMoveStarted(bForced, PrevMove);

	//PawnOwner.SoundGroupClass.static.PlayATKSoundOne(PawnOwner);
	PawnOwner.SetPhysics(PHYS_Custom);
	PawnOwner.CylinderComponent.SetCylinderSize(30,46);
    PawnOwner.velocity = vect(0,0,0);
    beginTime = 0;
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
    PawnOwner.SetPhysics(PHYS_Falling);
//	PawnOwner.StopConfigAnim(AnimCfg_Animation, AnimCfg_Animation.BlendOutTime);

	
}

simulated function Inner_StartPlayComboAnimation()
{
	PawnOwner.PlayConfigAnim(AnimCfg_Animation);
}

/**
 * Can this special move override InMove if it is currently playing?
 */
function bool CanOverrideSpecialMove(ESpecialMove InMove)
{
	local vector HitLocation,HitNormal,lStart,lEnd;
	local Actor HitActor;
	local float DistanceOffGround;

	if(InMove == SM_PHYS_Trans_Jump)
	{
	lStart = PawnOwner.Location;
	lEnd = PawnOwner.Location + vect(0,0,-1000);
	HitActor = PawnOwner.Trace(HitLocation, HitNormal, lEnd, lStart, true, ,,PawnOwner.TRACEFLAG_Bullet);

	if (HitActor!=NONE)
	{
		DistanceOffGround = lStart.z - PawnOwner.GetCollisionHeight() - HitLocation.z;

		if (DistanceOffGround > 40)
		{
			return true;
		}
	}
	}

	return false;
}
/**
 * Checks to see if this Special Move can be done.
 */
/*
protected function bool InternalCanDoSpecialMove()
{
	local vector HitLocation,HitNormal,lStart,lEnd;
	local Actor HitActor;
	local float DistanceOffGround;

	lStart = PawnOwner.Location;
	lEnd = PawnOwner.Location + vect(0,0,-1000);
	HitActor = PawnOwner.Trace(HitLocation, HitNormal, lEnd, lStart, true, ,,PawnOwner.TRACEFLAG_Bullet);

	if (HitActor!=NONE)
	{
		DistanceOffGround = lStart.z - PawnOwner.GetCollisionHeight() - HitLocation.z;

		if (DistanceOffGround > 40)
		{
            return true;
		}
	}
	
	return false;
}*/


event tickspecial(float deltaTime)
{
	
	 if (beginTime >= upTime)
	 {
		  PawnOwner.SetPhysics(PHYS_Falling);
		//  PawnOwner.Velocity.Z = -10;
		
		 return;
	 }
	    beginTime += deltaTime;
		PawnOwner.Velocity.Z = (PawnOwner.JumpZ * 0.2f);

		PawnOwner.Move(PawnOwner.Velocity * deltaTime);


}

DefaultProperties
{
	upTime=0.2
	//gongji01(1)
	//gongji03
	AnimCfg_Animation=(AnimationNames=("HD_heidi_jump_att"),BlendInTime=0.05,BlendOutTime=0.2,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[2]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
}
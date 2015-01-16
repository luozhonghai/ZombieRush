class ZSM_RunIntoWall extends ZBSpecialMove;

var() ZombiePawn.AnimationParaConfig		AnimCfg_Animation;

var() CameraShake HitWallShake;

var float KnockTime;
var Vector KonckVelocity;

var ESpecialMove PawnPrevMove;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);
	if(PCOwner.PlayerCamera != none)
	  PCOwner.PlayerCamera.PlayCameraShake(HitWallShake,10.0);
	PawnOwner.PlayConfigAnim(AnimCfg_Animation);
	PawnPrevMove = PrevMove;
	if(PawnPrevMove != SM_PHYS_Trans_Jump)
	{
	  KnockTime = 0.15;
		KonckVelocity =  -ZombieRushPC(PCOwner).RushDir * 200;
	}
	else
	{
		KnockTime = 0.15;
		KonckVelocity =  -ZombieRushPC(PCOwner).RushDir * 400;
	}
}
function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
	PCOwner.gotoState('PlayerRush');
}
event tickspecial(float deltaTime)
{
	if(KnockTime > 0)
  {
    KnockTime -= deltaTime;
    if(PawnPrevMove != SM_PHYS_Trans_Jump)
    	PawnOwner.velocity += KonckVelocity;
    else
  		PawnOwner.velocity = KonckVelocity;
   }	 
}

function bool CanOverrideMoveWith(ESpecialMove NewMove)
{
	if(NewMove == SM_Combat_GetHurt)
		return false;
	else
		return TRUE;
}
defaultproperties
{
	AnimCfg_Animation=(AnimationNames=("zhujue- runintowall"),BlendInTime=0.05,BlendOutTime=0.05,PlayRate=1.500000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[2]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
	bDisableMovement=True
	HitWallShake=CameraShake'Zombie_Archetype.Camera.Shake_RuntoWall'
	PawnPrevMove=SM_None
}
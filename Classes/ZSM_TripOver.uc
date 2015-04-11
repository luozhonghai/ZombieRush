class ZSM_TripOver extends ZBSpecialMove;

var() ZombiePawn.AnimationParaConfig		AnimCfg_TripOver;
var float LastTripTime;
var float MinIntervalTime;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);


	if (PawnOwner.health > 0)
	{
		PawnOwner.CollisionComponent.SetRBCollidesWithChannel(RBCC_Untitled1, false);
		PawnOwner.setphysics(PHYS_Interpolating);
		PawnOwner.SetCollision(false,false);
	//	PawnOwner.CylinderComponent.SetActorCollision(false, false);
    PawnOwner.bCollideWorld = false;
	//	PawnOwner.Mesh.SetActorCollision(false,false);
		PawnOwner.PlayConfigAnim(AnimCfg_TripOver);
	}
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
	PawnOwner.CollisionComponent.SetRBCollidesWithChannel(RBCC_Untitled1, true);
	PawnOwner.setphysics(PHYS_Walking);
  PawnOwner.bCollideWorld = true;
     
  if(ZombieRushPawn(PawnOwner)!=none)
    ZombieRushPawn(PawnOwner).bHitWall = false;
	PawnOwner.SetCollision(true,true);

	LastTripTime = PawnOwner.WorldInfo.TimeSeconds;
}
//cant be attacked by zombie
function bool CanOverrideMoveWith(ESpecialMove NewMove)
{
	if(NewMove == SM_Combat_GetHurt)
		return false;
	else
		return TRUE;
}
/**
 * Checks to see if this Special Move can be done. avoid continue tripped
 */
protected function bool InternalCanDoSpecialMove()
{
	local float CurrentTime;
	CurrentTime = PawnOwner.WorldInfo.TimeSeconds;
	if(LastTripTime < 0 || CurrentTime - LastTripTime >= MinIntervalTime)
		return TRUE;
	else
		return FALSE;
}
DefaultProperties
{
//	AnimCfg_TripOver=(AnimationNames=("zhujue-shuaidao"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendintime=0.0,blendouttime=0.3)
  AnimCfg_TripOver=(AnimationNames=("zhujue-shuaidao"),BlendInTime=0.15,BlendOutTime=0.15,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
  UseCustomRMM=True
	RMMInAction=RMM_Translate
	MinIntervalTime=1.0
	LastTripTime=-1
	//bDisableMovement=true
	//bDisableTurn=true
}
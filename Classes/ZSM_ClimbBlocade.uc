class ZSM_ClimbBlocade extends ZBSpecialMove;

var() ZombiePawn.AnimationParaConfig		AnimCfg_ClimbOver;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);


	if (PawnOwner.health > 0)
	{
		PawnOwner.setphysics(PHYS_Custom);
		 if(ZombieRushPawn(PawnOwner)!=none)
         ZombieRushPawn(PawnOwner).bHitWall = true;
	//	PawnOwner.SetCollision(false,false);
	//	PawnOwner.CylinderComponent.SetActorCollision(false, false);
        PawnOwner.bCollideWorld = false;
	//	PawnOwner.Mesh.SetActorCollision(false,false);
		PawnOwner.PlayConfigAnim(AnimCfg_ClimbOver);
	}
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
	PawnOwner.setphysics(PHYS_Walking);
     PawnOwner.bCollideWorld = true;
     
     if(ZombieRushPawn(PawnOwner)!=none)
         ZombieRushPawn(PawnOwner).bHitWall = false;
	PawnOwner.SetCollision(true,true);

	//ZombieRushPC(PCOwner).GotoState('PlayerRush');
}
DefaultProperties
{
//	AnimCfg_TripOver=(AnimationNames=("zhujue-shuaidao"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendintime=0.0,blendouttime=0.3)
    AnimCfg_ClimbOver=(AnimationNames=("zhujue-chengyue"),BlendInTime=0.15,BlendOutTime=0.25,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
    UseCustomRMM=True
	RMMInAction=RMM_Translate
	//bDisableMovement=true
	//bDisableTurn=true
}
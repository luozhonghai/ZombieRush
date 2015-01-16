class NSM_CutDown extends ZBSpecialMove;


var() ZombiePawn.AnimationParaConfig		AnimCfg_Cut,AnimCfg_GetUp;
var ZombiePawn.AnimationParaConfig LastAnimCfg;

var bool bPushedEndTimer;

var float PushedEndDelay;
var const float PushedDelayTime;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	if (PawnOwner.health > 0)
	{
		PawnOwner.PlayConfigAnim(AnimCfg_Cut);
		LastAnimCfg = AnimCfg_Cut;
	}
}


function AnimCfg_AnimEndNotify()
{
	// By default end this special move.
	if(LastAnimCfg == AnimCfg_Cut){
	//	ZombiePC(PawnOwner.getalocalplayercontroller()).HurtByZombieCinematicRecover();
		bPushedEndTimer = true;
	}
	
	else if(LastAnimCfg == AnimCfg_GetUp)
	     PawnOwner.EndSpecialMove();
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{

	local Vector boneLoc,pawnNewLoc;/*
	boneLoc = PawnOwner.mesh.GetBoneLocation('Bip01-Pelvis',0);// 0 == World, 1 == Local (Component)
	pawnNewLoc = boneLoc;
	pawnNewLoc.z=PawnOwner.location.z;
    PawnOwner.setlocation(pawnNewLoc);*/

	Super.SpecialMoveEnded(PrevMove, NextMove);

	if (PawnOwner.health > 0)
	{
	//	ZombiePC(PawnOwner.getalocalplayercontroller()).HurtByZombieZombieRecover();
		//PawnOwner.StopConfigAnim(AnimCfg_Cut, 0);
		
	}
}

event tickspecial(float deltaTime)
{
		if (bPushedEndTimer)
		{
            PushedEndDelay+=deltaTime;

			if (PushedEndDelay>PushedDelayTime)
			{
				bPushedEndTimer=false;
				PushedEndDelay=0;

				
				PawnOwner.health -= 10;
						
				if(PawnOwner.health > 0)
				{
					LastAnimCfg = AnimCfg_GetUp;
					PawnOwner.PlayConfigAnim(AnimCfg_GetUp);
				}
				else
					PawnOwner.CustomDie();

				
			}
		}
}

DefaultProperties
{
	AnimCfg_Cut=(AnimationNames=("zombie-Knockdown"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendouttime=-1.0)
	AnimCfg_GetUp=(AnimationNames=("zombie-creepingup"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendintime=0.0,blendouttime=0.15)

	UseCustomRMM=True
	RMMInAction=RMM_Translate

	PushedDelayTime=2.5
}

class NSM_Pushed extends ZBSpecialMove;


var() ZombiePawn.AnimationParaConfig		AnimCfg_Pushed,AnimCfg_GetUp,AnimCfg_Kicked;
var ZombiePawn.AnimationParaConfig LastAnimCfg;

var bool bPushedEndTimer;

var float PushedEndDelay;
var const float PushedDelayTime;

var float ForceBackDelay,ForceBackTimer;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	if (PawnOwner.health > 0)
	{
		ForceBackTimer = 0.0;
		if(PawnOwner.ZombieType == EZT_Walk)
		{
			PawnOwner.PlayConfigAnim(AnimCfg_Pushed);
			LastAnimCfg = AnimCfg_Pushed;
		}
		else if(PawnOwner.ZombieType == EZT_Creep)
		{
			PawnOwner.Mesh.RootMotionMode = RMM_Translate;
			PawnOwner.PlayConfigAnim(AnimCfg_Kicked);
			LastAnimCfg = AnimCfg_Kicked;		
		}
	}
}


function AnimCfg_AnimEndNotify()
{
	// By default end this special move.
	if(LastAnimCfg == AnimCfg_Pushed || LastAnimCfg == AnimCfg_Kicked){
		//only valid for direct interact Zombie  ,others just pushed by PlayerPawn~
		if(PawnOwner == ZombieControllerBase(PawnOwner.Controller).globalPlayerController.InteractZombie)
		{
		   ZombiePC(PawnOwner.getalocalplayercontroller()).HurtByZombieCinematicRecover();
		}
		////////////////////
		bPushedEndTimer = true;
	//	PawnOwner.SetCollision(true,true);
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
		//ZombiePC(PawnOwner.getalocalplayercontroller()).HurtByZombieZombieRecover();
		ZBAIPawnBase(PawnOwner).PushedByPlayer();
		//PawnOwner.StopConfigAnim(AnimCfg_Pushed, 0);
		
		PawnOwner.Mesh.RootMotionMode = RMM_Ignore;
	}
}

event tickspecial(float deltaTime)
{
	// No damage for push down
/*
				if (PawnOwner == ZombieControllerBase(PawnOwner.Controller).globalPlayerController.InteractZombie)
				{
					PawnOwner.health -= 20;
				}	
				*/
		if (bPushedEndTimer)
		{
            PushedEndDelay+=deltaTime;

			if (PushedEndDelay>PushedDelayTime)
			{
				bPushedEndTimer=false;
				PushedEndDelay=0;


				if(PawnOwner.health > 0)
				{
					if(LastAnimCfg == AnimCfg_Pushed)
					{
						LastAnimCfg = AnimCfg_GetUp;
						//ZBAIPawnBase(PawnOwner).RestoreFixedLocAndRot();
						PawnOwner.PlayConfigAnim(AnimCfg_GetUp);
					}
					else // for ti kai, end special move directly
						PawnOwner.EndSpecialMove();
				}
			//	else
			//		PawnOwner.CustomDie();

				
			}
		}
		else if((LastAnimCfg == AnimCfg_Pushed || LastAnimCfg == AnimCfg_Kicked))
		{
			if(ForceBackTimer<ForceBackDelay)
			   ForceBackTimer += deltaTime;
			else
			{
				 ZBAIPawnBase(PawnOwner).RecoverCollision();
				 if(LastAnimCfg == AnimCfg_Pushed)
				 PawnOwner.Move(-350 * Vector(PawnOwner.rotation) *deltaTime);
			}
			   
		}
}
DefaultProperties
{
	//zombie01-tuidao
	//zombie-pushdown
	
	//zombie-pushaway
	AnimCfg_Pushed=(AnimationNames=("zombie-pushaway"),PlayRate=1.0,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendouttime=-1.0)
    AnimCfg_Kicked=(AnimationNames=("zombie-tikai"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendouttime=-1.0)
	AnimCfg_GetUp=(AnimationNames=("zombie-getup"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendintime=0.0,blendouttime=0.15)
    
	 //  UseCustomRMM=True
	//	RMMInAction=RMM_Translate

		PushedDelayTime=2.5
		ForceBackDelay=0.4
}
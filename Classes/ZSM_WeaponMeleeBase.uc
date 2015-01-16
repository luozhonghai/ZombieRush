class ZSM_WeaponMeleeBase extends ZBSpecialMove;


function bool CanChainMove(ESpecialMove NextMove)
{
	return false;
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
	if(ZombieRushPawn(PawnOwner) != None)
		ZombieRushPawn(PawnOwner).bHitWall = true;
}
/**
 * Can a new special move override this one before it is finished?
 * This is only if CanDoSpecialMove() == TRUE && !bForce when starting it.
 */
function bool CanOverrideMoveWith(ESpecialMove NewMove)
{
	return false;
}

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	
	
	Super.SpecialMoveStarted(bForced, PrevMove);
//ÏÈstartspecialmove  ¸Ä±äMesh.RootMotion=RMM_Translate
	StartPlayComboAnimation();
}

simulated  function Inner_StartPlayComboAnimation();

event StartPlayComboAnimation()
{
	Inner_StartPlayComboAnimation();
}

DefaultProperties
{
	bDisableMovement=True
		UseCustomRMM=True
		RMMInAction=RMM_Translate
		bDisableTurn=true
}

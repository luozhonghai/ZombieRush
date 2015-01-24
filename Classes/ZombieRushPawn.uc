class ZombieRushPawn extends ZombiePlayerPawn
	dependson(ZBSpecialMove);


enum EWeaponType
  {
	EWT_None,
	EWT_Axe,
	EWT_Pistol,
	EWT_Rifle,
	EWT_ScatterGun,
};

var int TotalAmmo;
var array<int> AmmoNum;
var array<ZBWeapon> WeaponList;
  
// Only in walking status, won't be tripped over by some blockades
var private bool  bWalkingStatus;
var bool bHitWall;

var actor interactActor;

var EWeaponType CurrentWeaponType;

var bool bCaptureCase;
var Vector PushCasePoint,MoveToCaseDir;



event RanInto(Actor Other)
{
	super.RanInto(Other);										
}
event Initialize()
{
	// Ensure Pawn initializes first
	super.Initialize();		

  //look for pre hold weapon cross level , other wise get EWT_None
	CurrentWeaponType = ZombieRushGame(WorldInfo.Game).PreWeaponType;
	//Add all weapons and switch to the certain
	AddRushGameWeapons();
  //clear temp level trans info
	ZombieRushGame(WorldInfo.Game).ClearTempLevelInfo();
}
function bool IsWeaponActive(EWeaponType CheckType)
{
	return CurrentWeaponType == CheckType;
}
function AddRushGameWeapons()
{	
	WeaponList[1] = Spawn(class'ZBWeaponAxe', , , self.Location);
	WeaponList[2] = Spawn(class'ZBWeaponGun', , , self.Location);
	InvManager.AddInventory( WeaponList[1],true );
	WeaponList[1].bCanThrow = false; // don't allow default weapon to be thrown out
	InvManager.AddInventory( WeaponList[2],true );
	WeaponList[2].bCanThrow = false; // don't allow default weapon to be thrown out
	SetActiveWeaponByType(CurrentWeaponType);
}
function SetActiveWeaponByType(EWeaponType PendingType)
{
	CurrentWeaponType = PendingType;
	super.SetActiveWeapon(WeaponList[PendingType]);
}
function ConsoleSetActiveWeaponByType(EWeaponType PendingType)
{
	CurrentWeaponType = PendingType;
	super.SetActiveWeapon(WeaponList[PendingType]);
}
function AddWeaponAmmo(EWeaponType PendingType, int Num)
{
	if(Num>0)
	  AmmoNum[PendingType] += Num;
}	
function AddSharedWeaponAmmo(int Num)
{
	if(Num>0)
	  TotalAmmo += Num;
}	
function AddAmmoToCurrentWeapon()
{
	local int AmmoCount;
	if(TotalAmmo >= WeaponList[CurrentWeaponType].RELOAD_AMMO)
	{
		AmmoCount = WeaponList[CurrentWeaponType].RELOAD_AMMO;
	}
	else
	  AmmoCount = TotalAmmo;
	AmmoNum[CurrentWeaponType] += AmmoCount;
	TotalAmmo -= AmmoCount;
}

function bool CanBeMeleeAttacked()
{
	if(IsDoingASpecialMove())
    	return SpecialMoves[SpecialMove].CanOverrideMoveWith(SM_Combat_GetHurt);
	else
	  	return true;
}
event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
{
	super.Bump(Other,OtherComp,HitNormal);
	//`log("Bumping");
    if(InterpActor(Other)!=None)
	{
		if(Other.tag == 'dingci_01')
	        ZombieRushPC(Controller).EntityBuffer.AddDingciEffect();
	}
}

event BaseChange()
{
	super.BaseChange();
	if(InterpActor(Base)!=None)
	{
		if(Base.tag == 'dingci_01')
	        ZombieRushPC(Controller).EntityBuffer.AddDingciEffect();
	}
}
event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp )
{
	//use to find avoid direction when hit wall
	local Vector ForwardTraceVector,LeftForwardTraceVector,RightForwardTraceVector,X,Y,Z;

	if( ZombieRushPC(Controller).IsInState('FallingHole'))
	  return;
	super.HitWall(HitNormal,Wall,WallComp);
	
	if(bHitWall)
	   return;
	bHitWall = true;
	
	//PlayerController(Controller).ClientMessage("Wall.Tag"@Wall.Tag@Wall);
	if(InterpActor(Wall)!=None)
	{
		if(bWalkingStatus)
		   return;
		   
		if(Wall.Tag=='luzhang_01' || Wall.Tag=='luzhang' || Wall.Tag=='langan_02')
		{
		   if(abs(Vector(Wall.Rotation) dot vector(Rotation)) < 0.75)
	        TripOverByBlockade();
	       else
	        RanintoBlockade(-HitNormal);
	  }
	   else if(Wall.Tag == 'zhangai_02')
	    		TripOverByBlockade();
	    else if(Wall.tag == 'juma_01')
	        CollideCheval();
	    else if(Wall.tag == 'dingci_01')
	        ZombieRushPC(Controller).EntityBuffer.AddDingciEffect();
	    else if(Wall.tag == 'xiangzi_01' && !bCaptureCase && !IsDoingASpecialMove()&& CanGetCase())
	    {
	    	  ZeroMovementVariables();
	    	  //avoid unknown translation of case if trigger instantly...
					SetTimer(0.01,false,'PushCase');
					// ignore turn around during this interval
					ZombieRushPC(Controller).bReceiveInput = false;
	    }
	 }

	else if(ZBLevelEntity_BlockadeTrip(Wall)!=None)
	{
		if(bWalkingStatus)
		   return;
		if(ZBLevelEntity_BlockadeTrip(Wall).BlockadeType==0)
		{
		   if(abs(Vector(Wall.Rotation) dot vector(Rotation)) < 0.75)
			TripOverByBlockade();
		   else
	        RanintoBlockade(-HitNormal); 
		}
		if(ZBLevelEntity_BlockadeTrip(Wall).BlockadeType==1) //"luzhang_03"
		{
			/*
			if(abs(Vector(Wall.Rotation) dot vector(Rotation)) > 0.4)
	          RanintoBlockade(HitNormal);*/
		}
	 }
	else if(ZBLevelEntity_Cheval(Wall)!=None)
	{
       CollideCheval();
	 }
	 else
	 {
	 	GetAxes(Rotation,X,Y,Z);
	 	//ignore sometimes  hit wall from side vertically
	 	if(abs(X dot HitNormal) <=0.2)
	 	{
	 		RanStrafe(1000,HitNormal);
	 		return;
	 	}
	 	Y *= 2*GetCollisionRadius();
	 	Z *= GetCollisionHeight();
	 	ForwardTraceVector = Vector(Rotation) * (3*GetCollisionRadius());
	  LeftForwardTraceVector = (3 * GetCollisionRadius()  )* HitNormal cross vect(0,0,-1);
    RightForwardTraceVector = (3 * GetCollisionRadius()  ) * HitNormal cross vect(0,0, 1);
	 	// need other content !!!!!not trace pawns
`if(`isdefined(debug))	 	
	 	DrawDebugLine(ForwardTraceVector + Location + Y , Location + Y ,0,255,0,true);
			DrawDebugLine(ForwardTraceVector + Location - Y , Location - Y ,0,255,0,true);
	DrawDebugLine(LeftForwardTraceVector + Location  , Location ,0,255,0,true);
	DrawDebugLine(RightForwardTraceVector + Location  , Location ,0,255,0,true);
`endif

	 	if(FastTrace(LeftForwardTraceVector + Location  , Location ,vect(46,46,90))
	 		&& FastTrace(ForwardTraceVector + Location  - Y , Location - Y ,vect(46,46,90)))
	 		RanOffBlockade(HitNormal,true);
	 	else if(FastTrace(RightForwardTraceVector + Location  , Location  , vect(46,46,90))
	 		&& FastTrace(ForwardTraceVector + Location  + Y , Location + Y ,vect(46,46,90)))
	 	  RanOffBlockade(HitNormal);
	 	else 
	 	{
	 		ZombieRushPC(Controller).GotoState('DoingSpecialMove');
	 		DoSpecialMove(SM_RunIntoWall,true);
	 	}
	 }
}

function bool PhysicsTraceFowardBlocked(Vector Dir)
{
	local Vector Extent,Forward;
  Forward =  Normal(Dir) * (GetCollisionRadius() + 1);
  Extent.X = GetCollisionRadius();
  Extent.Y = Extent.X;
  Extent.Z = GetCollisionHeight();
	return !FastTrace(Forward + Location  , Location ,Extent);
}
function bool PhysicsTraceFowardHole()
{
	local Vector lStart,lEnd,lHitLocation,lHitNormal;
	local Actor lHitActor;
	lStart = Location;
	lStart.z -= GetCollisionHeight();
	lEnd= lStart + Normal(Velocity)*(20 + GetCollisionRadius());
  lHitActor = Trace(lHitLocation, lHitNormal, lEnd, lStart, true, , , TRACEFLAG_Bullet);
  if(ZBLevelEntity_Hole(lHitActor)!=none)
  	return true;
  else
  	return false;
}
function  LatentPushCase()
{
	DoSpecialMove(SM_PushCase,true);
}

State IgnoreWall
{
	ignores HitWall,Landed;
	event BeginState(name previousStateName)
	{
		`log("IgnoreWall");
	}
	begin:
	Sleep(1.0);
	GotoState('');
}
function TripOverByBlockade()
{
	`log("TripOverByBlockade");
	self.DoSpecialMove(SM_TripOver,false);
}

function CollideCheval()
{
	   PlayerHealth=0;
	   ZombieRushPC(Controller).GotoState('DoingSpecialMove');
	   DoSpecialMove(SM_Combat_GetHurt,true,none,1);

}

function  RanintoBlockade(vector HitNormal,optional bool bInverse)
{
	ZombieRushPC(Controller).PawnRanintoBlockade(HitNormal,bInverse);
}

function RanOffBlockade(vector HitNormal,optional bool bInverse)
{
	ZombieRushPC(Controller).PawnRanOffBlockade(HitNormal,bInverse);
}
function RanStrafe(float Mag, vector Dir)
{
	ZombieRushPC(Controller).PawnRanStrafe(Mag, Dir);
}
///burn by fire collection
function  BurnToDeath()
{
	ZombieRushPC(Controller).GotoState('DoingSpecialMove');
	DoSpecialMove(SM_Combat_GetHurt,true);
}


function SetWalkingStatus(bool flag)
{
	bWalkingStatus = flag;
}
function bool GetWalkingStatus()
{
	return bWalkingStatus;
}

function RestorePower(float amount)
{
	PlayerPower+=amount;

	if (PlayerPower>=100)
	{
		PlayerPower=100;
	}
}

function bool CanGetCase()
{
	local Vector lHitNormalTop,lHitLocationTop,lEndTop,lStartTop;
    local Actor lHitActorTop;
    local Vector lForward;

    lForward = TransformVectorByRotation(Rotation, TraversalRays[0].Length);
    lStartTop = Location ;//+ 0.1* GetCollisionHeight() * vect(0,0,1);
  	lEndTop = lStartTop + lForward;
`if(`isdefined(debug))
  	drawdebugline(lStartTop,lEndTop,255,0,0,true);
`endif
  	lHitActorTop = Trace(lHitLocationTop, lHitNormalTop, lEndTop, lStartTop, true, , , TRACEFLAG_Bullet);

  	return InterpActor(lHitActorTop) != none && (lHitActorTop.tag=='Case' || lHitActorTop.tag=='xiangzi_01');

}
//Push Cases
function bool PushCase()
{
	local Vector lStart,lStartLeft,lStartRight;
	local Vector lEnd, lEndLeft, lEndRight;
	local Vector lForward;
	local Vector lHitLocation, lHitLocationLeft, lHitLocationRight;
	local Vector lHitNormal, lHitNormalLeft, lHitNormalRight;
	local Actor lHitActor, lHitActorLeft ,lHitActorRight ;
	local bool leftCapture, rightCapture;

	local Vector offsetX, offsetY;
  
    
  ZombieRushPC(Controller).bReceiveInput = true;
	// Determine the start and end points
	lStart = TransformVectorByRotation(Rotation, TraversalRays[0].Start);
	lStart = Location + lStart;
	lForward = TransformVectorByRotation(Rotation, TraversalRays[0].Length);
	lEnd = lStart + lForward;
	// Test if we collide with Case. 
	lHitActor = Trace(lHitLocation, lHitNormal, lEnd, lStart, true, , , TRACEFLAG_Bullet);

	lStartLeft = TransformVectorByRotation(Rotation, TraversalRays[1].Start);
	lStartLeft = Location + lStartLeft;
	lEndLeft = lStartLeft + lForward;
  lHitActorLeft = Trace(lHitLocationLeft, lHitNormalLeft, lEndLeft, lStartLeft, true, , , TRACEFLAG_Bullet);

  lStartRight = TransformVectorByRotation(Rotation, TraversalRays[2].Start);
	lStartRight = Location + lStartRight;
	lEndRight = lStartRight + lForward;
  lHitActorRight = Trace(lHitLocationRight, lHitNormalRight, lEndRight, lStartRight, true, , , TRACEFLAG_Bullet);
  


  leftCapture = InterpActor(lHitActorLeft) != none && (lHitActorLeft.tag=='Case' || lHitActorLeft.tag=='xiangzi_01');
  rightCapture = InterpActor(lHitActorRight) != none && (lHitActorRight.tag=='Case' || lHitActorRight.tag=='xiangzi_01');
	//drawdebugline(lStart,lEnd,255,0,0,true);
	/*
	if (InterpActor(lHitActor) != none && (lHitActor.tag=='Case' || lHitActor.tag=='xiangzi_01'))
	{
		 SetRotation(rotator(-lHitNormal));
		InteractCase = lHitActor;
		//InteractCase.setphysics(PHYS_Interpolating);
		
		bCaptureCase = true;
	//	ZombieRushPC(Controller).GotoState('DoingSpecialMove');
		DoSpecialMove(SM_PushCase,true);
		return true;
	}*/

	if(leftCapture && rightCapture)
	{
	//	SetRotation(rotator(-lHitNormalLeft));
		InteractCase = lHitActor;		
	//	InteractCase.setBase(self);
		bCaptureCase = true;
		offsetX =  - TransformVectorByRotation(Rotation, vect(10,0,0));
		//DoSpecialMove(SM_PushCase,true);
		PushCasePoint = Location + offsetX;
		MoveToCaseDir = Normal(offsetX);
		ZombieRushPC(Controller).PushState('MoveToPushCasePoint');
		return true;
	}
	else if(!rightCapture)
	{
		lStartRight = lEndRight;
		lEndRight = lStartRight + TransformVectorByRotation(Rotation, 2 * GetCollisionRadius() * vect(0, -1, 0));
		// capture the right side of case
		Trace(lHitLocationRight, lHitNormalRight, lEndRight, lStartRight, true, , , TRACEFLAG_Bullet);
		offsetY = lHitLocationRight - lStartRight;

		offsetX = lHitLocationLeft - lStartLeft - TransformVectorByRotation(Rotation, vect(10,0,0) + GetCollisionRadius() * vect(1,0,0));
    
   // SetLocation(Location + offsetX + offsetY);
	//	SetRotation(rotator(-lHitNormalLeft));
		InteractCase = lHitActorLeft;	
	
		bCaptureCase = true;
		PushCasePoint = Location + offsetX + offsetY;
		MoveToCaseDir = Normal(offsetX + offsetY);
		ZombieRushPC(Controller).PushState('MoveToPushCasePoint');
		return true;
	//	SetTimer(0.2,false,'LatentDoPushCase');
	}
	else if(!leftCapture)
	{
		lStartLeft = lEndLeft;
		lEndLeft = lStartLeft + TransformVectorByRotation(Rotation, 2 * GetCollisionRadius() * vect(0, 1, 0));
		// capture the right side of case
		Trace(lHitLocationLeft, lHitNormalLeft, lEndLeft, lStartLeft, true, , , TRACEFLAG_Bullet);
		offsetY = lHitLocationLeft - lStartLeft;

		offsetX = lHitLocationRight - lStartRight - TransformVectorByRotation(Rotation, vect(10,0,0) + GetCollisionRadius() * vect(1,0,0));
    
 //   SetLocation(Location + offsetX + offsetY);
	//	SetRotation(rotator(-lHitNormalLeft));
		InteractCase = lHitActorRight;		
		
		bCaptureCase = true;
		PushCasePoint = Location + offsetX + offsetY;
		MoveToCaseDir = Normal(offsetX + offsetY);
		ZombieRushPC(Controller).PushState('MoveToPushCasePoint');
		return true;
		//SetTimer(0.2,false,'LatentDoPushCase');
	}
	else
		return false;
} 
function DoPushCase()
{
	//	InteractCase.setBase(self);
	DoSpecialMove(SM_PushCase,true);
}
function bool TraceCaseBlocked()
{
	local Vector lStart;
	local Vector lEnd;
	local vector Zoffset;
	local bool res1_left,res2_right,res3_mid,res_final;

	Zoffset = vect(0,0,10);
    if (InteractCase != none)
    {
		lStart = InteractCase.Location;
		lStart.z += 60;
		lEnd = TransformVectorByRotation(Rotation, CaseTraceVector);
		lEnd = lStart + lEnd;
`if(`isdefined(debug))
		drawdebugline(lStart,lEnd,255,0,0,true);
`endif	
	//	returns true if did not hit world geometry
        res3_mid=InteractCase.FastTrace(lEnd,lStart,CaseTraceExtent);

		lStart = InteractCase.Location + Zoffset + TransformVectorByRotation(Rotation, vect(0,-60,0));
		lEnd = TransformVectorByRotation(Rotation, CaseTraceVector);
		lEnd = lStart + lEnd;
`if(`isdefined(debug))
		drawdebugline(lStart,lEnd,255,0,0,true);
`endif	
		// returns true if did not hit world geometry
		res1_left=InteractCase.FastTrace(lEnd,lStart);

		lStart = InteractCase.Location + Zoffset + TransformVectorByRotation(Rotation, vect(0,60,0));
		lEnd = TransformVectorByRotation(Rotation, CaseTraceVector);
		lEnd = lStart + lEnd;
`if(`isdefined(debug))
		drawdebugline(lStart,lEnd,255,0,0,true);
`endif	
		// returns true if did not hit world geometry
		res2_right=InteractCase.FastTrace(lEnd,lStart);

    res_final = !(res1_left && res3_mid && res2_right);
		return res_final;
    }

	return false;
}




event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal ){
	super.Touch(Other, OtherComp, HitLocation, HitNormal);
	/*
	if(LevelTransVolume(Other) != none && LevelTransVolume(Other).NextLevelName!="")
	{		
		ZombieRushPC(Controller).TransNextLevel(LevelTransVolume(Other).NextLevelName);
	}*/
	
}
//AnimNotify
function AnimNotify_Shoot()
{
	if(IsDoingSpecialMove(SM_GunAttack))
	   ZSM_GunFire(SpecialMoves[SpecialMove]).PlayFire();
}

////////////////////////////////////
//simulated function AnimCfg_AnimEndNotify()
/** Event called when body stance animation finished playing */
simulated function AnimCfg_AnimEndNotify()
{
	//	if(bDebug)
		//`log("AnimCfg_AnimEndNotify");
	if( SpecialMove != SM_None )
	{
		SpecialMoves[SpecialMove].AnimCfg_AnimEndNotify();
	}
}
defaultproperties
{
	WeaponList(0)=None

	TotalAmmo=1
	AmmoNum(0)=-1
	AmmoNum(1)=-1
	AmmoNum(2)=12
	AmmoNum(3)=10
	AmmoNum(4)=10
	PlayerPower=100
	
	WalkableFloorZ=0.78
	MaxStepHeight=22.0
	MaxJumpHeight=49.0


  //AccelRate = 0
  WalkJumpScale=100       //45
	AirControl=+0.35


}
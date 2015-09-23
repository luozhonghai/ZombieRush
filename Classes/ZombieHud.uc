class ZombieHud extends UDKHud;


var float InputAccel;
var GfxZombie_Hud GameNormalHudMovie;

var class<GfxZombie_Hud> GameNormalHUDClass;

var GfxCamera CameraHUDMovie;

var class<GfxCamera> CameraHUDClass;
delegate LastOnReleaseActButton();

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	CreateHUDMovie();
}

event PostRender()
{
	Local ZombiePC PPC;
	local ZombiePlayerPawn PPawn;
  local color OldColor;
  local Actor a;
	super.PostRender();


	//for debug use;

	PPC=ZombiePC(PlayerOwner);
	PPawn=ZombiePlayerPawn(PPC.Pawn);

   if(PPC.GameDebug)
   {
     //`include(AmbientCreature_Debug.uci)
         OldColor = Canvas.DrawColor;        
         Canvas.SetDrawColor(255,0,0);
         // Canvas.SetPos(400,50);
         // Canvas.DrawText("PlayerPower: "@PPawn.PlayerPower);
         Canvas.SetPos(400,50);
         Canvas.DrawText("Health: "@PPawn.PlayerPower);
   // `if(`isdefined(debug))
		// Canvas.DrawText("RootMotionRotationMode: "@(PPawn.Mesh.RootMotionRotationMode));
		//Canvas.DrawText("InteractZombie: "@PPC.InteractZombie);
         Canvas.SetPos(400,80);
         Canvas.DrawText("ControllerState: "@PPC.getstatename());
         Canvas.SetPos(400,110);
         Canvas.DrawText("Specialmove: "@PPawn.SpecialMove);
         Canvas.SetPos(400,140);
         Canvas.DrawText("Physics:"@ZombieRushPawn(PPawn).Physics);
         Canvas.SetPos(400,170);
         Canvas.DrawText("Timer:"@ZombieRushPawn(PPawn).Physics);
       
    //`if(`isdefined(debug))
         Canvas.SetPos(400,170);
    //     Canvas.DrawText("AMMO:"@ZombieRushPawn(PPawn).AmmoNum[ZombieRushPawn(PPawn).CurrentWeaponType]);
     //   if(ZombieRushPawn(PPawn).CurrentActiveCustomAnimNode.GetCustomAnimNodeSeq() != none)
     //    Canvas.DrawText(ZombieRushPawn(PPawn).CurrentActiveCustomAnimNode.GetCustomAnimNodeSeq().AnimSeqName);

         Canvas.SetPos(400,200);
         Canvas.DrawText("InteractZombie: "@PPC.InteractZombie);
        // Canvas.DrawText("CustomHealth"@PPawn.GetCustomHealth()@"Health"@PPawn.Health);


         Canvas.SetPos(400,230);
        // Canvas.DrawText("GunAmmoNum"@ZombieRushPawn(PPawn).AmmoNum[2]);

         Canvas.SetPos(400,260);
        // Canvas.DrawText("bHitWall"@ZombieRushPawn(PPawn).bHitWall);
        // Canvas.DrawText("TotalAmmoNum"@ZombieRushPawn(PPawn).CurrentWeaponType);

         foreach AllActors(class 'Actor', a, class 'IDebugInterface')
         {
         	IDebugInterface(a).DrawDebug(self);
         }
         Canvas.SetDrawColorStruct(OldColor);
    //`endif
  }
	//Canvas.SetPos(400,50);
//	Canvas.DrawText("Specialmove:"@PPawn.SpecialMove@"MoveState:"@PPawn.Mesh.RootMotionMode
//		);
    

//	Canvas.DrawText("Accel:"@InputAccel@"SpecialMove:"@PPawn.SpecialMove@"PCState:"@PPC.GetStateName());
	//Canvas.DrawText("Accel:"@PPC.getstatename()@"Health:"@PPawn.SpecialMove@"Power:"@int(PPawn.PlayerPower));
	//	Canvas.DrawText("SpecialMove"@PPawn.SpecialMove@"CurrentJumpStatus:"@PPawn.CurrentJumpStatus
	//		@"bPressedJump"@PPC.bPressedJump);

}
function CreateHUDMovie()
{
  /*
	GameNormalHudMovie = new GameNormalHUDClass;
	GameNormalHudMovie.SetTimingMode(TM_Real);
	GameNormalHudMovie.Init(class'Engine'.static.GetEngine().GamePlayers[GameNormalHudMovie.LocalPlayerOwnerIndex]);
  */
  CameraHUDMovie = new CameraHUDClass;
  CameraHUDMovie.Init(class'Engine'.static.GetEngine().GamePlayers[GameNormalHudMovie.LocalPlayerOwnerIndex]);
}


function ShowFireTargetHint(Vector2D NormalizedScreenLoc)
{
   GameNormalHudMovie.GfxShowFireTargetHint(NormalizedScreenLoc);
}
function HideFireTargetHint()
{
	GameNormalHudMovie.GfxHideFireTargetHint();
}
function bool HudCheckTouchEvent(int Handle,ETouchType Type,Vector2D TouchLocation,Vector2D ViewportSize)
{
   local Vector2D TouchLocRatio;
	
   TouchLocRatio.x = TouchLocation.x / ViewportSize.x;
   TouchLocRatio.y = TouchLocation.y / ViewportSize.y;
  
  if(GameNormalHudMovie != none)
   return GameNormalHudMovie.GfxCheckTouchEvent(Handle,Type,TouchLocRatio);
  else if(CameraHUDMovie != none)
   return CameraHUDMovie.GfxCheckWithin(TouchLocation);
  else
   return false;
}

function  HudCheckTouchEvent_CaptureByZombie(int Handle,ETouchType Type,Vector2D TouchLocation,Vector2D ViewportSize)
{
	local Vector2D TouchLocRatio;

	TouchLocRatio.x = TouchLocation.x / ViewportSize.x;
	TouchLocRatio.y = TouchLocation.y / ViewportSize.y;

  if(GameNormalHudMovie != none)
	GameNormalHudMovie.GfxCheckTouchEvent_CaptureByZombie(Handle,Type,TouchLocRatio);
}

function SetActionFunction(delegate<GfxZombie_Hud.ActionButtonActive> OnReleaseActButton)
{
	if(GameNormalHudMovie.ActionButtonActive!=none)
	  LastOnReleaseActButton = GameNormalHudMovie.ActionButtonActive;
	GameNormalHudMovie.ActionButtonActive = OnReleaseActButton;
}
function ReSetActionFunction()
{
	GameNormalHudMovie.ActionButtonActive = none;
}

function RestoreActionFunction()
{
    GameNormalHudMovie.ActionButtonActive = LastOnReleaseActButton;
}

function GfxZombie_Hud GetGfxHud()
{
	return GameNormalHudMovie;
}


//Draw Custom Joystick
function DrawMobileZone_Joystick(MobileInputZone Zone)
{
  //GameNormalHudMovie.GfxDrawMobileZone_Joystick(Zone,ZombiePC(PlayerOwner).ViewportSize);
}
DefaultProperties
{
	GameNormalHUDClass=class'GfxZombie_Hud'
  CameraHUDClass=class'GfxCamera'
}

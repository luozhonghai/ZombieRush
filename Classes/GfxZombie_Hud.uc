class GfxZombie_Hud extends GfxMoviePlayer;


var GFxObject RootMC,LockTargetMC;

var GFxClikWidget DashBtn,JumpBtn,ActionBtn;


//JoyStick
var GFxObject JoystickMC,JoystickButtonMC,JoystickBgMC;
var bool DisableBtnAct;
var bool DisableBtnDash;
var bool DisableBtnJump;

var ZombiePC PC;





//For ios touch
struct SButtonEvent 
{
	var bool bProcessing;
   var int LastHandle;
   var GFxClikWidget GfxButton;
   var delegate<EventListener> OnPressButton;
   
   var delegate<EventListener> OnReleaseButton;

};


var array<SButtonEvent> ButtonEvents;

var GFxObject CameraMC;
delegate EventListener(ETouchType Type);

delegate ActionButtonActive();



function Init(optional LocalPlayer player)
{
	super.Init(player);
	//ThisWorld = GetPC().WorldInfo;
	Start();	
}

function bool Start(optional bool StartPaused = false)
{
	local ASDisplayInfo asinfo;
	local SButtonEvent ButtonEvent;
	super.Start();
	Advance(0.0);
	//SavePath=GetSavePath()$"\\Moontea Games\\PAL4L\\SaveData\\";

	PC = ZombiePC(GetPC());
	RootMC=GetVariableObject("_root");
	SetViewScaleMode(SM_ExactFit);	

//actbtn_mc jumpbtn_mc
	DashBtn = GFxClikWidget(RootMC.GetObject("dashbtn_mc",class'GFxClikWidget'));
	JumpBtn = GFxClikWidget(RootMC.GetObject("jumpbtn_mc",class'GFxClikWidget'));
	ActionBtn = GFxClikWidget(RootMC.GetObject("actbtn_mc",class'GFxClikWidget'));
    LockTargetMC = RootMC.GetObject("lockicon_mc");
/*
	asinfo = LockTargetMC.getDisplayInfo();
	asinfo.x = 1000;
	asinfo.y = 500;
	asinfo.visible = true;
	LockTargetMC.setDisplayInfo(asinfo);
*/
	ButtonEvent.GfxButton = DashBtn;
	ButtonEvent.OnPressButton = CustomOnPressDash;
	ButtonEvent.OnReleaseButton = CustomOnReleaseDash;
	ButtonEvents.AddItem(ButtonEvent);

	ButtonEvent.GfxButton = JumpBtn;
	ButtonEvent.OnPressButton = CustomOnPressJump;
	ButtonEvent.OnReleaseButton = CustomOnReleaseJump;
	ButtonEvents.AddItem(ButtonEvent);

	ButtonEvent.GfxButton = ActionBtn;
	ButtonEvent.OnPressButton = CustomOnPressAct;
	ButtonEvent.OnReleaseButton = CustomOnReleaseAct;
	ButtonEvents.AddItem(ButtonEvent);

	
	//	DashBtn.AddEventListener('CLIK_buttonClick',OnClick);

	JoystickMC = RootMC.GetObject("joystick_mc");
	JoystickButtonMC = JoystickMC.GetObject("joystickbtn_mc");
	JoystickBgMC = JoystickMC.GetObject("joystickbg_mc");


	//LoadCameraMC();
}


function LoadCameraMC()
{
	local ASValue asval;
	local array<ASValue> args;

	asval.Type = AS_String;
	asval.s = "camrea.swf";
	args[0] = asval;

  CameraMC = RootMC.CreateEmptyMovieClip("CameraMC");
  CameraMC.SetPosition(0,0);
	CameraMC.Invoke( "loadMovie", args );
	CameraMC.SetVisible(true);
}

//Custom button event 

function CustomOnPressAct(ETouchType Type)
{
	if(DisableBtnAct)
		 return;
	//`log("press act");
    
	ZombiePlayerPawn(PC.pawn).PushCase();
}
function CustomOnReleaseAct(ETouchType Type)
{
	if(DisableBtnAct)
		return;
	//`log("release act");
	ActionButtonActive();

    ZombiePlayerPawn(PC.pawn).StopPushCase();
}
function CustomOnPressDash(ETouchType Type)
{
	if(DisableBtnDash)
		return;
	//PC.ClientMessage("GfxZombie_Hud.CustomOnPressDash !"@Type);
	//PC.SetDashSpeed(true);
}

function CustomOnReleaseDash(ETouchType Type)
{
	if(DisableBtnDash)
		return;
	//PC.ClientMessage("GfxZombie_Hud.CustomOnReleaseDash !"@Type);
	//PC.SetDashSpeed(false);
	 PC.NextWeapon();
}

function CustomOnPressJump(ETouchType Type)
{
	if(DisableBtnJump)
		return;
	//PC.CustomJump();
	//`log("press jump");
}

function CustomOnReleaseJump(ETouchType Type)
{
	if(DisableBtnJump)
		return;
	PC.CustomJump();
	//`log("release jump");
}
/*
enum ETouchType
{
	Touch_Began,
	Touch_Moved,
	Touch_Stationary,
	Touch_Ended,
	Touch_Cancelled,
};
*/
function GfxHideFireTargetHint()
{
   local ASDisplayInfo asinfo;
   asinfo = LockTargetMC.getDisplayInfo();
   asinfo.visible = false;
   LockTargetMC.setDisplayInfo(asinfo);
}
function GfxShowFireTargetHint(Vector2D Ratio)
{
	local Vector2D locTrans;
	local ASDisplayInfo asinfo;
	asinfo = LockTargetMC.getDisplayInfo();
	locTrans.X = Ratio.X*1920;
	locTrans.Y = Ratio.Y*1080;
	asinfo.x = locTrans.X-50;
    asinfo.y = locTrans.Y-50;
    asinfo.visible = true;
	LockTargetMC.setDisplayInfo(asinfo);
}
function bool GfxCheckTouchEvent(int Handle,ETouchType Type,Vector2D touchRatio)
{
	local Vector2D locTrans;
	local int index;
	locTrans.X = touchRatio.X*1920;
	locTrans.Y = touchRatio.Y*1080;

	for(index=0; index< ButtonEvents.length; index++)
	{
		if(IsWithinGfxObject(ButtonEvents[index].GfxButton,locTrans)&&Type==Touch_Began)      //BUtton pressed
		{
		//	`log(ButtonEvents[index].GfxButton);
			ButtonEvents[index].LastHandle = Handle;
			ButtonEvents[index].bProcessing = true;
			EventListener = ButtonEvents[index].OnPressButton;
			EventListener(Type);
            return true;
		}

		//Button release
		else if (ButtonEvents[index].bProcessing&&Handle==ButtonEvents[index].LastHandle
			&&(!IsWithinGfxObject(ButtonEvents[index].GfxButton,locTrans)
			||Type==Touch_Ended || Type==Touch_Cancelled))
		{
			ButtonEvents[index].bProcessing = false;
			EventListener = ButtonEvents[index].OnReleaseButton;
			EventListener(Type);
			
		}
	}
	return false;  
}


function GfxCheckTouchEvent_CaptureByZombie(int Handle,ETouchType Type,Vector2D touchRatio)
{
	local Vector2D locTrans;
	
	locTrans.X = touchRatio.X*1920;
	locTrans.Y = touchRatio.Y*1080;

	if(IsWithinGfxObject(ActionBtn,locTrans)&&Type==Touch_Began)      //BUtton pressed
	{
		//	`log(ButtonEvents[index].GfxButton);
		ButtonEvents[2].LastHandle = Handle;
		ButtonEvents[2].bProcessing = true;
		CustomOnPressAct(Type);

	}

	//Button release
	else if (ButtonEvents[2].bProcessing&&Handle==ButtonEvents[2].LastHandle
		&&(!IsWithinGfxObject(ActionBtn,locTrans)
		||Type==Touch_Ended || Type==Touch_Cancelled))
	{
		ButtonEvents[2].bProcessing = false;
		CustomOnReleaseAct(Type);
	}
}

function bool IsWithinGfxObject(GFxObject mc,Vector2D loc)
{
	local ASDisplayInfo asinfo;
	local float right,bottom;
	local float width,height;
	asinfo = mc.GetDisplayInfo();
	width = mc.GetFloat("width");
	height = mc.GetFloat("height");
	right = asinfo.X + width;
	bottom = asinfo.Y + height;

	//PC.ClientMessage("thumbloc:"@loc.x@loc.y@" right:"@right@" bottom:"@bottom);
	return (loc.X>=asinfo.X&&loc.X<=right
		&&loc.Y>=asinfo.Y&&loc.Y<=bottom);
}

//Disable and Enable Buttons
function DisbaleActBtn()
{
    DisableBtnAct=true;
    HideButton(ActionBtn);
}
function DisbaleJumpBtn()
{
	DisableBtnJump=true;
	HideButton(JumpBtn);
}
function DisbaleDashBtn()
{
	DisableBtnDash=true;
	HideButton(DashBtn);
}

function EnbaleActBtn()
{
	DisableBtnAct=false;
	ShowButton(ActionBtn);
}
function EnbaleJumpBtn()
{
	DisableBtnJump=false;
	ShowButton(JumpBtn);
}
function EnbaleDashBtn()
{
	DisableBtnDash=false;
	ShowButton(DashBtn);
}

function HideButton(GFxObject btn)
{
	local ASDisplayInfo asinfo;
	asinfo = btn.getDisplayInfo();
	asinfo.visible = false;
	btn.setDisplayInfo(asinfo);
}
function ShowButton(GFxObject btn)
{
	local ASDisplayInfo asinfo;
	asinfo = btn.getDisplayInfo();
	asinfo.visible = true;
	btn.setDisplayInfo(asinfo);
}

/*
function GfxDrawMobileZone_Joystick(MobileInputZone Zone , vector2d ViewportSize)
{
	local int X, Y, Width, Height;
	local Color LineColor;
	local float ClampedX, ClampedY, Scale;

	local Vector2D locTrans;
	local ASDisplayInfo asinfo;


	ClampedX = Zone.CurrentLocation.X - Zone.CurrentCenter.X;
	ClampedY = Zone.CurrentLocation.Y - Zone.CurrentCenter.Y;

	Scale = 1.0f;
	if ( ClampedX != 0 || ClampedY != 0 )
	{
		Scale = Min( Zone.ActiveSizeX, Zone.ActiveSizeY ) / ( 2.0 * Sqrt(ClampedX * ClampedX + ClampedY * ClampedY) );
		Scale = FMin( 1.0, Scale );
	}
	ClampedX = ClampedX * Scale ;//+ Zone.CurrentCenter.X;
	ClampedY = ClampedY * Scale ;//+ Zone.CurrentCenter.Y;


	asinfo = JoystickButtonMC.getDisplayInfo();
	locTrans.X = ClampedX*1920/ViewportSize.x;
	locTrans.Y = ClampedY*1080/ViewportSize.y;
	asinfo.x = locTrans.X-136;
	asinfo.y = locTrans.Y-136;
	 asinfo.yscale = asinfo.xscale;
	//asinfo.visible = true;
	JoystickButtonMC.setDisplayInfo(asinfo);
    if (ZBMobileInputZone(Zone)!=none)
    {
	    if(ZBMobileInputZone(Zone).bActive)
           JoystickButtonMC.gotoAndStop("press");
		else
           JoystickButtonMC.gotoAndStop("normal");
	}

	asinfo = JoystickMC.getDisplayInfo();
    asinfo.yscale = asinfo.xscale/ViewportSize.x*ViewportSize.y;
	asinfo.x = Zone.CurrentCenter.X*1920/ViewportSize.x;
    asinfo.y = Zone.CurrentCenter.y*1080/ViewportSize.y;
	JoystickMC.setDisplayInfo(asinfo);

	//JoystickBgMC.gotoAndStop("green");
}*/

DefaultProperties
{
	bAllowInput=True
		bAllowFocus=true
		bDisplayWithHudOff=false
	MovieInfo=SwfMovie'Zombiehud_res.zombie_hud'
}


/**参考用代码片段
*/


//AS 3.0 中 event信息 在ev._this 里面
/*
function OnStateChange(GFxClikWidget.EventData ev)
{
	local string btnState;
	local ASValue asval,asval2;
	local array<ASValue> args;

	local GFxClikWidget ButtonPressed;

	asval.Type = AS_String;
	asval.s = "";
	args[0] = asval;

	asval2.Type = AS_String;
	asval2.s = "";

	//GFxClikWidget(ev._this.GetObject("target", class'GFxClikWidget'));

	ButtonPressed = GFxClikWidget(ev._this.GetObject("target", class'GFxClikWidget'));
	btnState = ButtonPressed.GetString("state");

}

function OnClick(GFxClikWidget.EventData ev)
{
PC.ClientMessage("GfxZombie_Hud.OnClick"@ev.mouseIndex);
}

*/



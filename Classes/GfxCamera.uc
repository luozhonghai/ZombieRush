class GfxCamera extends GFxMoviePlayer;


var ZombiePC PC;

var int x,y,width,height;

var MicroTransactionBase MicroTrans;
// Body...
function Init(optional LocalPlayer player)
{
	super.Init(player);
	//ThisWorld = GetPC().WorldInfo;
	Start();	
  PC = ZombiePC(GetPC());
	SetViewScaleMode(SM_NoBorder);	
	SetViewport(x,y,width,height);

	MicroTrans = class'PlatformInterfaceBase'.static.GetMicroTransactionInterface();
	MicroTrans.AddDelegate(MTD_PurchaseQueryComplete, OnProductQueryComplete);
	MicroTrans.AddDelegate(MTD_PurchaseComplete, OnProductPurchaseComplete);

	//SetAlignment();
}
//true: camDown false: Normal
function Callback_getCameraState(bool NewCamState)
{
	//PC.ClientMessage(NewCamState);
	//ZBRushCamera(PC.PlayerCamera).CameraPitchToggle(NewCamState);

	MicroTrans.QueryForAvailablePurchases();
}


//touch a button 

//MicroTrans.BeginPurchase(0);

function OnProductQueryComplete(const out PlatformInterfaceDelegateResult Result)
{
	local int Index;
	local PurchaseInfo Info;
  
  PC.ClientMessage("OnProductQueryComplete");
	for (Index = 0; Index < MicroTrans.AvailableProducts.length; Index++)
	{
		Info = MicroTrans.AvailableProducts[Index];
		// if (Index < 2)
		// {
		// 	ProductButtons[Index].bIsHidden = false;
		// 	ProductButtons[Index].Caption = Info.DisplayName;
		// }
		`log("Purchase " $ Index $ ":");
		`log("  " $ Info.Identifier $ " - " $ Info.DisplayName $ " / " $ Info.DisplayPrice $ " - " $ Info.DisplayDescription);
	}

}

function OnProductPurchaseComplete(const out PlatformInterfaceDelegateResult Result)
{
	`log("Purchase complete:");
	`log("  Product = " $ Result.Data.StringValue);	
	`log("  bSuccess = " $ Result.bSuccessful);	
	`log("  Result = " $ Result.Data.IntValue);	

	if (Result.Data.IntValue == MTR_Failed)
	{
		`log("  Error: " $ MicroTrans.LastError);
		`log("  Solution: " $ MicroTrans.LastErrorSolution);
	}
}

function bool GfxCheckWithin(Vector2D TouchLocation)
{
	if(TouchLocation.x > x && TouchLocation.x < x+width
		&& TouchLocation.y > y && TouchLocation.y < y+width)
	  return true;
	else
		return false;
}


/*
function bool ProcessUIClick()
{
	local int CameraState;
	CameraState = ActionScriptInt("Callback_getCameraState");
	 return false;
}*/
defaultproperties
{
		bAllowInput=True
		bAllowFocus=true
		bDisplayWithHudOff=false
		MovieInfo=SwfMovie'Zombiehud_res.camrea'
		x=0
		y=0
		width=64
		height=64
}
class GfxCamera extends GFxMoviePlayer;


var ZombiePC PC;

var int x,y,width,height;
// Body...
function Init(optional LocalPlayer player)
{
	super.Init(player);
	//ThisWorld = GetPC().WorldInfo;
	Start();	
  	PC = ZombiePC(GetPC());
	SetViewScaleMode(SM_NoBorder);	
	SetViewport(x,y,width,height);
	//SetAlignment();
}
//true: camDown false: Normal
function Callback_getCameraState(bool NewCamState)
{
	//PC.ClientMessage(NewCamState);
	ZBRushCamera(PC.PlayerCamera).CameraPitchToggle(NewCamState);
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
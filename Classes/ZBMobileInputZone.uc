class ZBMobileInputZone extends MobileInputZone;


var bool bActive;
function bool ProcessGameplayInput(MobileInputZone Zone, float DeltaTime, int Handle, ETouchType EventType, Vector2D TouchLocation)
{
	if (EventType == Touch_Began)
	{
		bActive = true;
	}
	else if (EventType == Touch_Ended || EventType == Touch_Cancelled)
	{
        bActive = false;
	}
	return false;

}
DefaultProperties
{
	OnProcessInputDelegate=ProcessGameplayInput
}

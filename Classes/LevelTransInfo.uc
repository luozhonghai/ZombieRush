class LevelTransInfo extends Object
	dependson(ZombieRushPawn);

var string SerializeWorldData;
// SaveGameState revision number
const LEVELTRANS_REVISION = 1;
// Body...

function SavePrevLevelName()
{
	local WorldInfo WorldInfo;
	local JSonObject JsonObject;
	JSonObject = new () class'JSonObject';
	if (JsonObject != none)
	{
		WorldInfo = class'WorldInfo'.static.GetWorldInfo();
		if (WorldInfo == None)
		{
			return;
		}
		JsonObject.SetStringValue("PrevLevel", ZombieMapInfo(WorldInfo.GetMapInfo()).LevelName);
		SerializeWorldData = class'JsonObject'.static.EncodeJson(JsonObject);
	}
}
function ClearPrevLevelName()
{
	local WorldInfo WorldInfo;
	local JSonObject JsonObject;
	JSonObject = new () class'JSonObject';
	if (JsonObject != none)
	{
		WorldInfo = class'WorldInfo'.static.GetWorldInfo();
		if (WorldInfo == None)
		{
			return;
		}
		JsonObject.SetStringValue("PrevLevel", "");
		SerializeWorldData = class'JsonObject'.static.EncodeJson(JsonObject);
	}
}
function string LoadPrevLevelName()
{
	local string LevelName;
	local JSonObject JSonObject;
	JSonObject = class'JSonObject'.static.DecodeJson(SerializeWorldData);
	if (JSonObject != None)
	{
		// Get the object name
		LevelName = JSonObject.GetStringValue("PrevLevel");
		return LevelName;
	}
	else
	{
		return "";
	}
}


function SavePrevWeaponType()
{
	local WorldInfo WorldInfo;
	local JSonObject JsonObject;
	JSonObject = new () class'JSonObject';
	if (JsonObject != none)
	{
		WorldInfo = class'WorldInfo'.static.GetWorldInfo();
		if (WorldInfo == None)
		{
			return;
		}
		JsonObject.SetIntValue("PrevWeapon", int(ZombieRushPawn(WorldInfo.GetALocalPlayerController().Pawn).CurrentWeaponType));
		SerializeWorldData = class'JsonObject'.static.EncodeJson(JsonObject);
	}
}
function ClearPrevWeaponType()
{
	local JSonObject JsonObject;
	JSonObject = new () class'JSonObject';
	if (JsonObject != none)
	{
		JsonObject.SetIntValue("PrevLevel", 0);
		SerializeWorldData = class'JsonObject'.static.EncodeJson(JsonObject);
	}
}
function EWeaponType LoadPrevWeaponType()
{
	local int WeaponTypeId;
	local JSonObject JSonObject;
	JSonObject = class'JSonObject'.static.DecodeJson(SerializeWorldData);
	if (JSonObject != None)
	{
		// Get the object name
		WeaponTypeId = JSonObject.GetIntValue("PrevWeapon");
		return CastIntToWeaponType(WeaponTypeId);
	}
	else
	{
		return EWT_None;
	}
}

function EWeaponType CastIntToWeaponType(int id)
{
	switch (id)
	{
		case 0:
			return EWT_None;
		case 1:
			return EWT_Axe;
		case 2:
			return EWT_Pistol;
		case 3:
			return EWT_Rifle;
		case 4:
			return EWT_ScatterGun;
		default: return EWT_None;
	}
}
defaultproperties
{
	
}
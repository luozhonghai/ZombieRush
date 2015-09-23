class ZombieRushGame extends SimpleGame;

//WorldInfo = class'WorldInfo'.static.GetWorldInfo();

struct PlayerData
{
	var() int CheckPointUseable;

	structdefaultproperties
	{
		CheckPointUseable = 1 ;
	}
};

enum SaveType
{
	ST_Local,
	ST_Cloud
};

var SaveType CurrentSaveType;
var string LevelTransFileName;
var bool bInTransLevel;

var EWeaponType PreWeaponType;
var config string PhysicsConfigArcheTypeName;
var PlayerPyhsicsData PlayerPyhsicsDataInstance;

var GlobalConfigData ConfigData;
var GlobalConfigData ConfigDataArche;

//cloud save
var int SlotIndex;
var CloudStorageBase Cloud;
var ZBCloudSaveData CloudZBSaveData;

var ZBCheckpointVolume LastCheckpoint;

//local save
// var ZBLocalSaveData LocalZBSaveData;
// var string LocalSaveDataFileName;

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	if (InStr(MapName, "parkour") != -1)
	{
		return class'ZGame.ZombieParkourGame';
	}
	return class'ZGame.ZombieRushGame';  
}

event PostLogin(PlayerController rPlayerController)
{
	local ZombiePawn lPawn;
	local ZombieSpawnNodeDistance lNode;
	//local NXActor lActor;

	super.PostLogin(rPlayerController);
  

	/* Cycle through all the ZombiePawn and initialize them as well */
	foreach WorldInfo.AllPawns(class'ZombiePawn', lPawn)
	{
		lPawn.Initialize();
	}

	foreach AllActors(class'ZombieSpawnNodeDistance', lNode)
	{
		lNode.CustomInitialize();
	}
//`if(`isdefined(release))
	GetALocalPlayerController().ConsoleCommand("disableallscreenmessages");
//`endif
  //apply config
	ConfigData = new class 'GlobalConfigData'(default.ConfigDataArche);
	ZombiePC(rPlayerController).GameDebug = ConfigData.bGameDebug;
	ZombiePC(rPlayerController).bCheat = ConfigData.bCheat;

	ZombieRushPC(rPlayerController).ClimbOverDistance = ConfigData.ClimbOverDistance;
	ZombieRushPC(rPlayerController).SprintSpeed = ConfigData.SprintSpeed;
	ZombieRushPC(rPlayerController).RunSpeed = ConfigData.RunSpeed;
	ZombieRushPC(rPlayerController).WalkSpeed = ConfigData.WalkSpeed;


	WorldInfo.WorldGravityZ = ConfigData.CustomGravityZ;
	ZombiePlayerPawn(rPlayerController.Pawn).PlayerHealth = ConfigData.PlayerHealth;
	ZombieRushPawn(rPlayerController.Pawn).KnockDownVelocity = ConfigData.KnockDownVelocity;
  ZombieRushPawn(rPlayerController.Pawn).MinHitWallInterval = ConfigData.MinHitWallInterval;


  SlotIndex = -1;

	// listen for cloud storage value changes
	Cloud = class'PlatformInterfaceBase'.static.GetCloudStorageInterface();
	Cloud.AddDelegate(CSD_ValueChanged, CloudValueChanged);
	Cloud.AddDelegate(CSD_DocumentReadComplete, CloudReadDocument);
	Cloud.AddDelegate(CSD_DocumentConflictDetected, CloudConflictDetected);

  CloudGetDocs();
}
function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string IncomingName )
{
  local LevelTransInfo LevelTransInfo;
  local NavigationPoint BestStart , N;
  local string CommingLevel;
	// Instance the save game state
	LevelTransInfo = new () class'LevelTransInfo';
	if (LevelTransInfo == None)
	{
		BestStart = ChoosePlayerStart(Player, InTeam);
		return BestStart;
	}
	// Attempt to deserialize the LevelTransInfo object from disk
	if (class'Engine'.static.BasicLoadObject(LevelTransInfo, LevelTransFileName, true, class'LevelTransInfo'.const.LEVELTRANS_REVISION))
	{
		// Start the map with the command line parameters required to then load the save game state
		//ConsoleCommand("start "$SaveGameState.PersistentMapFileName$"?Game="$SaveGameState.GameInfoClassName$"?SaveGameState="$FileName);
		CommingLevel = LevelTransInfo.LoadPrevLevelName();
		PreWeaponType = LevelTransInfo.LoadPrevWeaponType();
		ForEach WorldInfo.AllNavigationPoints( class 'NavigationPoint', N )
			if( string(N.Tag)~=CommingLevel )
			{
          BestStart = N;
          break;
			}
		if(BestStart == none)
		{
			BestStart = ChoosePlayerStart(Player, InTeam);
		}
	}
	else
	{
		BestStart = ChoosePlayerStart(Player, InTeam);
	}

	return BestStart;
}

function SavePrevLevelInfo()
{
	local LevelTransInfo LevelTransInfo;
  local PlayerController PC;
	// Instance the save game state
	LevelTransInfo = new () class'LevelTransInfo';
	if (LevelTransInfo == None)
	{
		return;
	}
	LevelTransInfo.SavePrevLevelName();

	LevelTransInfo.SavePrevWeaponType();

	// Serialize the save game state object onto disk
	if (class'Engine'.static.BasicSaveObject(LevelTransInfo, LevelTransFileName, true, class'LevelTransInfo'.const.LEVELTRANS_REVISION))
	{
`if(`isdefined(debug))
		// If successful then send a message
		foreach LocalPlayerControllers(class'PlayerController', PC)
		{
			PC.ClientMessage("Saved game state to "$LevelTransFileName$".", 'System');
		}
`endif

	}

}

function ClearTempLevelInfo()
{
	local LevelTransInfo LevelTransInfo;
	// Instance the save game state
	LevelTransInfo = new () class'LevelTransInfo';
	if (class'Engine'.static.BasicLoadObject(LevelTransInfo, LevelTransFileName, true, class'LevelTransInfo'.const.LEVELTRANS_REVISION))
	{
		LevelTransInfo.ClearPrevLevelName();
		LevelTransInfo.ClearPrevWeaponType();
		class'Engine'.static.BasicSaveObject(LevelTransInfo, LevelTransFileName, true, class'LevelTransInfo'.const.LEVELTRANS_REVISION);
	}
}


//==================
// respawn

function PawnDied()
{
	local PlayerController PC;
	foreach LocalPlayerControllers(class'PlayerController', PC)
	{
		PC.ClientSetCameraFade(true,MakeColor(0,0,0,255),vect2d(0,1),2.0);
	}
	SetTimer(2.0f,false,'RestartGame');
}

function RestartGame()
{
	local Pawn OldPawn, NewPawn;
	local Controller PC;
	PC = GetalocalPlayerController();
	if (LastCheckpoint != none)
	{
		OldPawn = PC.Pawn;
		OldPawn.Destroy();
		PC.Pawn = SpawnNewPawnFromCheckpoint(PC, LastCheckpoint);
		PC.Possess(PC.Pawn, false);
		PC.ClientSetRotation(PC.Pawn.Rotation, TRUE);

	}
	else
	{
		GetalocalPlayerController().Consolecommand("restartlevel");
	}
	
}

function Pawn SpawnNewPawnFromCheckpoint(Controller NewPlayer, ZBCheckpointVolume CheckPoint)
{
	local class<Pawn> DefaultPlayerClass;
	local Rotator StartRotation;
	local Pawn ResultPawn;

	DefaultPlayerClass = GetDefaultPlayerClass(NewPlayer);

	// don't allow pawn to be spawned with any pitch or roll
	StartRotation.Yaw = CheckPoint.Rotation.Yaw;

	ResultPawn = Spawn(DefaultPlayerClass,,,CheckPoint.Location,StartRotation);
	if ( ResultPawn == None )
	{
		`log("Couldn't spawn player of type "$DefaultPlayerClass$" at "$CheckPoint);
	}
	return ResultPawn;

}

//==============================
// physics

function PlayerPyhsicsData GetPlayerPyhsicsDataInstance()
{
	return PlayerPyhsicsDataInstance;
}

//=============================
// save key and value

function int GetPlayerCheckPointUseable()
{
	return CloudZBSaveData.CurrentData.CheckPointUseable;
}

function SetPlayerCheckPointUseable(int value)
{
	CloudZBSaveData.CurrentData.CheckPointUseable = value;
	CloudGameSave();
}

//=====================================
//low level save
//CloudSave called directly
exec function CloudGetDocs()
{
	Cloud.AddDelegate(CSD_DocumentQueryComplete, CloudGotDocuments);
	Cloud.QueryForCloudDocuments();
}

exec function bool CloudGameLoad()
{
	if (SlotIndex == -1)
	{
		`log("No save data in that slot");
		return false;
	}
	Cloud.ReadCloudDocument(SlotIndex);
	return true;
}

exec function CloudGameSave()
{
	Cloud = class'PlatformInterfaceBase'.static.GetCloudStorageInterface();
	if (SlotIndex == -1)
	{
		`log("Creating new save slot");
		SlotIndex = Cloud.CreateCloudDocument("0_Save.bin");
	}

	// save the document
	Cloud.SaveDocumentWithObject(SlotIndex, CloudZBSaveData, 0);
	Cloud.WriteCloudDocument(SlotIndex);
}


//=========
//cloudsave callback related

function CloudGotDocuments(const out PlatformInterfaceDelegateResult Result)
{
	local int NumDocs, i;

	NumDocs = Cloud.GetNumCloudDocuments();
	`log("We have found " $ NumDocs $ " documents in the cloud:");
	if (NumDocs > 0)
	{
		`log("  - " $ Cloud.GetCloudDocumentName(0));
		SlotIndex = int(Left(Cloud.GetCloudDocumentName(0), 1));
	}

	if(!CloudGameLoad())
		CloudZBSaveData = new () class'ZBCloudSaveData';
}

function CloudReadDocument(const out PlatformInterfaceDelegateResult Result)
{
	local int DocumentIndex;
	DocumentIndex = Result.Data.IntValue;
	
	if (Result.bSuccessful)
	{
		CloudZBSaveData = ZBCloudSaveData(Cloud.ParseDocumentAsObject(DocumentIndex, class'ZBCloudSaveData', 0));
	}
	else
	{
		`log("Failed to read document index " $ DocumentIndex);
	}
}

function CloudValueChanged(const out PlatformInterfaceDelegateResult Result)
{
	`log("Value " $ Result.Data.StringValue $ " changed with tag " $ Result.Data.DataName );
}

function CloudConflictDetected(const out PlatformInterfaceDelegateResult Result)
{
	`log("Aww, there's a conflict in " $ Cloud.GetCloudDocumentName(Result.Data.IntValue) $ 
		" . There are " $ Cloud.GetNumCloudDocuments(true) $ " versions. Going to resolve to newest version");

	// this is the easy way to resolve differences - just pick the newest one
	// @todo: test reading all versions and picking largest XP version
	Cloud.ResolveConflictWithNewestDocument();
}



DefaultProperties
{
	DefaultPawnClass=class'ZombieRushPawn'
	PlayerControllerClass=class'ZombieRushPC'
	HUDType=class'ZombieHud'

	
  LevelTransFileName="LevelTrans.bin"
  LocalSaveDataFileName="Save.bin"

  ConfigDataArche=GlobalConfigData'Zombie_Archetype.ConfigData.ConfigData_ArcheType'
  //GlobalConfigData'Zombie_Archetype.ConfigData.ConfigData_ArcheType'
  CurrentSaveType=ST_Local
}

class PlayerPyhsicsData extends Object;

// Body...

struct PhysConfigArray
{
  var() ZombiePawn.ESpecialMove SpecialMove;
  var() array<ZombiePawn.PhysConfig> ConfigDatas;
};

 
//var  PlayerPyhsicsData Instance;

//var config string ArcheTypeName;

var PlayerPyhsicsData ArcheTypeObject;
var() array<PhysConfigArray> SpecialMoveConfigInfos;
static function ZombiePawn.PhysConfig GetPhysInteractConfigBySpeciakMove(PlayerPyhsicsData Instance, ZombiePawn.ESpecialMove SpecialMove, name InteractActorTag)
{
   local PhysConfigArray PhysConfig_Move;
   local ZombiePawn.PhysConfig PhysConfig_Move_Tag;
   local int index;
   if(Instance == None) {
      //Instance = PlayerPyhsicsData(DynamicLoadObject(ConfigFile, class 'PlayerPyhsicsData'));
      Instance = new class 'PlayerPyhsicsData'(default.ArcheTypeObject);
    if(Instance == None) {
      `log("PlayerPyhsicsData not found!");
      return PhysConfig_Move_Tag;
    }  
   }
   index = Instance.SpecialMoveConfigInfos.Find('SpecialMove', SpecialMove);
   //`assert(index != -1);
   if (index != -1)
   {
      PhysConfig_Move = Instance.SpecialMoveConfigInfos[index];
      index = PhysConfig_Move.ConfigDatas.Find('Actor_Tag', InteractActorTag);
      if (index != -1)
      {
        PhysConfig_Move_Tag = PhysConfig_Move.ConfigDatas[index];
      }
    }
      return PhysConfig_Move_Tag;
}

defaultproperties
{
  ArcheTypeObject=PlayerPyhsicsData'Zombie_Archetype.PhysicsData.PlayerPyhsicsData_ArcheType'
  //ArcheTypeName="Zombie_Archetype.PhysicsData.PlayerPyhsicsData_ArcheType"
}
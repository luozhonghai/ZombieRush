class PhysicsUtil extends Object
  dependson(PlayerPyhsicsData);

// Body...

static function ZombiePawn.PhysConfig ActivePhysicsInteract(ZombiePawn Pawn, PlayerPyhsicsData Instance, ZombiePawn.ESpecialMove SpecialMove, name InteractActorTag)
{
  return class 'PlayerPyhsicsData'.static.GetPhysInteractConfigBySpeciakMove(Instance, SpecialMove, InteractActorTag);
}


static function ObjectTimer(ZombiePawn Pawn)
{
  Pawn.SetTimer(0.1, false, NameOf(SimulatingPhysics));
}


static function SimulatingPhysics()
{
  `log("PhysicsUtil: SimulatingPhysics");
}
defaultproperties
{
  
}
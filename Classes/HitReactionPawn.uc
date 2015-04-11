class HitReactionPawn extends SkeletalMeshCinematicActor;

// Death animation
var(HitReaction) Name DeathAnimName;
// Bone names to unfix when hit reaction is simulated
var(HitReaction) array<Name> UnfixedBodyNames;
// Bone names to enable springs when hit reaction is simulated
var(HitReaction) array<Name> EnabledSpringBodyNames;
// Linear bone spring strength to use when hit reaction is simulated
var(HitReaction) float LinearBoneSpringStrength;
// Angular bone spring strength to use when hit reaction is simulated
var(HitReaction) float AngularBoneSpringStrength;
// Radius of the force to apply
var(HitReaction) float ForceRadius;
// Force amplification
var(HitReaction) float ForceAmplification;
// Maximum amount of force that can be applied 
var(HitReaction) float MaximumForceThatCanBeApplied;
// Blend in time for the hit reaction
var(HitReaction) float PhysicsBlendInTime;
// Physics simulation time for the hit reaction
var(HitReaction) float PhysicsTime;
// Blend out time for the hit reaction
var(HitReaction) float PhysicsBlendOutTime;
// Full body rag doll
var(HitReaction) bool FullBodyRagdoll;

var Name PreviousAnimName;

var(ZBGame) Actor BumpSource;

var(ZBGame) int DamageAmount;

var(ZBGame) bool UnFixAll;

var(ZBGame) float PhysicWeightScale;

simulated function OnTestTriggerPhysicsBump(SeqAct_TestTriggerPhysicsBump inAction)
 {
 		if(BumpSource != none)
 			TakeDamage(DamageAmount, GetALocalPlayerController(), BumpSource.Location, Normal(Location - BumpSource.Location), class'DamageType');
 }

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local AnimNodeSequence AnimNodeSequence;

	Super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	if (SkeletalMeshComponent == None || SkeletalMeshComponent.PhysicsAssetInstance == None)
	{
		return;
	}

	if (IsTimerActive(NameOf(SimulatingPhysicsBlendIn)) || IsTimerActive(NameOf(SimulatingPhysics)) || IsTimerActive(NameOf(SimulatedPhysicsBlendOut)))
	{
		return;
	}

	if (FullBodyRagdoll)
	{
		if (DeathAnimName != '')
		{
			AnimNodeSequence = AnimNodeSequence(SkeletalMeshComponent.Animations);

			if (AnimNodeSequence != None)
			{
				PreviousAnimName = AnimNodeSequence.AnimSeqName;
				AnimNodeSequence.SetAnim(DeathAnimName);
				AnimNodeSequence.PlayAnim();
				//AnimNodeSequence.bCauseActorAnimEnd = true;
				//return;
			}
		}
		// else
		// {
			TurnOnRagdoll(Normal(Momentum) * FMin(DamageAmount * ForceAmplification, MaximumForceThatCanBeApplied));
		//}
	}
	else
	{	
		if (DeathAnimName != '')
		{
			AnimNodeSequence = AnimNodeSequence(SkeletalMeshComponent.Animations);

			if (AnimNodeSequence != None)
			{
				PreviousAnimName = AnimNodeSequence.AnimSeqName;

				// AnimNodeSequence.SetRootBoneAxisOption(RBA_Translate, RBA_Translate, RBA_Default);
				// AnimNodeSequence.SetRootBoneRotationOption(RRO_Default, RRO_Default, RRO_Extract);
				// SkeletalMeshComponent.bRootMotionModeChangeNotify = TRUE;


				AnimNodeSequence.SetAnim(DeathAnimName);
				AnimNodeSequence.PlayAnim();
				//AnimNodeSequence.bCauseActorAnimEnd = true;
				//return;
			}
		}
		//else
		//{
			TurnOnRagdoll(Vect(0.f, 0.f, 0.f));
			// Apply the impulse
			SkeletalMeshComponent.AddRadialImpulse(HitLocation , ForceRadius, FMin(DamageAmount * ForceAmplification, MaximumForceThatCanBeApplied), RIF_Linear, true);
			// Wake up the rigid body
			SkeletalMeshComponent.WakeRigidBody();
		//}
	}

  if( PhysicsBlendInTime > -0.00001)
	  BlendInPhysics();
}

event OnAnimEnd(AnimNodeSequence AnimNodeSequence, float PlayedTime, float ExcessTime)
{
	TurnOnRagdoll(Vect(0.f, 0.f, 0.f));
	BlendInPhysics();
	AnimNodeSequence.bCauseActorAnimEnd = false;
}

function TurnOnRagdoll(Vector RBLinearVelocity)
{
	// Force update the skeleton
	SkeletalMeshComponent.ForceSkelUpdate();

	// Fix the bodies that don't need to play a part in the physical hit reaction
	if (UnfixedBodyNames.Length > 0 && !UnFixAll)
	{
		SkeletalMeshComponent.PhysicsAssetInstance.SetNamedBodiesFixed(false, UnfixedBodyNames, SkeletalMeshComponent,, true);
	}
	else
	{
		SkeletalMeshComponent.PhysicsAssetInstance.SetAllBodiesFixed(false);
	}

	// Enable springs on bodies that are required in the physical hit reaction
	if (EnabledSpringBodyNames.Length > 0)
	{
		SkeletalMeshComponent.PhysicsAssetInstance.SetNamedRBBoneSprings(true, EnabledSpringBodyNames, LinearBoneSpringStrength, AngularBoneSpringStrength, SkeletalMeshComponent);
	}

	SkeletalMeshComponent.bUpdateKinematicBonesFromAnimation = false;
	SkeletalMeshComponent.SetRBLinearVelocity(RBLinearVelocity, true);
	SkeletalMeshComponent.WakeRigidBody();
}

function BlendInPhysics()
{
	// Set the timer for the physics to blend in
	if (PhysicsBlendInTime > 0.f)
	{
		SetTimer(PhysicsBlendInTime, false, NameOf(SimulatingPhysicsBlendIn));
	}
	else 
	{
		SkeletalMeshComponent.PhysicsWeight = PhysicWeightScale * 1.f;
		SimulatingPhysicsBlendIn();
	}
}


function SimulatingPhysicsBlendIn()
{
	if (PhysicsTime == 0.f)
	{
		SimulatingPhysics();
	}
	else
	{
		// Set the timer for the physics to stay
		SetTimer(PhysicsTime, false, NameOf(SimulatingPhysics));
	}
}

function SimulatingPhysics()
{
	local AnimNodeSequence AnimNodeSequence;
	local rotator NewRotation;
	local vector RootLocation;
	local bool GetUpFromBack;

	// Set the timer for the physics to blend out
	if(PhysicsBlendOutTime > -0.0001f) // -1 no blend out
	{
	  SetTimer(PhysicsBlendOutTime, false, NameOf(SimulatedPhysicsBlendOut));

	 //  SetPhysics(PHYS_Interpolating);
		// GetUpFromBack = (SkeletalMeshComponent.GetBoneAxis('Bip01-Head', AXIS_Y).Z > 0.0);

		// // force rotation to match the body's direction so the blend to the getup animation looks more natural
		// NewRotation = Rotation;
		// NewRotation.Yaw = rotator(SkeletalMeshComponent.GetBoneAxis('Bip01-Pelvis', AXIS_X)).Yaw;
		// // flip it around if the head is facing upwards, since the animation for that makes the character
		// // end up facing in the opposite direction that its body is pointing on the ground
		// if (!GetUpFromBack)
		// {
		// 	NewRotation.Yaw += 32768;
		// }
		// SetRotation(NewRotation);
		// RootLocation = SkeletalMeshComponent.GetBoneLocation('Bip01',0);
  // 	RootLocation.z = Location.z;
		// SetLocation(RootLocation);

	}

/*
	if (PreviousAnimName != '')
	{
		AnimNodeSequence = AnimNodeSequence(SkeletalMeshComponent.Animations);

		if (AnimNodeSequence != None)
		{
			AnimNodeSequence.SetAnim(PreviousAnimName);
			AnimNodeSequence.PlayAnim(true);
		}
	}
	*/
}

function SimulatedPhysicsBlendOut()
{
	// Set physics weight to zero
	SkeletalMeshComponent.PhysicsWeight = 0.f;
	SkeletalMeshComponent.ForceSkelUpdate();

	if (FullBodyRagdoll)
	{
		SkeletalMeshComponent.PhysicsAssetInstance.SetAllBodiesFixed(true);
		SkeletalMeshComponent.bUpdateKinematicBonesFromAnimation = true;
	}
	else
	{
		SkeletalMeshComponent.bUpdateKinematicBonesFromAnimation = true;

		if (UnfixedBodyNames.Length > 0 && !UnFixAll)
		{
			SkeletalMeshComponent.PhysicsAssetInstance.SetNamedBodiesFixed(true, UnfixedBodyNames, SkeletalMeshComponent,, true);
		}
		else
		{
			SkeletalMeshComponent.PhysicsAssetInstance.SetAllBodiesFixed(true);
		}

		// Disable springs on bodies that were required in the physical hit reaction
		if (EnabledSpringBodyNames.Length > 0)
		{
			SkeletalMeshComponent.PhysicsAssetInstance.SetNamedRBBoneSprings(false, EnabledSpringBodyNames, 0.f, 0.f, SkeletalMeshComponent);
		}
	}

	// Put the rigid body to sleep
	SkeletalMeshComponent.PutRigidBodyToSleep();
}

function Tick(float DeltaTime)
{
	local Vector RootLocation;
	local Rotator RootRotation;
	local rotator NewRotation;
	local bool GetUpFromBack;
	Super.Tick(DeltaTime);

	if (IsTimerActive(NameOf(SimulatingPhysicsBlendIn)))
	{
		// Blending in physics
		SkeletalMeshComponent.PhysicsWeight = PhysicWeightScale * GetTimerCount(NameOf(SimulatingPhysicsBlendIn)) / GetTimerRate(NameOf(SimulatingPhysicsBlendIn));


	}
	else if (IsTimerActive(NameOf(SimulatedPhysicsBlendOut)))
	{
		// Blending out physics
		SkeletalMeshComponent.PhysicsWeight = PhysicWeightScale * (1.f - (GetTimerCount(NameOf(SimulatedPhysicsBlendOut)) / GetTimerRate(NameOf(SimulatedPhysicsBlendOut))));
	}
  else if(IsTimerActive(NameOf(SimulatingPhysics)))
  {
  	// 	RootLocation = SkeletalMeshComponent.GetBoneLocation('Bip01',0);
  	// 	RootLocation.z = Location.z;
			// SetLocation(RootLocation);
			// RootRotation = QuatToRotator(SkeletalMeshComponent.GetBoneQuaternion('Bip01',0));
			// RootRotation.pitch = 0;
			// SetRotation(RootRotation);
  }
}


simulated event RootMotionModeChanged(SkeletalMeshComponent SkelComp)
{
   /**
    * ¸ù¹Ç÷ÀÔË¶¯½«»áÔÚÏÂÒ»Ö¡»á½øÐÐ
    * ËùÒÔÎÒÃÇ¿ÉÒÔÏú»ÙPawnÔË¶¯£¬²¢ÈÃ¸ù¹Ç÷ÀÔË¶¯À´½Ó¹Ü
    */
   if( SkelComp.RootMotionMode == RMM_Translate )
   {
      Velocity = Vect(0.f, 0.f, 0.f);
      Acceleration = Vect(0.f, 0.f, 0.f);
   }

   //½ûÓÃÍ¨Öª
   SkeletalMeshComponent.bRootMotionModeChangeNotify = false;
}

defaultproperties
{
	Begin Object Name=SkeletalMeshComponent0
		bHasPhysicsAssetInstance=true
		bUpdateJointsFromAnimation=true
		//RootMotionMode=RMM_Translate
	End Object

	ForceRadius=64.f

	PhysicWeightScale=1.0f

}
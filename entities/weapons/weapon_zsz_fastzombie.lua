SWEP.Base = "weapon_zsz_basezombie"
DEFINE_BASECLASS("weapon_zsz_basezombie")

SWEP.PrintName = "Fast Zombie"

SWEP.ViewModel = Model("models/weapons/v_fza.mdl")
SWEP.WorldModel = ""

SWEP.CanClimb = true
SWEP.ClimbSpeedVertical = 250
SWEP.ClimbSpeedHorizontal = 180
SWEP.ClimbIntervalLong = 0.5
SWEP.ClimbIntervalShort = 0.35

--this is fasty slow swing
SWEP.Attack1 = {
  WindupTime = 0.8,
  WinddownTime = 0.4,
  AnimationDelay = 0.25,
  Type = ZATTACK_MELEE,
  MeleeDamage = 18,
  MeleeDamageType = DMG_SLASH,
  MeleeDoPreHit = true,
  MeleeReach = 42,
  MeleeSize = 4.5,
  SpeedMul = 0.5,
  PlayAttackSound = function(self)
  	self:EmitSound("npc/fast_zombie/wake1.wav")
  end
}

--this is fasty leap
SWEP.Attack2 = {
  AttackAnim = ACT_INVALID,
  AnimationMul = 2,
  WindupTime = 0.5,
  WinddownTime = 0.75,
  SpeedMul = 0.5,
  Type = ZATTACK_LEAP,
  LeapSpeed = 800,
  LeapDamage = 8,
  LeapMinVertical = 0.25,
  LeapCanAirControl = false,
  LeapCanInterrupt = false,
  LeapForceScale = 12,
  PlayAttackSound = function(self)
  	self:EmitSound("npc/fast_zombie/leap1.wav")
  end,
  PlayHitSound = function(self)
    self:EmitSound("npc/zombie/zombie_hit.wav")
  end,
  PlayLeapSound = function(self)
    self:EmitSound("npc/fast_zombie/fz_scream1.wav",75,100,1,CHAN_VOICE)
  end,
  GetDescriptorText = function(self)
    return table.concat({
      translate.Get("launches_them_back"), "\n",
    })
  end
}

//tropical D3bot compat
SWEP.PounceAttack = SWEP.Attack2

function SWEP:OnResolveAttack(Attack)
  /*
  if Attack == self.Attack2 then
    --if this is the leap, play the fastie scream
    self:EmitSound("npc/fast_zombie/fz_scream1.wav",75,100,1,CHAN_VOICE)
  end
  */
end
function SWEP:AltUse()
  --self:TryAttack(self.AltAttack)
end
function SWEP:AltRelease()
end

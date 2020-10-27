SWEP.Base = "weapon_zsz_basezombie"

SWEP.PrintName = "Hunter"

SWEP.CanClimb = true
SWEP.ClimbSpeedVertical = 220
SWEP.ClimbSpeedHorizontal = 110
SWEP.ClimbIntervalLong = 0.5
SWEP.ClimbIntervalShort = 0.35

SWEP.Alt = {
  SpeedMul = 2,
  DamageTakenMul = 2,
  DamageTakenStatus = "hitstun",
  DamageTakenStatusDuration = 1,
  CanAttack = false,
  WinddownTime = 0.5,
}
SWEP.Attack1 = {
  WindupTime = 0.74,
  WinddownTime = 0.7,
  Type = ZATTACK_MELEE,
  MeleeDamage = 25,
  MeleeForceScale = 1,
  MeleeDamageType = DMG_SLASH,
  MeleeDoPreHit = true,
  MeleeReach = 48,
  MeleeSize = 4.5,
  SpeedMul = 0.75,
  PlayAttackSound = function(self)
  	self:EmitSound("npc/fast_zombie/wake1.wav",75,125,0.75)
  end
}

SWEP.Attack2 = {
  AttackAnim = ACT_INVALID,
  AnimationMul = 2,
  WindupTime = 0.5,
  SpeedMul = 0,
  WinddownTime = 0.5,
  Type = ZATTACK_LEAP,
  LeapSpeed = 600,
  LeapDamage = 0,
  LeapMinVertical = 0.25,
  LeapCanAirControl = false,
  LeapCanInterrupt = true,
  PlayAttackSound = function(self)
  	self:EmitSound("npc/fast_zombie/leap1.wav",75,125,0.75)
  end,
  PlayHitSound = function(self)
    self:EmitSound("npc/zombie/zombie_hit.wav",75,125,0.75)
  end,
}

function SWEP:OnResolveAttack(Attack)
  if Attack == self.Attack2 then
    --if this is the leap, play the fastie scream
    self:EmitSound("npc/fast_zombie/fz_scream1.wav",75,125,0.75,CHAN_VOICE)
  end
end

if not CLIENT then return end

function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

local matSheet = Material("models/weapons/v_zombiearms/ghoulsheet")
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
end

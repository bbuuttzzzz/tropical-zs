SWEP.Base = "weapon_zsz_hunter"

SWEP.Alt = false


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
  SpeedMul = 0.5,
  PlayAttackSound = function(self)
  	self:EmitSound("npc/fast_zombie/wake1.wav",75,125,0.75)
  end
}

SWEP.Attack2 = {
  AttackAnim = ACT_INVALID,
  AnimationMul = 2,
  WindupTime = 0.5,
  WinddownTime = 0.5,
  SpeedMul = 0,
  Type = ZATTACK_LEAP,
  LeapSpeed = 800,
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

SWEP.PounceAttack = SWEP.Attack2

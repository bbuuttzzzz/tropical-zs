SWEP.Base = "weapon_zsz_basezombie"

SWEP.PrintName = "Fresh Dead"

SWEP.Attack1 = {
  WindupTime = 0.74,
  WinddownTime = 0.46,
  Type = ZATTACK_MELEE,
  MeleeDamage = 20,
  MeleeForceScale = 1,
  MeleeDamageType = DMG_SLASH,
  MeleeDoPreHit = true,
  MeleeReach = 48,
  MeleeSize = 4.5
}

SWEP.CanClimb = true

function SWEP:PlayDefaultAttackSound()
  if self:IsAlting() then
  	self:EmitSound("npc/zombie/zo_attack"..math.random(2)..".wav",75,110)
  else
  	self:EmitSound("npc/zombie/zo_attack"..math.random(2)..".wav")
  end
end

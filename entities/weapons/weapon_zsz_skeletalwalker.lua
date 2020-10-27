SWEP.Base = "weapon_zsz_basezombie"

SWEP.PrintName = "Skeletal Walker"

SWEP.CanClimb = true

SWEP.Alt = {
  SpeedMul = 0.5,
  DamageTakenMul = 0.3
}
SWEP.Attack1 = {
  WindupTime = 0.74,
  WinddownTime = 0.46,
  Type = ZATTACK_MELEE,
  MeleeDamage = 25,
  MeleeForceScale = 1,
  MeleeDamageType = DMG_SLASH,
  MeleeDoPreHit = true,
  MeleeReach = 48,
  MeleeSize = 4.5,
  PlayAttackSound = function(swep)
  	swep:EmitSound("npc/fast_zombie/wake1.wav", 70, math.random(115, 140))
  end
}

if not CLIENT then return end

local matSheet = Material("models/props_c17/doll01")

function SWEP:PreDrawViewModel(vm, wep, pl)
	render.ModelMaterialOverride(matSheet)
end

function SWEP:PostDrawViewModel(vm, wep, pl)
	render.ModelMaterialOverride(nil)
end

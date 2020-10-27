SWEP.Base = "weapon_zsz_basezombie"

SWEP.PrintName = "Bloated Zombie"

SWEP.Attack1 = {
  WindupTime = 1,
  AnimationDelay = 0.24,
  WinddownTime = 0.46,
  Type = ZATTACK_MELEE,
  MeleeDamage = 31,
  MeleeForceScale = 1.25,
  MeleeDamageType = DMG_SLASH,
  MeleeDoPreHit = true,
  MeleeReach = 48,
  MeleeSize = 4.5,
  PlayAttackSound = function(self)
  	self:EmitSound("npc/ichthyosaur/attack_growl"..math.random(3)..".wav", 70, math.Rand(145, 155))
  end
}

function SWEP:IsAlting()
  return false
end

if not CLIENT then return end

function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

local matSheet = Material("models/weapons/v_zombiearms/ghoulsheet")
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
end

SWEP.Base = "weapon_zsz_basezombie"
DEFINE_BASECLASS("weapon_zsz_basezombie")

SWEP.PrintName = "Nightmare"

SWEP.Alt = {
  SpeedMul = 0.25,
  Regen = 15
}
SWEP.Attack1 = {
  CrippleDamage = 30,
  WindupTime = 0.74,
  WinddownTime = 0.46,
  Type = ZATTACK_MELEE,
  PropDamage = 35,
  MeleeDamage = 20,
  MeleeForceScale = 1,
  MeleeDamageType = DMG_SLASH,
  MeleeDoPreHit = true,
  MeleeReach = 48,
  MeleeSize = 4.5,
  PlayAttackSound = function(swep)
  	swep:EmitSound("npc/barnacle/barnacle_bark"..math.random(2)..".wav",75,50)
  end,
	GetDescriptorText = function(self)
		return table.concat({
			translate.Format("applies_x_cripple",self.CrippleDamage), "\n"
		})
	end
}

SWEP.Attack2 = {
  SpeedMul = 0.75,
	WindupTime = 0.74,
	WinddownTime = 1,
	Type = ZATTACK_RANGED,
	RangedProjectile = "projectile_tar",
	RangedNumShots = BULLETPATTERN_TALL,
	RangedCone = 32,
	RangedProjectileSpeed = 380,
  PlayAttackSound = function(swep)
  	swep:EmitSound("npc/fast_zombie/wake1.wav", 70, math.random(70, 90))
  end,
	GetDescriptorText = function(self)
    local shotcount = #BULLETPATTERNS[self.RangedNumShots] or self.RangedNumShots
    return table.concat({
      translate.Format("deals_x_to_y_damage",2,2*shotcount), "\n",
      translate.Format("applies_x_to_y_cripple",10,10*shotcount), "\n"
    })
	end
}

function SWEP:MeleeHit(ent, trace, damage, forcescale, damagetype)
  if not ent:IsPlayer() then
    damage = self.Attack1.PropDamage
  end

  self.BaseClass.MeleeHit(self, ent, trace, damage, forcescale, damagetype)
end

function SWEP:OnMeleeHitPlayer(pl, tr, dmginfo)
  if SERVER and self.ActiveAttack == self.Attack1 then
    pl:AddCrippleDamage(self.ActiveAttack.CrippleDamage, self:GetOwner())
  end
end

if not CLIENT then return end

function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

local matSheet = Material("Models/Charple/Charple1_sheet")
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
end

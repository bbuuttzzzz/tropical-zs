SWEP.Base = "weapon_zsz_basezombie"

SWEP.PrintName = "Blood Bag"

SWEP.ViewModel = "models/weapons/v_knife_t.mdl"
SWEP.WorldModel = ""

SWEP.ExplodeRadius = 256
SWEP.ExplodeDamage = 50
SWEP.ExplodeFalloff = 0.5
SWEP.ExplodeHeal = 200

function SWEP:Initialize()
	self:HideViewAndWorldModel()
end

SWEP.Attack1 = {
  WindupTime = 0.40,
  WinddownTime = 0.75,
  Type = ZATTACK_RANGED,
  RangedProjectile = "projectile_bloodbag",
  RangedNumShots = 5,
  RangedCone = 15,
  RangedProjectileSpeed = 380,
  PlayAttackSound = function(swep)
    swep:EmitSound("npc/antlion_guard/angry"..math.random(3)..".wav", 75, 140)
  end,
	GetDescriptorText = function(self)
		return table.concat({
			translate.Format("applies_x_to_y_bleed",5,5*self.RangedNumShots), "\n",
			translate.Get("heals_teammates"), "\n"
		})
	end
}

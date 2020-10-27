SWEP.Base = "weapon_zsz_basezombie"
DEFINE_BASECLASS("weapon_zsz_basezombie")

SWEP.PrintName = "Nightmare"

SWEP.CanClimb = true

SWEP.Alt = {
  SpeedMul = 0.25,
  Regen = 15
}
SWEP.Attack1 = {
  BleedDamage = 25,
  PropDamage = 55,
  WindupTime = 0.74,
  WinddownTime = 0.46,
  Type = ZATTACK_MELEE,
  MeleeDamage = 15,
  MeleeForceScale = 1,
  MeleeDamageType = DMG_SLASH,
  MeleeDoPreHit = true,
  MeleeReach = 48,
  MeleeSize = 4.5,
  PlayAttackSound = function(swep)
  	swep:EmitSound("npc/barnacle/barnacle_bark"..math.random(2)..".wav")
  end,
	GetDescriptorText = function(self)
		return table.concat({
			translate.Format("applies_x_bleed",self.BleedDamage), "\n",
      translate.Format("deals_x_to_props",self.PropDamage), "\n"
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
    pl:AddBleedDamage(self.ActiveAttack.BleedDamage, self:GetOwner())
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

SWEP.Base = "weapon_zsz_basezombie"
DEFINE_BASECLASS("weapon_zsz_basezombie")

SWEP.PrintName = "The Tickle Monster"

SWEP.Attack1 = {
  WindupTime = 0.74,
  WinddownTime = 0.46,
  Type = ZATTACK_MELEE,
  MeleeDamage = 15,
  PropDamage = 30,
  MeleeForceScale = 1,
  MeleeDamageType = DMG_SLASH,
  MeleeDoPreHit = true,
  MeleeReach = 150,
  MeleeSize = 4.5,
  PlayAttackSound = function(self)
  	self:EmitSound("npc/barnacle/barnacle_bark"..math.random(2)..".wav")
  end,
	GetDescriptorText = function(self)
		return table.concat({
			translate.Get("long_arms"), "\n",
		})
	end
}

function SWEP:MeleeHit(ent, trace, damage, forcescale, damagetype)
  if not ent:IsPlayer() then
    damage = self.Attack1.PropDamage
  end

  self.BaseClass.MeleeHit(self, ent, trace, damage, forcescale, damagetype)
end

if not CLIENT then return end

function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

local matSheet = Material("Models/Charple/Charple1_sheet")
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
end

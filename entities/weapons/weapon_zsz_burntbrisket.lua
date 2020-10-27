SWEP.Base = "weapon_zsz_basezombie_sck"
DEFINE_BASECLASS("weapon_zsz_basezombie_sck")

SWEP.PrintName = "Burnt Brisket"

SWEP.ViewModel = Model("models/weapons/v_pza.mdl")
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.Alt = nil

SWEP.Attack1 = {
  WindupTime = 1.1,
  WinddownTime = 1.1,
  AnimationDelay = 0.5,
  AnimationMul = 0.5,
  Type = ZATTACK_MELEE,
  KnockdownTime = 3,
  KnockdownForce = Vector(0,0,.3),
  MeleeDamage = 5,
  MeleeForceScale = 1,
  MeleeDamageType = DMG_SLASH,
  MeleeDoPreHit = true,
  MeleeReach = 75,
  MeleeSize = 4.5,
  AttackAnim = ACT_VM_HITCENTER,
  PlayAttackSound = function(swep)
    swep:EmitSound(string.format("npc/zombie_poison/pz_warn%d.wav",math.random(1,2)),75,60)
  end,
  DoOverrideDescriptor = true,
  GetDescriptorText = function(self)
    return table.concat({
      "Instagib any human you touch \n"
    })
  end
}

SWEP.Attack2 = {
	WindupTime = 7,
	WinddownTime = 2,
	AnimationDelay = 7,
	Type = ZATTACK_RANGED,
	RangedProjectile = "projectile_brisket",
	RangedNumShots = 1,
	RangedCone = 0,
	RangedProjectileSpeed = 200,
	PlayAttackSound = function(swep)
		    swep:EmitSound("npc/fast_zombie/fz_scream1.wav",100,20)
	end,
  PlayFireSound = function(swep)
      swep:EmitSound("npc/antlion_guard/angry2.wav",150,20)
  end,
  DoOverrideDescriptor = true,
  GetDescriptorText = function(self)
    return table.concat({
      "throws the most terrifying projectile ever concieved \n"
    })
  end
}

function SWEP:OnResolveAttack(Attack)
  if Attack == self.Attack2 then

  end
end

function SWEP:OnMeleeHitPlayer(pl, tr, dmginfo)
  if SERVER and self.ActiveAttack == self.Attack1 and pl:IsValidLivingHuman() then

    dmginfo:SetDamage(pl:Health() - 1)

    pl:GiveStatus("knockdown", self.Attack1.KnockdownTime)
    pl:GiveStatus("deathtouch", self.Attack1.KnockdownTime, self:GetOwner())
    local norm = tr.Normal
    norm.z = self.Attack1.KnockdownForce.z
    pl:SetVelocity(norm*5000)
  end
end


if not CLIENT then return end

SWEP.ShowWorldModel = false
SWEP.WElements = {
	["mouth"] = { type = "Model", model = "models/Gibs/Fast_Zombie_Legs.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "head", pos = Vector(-0.348, 0.279, -1.599), angle = Angle(115.609, 12.975, 0), size = Vector(0.367, 0.367, 0.009), color = Color(165, 165, 161, 255), surpresslightning = false, material = "models/charple/charple1_sheet", skin = 0, bodygroup = {} },
	["rightEye"] = { type = "Model", model = "models/props/cs_office/snowman_eye1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "head", pos = Vector(-7.854, -8.954, 5.076), angle = Angle(22.208, -122.889, 47.299), size = Vector(1.304, 1.304, 1.304), color = Color(255, 130, 130, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["rightEyeLid"] = { type = "Model", model = "models/props/cs_office/snowman_eye1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "rightEye", pos = Vector(0.054, -0.41, 0), angle = Angle(0, 0, 0), size = Vector(1.59, 1.59, 1.59), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/charple/charple1_sheet", skin = 0, bodygroup = {} },
	["head"] = { type = "Model", model = "models/headcrabblack.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "", pos = Vector(5.714, -4.527, 0), angle = Angle(10.519, 180, -92.338), size = Vector(0.754, 0.754, 0.754), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/charple/charple1_sheet", skin = 0, bodygroup = {} },
	["LeftEyeLid"] = { type = "Model", model = "models/props/cs_office/snowman_eye1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "leftEye", pos = Vector(0, 0.243, 0.481), angle = Angle(-0.839, -3.211, 5.026), size = Vector(1.598, 1.598, 1.598), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/charple/charple1_sheet", skin = 0, bodygroup = {} },
	["LeftEyePupil"] = { type = "Model", model = "models/props/cs_office/snowman_eye1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "leftEye", pos = Vector(0.225, -0.464, -0.634), angle = Angle(0, 0, 0), size = Vector(0.632, 0.632, 0.632), color = Color(0, 0, 0, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["leftEye"] = { type = "Model", model = "models/props/cs_office/snowman_eye1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "head", pos = Vector(-6.565, 9.225, -0.461), angle = Angle(23.561, 107.385, -11.777), size = Vector(1.304, 1.304, 1.304), color = Color(255, 117, 117, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["rightEyePupil"] = { type = "Model", model = "models/props/cs_office/snowman_eye1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "rightEye", pos = Vector(-0.145, 0.652, 0), angle = Angle(0, 0, 0), size = Vector(0.629, 0.629, 0.629), color = Color(0, 0, 0, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} }
}

SWEP.ViewModelFOV = 47

function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

local matSheet = Material("Models/Charple/charple1_sheet")
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
end

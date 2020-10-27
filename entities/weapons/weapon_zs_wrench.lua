AddCSLuaFile()

SWEP.Base = "weapon_zs_baserepair"

SWEP.PrintName = "Monkey Wrench"
SWEP.Description = "Smack props to heal them. Use up an oomph charge to heal more."

SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false

SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.WorldModel = "models/props_c17/tools_wrench01a.mdl"

SWEP.VElements = {
	["base"] = { type = "Model", model = "models/props_c17/tools_wrench01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2, 2, 0), angle = Angle(190, 0, 90), size = Vector(1.5, 1.5, 1.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["base"] = { type = "Model", model = "models/props_c17/tools_wrench01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2, 1, 0), angle = Angle(190, 90, 90), size = Vector(1.5, 1.5, 1.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} }
}

SWEP.MeleeDamage = 20
SWEP.MeleeRange = 50
SWEP.MeleeSize = 0.875
SWEP.DamageType = DMG_CLUB

SWEP.Primary.Delay = 1.2
SWEP.Primary.Automatic = true

SWEP.WeightClass = WEIGHT_LIGHT

SWEP.OomphCost = 6

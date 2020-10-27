AddCSLuaFile()

SWEP.PrintName = "'Crossfire' Glock 3"
SWEP.Description = "Fires 3 bullets for the price of one"

SWEP.TranslationName = "wep_glock"
SWEP.TranslationDesc = "wep_d_glock"

SWEP.Slot = 1
SWEP.Tier = 2
SWEP.SlotPos = 0

SWEP.WeightClass = WEIGHT_LIGHT

SWEP.StatDPS = 3
SWEP.StatDPR = 3
SWEP.StatRange = 2
SWEP.StatSpecial = 2

if CLIENT then
	SWEP.ViewModelFOV = 50
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "v_weapon.Glock_Slide"
	SWEP.HUD3DPos = Vector(5, 0.25, -0.8)
	SWEP.HUD3DAng = Angle(90, 0, 0)
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_Glock.Single")
SWEP.Primary.Damage = 13.5
SWEP.Primary.NumShots = 3
SWEP.Primary.Delay = 0.25

SWEP.Primary.ClipSize = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 4.5
SWEP.ConeMin = 3

SWEP.IronSightsPos = Vector(-5.75, 10, 2.7)

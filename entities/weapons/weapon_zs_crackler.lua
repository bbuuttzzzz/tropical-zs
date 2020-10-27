AddCSLuaFile()

SWEP.PrintName = "'Crackler' Marksman Rifle"
SWEP.Description = "A Great shot, but hard to hold steady. Semi Automatic."

SWEP.TranslationName = "wep_crackler"
SWEP.TranslationDesc = "wep_d_crackler"

SWEP.Slot = 2
SWEP.Tier = 3
SWEP.SlotPos = 0

SWEP.StatDPS = 5
SWEP.StatDPR = 1
SWEP.StatRange = 4
SWEP.StatSpecial = 1

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "v_weapon.famas"
	SWEP.HUD3DPos = Vector(1.1, -3.5, 10)
	SWEP.HUD3DScale = 0.02
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_rif_famas.mdl"
SWEP.WorldModel = "models/weapons/w_rif_famas.mdl"
SWEP.UseHands = true

SWEP.ReloadSound = Sound("Weapon_FAMAS.Clipout")
SWEP.Primary.Sound = Sound("Weapon_FAMAS.Single")
SWEP.Primary.Damage = 40
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.25

SWEP.Primary.ClipSize = 22
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "ar2"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 5.5
SWEP.ConeMin = 0.75

SWEP.ReloadSpeed = 1.1

SWEP.WeightClass = WEIGHT_MEDIUM

SWEP.IronSightsPos = Vector(-3, 3, 2)

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.375, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.2, 1)
GAMEMODE:AddNewRemantleBranch(SWEP, 1, "'Crackler' Combat Rifle", "Loses automatic fire rate but gains a bit of damage and accuracy", function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 1.2
	wept.Primary.Delay = wept.Primary.Delay * 2
	wept.Primary.ClipSize = 15
	wept.ConeMin = wept.ConeMin * 0.7
	wept.ConeMax = wept.ConeMax * 0.7
	wept.Primary.Automatic = false
end)

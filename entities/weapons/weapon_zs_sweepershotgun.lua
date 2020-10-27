AddCSLuaFile()

SWEP.Base = "weapon_zs_baseshotgun"
SWEP.Slot = 3
SWEP.Tier = 4

SWEP.StatDPS = 3
SWEP.StatDPR = 3
SWEP.StatRange = 2
SWEP.StatSpecial = 1

SWEP.PrintName = "'Sweeper' Shotgun"
SWEP.Description = "BOOM chickchick BOOM"

SWEP.TranslationName = "wep_sweepershotgun"
SWEP.TranslationDesc = "wep_d_sweepershotgun"

if CLIENT then
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "v_weapon.M3_PARENT"
	SWEP.HUD3DPos = Vector(-1, -4, -3)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.HoldType = "shotgun"

SWEP.ViewModel = "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"
SWEP.UseHands = true

SWEP.ReloadDelay = 0.45

SWEP.Primary.Sound = Sound("Weapon_M3.Single")
SWEP.Primary.Damage = 350 --31.25
SWEP.Primary.NumShots = BULLETPATTERN_SHOTGUN --8
SWEP.Primary.Delay = 0.87
SWEP.HeadshotMulti = 1.5

SWEP.Primary.ClipSize = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "buckshot"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 8
SWEP.ConeMin = 4.5

SWEP.FireAnimSpeed = 1.2
SWEP.WeightClass = WEIGHT_MEDIUM

SWEP.MaxStock = 3

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1)

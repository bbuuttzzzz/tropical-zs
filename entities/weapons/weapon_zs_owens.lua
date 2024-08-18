AddCSLuaFile()

SWEP.PrintName = "'Owens' Handgun"
SWEP.Description = "This gun freaking owns, but only up close. Reduced headshot damage."

SWEP.TranslationName = "wep_owens"
SWEP.TranslationDesc = "wep_d_owens"

SWEP.Slot = 1
SWEP.Tier = 1
SWEP.SlotPos = 0

SWEP.WalkSpeed = SPEED_FAST

SWEP.StatDPS = 5
SWEP.StatDPR = 2
SWEP.StatRange = 1
SWEP.StatSpecial =  3

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "ValveBiped.square"
	SWEP.HUD3DPos = Vector(1.1, 0.25, -2)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true

SWEP.CSMuzzleFlashes = false

SWEP.ReloadSound = Sound("Weapon_Pistol.Reload")
SWEP.Primary.Sound = Sound("Weapon_Pistol.NPC_Single")
SWEP.Primary.Damage = 17
SWEP.HeadshotMulti = 1.3
SWEP.Primary.NumShots = 2
SWEP.Primary.Delay = 0.12

SWEP.Primary.ClipSize = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.ClipMultiplier = 12/10
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 7
SWEP.ConeMin = 5

SWEP.IronSightsPos = Vector(-5.95, 3, 2.75)
SWEP.IronSightsAng = Vector(-0.15, -1, 2)

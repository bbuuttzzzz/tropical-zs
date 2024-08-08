AddCSLuaFile()

SWEP.PrintName = "'Succubus' SMG"
SWEP.Description =  "Deals more damage the lower HP you are."

SWEP.TranslationName = "wep_succubus"
SWEP.TranslationDesc = "wep_d_succubus"

SWEP.Slot = 3
SWEP.Tier = 4
SWEP.SlotPos = 0

SWEP.WeightClass = WEIGHT_LIGHT

SWEP.StatDPS = 2
SWEP.StatDPR = 5
SWEP.StatRange = 3
SWEP.StatSpecial = 1

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "v_weapon.TMP_Parent"
	SWEP.HUD3DPos = Vector(-1, -3.5, -1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"
DEFINE_BASECLASS("weapon_zs_base")

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_smg_tmp.mdl"
SWEP.WorldModel = "models/weapons/w_smg_tmp.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("weapons/m4a1/m4a1-1.wav")
SWEP.Primary.Damage = 25
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.08

SWEP.Primary.ClipSize = 40
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_AR2

SWEP.ConeMax = 6.5
SWEP.ConeMin = 3.6

SWEP.MaxBonusDamage = 20

SWEP.ReloadSpeed = 1

SWEP.MaxStock = 3


SWEP.IronSightsPos = Vector(-7, 3, 2.5)

function SWEP.BulletCallback(attacker, tr, dmginfo)
	if not SERVER then return end

	local swep = attacker:GetActiveWeapon()
	local healthFraction = attacker:Health() / attacker:GetMaxHealth()
	local bonusDamage = math.min(0, (1 - healthFraction)) * swep.MaxBonusDamage

	dmgInfo:SetDamage(swep.Primary.Damage + bonusDamage)
end

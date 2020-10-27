AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

SWEP.PrintName = "'Stalker' M4"
SWEP.Description = "hides your aura from distant undead. Deals bonus damage in the back"

SWEP.TranslationName = "wep_m4"
SWEP.TranslationDesc = "wep_d_m4"

SWEP.Slot = 4
SWEP.Tier = 4
SWEP.SlotPos = 0

SWEP.StatDPS = 4
SWEP.StatDPR = 4
SWEP.StatRange = 3
SWEP.StatSpecial = 5

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "v_weapon.m4_Parent"
	SWEP.HUD3DPos = Vector(-0.5, -5, -1.2)
	SWEP.HUD3DAng = Angle(0, -5, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_m4a1.Single")
SWEP.Primary.Damage = 24.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.11

SWEP.Primary.ClipSize = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SMG1

SWEP.ConeMax = 5
SWEP.ConeMin = 1.5

SWEP.WeightClass = WEIGHT_MEDIUM

SWEP.MaxStock = 3

SWEP.IronSightsPos = Vector(-3, 0, 2)

SWEP.BackstabMultiplier = 1.5

function SWEP.BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	if ent:IsValidZombie() then
		local owneryaw = attacker:GetForward():Angle().yaw
		local zombieyaw = ent:GetForward():Angle().yaw
		local yawDiff = math.abs(owneryaw - zombieyaw)

		if(yawDiff <= 90 or yawDiff >= 270) then
			dmginfo:SetDamage(dmginfo:GetDamage() * attacker:GetActiveWeapon().BackstabMultiplier)
		end

		if IsFirstTimePredicted() then
			--emit backshot sound
		end
	end
end

function SWEP:GetAuraRange()
	return 512
end

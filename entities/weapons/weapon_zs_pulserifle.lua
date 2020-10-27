AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

SWEP.PrintName = "'Adonis' Pulse Rifle"
SWEP.Description = "Deals massive damage and slows targets."

SWEP.TranslationName = "wep_pulserifle"
SWEP.TranslationDesc = "wep_d_pulserifle"

SWEP.Slot = 5
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "Vent"
	SWEP.HUD3DPos = Vector(1, 0, 0)
	SWEP.HUD3DScale = 0.018
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_IRifle.mdl"
SWEP.UseHands = true

SWEP.CSMuzzleFlashes = false

SWEP.ReloadSound = Sound("Weapon_SMG1.Reload")
SWEP.Primary.Sound = Sound("Airboat.FireGunHeavy")
SWEP.Primary.Damage = 29
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.2

SWEP.Primary.ClipSize = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pulse"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 3
SWEP.ConeMin = 1

SWEP.WeightClass = WEIGHT_HEAVY

SWEP.IronSightsPos = Vector(-3, 1, 1)

SWEP.Tier = 5
SWEP.MaxStock = 2

SWEP.PointsMultiplier = GAMEMODE.PulsePointsMultiplier

SWEP.TracerName = "AR2Tracer"

SWEP.FireAnimSpeed = 0.4
SWEP.LegDamage = 5.5

function SWEP.BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	if ent:IsValidZombie() then
		ent:GiveStatus("slow",0.3)

		/*
		local activ = attacker:GetActiveWeapon()
		ent:AddLegDamageExt(activ.LegDamage, attacker, activ, SLOWTYPE_PULSE)
		*/
	end

	if IsFirstTimePredicted() then
		util.CreatePulseImpactEffect(tr.HitPos, tr.HitNormal)
	end
end

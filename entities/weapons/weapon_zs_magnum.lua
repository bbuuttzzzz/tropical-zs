AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

SWEP.PrintName = "'Ricochete' Magnum"
SWEP.Description = "Bullets ricochet for extra damage. Bounced bullets always do 1.5x damage, no matter where it hits"

SWEP.TranslationName = "wep_magnum"
SWEP.TranslationDesc = "wep_d_magnum"

SWEP.Slot = 1
SWEP.Tier = 2
SWEP.SlotPos = 0

SWEP.WeightClass = WEIGHT_LIGHT

SWEP.StatDPS = 1
SWEP.StatDPR = 5
SWEP.StatRange = 5
SWEP.StatSpecial = 2

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "Python"
	SWEP.HUD3DPos = Vector(0.85, 0, -2.5)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "revolver"

SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.UseHands = true

SWEP.CSMuzzleFlashes = false

SWEP.Primary.Sound = Sound("Weapon_357.Single")
SWEP.Primary.Delay = 0.9
SWEP.Primary.Damage = 72
SWEP.Primary.NumShots = 1

SWEP.Primary.ClipSize = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
GAMEMODE:SetupDefaultClip(SWEP.Primary)


SWEP.ConeMax = 4
SWEP.ConeMin = .3
SWEP.BounceMulti = 2.2

SWEP.IronSightsPos = Vector(-4.65, 4, 0.25)
SWEP.IronSightsAng = Vector(0, 0, 1)

local function DoRicochet(attacker, hitpos, hitnormal, normal, damage)
	local RicoCallback = function(att, tr, dmginfo)
		tr.HitGroup = HITGROUP_CHEST
	end

	attacker.RicochetBullet = true
	if attacker:IsValid() then
		attacker:FireBulletsLua(hitpos, 2 * hitnormal * hitnormal:Dot(normal * -1) + normal, 0, 1, damage, nil, nil, "tracer_rico", RicoCallback, nil, nil, 1000, nil, attacker:GetActiveWeapon())
	end
	attacker.RicochetBullet = nil
end
function SWEP.BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	if SERVER and tr.HitWorld and not tr.HitSky then
		local hitpos, hitnormal, normal, dmg = tr.HitPos, tr.HitNormal, tr.Normal, dmginfo:GetDamage() * attacker:GetActiveWeapon().BounceMulti
		timer.Simple(0, function() DoRicochet(attacker, hitpos, hitnormal, normal, dmg) end)
	end

end

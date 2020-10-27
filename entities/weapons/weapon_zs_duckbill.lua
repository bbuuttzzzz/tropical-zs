AddCSLuaFile()

SWEP.Base = "weapon_zs_baseshotgun"

SWEP.Slot = 3
SWEP.Tier = 4

SWEP.StatDPS = 2
SWEP.StatDPR = 3
SWEP.StatRange = 1
SWEP.StatSpecial = 5

SWEP.PrintName = "'Duckbill' Shotgun"
SWEP.Description = "huge horizontal spread, does equal damage no matter how many bullets hit. only effective at close range. Cannot headshot."

SWEP.TranslationName = "wep_duckbill"
SWEP.TranslationDesc = "wep_d_duckbill"

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "v_weapon.xm1014_Parent"
	SWEP.HUD3DPos = Vector(1, 0, 6)
	SWEP.HUD3DScale = 0.015
end

SWEP.HoldType = "shotgun"

SWEP.ViewModel = "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"
SWEP.UseHands = true

SWEP.ReloadDelay = 0.4

SWEP.Primary.Sound = Sound("weapons/xm1014/xm1014-1.wav")
SWEP.Primary.Damage = 1 --gets overwritten!!! see SWEP.DamageMax
SWEP.Primary.NumShots = BULLETPATTERN_DUCKBILL
SWEP.Primary.Delay = 0.5
SWEP.Primary.MaxDistance = 1000

SWEP.Primary.ClipSize = 9
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "buckshot"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 8
SWEP.ConeMin = 5
SWEP.ConeModifier = 2 -- applied right before you shoot, so the crosshair isn't stupidly big

SWEP.WeightClass = WEIGHT_MEDIUM

SWEP.PumpSound = Sound("Weapon_M3.Pump")
SWEP.ReloadSound = Sound("weapons/xm1014/xm1014_insertshell.wav")

SWEP.DamageMax = 150
SWEP.DamageMaxRange = 50

SWEP.DamageMin = 50
SWEP.DamageMinRange = 500

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())

	self:EmitFireSound()
	self:TakeAmmo()

	self.Hits = {}

	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone() * self.ConeModifier)
	self.IdleAnimation = CurTime() + self:SequenceDuration()

end

function SWEP.BulletCallback(attacker, tr, dmginfo)
	local hitEnt = tr.Entity
	if not hitEnt.IsValidZombie then return end

	local swep = attacker:GetActiveWeapon()

	local found = false
	for n, ent in ipairs(swep.Hits) do
		if hitEnt == ent then
			found = true
			break
		end
	end

	if not found then
		--add to ignore list
		swep.Hits[#swep.Hits + 1] = hitEnt

		--get new damage value
		local dist = tr.Fraction * swep.Primary.MaxDistance
		local t = (dist - swep.DamageMaxRange)/(swep.DamageMinRange - swep.DamageMaxRange)
		local damage = Lerp(t,swep.DamageMax,swep.DamageMin)

		dmginfo:SetDamage(damage)
		tr.HitGroup = HITGROUP_CHEST
	else
		dmginfo:SetDamage(0)
	end

end

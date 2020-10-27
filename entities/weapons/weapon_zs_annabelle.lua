AddCSLuaFile()

SWEP.Base = "weapon_zs_baseshotgun"
SWEP.Slot = 3
SWEP.Tier = 4

SWEP.StatDPS = 2
SWEP.StatDPR = 5
SWEP.StatRange = 5
SWEP.StatSpecial = 2

SWEP.PrintName = "'Annabelle' Rifle"
SWEP.Description = "Bullet explodes into a shotgun blast when they hit walls or zombies"

SWEP.TranslationName = "wep_annabelle"
SWEP.TranslationDesc = "wep_d_annabelle"

if CLIENT then
	SWEP.ViewModelFlip = false

	SWEP.IronSightsPos = Vector(-8.8, 10, 4.32)
	SWEP.IronSightsAng = Vector(1.4, 0.1, 5)

	SWEP.HUD3DBone = "ValveBiped.Gun"
	SWEP.HUD3DPos = Vector(1.75, 1, -5)
	SWEP.HUD3DAng = Angle(180, 0, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/c_annabelle.mdl"
SWEP.WorldModel = "models/weapons/w_annabelle.mdl"
SWEP.UseHands = true

SWEP.CSMuzzleFlashes = false

SWEP.Primary.Sound = Sound("Weapon_Shotgun.Single")
SWEP.Primary.Damage = 100
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.9

--this is for ricochet rounds
SWEP.Secondary.Damage = 250
SWEP.Secondary.NumShots = BULLETPATTERN_SHOTGUN
SWEP.Secondary.Spread = 2

SWEP.ReloadDelay = 0.4

SWEP.Primary.ClipSize = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "357"
SWEP.Primary.DefaultClip = 25

SWEP.ConeMax = 4
SWEP.ConeMin = 0.75

SWEP.ReloadSound = Sound("Weapon_Shotgun.Reload")
SWEP.PumpSound = Sound("Weapon_Shotgun.Special1")

SWEP.WeightClass = WEIGHT_MEDIUM


function SWEP:EmitFireSound()
	self:EmitSound(self.Primary.Sound, 75, math.random(95, 103), 0.8)
	self:EmitSound("weapons/shotgun/shotgun_fire6.wav", 75, math.random(78, 81), 0.65, CHAN_WEAPON + 20)
end

function SWEP:SecondaryAttack()
	if self:GetNextSecondaryFire() <= CurTime() and not self:GetOwner():IsHolding() and self:GetReloadFinish() == 0 then
		self:SetIronsights(true)
	end
end

function SWEP:Think()
	if self:GetIronsights() and not self:GetOwner():KeyDown(IN_ATTACK2) then
		self:SetIronsights(false)
	end

	self.BaseClass.Think(self)
end

local function DoExplode(attacker, origin, direction, isRico)
	local RicoCallback = function(att, tr, dmginfo)

	end

	local swep = attacker:GetActiveWeapon()
	local damage = swep.Secondary.Damage
	local numshots = swep.Secondary.NumShots
	local spread = swep.Secondary.Spread

	attacker.RicochetBullet = true
	if attacker:IsValid() then
		attacker:FireBulletsLua(origin + direction * (isRico and 0 or 16), direction, spread, numshots, damage, nil, nil, "tracer_rico",RicoCallback,nil,nil,512,nil,swep)
	end



end

function SWEP.BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	if SERVER then
		if tr.HitWorld and not tr.HitSky then
			local swep = attacker:GetActiveWeapon()

			local origin = tr.HitPos
			local hitNormal = tr.HitNormal
			local normal = tr.Normal
			local direction = 2 * hitNormal * hitNormal:Dot(normal * -1) + normal

			timer.Simple(0, function() DoExplode(attacker, origin, direction, true) end)

		elseif ent and ent:IsPlayer() then
			local origin = tr.HitPos
			local direction = tr.Normal

			timer.Simple(0, function() DoExplode(attacker, origin, direction, nil) end)
		end
	end

end

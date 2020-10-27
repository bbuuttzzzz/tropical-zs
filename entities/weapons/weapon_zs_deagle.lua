AddCSLuaFile()

SWEP.PrintName = "'Zombie Drill' Desert Eagle"
SWEP.Description = "Bullet pierces to hit a second zombie" --SWEP.Description = "This high-powered handgun has the ability to pierce through multiple zombies. The bullet's power decreases by half which each zombie it hits."

SWEP.TranslationName = "wep_deagle"
SWEP.TranslationDesc = "wep_d_deagle"

SWEP.Slot = 1
SWEP.Tier = 2
SWEP.SlotPos = 0

SWEP.WeightClass = WEIGHT_LIGHT

SWEP.StatDPS = 2
SWEP.StatDPR = 4
SWEP.StatRange = 3
SWEP.StatSpecial = 4

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55

	SWEP.HUD3DBone = "v_weapon.Deagle_Slide"
	SWEP.HUD3DPos = Vector(-1, 0, 1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015

	SWEP.IronSightsPos = Vector(-6.35, 5, 1.7)
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "revolver"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_Deagle.Single")
SWEP.Primary.Damage = 57
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.32
SWEP.Primary.KnockbackScale = 2

SWEP.Primary.ClipSize = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 3.4
SWEP.ConeMin = 1.25

SWEP.FireAnimSpeed = 1.3


GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 2)

SWEP.Pierces = 3 --actually only pierces [Pierces-1]? did when i tested

function SWEP:ShootBullets(dmg, numbul, cone)
	local owner = self:GetOwner()
	self:SendWeaponAnimation()
	owner:DoAttackEvent()

	local dir = owner:GetAimVector()
	local dirang = dir:Angle()
	local start = owner:GetShootPos()

	dirang:RotateAroundAxis(dirang:Forward(), util.SharedRandom("bulletrotate1", 0, 360))
	dirang:RotateAroundAxis(dirang:Up(), util.SharedRandom("bulletangle1", -cone, cone))

	dir = dirang:Forward()
	local tr = owner:CompensatedPenetratingMeleeTrace(4092, 0.01, start, dir)
	local ent

	local dmgf = function(i) return dmg * (1 - 0.5 * i) end

	owner:LagCompensation(true)
	for i, trace in ipairs(tr) do
		if not trace.Hit then continue end
		if i > self.Pierces - 1 then break end

		ent = trace.Entity

		if ent and ent:IsValid() then
			owner:FireBulletsLua(trace.HitPos, dir, 0, numbul, dmgf(i-1), nil, self.Primary.KnockbackScale, "", self.BulletCallback, self.Primary.HullSize, nil, self.Primary.MaxDistance, nil, self)
		end
	end
	owner:FireBulletsLua(start, dir, cone, numbul, 0, nil, self.Primary.KnockbackScale, self.TracerName, self.BulletCallback, self.Primary.HullSize, nil, self.Primary.MaxDistance, nil, self)
	owner:LagCompensation(false)
end

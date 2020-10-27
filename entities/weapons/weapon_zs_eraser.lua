AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

SWEP.PrintName = "'Eraser' Tactical Pistol"
SWEP.Description =  "The last bullet in the clip does massive damage"

SWEP.TranslationName = "wep_eraser"
SWEP.TranslationDesc = "wep_d_eraser"

SWEP.Slot = 1
SWEP.Tier = 2
SWEP.SlotPos = 0

SWEP.StatDPS = 4
SWEP.StatDPR = 2
SWEP.StatRange = 3
SWEP.StatSpecial = 5

if CLIENT then
	SWEP.ViewModelFOV = 60
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "v_weapon.FIVESEVEN_PARENT"
	SWEP.HUD3DPos = Vector(-1, -2.5, -1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_fiveseven.mdl"
SWEP.WorldModel = "models/weapons/w_pist_fiveseven.mdl"
SWEP.UseHands = true

--

SWEP.Primary.Sound = Sound("weapons/ar2/fire1.wav")
SWEP.Primary.Damage = 33
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.18

SWEP.Primary.ClipSize = 12
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.WarningShotSound = Sound("weapons/ar2/npc_ar2_altfire.wav")

SWEP.Secondary.Sound = Sound("weapons/ar2/ar2_altfire.wav")
SWEP.Secondary.Damage = 160
SWEP.Secondary.NumShots = BULLETPATTERN_SHOTGUN
SWEP.Secondary.ConeMul = 2
SWEP.Secondary.Recoil = 6
SWEP.Knockback = 150

SWEP.ConeMax = 3.5--2.5
SWEP.ConeMin = 2.5--1.25

SWEP.ReloadSpeed = 1
SWEP.HeadshotMulti = 2

SWEP.IronSightsPos = Vector(-5.95, 0, 2.5)

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())

	local clip = self:Clip1()

	if clip == 1 then
		self.IsLastShot = true
		self:ShootBullets(self.Secondary.Damage, self.Secondary.NumShots, self:GetCone())
		self:EmitSound(self.Secondary.Sound)

		owner = self:GetOwner()

		local r = math.Rand(0.8, 1)
		owner:ViewPunch(Angle(r * -self.Secondary.Recoil, 0, (1 - r) * (math.random(2) == 1 and -1 or 1) * self.Secondary.Recoil))

		local vec = owner:GetAimVector() * -1
		vec.z = math.Clamp(vec.z,1.25, 1.25)

		owner:SetGroundEntity(NULL)
		owner:SetVelocity(self.Knockback * vec)

		self.IsLastShot = false
	else
		self.IsLastShot = false
		self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone())

		if clip == 2 then
			self.IsLastShot = true
				self:EmitSound(self.WarningShotSound, 75, 150)
		else
			self:EmitFireSound()
		end
	end

	self:TakeAmmo()
	self.IdleAnimation = CurTime() + self:SequenceDuration()

end

function SWEP:GetCone()
	local mul = self.IsLastShot and self.Secondary.ConeMul or 1
	return BaseClass.GetCone(self) * mul
end

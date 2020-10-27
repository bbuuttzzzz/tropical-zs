AddCSLuaFile()

SWEP.PrintName = "'blitzer' Autopistol"
SWEP.Description = "The world's first fully automatic handgun. right click to fire the whole clip at once!"
SWEP.Slot = 3
SWEP.SlotPos = 0

SWEP.StatDPS = 5
SWEP.StatDPR = 2
SWEP.StatRange = 1
SWEP.StatSpecial = 1

SWEP.WeightClass = WEIGHT_FEATHER

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "ValveBiped.square"
	SWEP.HUD3DPos = Vector(1.1, 0.25, -2)
	SWEP.HUD3DScale = 0.015

	SWEP.ShowViewModel = false

	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/weapons/w_alyx_gun.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(7, 2, -4.092), angle = Angle(170, 10, 10), size = Vector(1.1, 1.1, 1.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_alyx_gun.mdl"
SWEP.UseHands = true

SWEP.CSMuzzleFlashes = false

SWEP.ReloadSound = Sound("weapons/alyx_gun/alyx_shotgun_cock1.wav")
SWEP.Primary.Sound = Sound("weapons/alyx_gun/alyx_gun_fire3.wav")
SWEP.Primary.Automatic = true
SWEP.Primary.Damage = 24
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.125

SWEP.Primary.ClipSize = 17
SWEP.Primary.Ammo = "pistol"

SWEP.Secondary.Recoil = 1
SWEP.Knockback = 15
SWEP.ReloadSpeed = 0.7

SWEP.Secondary.Delay = 0.5
SWEP.Secondary.Sound = Sound("weapons/airboat/airboat_gun_energy1.wav")
SWEP.Secondary.Damage = 18

SWEP.ConeMax = 4.5
SWEP.ConeMin = 2

SWEP.IronSightsPos = Vector(-5.95, 3, 2.75)
SWEP.IronSightsAng = Vector(-0.15, -1, 2)

SWEP.TracerName = "AR2Tracer"

function SWEP:SecondaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()

	self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
	self:EmitSound(self.Secondary.Sound)

	local clip = self:Clip1()

	self:ShootBullets(self.Secondary.Damage, clip, self:GetCone() * 3)

	self:TakePrimaryAmmo(clip)
	owner:ViewPunch(clip * self.Secondary.Recoil * Angle(math.Rand(-0.1, -0.1), math.Rand(-0.1, 0.1), 0))

	owner:SetGroundEntity(NULL)
	owner:SetVelocity(-self.Knockback * clip * owner:GetAimVector())

	self.IdleAnimation = CurTime() + self:SequenceDuration()

end

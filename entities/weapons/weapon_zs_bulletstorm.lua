AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

SWEP.PrintName = "'Bullet Storm' SMG"
SWEP.Description = ""

SWEP.TranslationName = "wep_bulletstorm"
SWEP.TranslationDesc = "wep_d_bulletstorm"

SWEP.Slot = 2
SWEP.Tier = 3
SWEP.SlotPos = 0

SWEP.StatDPS = 4
SWEP.StatDPR = 2
SWEP.StatRange = 3
SWEP.StatSpecial = 3

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50

	SWEP.HUD3DBone = "v_weapon.p90_Release"
	SWEP.HUD3DPos = Vector(-1.35, -0.5, -6.5)
	SWEP.HUD3DAng = Angle(0, 0, 0)
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "smg"

SWEP.ViewModel = "models/weapons/cstrike/c_smg_p90.mdl"
SWEP.WorldModel = "models/weapons/w_smg_p90.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_p90.Single")
SWEP.Primary.Damage = 11
SWEP.Primary.NumShots = 2
SWEP.Primary.Delay = 0.07
SWEP.HeadshotMulti = 1.3

SWEP.Primary.ClipSize = 75
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 7
SWEP.ConeMin = 5

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SMG1

SWEP.WeightClass = WEIGHT_LIGHT

SWEP.MaxStock = 3

SWEP.IronSightsPos = Vector(-2, 6, 3)
SWEP.IronSightsAng = Vector(0, 2, 0)

/*

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	local ironsights = self:GetIronsights()

	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay() * (ironsights and 1.3333 or 1))

	self:EmitFireSound()
	self:TakeAmmo()
	self:ShootBullets(self.Primary.Damage * (ironsights and 0.6666 or 1), self.Primary.NumShots * (ironsights and 2 or 1), self:GetCone())
	self.IdleAnimation = CurTime() + self:SequenceDuration()
end

function SWEP:SetIronsights(b)
	if self:GetIronsights() ~= b then
		if b then
			self:EmitSound("npc/scanner/scanner_scan4.wav", 40)
		else
			self:EmitSound("npc/scanner/scanner_scan2.wav", 40)
		end
	end

	BaseClass.SetIronsights(self, b)
end

function SWEP:SecondaryAttack()
	if self:GetNextSecondaryFire() <= CurTime() and not self:GetOwner():IsHolding() and self:GetReloadFinish() == 0 then
		self:SetIronsights(true)
	end
end

*/

util.PrecacheSound("npc/scanner/scanner_scan4.wav")
util.PrecacheSound("npc/scanner/scanner_scan2.wav")

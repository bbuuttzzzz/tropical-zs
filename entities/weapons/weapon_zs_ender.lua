AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

SWEP.PrintName = "'Ender' Automatic Shotgun"
SWEP.Description = "the world's first automatic shotgun! Gets more accurate as you shoot."

SWEP.TranslationName = "wep_ender"
SWEP.TranslationDesc = "wep_d_ender"

SWEP.Slot = 3
SWEP.Tier = 4
SWEP.SlotPos = 0

SWEP.StatDPS = 5
SWEP.StatDPR = 1
SWEP.StatRange = 2
SWEP.StatSpecial = 1

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "v_weapon.galil"
	SWEP.HUD3DPos = Vector(1, 0, 6)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "shotgun"

SWEP.ViewModel = "models/weapons/cstrike/c_rif_galil.mdl"
SWEP.WorldModel = "models/weapons/w_rif_galil.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_Galil.Single")
SWEP.Primary.Damage = 170
SWEP.Primary.NumShots = BULLETPATTERN_SHOTGUN
SWEP.Primary.Delay = 0.3

SWEP.MinFocusMul = 1.25 --at no focus, this is the modifier on accuracy
SWEP.MaxFocusMul = 0.5 --at full focus, this is the modifier on accuracy
SWEP.MaxFocusTime = 4 --amount of "focus" (time) equivalent to full focus, where min is 0
SWEP.AddFocusTime = 1 --amount of "focus" (time) added per shot

SWEP.Primary.ClipSize = 16
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "buckshot"
GAMEMODE:SetupDefaultClip(SWEP.Primary)
SWEP.HeadshotMulti = 1.5

SWEP.ConeMax = 5.625
SWEP.ConeMin = 4.875

SWEP.WeightClass = WEIGHT_MEDIUM

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())

	self:AddFocus(self.AddFocusTime)

	self:EmitFireSound()
	self:TakeAmmo()
	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone())
	self.IdleAnimation = CurTime() + self:SequenceDuration()
end

function SWEP:FinishReload()
	self:SetFocusDecayTime(CurTime())
	BaseClass.FinishReload(self)
end

function SWEP:GetCone()
	local t = self:GetFocus() / self.MaxFocusTime
	--self:GetOwner():ChatPrint(t)

	local mul = Lerp(t,self.MinFocusMul,self.MaxFocusMul)
	return BaseClass.GetCone(self) * mul or 1
end

function SWEP:GetFocus()
	return math.max(self:GetFocusDecayTime() - CurTime(),0)
end

function SWEP:AddFocus(t)
	local curFocus = self:GetFocus()
	local newFocus = math.min(self.MaxFocusTime,curFocus + t)

	self:SetFocusDecayTime(CurTime() + newFocus)
end

function SWEP:SetFocusDecayTime(t)
	self:SetDTFloat(9, t)
end

function SWEP:GetFocusDecayTime()
	return self:GetDTFloat(9)
end

function SWEP:SecondaryAttack()
end

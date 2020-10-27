AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

SWEP.PrintName = "'Akbar' Assault Rifle"
SWEP.Description =  "Very Accurate. Gets less accurate as you fire"

SWEP.TranslationName = "wep_akbar"
SWEP.TranslationDesc = "wep_d_akbar"

SWEP.Slot = 4
SWEP.Tier = 5
SWEP.SlotPos = 0

SWEP.StatDPS = 3
SWEP.StatDPR = 4
SWEP.StatRange = 3
SWEP.StatSpecial = 3

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50

	SWEP.HUD3DBone = "v_weapon.AK47_Parent"
	SWEP.HUD3DPos = Vector(-1, -4.5, -4)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"
SWEP.UseHands = true

SWEP.ReloadSound = Sound("Weapon_AK47.Clipout")
SWEP.Primary.Sound = Sound("Weapon_AK47.Single")
SWEP.Primary.Damage = 26
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.12

SWEP.Primary.ClipSize = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 5
SWEP.ConeMin = 1.275


SWEP.MinFocusMul = 0.25 --at no focus, this is the modifier on accuracy
SWEP.MaxFocusMul = 1.5 --at full focus, this is the modifier on accuracy
SWEP.MaxFocusTime = 1.66 --amount of "focus" (time) equivalent to full focus
SWEP.AddFocusTime = .5 --amount of "focus" (time) added per shot

--SWEP.HeadshotMulti = 2.5

SWEP.WeightClass = WEIGHT_MEDIUM

SWEP.IronSightsPos = Vector(-6.6, 20, 3.1)

//SWEP.Recoil = 3

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
	return BaseClass.GetCone(self) * Lerp(t,self.MinFocusMul,self.MaxFocusMul)
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

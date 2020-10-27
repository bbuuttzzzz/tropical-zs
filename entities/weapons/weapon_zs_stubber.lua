AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

SWEP.PrintName = "'Stubber' Rifle"
SWEP.Description = "Your basic bolt action sniper rifle, capable of providing good damage on headshots."

SWEP.TranslationName = "wep_stubber"
SWEP.TranslationDesc = "wep_d_stubber"

SWEP.Slot = 1
SWEP.SlotPos = 5

if CLIENT then
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "v_weapon.scout_Parent"
	SWEP.HUD3DPos = Vector(-1, -2.75, -6)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.StatDPS = 1
SWEP.StatDPR = 5
SWEP.StatRange = 5
SWEP.StatSpecial = 1

SWEP.WeightClass = WEIGHT_LIGHT

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_snip_scout.mdl"
SWEP.WorldModel = "models/weapons/w_snip_scout.mdl"
SWEP.UseHands = true

SWEP.ReloadSound = Sound("Weapon_Scout.ClipOut")
SWEP.Primary.Sound = Sound("Weapon_Scout.Single")
SWEP.Primary.Damage = 59
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 1.25
SWEP.ReloadDelay = SWEP.Primary.Delay

SWEP.Primary.ClipSize = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "357"
SWEP.Primary.DefaultClip = 25

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN

SWEP.ConeMax = 3.75
SWEP.ConeMin = 0

SWEP.IronSightsPos = Vector(5.015, -8, 2.52)
SWEP.IronSightsAng = Vector(0, 0, 0)

function SWEP:IsScoped()
	return self:GetIronsights() and self.fIronTime and self.fIronTime + 0.25 <= CurTime()
end

function SWEP:EmitFireSound()
	self:EmitSound(self.Primary.Sound, 85, 100)
end

if CLIENT then
	SWEP.IronsightsMultiplier = 0.25

	function SWEP:GetViewModelPosition(pos, ang)
		if GAMEMODE.DisableScopes then return end

		if self:IsScoped() then
			return pos + ang:Up() * 256, ang
		end

		return BaseClass.GetViewModelPosition(self, pos, ang)
	end

	function SWEP:DrawHUDBackground()
		if GAMEMODE.DisableScopes then return end

		if self:IsScoped() then
			self:DrawRegularScope()
		end
	end
end

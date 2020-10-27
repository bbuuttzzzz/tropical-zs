AddCSLuaFile()

SWEP.PrintName = "'Succubus' SMG"
SWEP.Description =  "Drinks your blood when you reload, fills you up when you fire. Never kills you, Never makes you whole again."

SWEP.TranslationName = "wep_succubus"
SWEP.TranslationDesc = "wep_d_succubus"

SWEP.Slot = 3
SWEP.Tier = 4
SWEP.SlotPos = 0

SWEP.WeightClass = WEIGHT_LIGHT

SWEP.StatDPS = 2
SWEP.StatDPR = 5
SWEP.StatRange = 3
SWEP.StatSpecial = 1

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "v_weapon.TMP_Parent"
	SWEP.HUD3DPos = Vector(-1, -3.5, -1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"
DEFINE_BASECLASS("weapon_zs_base")

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_smg_tmp.mdl"
SWEP.WorldModel = "models/weapons/w_smg_tmp.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("weapons/m4a1/m4a1-1.wav")
SWEP.Primary.Damage = 25
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.08

SWEP.Primary.ClipSize = 40
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_AR2

SWEP.ConeMax = 6.5
SWEP.ConeMin = 3.6

SWEP.ReloadHealthDrain = 0.30 -- frac current health to drink on reload
SWEP.HealPerBullet = 2 -- frac max hp to fill if you hit every bullet in a clip

SWEP.ReloadSpeed = 1

SWEP.MaxStock = 3


SWEP.IronSightsPos = Vector(-7, 3, 2.5)

function SWEP:FinishReload()
	if SERVER then
		local owner = self:GetOwner()

		local dmginfo = DamageInfo()
      dmginfo:SetAttacker(owner)
			--assigning an inflictor here will cause a damage force to occur
      dmginfo:SetDamageType(DMG_GENERIC)
      dmginfo:SetDamage(owner:Health() * self.ReloadHealthDrain)
      dmginfo:SetDamageForce(Vector(0,0,0))
    owner:TakeDamageInfo(dmginfo)
	end

	self:EmitSound("npc/headcrab_poison/ph_poisonbite" .. math.random(1,3) .. ".wav")
	--self:EmitSound("npc/headcrab_poison/ph_pain" .. math.random(1,3) .. ".wav")

	BaseClass.FinishReload(self)
end

function SWEP.BulletCallback(attacker, tr)
	if not SERVER then return end

	local hitent = tr.Entity
	if hitent:IsValidLivingZombie() then
		local swep = attacker:GetActiveWeapon()
		attacker:HealPlayer(attacker, swep.HealPerBullet, 0)
	end
end

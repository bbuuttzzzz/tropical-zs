AddCSLuaFile()
SWEP.Base = "weapon_zs_baserepair"
DEFINE_BASECLASS("weapon_zs_baserepair")

SWEP.PrintName = "Sledgehammer"
SWEP.Description = "A heavy, but powerful melee weapon. Can also repair barricades. Can use repair oomph to empower melee attacks"

SWEP.Tier = 1

SWEP.StatDPS = 5
SWEP.StatDPR = 5
SWEP.StatRange = 1
SWEP.StatSpecial =  1

if CLIENT then
	SWEP.ViewModelFOV = 75
end

SWEP.OomphCost = 12
SWEP.OomphRepairAmount = 150
SWEP.OomphMeleeMultiplier = 2.5
SWEP.RepairAmount = 20

SWEP.HoldType = "melee2"

SWEP.DamageType = DMG_CLUB

SWEP.ViewModel = "models/weapons/v_sledgehammer/c_sledgehammer.mdl"
SWEP.WorldModel = "models/weapons/w_sledgehammer.mdl"
SWEP.UseHands = true

SWEP.MeleeDamage = 50
SWEP.MeleeRange = 64
SWEP.MeleeSize = 1
SWEP.MeleeKnockBack = 125

SWEP.Primary.Delay = 1.3

SWEP.Tier = 2

SWEP.WeightClass = WEIGHT_MEDIUM

SWEP.SwingRotation = Angle(60, 0, -80)
SWEP.SwingOffset = Vector(0, -30, 0)
SWEP.SwingTime = 0.75
SWEP.SwingHoldType = "melee"

SWEP.AllowQualityWeapons = true

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_IMPACT_DELAY, -0.1, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.1, 1)

//try and repair this thing if it's a prop or other repairable
//also use oomph to damage zombies
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if BaseClass.OnMeleeHit(self, hitent, hitflesh, tr) then
		return true
	end

	local owner = self:GetOwner()

	if hitent:IsPlayer() and self:ConsumeOomphCharge() then
		hitent:EmitSound(string.format("npc/dog/dog_pneumatic%d.wav",math.random(1,2)),70, math.random(100,105))
		self.m_Critting = true
		self.MeleeDamage = self.MeleeDamage * self.OomphMeleeMultiplier

		local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetNormal(tr.HitNormal)
			effectdata:SetMagnitude(1)
		util.Effect("nailrepairedoomph", effectdata, true, true)
	end
end


function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	if self.m_Critting then
		self.m_Critting = nil

		self.MeleeDamage = self.MeleeDamage / self.OomphMeleeMultiplier
	end

	BaseClass.PostOnMeleeHit(self, hitent, hitflesh, tr)
end


function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(35, 45))
end

function SWEP:PlayHitSound()
	self:EmitSound("physics/metal/metal_canister_impact_hard"..math.random(3)..".wav", 75, math.Rand(86, 90))
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav", 75, math.Rand(86, 90))
end

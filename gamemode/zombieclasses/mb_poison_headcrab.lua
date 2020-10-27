CLASS.Base = "_base"

CLASS.Name = "Poison Headcrab"
CLASS.TranslationName = "class_poison_headcrab"

CLASS.Type = ZTYPE_MINIBOSS

CLASS.SWEP = "weapon_zsz_poisonheadcrab"
CLASS.Model = Model("models/headcrabblack.mdl")

CLASS.Health = 150
CLASS.Speed = 145
CLASS.JumpPower = 100
CLASS.Points = 5

CLASS.NoFallDamage = true
CLASS.NoFallSlowdown = true

CLASS.IsHeadcrab = true

CLASS.Hull = {Vector(-12, -12, 0), Vector(12, 12, 18.1)}
CLASS.HullDuck = {Vector(-12, -12, 0), Vector(12, 12, 18.1)}
CLASS.ViewOffset = Vector(0, 0, 10)
CLASS.ViewOffsetDucked = Vector(0, 0, 10)
CLASS.StepSize = 8
CLASS.CrouchedWalkSpeed = 1
CLASS.Mass = 40

CLASS.CantDuck = true

CLASS.PainSounds = {"NPC_BlackHeadcrab.Pain"}
CLASS.DeathSounds = {"NPC_BlackHeadcrab.Die"}

CLASS.BloodColor = BLOOD_COLOR_GREEN

local math_random = math.random
local CurTime = CurTime
local math_max = math.max
local math_sin = math.sin
local math_pi = math.pi

local ACT_RUN = ACT_RUN
local STEPSOUNDTIME_NORMAL = STEPSOUNDTIME_NORMAL
local STEPSOUNDTIME_WATER_FOOT = STEPSOUNDTIME_WATER_FOOT
local STEPSOUNDTIME_ON_LADDER = STEPSOUNDTIME_ON_LADDER
local STEPSOUNDTIME_WATER_KNEE = STEPSOUNDTIME_WATER_KNEE

local StepSounds = {
	"npc/headcrab_poison/ph_step1.wav",
	"npc/headcrab_poison/ph_step2.wav",
	"npc/headcrab_poison/ph_step3.wav",
	"npc/headcrab_poison/ph_step4.wav"
}
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	pl:EmitSound(StepSounds[math_random(#StepSounds)], 60)

	return true
end

function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 285 - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 200
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 280
	end

	return 175
end

function CLASS:CalcMainActivity(pl, velocity)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() then
		if wep.ShouldPlayLeapAnimation and wep:ShouldPlayLeapAnimation() then
			return 1, 7
		end

		if wep.ShouldPlaySpitAnimation and wep:ShouldPlaySpitAnimation() then
			return 1, 2
		end
	end

	if pl:OnGround() then
		if velocity:Length2DSqr() > 1 then
			return ACT_RUN, -1
		end

		return 1, 4
	end

	return 1, 6
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local seq = pl:GetSequence()

	if seq == 2 then
		local wep = pl:GetActiveWeapon()
		if wep:IsValid() and wep.Attack2.WindupTime then
			local spitend = wep:GetAttackResolveTime()
			local lerp = 1 - math_max(0, spitend - CurTime()) / wep.Attack2.WindupTime

			if lerp == 1 then
				pl:SetCycle(0.6 + math_sin(CurTime() * math_pi) * 0.1)
			else
				pl:SetCycle(lerp * 0.6)
			end
			pl:SetPlaybackRate(0)

			return true
		end
	elseif seq == 7 then
		local wep = pl:GetActiveWeapon()
		if wep:IsValid() and wep.Attack1.WindupTime then
			local spitend = wep:GetAttackResolveTime()
			local lerp = 1 - math_max(0, spitend - CurTime()) / wep.Attack1.WindupTime

			if lerp == 1 then
				pl:SetCycle(0.7 + math_sin(CurTime() * math_pi) * 0.1)
			else
				pl:SetCycle(lerp * 0.7)
			end
			pl:SetPlaybackRate(0)

			return true
		end
	end
end

if not CLIENT then return end

CLASS.Icon = "zombiesurvival/killicons/poisonheadcrab"

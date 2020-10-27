CLASS.Base = "_base"

CLASS.Name = "Bloated Zombie"
CLASS.TranslationName = "class_bloated_zombie"
CLASS.Type = ZTYPE_NORMAL

CLASS.SWEP = "weapon_zsz_bloatedzombie"
CLASS.Speed = 125
CLASS.Health = 250
CLASS.HealthGrowth = 75
CLASS.Mass = DEFAULT_MASS * 2
CLASS.VoicePitch = 0.6
CLASS.BloodColor = BLOOD_COLOR_GREEN
CLASS.Points = 5

CLASS.Model = Model("models/player/fatty/fatty.mdl")

local math_ceil = math.ceil
local math_random = math.random
local string_format = string.format
local math_Rand = math.Rand

local ACT_HL2MP_IDLE_CROUCH_ZOMBIE = ACT_HL2MP_IDLE_CROUCH_ZOMBIE
local ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01


function CLASS:PlayPainSound(pl)
	pl:EmitSound(string_format("npc/zombie_poison/pz_idle%d.wav", math_random(2, 3)), 72, math_Rand(75, 85))
	pl.NextPainSound = CurTime() + 0.5

	return true
end

function CLASS:CalcMainActivity(pl, velocity)
	if pl:WaterLevel() >= 3 then
		return self.act_Swim, -1
	end

	local wep = pl:GetActiveWeapon()

	--[[
	if wep:IsValid() then
		if wep.IsClimbing and wep:IsClimbing() then
			return self.act_Climb, -1
		elseif wep.IsLeaping and wep:IsLeaping() then
			return self.act_Leap, -1
		elseif wep.IsAlting and wep:IsAlting() and not pl:Crouching() then
			return self.act_Walk - 1 + math_ceil((CurTime() / 3 + pl:EntIndex()) % 3), -1
		end
	end
	]]

	if velocity:Length2DSqr() <= 1 then
		if pl:Crouching() and pl:OnGround() then
			return ACT_HL2MP_IDLE_CROUCH_ZOMBIE, -1
		end

		return self.act_Walk, -1
	end

	if pl:Crouching() and pl:OnGround() then
		return ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 - 1 + math_ceil((CurTime() / 4 + pl:EntIndex()) % 3), -1
	end


	return self.act_Alt, -1
end

if CLIENT then
	CLASS.Icon = "zombiesurvival/killicons/bloatedzombie"
end

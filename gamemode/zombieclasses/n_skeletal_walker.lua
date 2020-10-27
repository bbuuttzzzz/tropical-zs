CLASS.Base = "_base"

CLASS.Name = "Skeletal Walker"
CLASS.TranslationName = "class_skeletal_walker"
CLASS.Type = ZTYPE_NORMAL

CLASS.SWEP = "weapon_zsz_skeletalwalker"
CLASS.Speed = 170
CLASS.Health = 200
CLASS.HealthGrowth = 60
CLASS.Model = Model("models/player/skeleton.mdl")
CLASS.VoicePitch = 0.8
CLASS.BloodColor = -1
CLASS.Points = 5
CLASS.Wave = 2

local ACT_HL2MP_RUN_KNIFE = ACT_HL2MP_RUN_KNIFE
local ACT_HL2MP_WALK_CROUCH_KNIFE = ACT_HL2MP_WALK_CROUCH_KNIFE
local ACT_HL2MP_IDLE_CROUCH_FIST = ACT_HL2MP_IDLE_CROUCH_FIST
local ACT_HL2MP_IDLE_KNIFE = ACT_HL2MP_IDLE_KNIFE

local math_ceil = math.ceil
local math_min = math.min

function CLASS:CalcMainActivity(pl, velocity)
	if pl:WaterLevel() >= 3 then
		return self.act_Swim, -1
	end

	local wep = pl:GetActiveWeapon()
	if wep:IsValid() then
		if wep.IsClimbing and wep:IsClimbing() then
			return self.act_Climb, -1
		elseif wep.IsLeaping and wep:IsLeaping() then
			return self.act_Leap, -1
		elseif wep.IsAlting and wep:IsAlting() and not pl:Crouching() then
			return ACT_HL2MP_RUN_KNIFE, -1
		end
	end

	if velocity:Length2DSqr() <= 1 then
		if pl:Crouching() and pl:OnGround() then
			return ACT_HL2MP_IDLE_CROUCH_FIST, -1
		end

		return self.act_Alt, -1
	end

	if pl:Crouching() and pl:OnGround() then
		return ACT_HL2MP_WALK_CROUCH_KNIFE, -1
	end


	return self.act_Alt, -1
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local len = velocity:Length()
	if len > 1 then
		--pl:SetPlaybackRate(math_min(len / maxseqgroundspeed * 0.666, 3))
		pl:SetPlaybackRate(math_min(len / maxseqgroundspeed, 3))
	else
		pl:SetPlaybackRate(1)
	end

	return true
end

if CLIENT then
	CLASS.Icon = "zombiesurvival/killicons/skeletal_walker"
end

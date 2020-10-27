CLASS.Base = "_base"

CLASS.Name = "Fresh Dead"
CLASS.TranslationName = "class_fresh_dead"
CLASS.Type = ZTYPE_NORMAL

CLASS.SWEP = "weapon_zsz_freshdead"
CLASS.Health = 100
CLASS.HealthGrowth = 25
CLASS.Speed = 190
CLASS.Points = 3

CLASS.Model = false
CLASS.UsePlayerModel = true

CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

CLASS.VoicePitch = 0.65

local ACT_HL2MP_RUN_KNIFE = ACT_HL2MP_RUN_KNIFE
local ACT_HL2MP_ZOMBIE_SLUMP_RISE = ACT_HL2MP_ZOMBIE_SLUMP_RISE

local math_ceil = math.ceil
local math_Clamp = math.Clamp

function CLASS:KnockedDown(pl, status, exists)
	pl:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
end

function CLASS:CalcMainActivity(pl, velocity)

	local revive = pl.Revive
	if revive and revive:IsValid() then
		return ACT_HL2MP_ZOMBIE_SLUMP_RISE, -1
	end

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
			return self.act_Crouch, -1
		end

		return self.act_Walk, -1
	end

	if pl:Crouching() and pl:OnGround() then
		return self.act_CrouchWalk - 1 + math_ceil((CurTime() / 4 + pl:EntIndex()) % 3), -1
	end


	return self.act_Alt, -1
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local revive = pl.Revive
	if revive and revive:IsValid() then
		pl:SetCycle(0.4 + (1 - math_Clamp((revive:GetReviveTime() - CurTime()) / revive.AnimTime, 0, 1)) * 0.6)
		pl:SetPlaybackRate(0)
		return true
	end
end

if CLIENT then
	CLASS.Icon = "zombiesurvival/killicons/fresh_dead"

	function CLASS:PrePlayerDraw(pl)
		render.SetColorModulation(0.5, 0.9, 0.5)
	end

	function CLASS:PostPlayerDraw(pl)
		render.SetColorModulation(1, 1, 1)
	end
end

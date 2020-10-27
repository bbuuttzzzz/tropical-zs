CLASS.Base = "_base"

CLASS.Name = "Burnt Brisket"
CLASS.TranslationName = "class_burnt_brisket"
CLASS.Type = ZTYPE_BOSS

CLASS.Model = Model("models/player/fatty/fatty.mdl")
--CLASS.OverrideModel = Model("models/Zombie/Poison.mdl")
--CLASS.NoHideMainModel = true

CLASS.SWEP = "weapon_zsz_burntbrisket"
CLASS.Speed = 135
CLASS.Health = 5500
CLASS.ModelScale = 1.3
CLASS.StepScale = 1.2
CLASS.act_Idle = ACT_HL2MP_RUN_ZOMBIE
CLASS.Points = 20

local math_ceil = math.ceil
local math_min = math.min
local math_random = math.random
local string_format = string.format
local math_Rand = math.Rand




function CLASS:PlayDeathSound(pl)
	pl:EmitSound(string_format("vehicles/v8/vehicle_rollover%d.wav", math_random(1, 2)), 180, math_Rand(40, 60) )
	return true
end

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 then
		pl:EmitSound(string_format("physics/concrete/boulder_impact_hard%d.wav", math_random(1, 2)), 85, math_random(75, 125))
	else
		pl:EmitSound(string_format("physics/concrete/boulder_impact_hard%d.wav", math_random(3, 4)), 85, math_random(70, 80))
	end

	return true
end

function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL, true)
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_RELOAD then
		return ACT_INVALID
	end
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)

	pl:SetPlaybackRate(0.5)
	return true
	/*
	local len2d = velocity:Length()
	if len2d > 1 then
		local wep = pl:GetActiveWeapon()
		pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed * 0.666, 3))
	else
		pl:SetPlaybackRate(1)
	end

	return true
	*/
end
function CLASS:ManipulateOverrideModel(overridestatus)

end

if SERVER then
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
		pl:FakeDeath(pl:LookupSequence("death_0"..math.random(4)), self.ModelScale)

		return true
	end

	function CLASS:PlayPainSound(pl)
		pl:EmitSound("plats/elevbell1.wav", 180, math_Rand(60, 90) )
		pl.NextPainSound = CurTime() + 0.2
		return true
	end

end




if CLIENT then
	CLASS.Icon = "tropical/killicons/burnt_brisket"

	local matFlesh = Material("Models/Charple/charple1_sheet")
	function CLASS:PrePlayerDraw(pl)
		render.ModelMaterialOverride(matFlesh)
	end

	function CLASS:PostPlayerDraw(pl)
		render.ModelMaterialOverride()
	end
	--{5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21}
	function CLASS:BuildBonePositions(pl)
		local bones = {
			[1] = 0.75,
			[0] = 0.666,
			[2] = 0.75,
			[3] = 0.75,
			[4] = 0.75,
			[5] = 0.75,
			[6] = 0.75,
			[8] = 0.75,
			[9] = 0.5,
			[10] = 0.5,
			[11] = 0.6,
			[12] = 0.9,
			[13] = 0,
			[14] = 0,
			[15] = 1.5,
			[28] = 1.5
		}
		local v = Vector(1,1,1)
		for bone, s in pairs(bones) do
			pl:ManipulateBoneScale(bone,v * s)
		end

		pl:ManipulateBonePosition(17, Vector(5, 0,0))
		pl:ManipulateBonePosition(16, Vector(5, 0,0))

		pl:ManipulateBonePosition(29, Vector(5, 0,0))
		pl:ManipulateBonePosition(30, Vector(5, 0,0))
	end
end

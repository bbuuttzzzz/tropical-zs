CLASS.Base = "_base"

CLASS.Name = "Demonic Gorilla"
CLASS.TranslationName = "class_demonic_gorilla"
CLASS.Type = ZTYPE_BOSS

CLASS.Model = Model("models/Zombie/Poison.mdl")

CLASS.SWEP = "weapon_zsz_demonicgorilla"
CLASS.Speed = 200
CLASS.Health = 1000
--CLASS.ModelScale = 1.3
--CLASS.StepScale = 1.2
CLASS.Points = 20

local math_ceil = math.ceil
local math_min = math.min
local math_random = math.random
local string_format = string.format
local math_Rand = math.Rand


function CLASS:PlayPainSound(pl)
	pl:EmitSound("plats/elevbell1.wav", 180, math_Rand(60, 90) )
	pl.NextPainSound = CurTime() + 0.2
	return true
end

function CLASS:PlayDeathSound(pl)
	pl:EmitSound(string_format("vehicles/v8/vehicle_rollover%d.wav", math_random(1, 2)), 180, math_Rand(40, 60) )
	return true
end

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 then
		pl:EmitSound(string_format("physics/concrete/boulder_impact_hard%d.wav", math_random(1, 2)), 85, math_random(70, 80))
	else
		pl:EmitSound(string_format("physics/concrete/boulder_impact_hard%d.wav", math_random(3, 4)), 85, math_random(70, 80))
	end

	return true
end

function CLASS:CalcMainActivity(pl, velocity)
	if velocity:Length2DSqr() <= 1 then
		return ACT_IDLE, -1
	end

	return ACT_WALK, -1
end

function CLASS:DoAnimationEvent(pl, event, data)

	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MELEE_ATTACK1, true)
		return ACT_INVALID
	end
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local len2d = velocity:Length()
	if len2d > 1 then
		local wep = pl:GetActiveWeapon()
		pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed * 0.666, 3) * 0.5)
	else
		pl:SetPlaybackRate(1 * 0.5)
	end

	return true
end


if CLIENT then
	CLASS.Icon = "tropical/killicons/demonic_gorilla"

	local matFlesh = Material("models/charple/charple1_sheet")
	function CLASS:PrePlayerDraw(pl)
		render.ModelMaterialOverride(matFlesh)
	end

	function CLASS:PostPlayerDraw(pl)
		render.ModelMaterialOverride()
	end

	local bones = {5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21}
	function CLASS:BuildBonePositions(pl)

		local v = Vector(2,2,2)
		for _, bone in pairs(bones) do
			pl:ManipulateBoneScale(bone,v)
		end
	end

end

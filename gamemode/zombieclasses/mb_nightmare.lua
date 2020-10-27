CLASS.Base = "_base"

CLASS.Name = "Nightmare"
CLASS.TranslationName = "class_nightmare"

CLASS.Type = ZTYPE_MINIBOSS
CLASS.IsDefault = true --this is the default miniboss

CLASS.SWEP = "weapon_zsz_nightmare"
CLASS.Health = 800
CLASS.Speed = 195
CLASS.Points = 10

CLASS.Model = Model("models/player/zombie_classic_hbfix.mdl")
CLASS.OverrideModel = Model("models/player/charple.mdl")

local StepSounds = {
	"npc/zombie/foot1.wav",
	"npc/zombie/foot2.wav",
	"npc/zombie/foot3.wav"
}

CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

local math_ceil = math.ceil
local math_min = math.min
local math_Rand = math.Rand
local math_random = math.random
local CurTime = CurTime

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
			return self.act_Walk - 1 + math_ceil((CurTime() / 3 + pl:EntIndex()) % 3), -1
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
	local len2d = velocity:Length2D()
	if len2d > 0.5 then
		pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed, 3))
	else
		pl:SetPlaybackRate(1)
	end

	return true
end

function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:DoZombieAttackAnim(data)
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_RELOAD then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
		return ACT_INVALID
	end
end

if not CLIENT then return end

CLASS.Icon = "zombiesurvival/killicons/zombie"


CLASS.Icon = "zombiesurvival/killicons/nightmare2"

local function CreateBoneOffsets(pl)
	pl.m_NightmareBoneOffsetsNext = CurTime() + math_Rand(0.02, 0.1)

	local offsets = {}
	local angs = {}
	for i=1, pl:GetBoneCount() - 1 do
		if math_random(3) == 3 then
			offsets[i] = VectorRand():GetNormalized() * math.Rand(0.5, 3)
		end
		if math_random(5) == 5 then
			angs[i] = Angle(math_Rand(-5, 5), math_Rand(-15, 15), math_Rand(-5, 5))
		end
	end
	pl.m_NightmareBoneOffsets = offsets
	pl.m_NightmareBoneAngles = angs
end

function CLASS:BuildBonePositions(pl)
	if not pl.m_NightmareBoneOffsets or CurTime() >= pl.m_NightmareBoneOffsetsNext then
		CreateBoneOffsets(pl)
	end

	local offsets = pl.m_NightmareBoneOffsets
	local angs = pl.m_NightmareBoneAngles
	for i=1, pl:GetBoneCount() - 1 do
		if offsets[i] then
			pl:ManipulateBonePosition(i, offsets[i])
		end
		if angs[i] then
			pl:ManipulateBoneAngles(i, angs[i])
		end
	end
end

function CLASS:PrePlayerDraw(pl)
	render.SetColorModulation(0.1, 0.1, 0.1)
end

function CLASS:PostPlayerDraw(pl)
	render.SetColorModulation(1, 1, 1)
end

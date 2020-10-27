CLASS.Base = "_base"

CLASS.Name = "Poison Zombie"
CLASS.TranslationName = "class_poison_zombie"
CLASS.Type = ZTYPE_NORMAL

CLASS.Model = Model("models/Zombie/Poison.mdl")

CLASS.Health = 300
CLASS.HealthGrowth = 100
CLASS.Speed = 150
CLASS.JumpPower = DEFAULT_JUMP_POWER * 1.081
CLASS.SWEP = "weapon_zsz_poisonzombie"
CLASS.Points = 5


CLASS.PainSounds = {"npc/zombie_poison/pz_pain1.wav", "npc/zombie_poison/pz_pain2.wav", "npc/zombie_poison/pz_pain3.wav"}
CLASS.DeathSounds = {"npc/zombie_poison/pz_die1.wav", "npc/zombie_poison/pz_die2.wav"}
CLASS.VoicePitch = 0.6
CLASS.ViewOffset = Vector(0, 0, 50)
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 64)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 35)}

CLASS.StepScale = 0.66


local math_random = math.random

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 and math_random(3) < 3 then
		pl:EmitSound("npc/zombie_poison/pz_right_foot1.wav")
	else
		pl:EmitSound("npc/zombie_poison/pz_left_foot1.wav")
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

if not CLIENT then return end

CLASS.Icon = "zombiesurvival/killicons/poisonzombie"

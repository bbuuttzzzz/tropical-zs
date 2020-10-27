CLASS.Name = "basezombie"
CLASS.TranslationName = "class_zombie"
CLASS.Description = "description_zombie"
CLASS.Help = "controls_zombie"

--CLASS.BetterVersion = "Eradicator"

CLASS.Wave = 1
CLASS.Unlocked = true
CLASS.Order = 0

CLASS.Disabled = true
CLASS.Hidden = true

CLASS.Health = 225
CLASS.Speed = 160

CLASS.Points = 5 --CLASS.Health/GM.HumanoidZombiePointRatio

CLASS.SWEP = "weapon_zsz_basezombie"

CLASS.Model = Model("models/player/zombie_classic_hbfix.mdl")

CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

CLASS.VoicePitch = 0.65

CLASS.StepScale = 1 --bigger value means larger steps
CLASS.ModelScale = 1

--optional parameters
--[[
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 58)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 32)}
CLASS.ViewOffset = Vector(0, 0, 50)
CLASS.ViewOffsetDucked = Vector(0, 0, 24)

CLASS.NoFallDamage = false
CLASS.NoFallSlowdown = false
]]

CLASS.act_Swim = ACT_HL2MP_SWIM_PHYSGUN
CLASS.act_Alt = ACT_HL2MP_RUN_ZOMBIE
CLASS.act_Crouch = ACT_HL2MP_IDLE_CROUCH_ZOMBIE
CLASS.act_Idle = ACT_HL2MP_IDLE_ZOMBIE
CLASS.act_CrouchWalk = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01
CLASS.act_Walk = ACT_HL2MP_WALK_ZOMBIE_01
CLASS.act_Climb = ACT_ZOMBIE_CLIMB_UP
CLASS.act_Leap = ACT_ZOMBIE_LEAPING

--don't touch
local CurTime = CurTime
local math_random = math.random
local math_ceil = math.ceil
local math_Clamp = math.Clamp
local math_min = math.min
local math_max = math.max
local GESTURE_SLOT_ATTACK_AND_RELOAD = GESTURE_SLOT_ATTACK_AND_RELOAD
local PLAYERANIMEVENT_ATTACK_PRIMARY = PLAYERANIMEVENT_ATTACK_PRIMARY
local ACT_GMOD_GESTURE_RANGE_ZOMBIE = ACT_GMOD_GESTURE_RANGE_ZOMBIE
local ACT_INVALID = ACT_INVALID
local PLAYERANIMEVENT_RELOAD = PLAYERANIMEVENT_RELOAD
local ACT_GMOD_GESTURE_TAUNT_ZOMBIE = ACT_GMOD_GESTURE_TAUNT_ZOMBIE
local STEPSOUNDTIME_NORMAL = STEPSOUNDTIME_NORMAL
local STEPSOUNDTIME_WATER_FOOT = STEPSOUNDTIME_WATER_FOOT
local STEPSOUNDTIME_ON_LADDER = STEPSOUNDTIME_ON_LADDER
local STEPSOUNDTIME_WATER_KNEE = STEPSOUNDTIME_WATER_FOOT
local HITGROUP_HEAD = HITGROUP_HEAD
local HITGROUP_LEFTLEG = HITGROUP_LEFTLEG
local HITGROUP_RIGHTLEG = HITGROUP_RIGHTLEG
local DMG_ALWAYSGIB = DMG_ALWAYSGIB
local DMG_BURN = DMG_BURN
local DMG_CRUSH = DMG_CRUSH
local bit_band = bit.band

function CLASS:KnockedDown(pl, status, exists)
	pl:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
end

function CLASS:IsBoss()
	return self.Type == ZTYPE_BOSS
end

function CLASS:CalcMaxHealth()
	return self.Health + (self.HealthGrowth and (GAMEMODE:GetNextActiveWave() - 1) * self.HealthGrowth or 0)
end

--CallZombieFunction functions
function CLASS:Move(pl, mv)
	local wep = pl:GetActiveWeapon()
	if wep.Move and wep:Move(mv) then
		return true
	end
end
function CLASS:AltUse(pl)
	local wep = pl:GetActiveWeapon()
	if wep.AltUse then
		wep:AltUse()
	end
end
function CLASS:AltRelease(pl)
	local wep = pl:GetActiveWeapon()
	if wep.AltRelease then
		wep:AltRelease()
	end
end


local StepSounds = {
	"npc/zombie/foot1.wav",
	"npc/zombie/foot2.wav",
	"npc/zombie/foot3.wav"
}
local ScuffSounds = {
	"npc/zombie/foot_slide1.wav",
	"npc/zombie/foot_slide2.wav",
	"npc/zombie/foot_slide3.wav"
}
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if math_random() < 0.15 then
		pl:EmitSound(ScuffSounds[math_random(#ScuffSounds)], 70)
	else
		pl:EmitSound(StepSounds[math_random(#StepSounds)], 70)
	end

	return true
end

-- Sound scripts are LITERALLY 100x slower than raw file input. Test it yourself if you don't believe me.
--[[function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 then
		if math_random() < 0.15 then
			pl:EmitSound("Zombie.ScuffLeft")
		else
			pl:EmitSound("Zombie.FootstepLeft")
		end
	else
		if math_random() < 0.15 then
			pl:EmitSound("Zombie.ScuffRight")
		else
			pl:EmitSound("Zombie.FootstepRight")
		end
	end

	return true
end]]

function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	local sc = self.StepScale

	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 625 * sc - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 600 * sc
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 750 * sc
	end

	return 450 * sc
end

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
			return self.act_Alt, -1
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

	return self.act_Walk - 1 + math_ceil((CurTime() / 3 + pl:EntIndex()) % 3), -1
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local len2d = velocity:Length()
	if len2d > 1 then
		local wep = pl:GetActiveWeapon()
		pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed * 0.666, 3))
	else
		pl:SetPlaybackRate(1)
	end

	return true
end

--TODO figure out what this actually does
function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:DoZombieAttackAnim(data)
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_RELOAD then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
		return ACT_INVALID
	end
end


function CLASS:DoesntGiveFear(pl)
	return false
end

function CLASS:Describe()
	//input.LookupBinding()
	/*
		so you have this table description that gets returned. each entry in this
		table gets added as its own richly formatted section. $ is the escape char
		and can hold the following values:
			$stats: gets put at the very start of the description with no header.
			$attack1/$attack2/$reload/$sprint: the header name gets replaced by the name
				of the key the player has bound to attack1/attack2/reload/sprint.
		all other entires get added with text of the same key added
	*/

	local wep = weapons.Get(self.SWEP)
	local description = {}

	description["$stats"] = self:DescribeStats()

	--don't need to check if these exist, will set to nil if it doesn't
	description["$attack1"] = wep:DescribeAttack(wep.Attack1)
	description["$attack2"] = wep:DescribeAttack(wep.Attack2)
	description["$reload"] = wep:DescribeAttack(wep.Attack3)
	description["$sprint"] = wep:DescribeAlt()

	return description
end

function CLASS:DescribeStats()
	local wep = weapons.GetStored(self.SWEP)

	txt = table.concat({
		translate.Format("health_x",self:CalcMaxHealth()), "\n",
		translate.Format("speed_x", self.Speed) , "\n",
		((wep.CanClimb) and (translate.Get("can_climb") .. "\n") or (""))
	})

	return txt
end

if SERVER then
	function CLASS:ProcessDamage(pl, dmginfo)
		local wep = pl:GetActiveWeapon()
		if wep.IsAlting and wep:IsAlting() then
			if wep.Alt.DamageTakenMul then
				dmginfo:SetDamage(dmginfo:GetDamage() * wep.Alt.DamageTakenMul)
			end

			if wep.Alt.DamageTakenStatus then
				pl:GiveStatus(wep.Alt.DamageTakenStatus, wep.Alt.DamageTakenStatusDuration)
				--note here that duration defaults to nil if not supplied
			end
		end
	end
end

if CLIENT then
	CLASS.Icon = "zombiesurvival/killicons/zombie"

	function CLASS:MakeStillIcon()
		local name = "StillMaterial" .. self.Name
		local data = {
			["$basetexture"] = self.Icon,
			["$nolod"] = 1,
			["$nomip"] = 1,
			["$ignorez"] = 1,
			["$translucent"] = 1,
			["$vertexalpha"] = 1,
			["$vertexcolor"] = 1
		}

		self.StillMaterial = CreateMaterial(name,"UnlitGeneric",data)
	end
end

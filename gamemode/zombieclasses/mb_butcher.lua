CLASS.Base = "_base"

CLASS.Name = "Butcher"
CLASS.TranslationName = "class_butcher"
CLASS.Type = ZTYPE_MINIBOSS

CLASS.SWEP = "weapon_zsz_butcher"
CLASS.Speed = 200
CLASS.Health = 600
CLASS.Points = 10

CLASS.Model = Model("models/player/corpse1.mdl")

CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

local math_ceil = math.ceil
local math_random = math.random

local StepLeftSounds = {
	"npc/fast_zombie/foot1.wav",
	"npc/fast_zombie/foot2.wav"
}
local StepRightSounds = {
	"npc/fast_zombie/foot3.wav",
	"npc/fast_zombie/foot4.wav"
}
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 then
		pl:EmitSound(StepLeftSounds[math_random(#StepLeftSounds)], 70)
	else
		pl:EmitSound(StepRightSounds[math_random(#StepRightSounds)], 70)
	end

	return true
end

local ACT_HL2MP_SWIM_MELEE = ACT_HL2MP_SWIM_MELEE
local ACT_HL2MP_IDLE_CROUCH_MELEE = ACT_HL2MP_IDLE_CROUCH_MELEE
local ACT_HL2MP_WALK_CROUCH_MELEE = ACT_HL2MP_WALK_CROUCH_MELEE
local ACT_HL2MP_IDLE_MELEE = ACT_HL2MP_IDLE_MELEE
local ACT_HL2MP_RUN_ZOMBIE = ACT_HL2MP_RUN_ZOMBIE
local ACT_HL2MP_RUN_MELEE = ACT_HL2MP_RUN_MELEE

function CLASS:CalcMainActivity(pl, velocity)
	if pl:WaterLevel() >= 3 then
		return ACT_HL2MP_SWIM_MELEE, -1
	end

	local wep = pl:GetActiveWeapon()
	if wep:IsValid() then
		if wep.IsAlting and wep:IsAlting() and not pl:Crouching() then
			return self.act_Alt, -1
		end
	end

	if velocity:Length2DSqr() <= 1 then
		if pl:Crouching() and pl:OnGround() then
			return ACT_HL2MP_IDLE_CROUCH_MELEE, -1
		end

		return ACT_HL2MP_IDLE_MELEE, -1
	end

	if pl:Crouching() and pl:OnGround() then
		return ACT_HL2MP_WALK_CROUCH_MELEE, -1
	end


	return ACT_HL2MP_RUN_MELEE, -1
end

function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE, true)
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_RELOAD then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
		return ACT_INVALID
	end
end

if CLIENT then
	CLASS.Icon = "zombiesurvival/killicons/butcher"

	local render_SetMaterial = render.SetMaterial
	local render_DrawSprite = render.DrawSprite
	local angle_zero = angle_zero
	local LocalToWorld = LocalToWorld

	local colGlow = Color(235, 50, 0)
	local matGlow = Material("sprites/glow04_noz")
	local vecEyeLeft = Vector(4, -4.6, -1)
	local vecEyeRight = Vector(4, -4.6, 1)

	function CLASS:PrePlayerDraw(pl)
		render.SetColorModulation(1, 0.5, 0.5)
	end

	function CLASS:PostPlayerDraw(pl)
		render.SetColorModulation(1, 1, 1)

		if pl == MySelf and not pl:ShouldDrawLocalPlayer() or pl.SpawnProtection then return end

		local pos, ang = pl:GetBonePositionMatrixed(6)
		if pos then
			render_SetMaterial(matGlow)
			render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 4, 4, colGlow)
			render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 4, 4, colGlow)
		end
	end
end

CLASS.Base = "_base"

CLASS.Name = "Flesh Crab"
CLASS.TranslationName = "class_flesh_crab"

CLASS.Type = ZTYPE_NORMAL

CLASS.SWEP = "weapon_zsz_fleshcrab"
CLASS.Model = Model("models/headcrab.mdl")

CLASS.Health = 40
CLASS.HealthGrowth = 10
CLASS.Speed = 175
CLASS.JumpPower = 100
CLASS.Points = 2

CLASS.NoFallDamage = true
CLASS.NoFallSlowdown = true

CLASS.IsHeadcrab = true

CLASS.Hull = {Vector(-12, -12, 0), Vector(12, 12, 18.1)}
CLASS.HullDuck = {Vector(-12, -12, 0), Vector(12, 12, 18.1)}
CLASS.ViewOffset = Vector(0, 0, 10)
CLASS.ViewOffsetDucked = Vector(0, 0, 10)
CLASS.StepSize = 8
CLASS.CrouchedWalkSpeed = 1
CLASS.Mass = 16

CLASS.CantDuck = true

CLASS.PainSounds = {"NPC_FastHeadcrab.Pain"}
CLASS.DeathSounds = {"NPC_FastHeadcrab.Die"}

CLASS.BloodColor = BLOOD_COLOR_YELLOW

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	return true
end

function CLASS:CalcMainActivity(pl, velocity)
	if pl:OnGround() then
		if velocity:Length2DSqr() > 1 then
			return ACT_RUN, -1
		end

		return 1, 1
	end

	if pl:WaterLevel() >= 3 then
		return 1, 9
	end

	return 1, 3
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local seq = pl:GetSequence()
	if seq == 3 then
		if not pl.m_PrevFrameCycle then
			pl.m_PrevFrameCycle = true
			pl:SetCycle(0)
		end

		pl:SetPlaybackRate(1)

		return true
	elseif pl.m_PrevFrameCycle then
		pl.m_PrevFrameCycle = nil
	end
end

function CLASS:ShouldDrawLocalPlayer(pl)
	local wep = pl:GetActiveWeapon()
	return wep and wep:IsValid() and wep:GetIsPlacing() or nil
end

if not CLIENT then return end

CLASS.Icon = "tropical/killicons/flesh_crab"

local matFlesh = Material("models/flesh")
function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matFlesh)
end

function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
end

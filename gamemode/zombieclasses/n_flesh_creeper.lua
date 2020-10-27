CLASS.Base = "_base"

CLASS.Name = "Flesh Creeper"
CLASS.TranslationName = "class_flesh_creeper"
CLASS.Type = ZTYPE_NORMAL

CLASS.SWEP = "weapon_zsz_fleshcreeper"
CLASS.Speed = 160

CLASS.Disabled = true
CLASS.Hidden = true

CLASS.Health = 150
CLASS.JumpPower = 220

CLASS.Model = Model("models/antlion.mdl")
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 36)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 36)}
CLASS.ViewOffset = Vector(0, 0, 35.5)
CLASS.ViewOffsetDucked = Vector(0, 0, 35.5)
CLASS.PainSounds = {Sound("npc/barnacle/barnacle_pull1.wav"), Sound("npc/barnacle/barnacle_pull2.wav"), Sound("npc/barnacle/barnacle_pull3.wav"), Sound("npc/barnacle/barnacle_pull4.wav")}
CLASS.DeathSounds = {Sound("npc/barnacle/barnacle_die1.wav"), Sound("npc/barnacle/barnacle_die2.wav")}
CLASS.BloodColor = BLOOD_COLOR_YELLOW

CLASS.ModelScale = 0.65

local ACT_RUN = ACT_RUN

local math_ceil = math.ceil

function CLASS:PlayerFootstep()
end

function CLASS:CalcMainActivity(pl, velocity)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.IsInAttackAnim then
		if wep:IsInAttackAnim() then
			return 1, 14
		end

		if wep:GetHoldingRightClick() then
			return 1, 21
		end
	end

	if wep.IsAlting and wep:IsAlting() then
		return ACT_GLIDE, -1
	end

	if velocity:Length2DSqr() > 1 then
		--[[if pl:Crouching() and pl:OnGround() then
			return 1, 17
		else]]
			return 1, 4
		--[[end
	elseif pl:Crouching() and pl:OnGround() then
		pl.CalcSeqOverride = 40]]
	end


	return 1, 2
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.IsInAttackAnim then
		if wep:IsInAttackAnim() then
			pl:SetPlaybackRate(0)
			pl:SetCycle(1 - (wep:GetAttackAnimTime() - CurTime()) / wep.Primary.Delay)

			return true
		elseif wep:GetHoldingRightClick() then
			pl:SetPlaybackRate(0)

			local delta = CurTime() - wep:GetRightClickStart()
			if delta > 1 then
				--pl:SetCycle(0.333 + (delta * 3 % 1) * 0.2)
				pl:SetCycle(0.5 + math_sin(delta * 12) * 0.05)
			else
				--pl:SetCycle(delta / 3)
				pl:SetCycle(delta / 2)
			end

			return true
		end
	end

	if velocity:Length2DSqr() >= 256 then
		GAMEMODE.BaseClass.UpdateAnimation(GAMEMODE.BaseClass, pl, velocity, maxseqgroundspeed)

		--[[local dir = Vector(0, 0, 0)
		dir:Set(velocity)
		dir.z = 0
		dir:Normalize()
		local aimdir = pl:GetAimVector()
		aimdir.z = 0
		aimdir:Normalize()

		if dir:Dot(aimdir) >= 0.5 then
			pl:SetPlaybackRate(pl:GetPlaybackRate() / self.ModelScale / 2)
		else]]
			pl:SetPlaybackRate(pl:GetPlaybackRate() / self.ModelScale)
		--end

		--[[if pl:Crouching() then
			pl:SetPoseParameter("move_yaw", 0)
		end]]

		return true
	end

	--[[if pl:Crouching() then
		pl:SetCycle(0.5 + math.sin(CurTime() * 2) * 0.025)
		pl:SetPlaybackRate(0)

		return true
	end]]

	return true
end

if SERVER then
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
		local ent = pl:FakeDeath(pl:LookupSequence("Flip1"), self.ModelScale, math.Rand(0.45, 0.5))
		if ent:IsValid() then
			ent:SetMaterial("models/flesh")
		end

		return true
	end
end

if CLIENT then
	CLASS.Icon = "zombiesurvival/killicons/fleshcreeper"

	local matFlesh = Material("models/flesh")
	function CLASS:PrePlayerDraw(pl)
		render.ModelMaterialOverride(matFlesh)
	end

	function CLASS:PostPlayerDraw(pl)
		render.ModelMaterialOverride()
	end
end

function CLASS:ShouldDrawLocalPlayer()
	return true
end

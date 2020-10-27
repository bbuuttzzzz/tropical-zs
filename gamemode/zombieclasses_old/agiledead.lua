CLASS.Base = "freshdead"

CLASS.Name = "Agile Dead"
CLASS.TranslationName = "class_agile_dead"
CLASS.Description = "description_agile_dead"
CLASS.Help = "controls_agile_dead"

--CLASS.BetterVersion = "Fast Zombie"

CLASS.SWEP = "weapon_zs_agiledead"

CLASS.Unlocked = true

CLASS.Health = 125
CLASS.Points = CLASS.Health/GM.NoHeadboxZombiePointRatio
CLASS.Speed = 195

CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 58)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 32)}
CLASS.ViewOffset = Vector(0, 0, 50)
CLASS.ViewOffsetDucked = Vector(0, 0, 24)

CLASS.UsePlayerModel = true
CLASS.UsePreviousModel = false

if SERVER then
	function CLASS:OnKilled() end
end

local ACT_ZOMBIE_CLIMB_UP = ACT_ZOMBIE_CLIMB_UP

local math_Clamp = math.Clamp
local math_min = math.min

if SERVER then
	--function CLASS:AltUse(pl) end
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo) end
end


function CLASS:ScalePlayerDamage(pl, hitgroup, dmginfo)
	return true
end

function CLASS:IgnoreLegDamage(pl, dmginfo)
	return true
end

function CLASS:CalcMainActivity(pl, velocity)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetClimbing and wep:GetClimbing() then
		return ACT_ZOMBIE_CLIMB_UP, -1
	end

	return self.BaseClass.CalcMainActivity(self, pl, velocity)
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetClimbing and wep:GetClimbing() then
		local vel = pl:GetVelocity()
		local speed = vel:LengthSqr()
		if speed > 64 then
			pl:SetPlaybackRate(math_Clamp(speed / 3600, 0, 1) * (vel.z < 0 and -1 or 1) * 0.25)
		else
			pl:SetPlaybackRate(0)
		end

		return true
	end

		return self.BaseClass.UpdateAnimation(self, pl, velocity, maxseqgroundspeed)
end


if not CLIENT then return end

CLASS.Icon = "zombiesurvival/killicons/fresh_dead"

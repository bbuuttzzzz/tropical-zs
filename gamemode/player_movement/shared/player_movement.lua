--CACHED GLOBALS
local math_min = math.min
local math_clamp = math.Clamp
local curtime = CurTime

local TEAM_HUMAN = TEAM_HUMAN

local GM_MaxLegDamage = GM.MaxLegDamage

local M_Entity = FindMetaTable("Entity")
local M_Player = FindMetaTable("Player")
local M_CMoveData = FindMetaTable("CMoveData")

local E_GetTable = M_Entity.GetTable
local E_GetDTFloat = M_Entity.GetDTFloat
local E_GetDTBool = M_Entity.GetDTBool
local P_Team = M_Player.Team
local P_CallZombieFunction1 = M_Player.CallZombieFunction1
local P_GetLegDamage = M_Player.GetLegDamage
local P_GetBarricadeGhosting = M_Player.GetBarricadeGhosting
local P_GetActiveWeapon = M_Player.GetActiveWeapon
local M_SetVelocity = M_CMoveData.SetVelocity
local M_GetVelocity = M_CMoveData.GetVelocity
local M_SetMaxSpeed = M_CMoveData.SetMaxSpeed
local M_GetMaxSpeed = M_CMoveData.GetMaxSpeed
local M_SetMaxClientSpeed = M_CMoveData.SetMaxClientSpeed
local M_GetMaxClientSpeed = M_CMoveData.GetMaxClientSpeed
local M_GetForwardSpeed = M_CMoveData.GetForwardSpeed
local M_GetSideSpeed = M_CMoveData.GetSideSpeed

function GM:SetupMove(pl, move, cmd)
end

local fw, sd, pt, vel, mul, phase
function GM:Move(pl, move)
	pt = E_GetTable(pl)

	if P_Team(pl) == TEAM_HUMAN then
		if P_GetBarricadeGhosting(pl) and not E_GetDTBool(pl, 1) then
			-- Use 7, because friction will amount this to a velocity of 1 roughly.
			phaseFrac = math.max(0,(E_GetDTFloat(pl, DT_PLAYER_PHASE_DECAY) - curtime())/self.PhaseDecayDuration)
			M_SetMaxClientSpeed(move, math_clamp(36 + ((pt.PhaseSpeedInitial or self.DefaultStartPhaseSpeed)-36)*phaseFrac,7,M_GetMaxClientSpeed(move)))
		elseif not pt.BackpedalPenaltyMul or pt.BackpedalPenaltyMul > 0 then
			fw = M_GetForwardSpeed(move)
			if fw < 0 then
				sd = M_GetSideSpeed(move)
				if sd < 0 then sd = -sd end

				if sd > fw then
					M_SetMaxClientSpeed(move, M_GetMaxClientSpeed(move) * (1 - (pt.BackpedalPenaltyMul or 1) * (P_GetActiveWeapon(pl).IsMelee and 0.25 or 0.5)))
				end
			end
		end
	else
		if pt.SpawnProtection then
			M_SetMaxSpeed(move, M_GetMaxSpeed(move) * 1.15)
			M_SetMaxClientSpeed(move, M_GetMaxClientSpeed(move) * 1.15)
		end

		if P_CallZombieFunction1(pl, "Move", move) then return end
	end

	legdmg = P_GetLegDamage(pl)
	if legdmg > 0 then
		M_SetMaxClientSpeed(move, M_GetMaxClientSpeed(move) * (1 - math_min(1, legdmg / GM_MaxLegDamage)))
	end
end

local reduceFrac = 0.3
local targetSpeed, currentSpeed, mul
function GM:FinishMove(pl, move)
	pt = E_GetTable(pl)

	-- ~Simple~ Complicated anti bunny hopping. Flag is set in OnPlayerHitGround
	-- if player lands with more speed than max movement speed, the player loses
	-- reduceFrac% of the amount over the normal max (humans have this speed locked at 250)
	if pt.LandSlow then
		pt.LandSlow = false

		vel = M_GetVelocity(move)

		targetSpeed = (P_Team(pl) == TEAM_HUMAN) and 250 or M_GetMaxSpeed(move)
		currentSpeed = vel:Length()


		if targetSpeed < currentSpeed then
			mul = 1 - reduceFrac + reduceFrac * targetSpeed / currentSpeed
			vel.x = vel.x * mul
			vel.y = vel.y * mul
			M_SetVelocity(move, vel)
		end

	end
end

local meta = FindMetaTable("Entity")

local vector_origin = vector_origin
local util_SharedRandom = util.SharedRandom
local util_TraceHull = util.TraceHull
local util_TraceLine = util.TraceLine
local TEAM_HUMAN = TEAM_HUMAN
local TEAM_UNDEAD = TEAM_UNDEAD
local HITGROUP_HEAD = HITGROUP_HEAD
local MASK_SHOT = MASK_SHOT
local pairs = pairs

local M_Player = FindMetaTable("Player")
local P_Team = M_Player.Team
local E_IsValid = meta.IsValid

local function GenerateShotgunPattern(spurs, rings, twist, rot, doAddCenter)
	--[[
	spurs: the amount of bullets per ring, or a table of 0-360 angles for where
		the spurs should be
	rings: the amount of rings of bullets (evenly spaced), or a table of 0-1
		fractions for where	in the spread the rings should be
	twist: a fraction from 0-1 for how far each new ring should be rotated,
		where 0 is not rotated, 0.5 is staggered in windows, and 1 shows no change
		or, if spurs is a set of angles, a 0-360 angle for how far the spurs
		should rotate for each ring
	rot: a 0-360 angle for how far the entire pattern should be rotated
	doAddCenter: a bool for whether or not to put a bullet at {0,0}

	returns: a table of {rotation,distance} tables for where a bullet should go
	]]

	--if we got a number input for spurs,
	--turn it into a table of evenly spaced spurs
	--and also convert twist from nice form to ugly form
	if isnumber(spurs) then
		local count = spurs
		spurs = {}
		for s = 1, count do
			spurs[s] = 360 / count * (s + rot)
		end

		twist = 360 / count * twist
	end

	--if we got a number input for rings,
	--turn it into a table of evenly spaced rings
	if isnumber(rings) then
		local count = rings
		rings = {}
		for s = 1, count do
			rings[s] = 1 / count * s
		end
	end

	local tab = {}
	if doAddCenter then
		tab[1] = {0,0}
	end

	for s, spur in ipairs(spurs) do
		for r, ring in ipairs(rings) do
			tab[#tab + 1] = {ring, spur + twist * r}
		end
	end

	/*
	for s = 1, spurs do
		local rot = 360 / spurs * (s + rotFrac)
		for i, ring in ipairs(rings) do
			tab[#tab + 1] = {rot + twist * i, ring}
		end
	end
	*/

	return tab
end

--generate a shotgun pattern (polar coordinates) from a given table of Pitch/Yaw
--coordinates (cartesian)
local function ConvertShotgunPatternXY(points)
	local x, y
	for _, point in ipairs(points) do
		x = point[1]
		y = point[2]

		point[1] = math.sqrt(x*x + y*y)
		point[2] = math.deg(math.atan2(y,x))
	end

	return points
end

-- Completely Lua-side bullets

BULLETPATTERNS = {}

BULLETPATTERN_SHOTGUN = -1
BULLETPATTERNS[BULLETPATTERN_SHOTGUN] = GenerateShotgunPattern(6,{0.55,1},0.5,0, true)

BULLETPATTERN_CROSS = -2
BULLETPATTERNS[BULLETPATTERN_CROSS] = GenerateShotgunPattern(3,{1},0,0.75, false)

BULLETPATTERN_DUCKBILL = -3
BULLETPATTERNS[BULLETPATTERN_DUCKBILL] = GenerateShotgunPattern({190,350},8,0,0,true)

BULLETPATTERN_TALL = -4
BULLETPATTERNS[BULLETPATTERN_TALL] = ConvertShotgunPatternXY({
	{0,0.5},
	{-0.2,0.2},
	{0.2,0.2},
	{-0.5,0},
	{0.5,0},
	{0,-0.2},
	{0,-0.6},
	{0,-1}
})

--Construct shotgun pattern
/*
do
	local spurs = 8
	local rings = {0.55, 1}
	PATTERN_SHOTGUN[1] = {0, 0} --add center bullet

	PATTERN_SHOTGUN_COUNT = spurs * #rings + 1
	local gap = 360 / spurs * 0.5
	for s = 1, spurs do
		local rot = 360 / spurs * s
		for i, ring in ipairs(rings) do
			PATTERN_SHOTGUN[#PATTERN_SHOTGUN + 1] = {rot + gap * i, ring}
		end
	end
end
*/


local CONTENTS_LIQUID = bit.bor(CONTENTS_WATER, CONTENTS_SLIME)
local MASK_SHOT_HIT_WATER = bit.bor(MASK_SHOT, CONTENTS_LIQUID)

local bullet_tr = {}
local bullet_water_tr = {}
local temp_angle = Angle(0, 0, 0)
local temp_ignore_team
local temp_has_spread
local method_to_use, base_ang
local bullet_trace = {mask = MASK_SHOT, output = bullet_tr}
local temp_shooter = NULL
local temp_attacker = NULL
local attacker_player, inflictor_weapon
local temp_vel_ents = {}
local temp_dirs = {}
local function BaseBulletFilter(ent)
	if ent == temp_shooter or ent == temp_attacker or ent.NeverAlive or ent.SpawnProtection or ent.IgnoreBullets or ent:IsPlayer() and P_Team(ent) == temp_ignore_team then
		return false
	end

	if ent.AlwaysImpactBullets then
		return true
	end

	return true
end

local function HandleShotImpactingWater(damage)
	-- Trace again with water enabled
	bullet_trace.mask = MASK_SHOT_HIT_WATER
	bullet_trace.output = bullet_water_tr
	util_TraceLine(bullet_trace)
	bullet_trace.output = bullet_tr
	bullet_trace.mask = MASK_SHOT

	if bullet_water_tr.AllSolid then return false end

	local contents = util.PointContents(bullet_water_tr.HitPos - bullet_water_tr.HitNormal * 0.1)
	if bit.band(contents, CONTENTS_LIQUID) == 0 then return false end

	if IsFirstTimePredicted() then
		local effectdata = EffectData()
		effectdata:SetOrigin(bullet_water_tr.HitPos)
		effectdata:SetNormal(bullet_water_tr.HitNormal)
		effectdata:SetScale(math.Clamp(damage * 0.25, 5, 30))
		effectdata:SetFlags(bit.band(contents, CONTENTS_SLIME) ~= 0 and 1 or 0)
		util.Effect("gunshotsplash", effectdata)
	end

	return true
end

local wspawn = Entity(0)
local function CheckFHB(tr)
	local ent = tr.Entity
	if ent == wspawn then return end

	if ent.FHB and E_IsValid(ent) then
		tr.Entity = ent:GetParent()
	end
end

function meta:FireBulletsLua(src, dir, spread, num, damage, attacker, force_mul, tracer, callback, hull_size, hit_own_team, max_distance, filter, inflictor)
	max_distance = max_distance or 56756
	attacker = attacker or self
	if not E_IsValid(attacker) then attacker = self end
	force_mul = force_mul or 1
	if num < 0 then
		damage = math.Round(damage / #BULLETPATTERNS[num], 1)
	end

	temp_shooter = self
	temp_attacker = attacker
	attacker_player = attacker:IsPlayer()
	inflictor_weapon = inflictor and inflictor:IsWeapon()

	bullet_trace.start = src
	if filter then
		bullet_trace.filter = filter
	else
		bullet_trace.filter = BaseBulletFilter
		if not hit_own_team and attacker_player then
			temp_ignore_team = P_Team(attacker)
		else
			temp_ignore_team = nil
		end
	end

	if hull_size then
		bullet_trace.maxs = Vector(hull_size, hull_size, hull_size) * 0.5
		bullet_trace.mins = bullet_trace.maxs * -1
		method_to_use = util_TraceHull
	else
		method_to_use = util_TraceLine
	end

	base_ang = dir:Angle()
	temp_has_spread = spread > 0
	temp_dirs[1] = dir

	if SERVER and num ~= 1 and attacker_player then attacker:StartDamageNumberSession() end

	if num > 0 then -- random pattern
		for i=1, num do
			if temp_has_spread then
				temp_angle:Set(base_ang)
				temp_angle:RotateAroundAxis(
					temp_angle:Forward(),
					inflictor_weapon and util_SharedRandom("bulletrotate" .. i, 0, 360) or math.Rand(0, 360)
				)
				temp_angle:RotateAroundAxis(
					temp_angle:Up(),
					inflictor_weapon and util_SharedRandom("bulletangle" .. i, -spread, spread) or math.Rand(-spread, spread)
				)

				temp_dirs[i] = temp_angle:Forward()
			end
		end
	else -- set pattern weapons
		for i=1, #BULLETPATTERNS[num] do
			temp_angle:Set(base_ang)
			temp_angle:RotateAroundAxis(
				temp_angle:Forward(),
				BULLETPATTERNS[num][i][2]
			)
			temp_angle:RotateAroundAxis(
				temp_angle:Up(),
				BULLETPATTERNS[num][i][1] * spread
			)

			temp_dirs[i] = temp_angle:Forward()
		end
		num = #BULLETPATTERNS[num]
	end

	for i=1, num do
		dir = temp_dirs[i]
		bullet_trace.endpos = src + dir * max_distance
		bullet_tr = method_to_use(bullet_trace)

		CheckFHB(bullet_tr)

		local hitwater
		if bit.band(util.PointContents(bullet_tr.HitPos), CONTENTS_LIQUID) ~= 0 then
			hitwater = HandleShotImpactingWater(damage)
		end

		local damageinfo = DamageInfo()
		damageinfo:SetDamageType(DMG_BULLET)
		damageinfo:SetDamage(damage)
		damageinfo:SetDamagePosition(bullet_tr.HitPos)
		damageinfo:SetAttacker(attacker)
		damageinfo:SetInflictor(inflictor or self)
		if force_mul > 0 then
			damageinfo:SetDamageForce(force_mul * damage * 70 * dir:GetNormalized())
		else
			damageinfo:SetDamageForce(Vector(0, 0, 1))
		end

		local use_tracer = true
		local use_impact = true
		local use_ragdoll_impact = true
		local use_damage = true

		if callback then
			local ret = callback(attacker, bullet_tr, damageinfo)
			if ret then
				if ret.donothing then continue end

				if ret.tracer ~= nil then use_tracer = ret.tracer end
				if ret.impact ~= nil then use_impact = ret.impact end
				if ret.ragdoll_impact ~= nil then use_ragdoll_impact = ret.ragdoll_impact end
				if ret.damage ~= nil then use_damage = ret.damage end
			end
		end

		local ent = bullet_tr.Entity
		if E_IsValid(ent) and use_damage then
			if ent:IsPlayer() then
				temp_vel_ents[ent] = temp_vel_ents[ent] or ent:GetVelocity()
				if SERVER then
					ent:SetLastHitGroup(bullet_tr.HitGroup)
					if bullet_tr.HitGroup == HITGROUP_HEAD then
						ent:SetWasHitInHead()
					end
				end
			elseif attacker:IsValidPlayer() then
				local phys = ent:GetPhysicsObject()
				if ent:GetMoveType() == MOVETYPE_VPHYSICS and phys:IsValid() and phys:IsMoveable() then
					ent:SetPhysicsAttacker(attacker)
				end
			end

			ent:DispatchTraceAttack(damageinfo, bullet_tr, dir)
		end

		if SERVER and num ~= 1 and i == num and attacker_player then
			local dmg, dmgpos, haspl = attacker:PopDamageNumberSession()

			if dmg > 0 and dmgpos then
				GAMEMODE:DamageFloater(attacker, ent, dmgpos, dmg, haspl)
			end
		end

		if IsFirstTimePredicted() then
			local effectdata = EffectData()
			effectdata:SetOrigin(bullet_tr.HitPos)
			effectdata:SetStart(src)
			effectdata:SetNormal(bullet_tr.HitNormal)

			if hitwater then
				-- We may not impact, but we DO need to affect ragdolls on the client
				if use_ragdoll_impact then
					util.Effect("RagdollImpact", effectdata)
				end
			elseif use_impact and not bullet_tr.HitSky and bullet_tr.Fraction < 1 then
				effectdata:SetSurfaceProp(bullet_tr.SurfaceProps)
				effectdata:SetDamageType(DMG_BULLET)
				effectdata:SetHitBox(bullet_tr.HitBox)
				effectdata:SetEntity(ent)
				util.Effect("Impact", effectdata)
			end

			if use_tracer then
				if self:IsPlayer() and E_IsValid(self:GetActiveWeapon()) then
					effectdata:SetFlags( 0x0003 ) --TRACER_FLAG_USEATTACHMENT + TRACER_FLAG_WHIZ
					effectdata:SetEntity(self:GetActiveWeapon())
					effectdata:SetAttachment(1)
				else
					effectdata:SetEntity(self)
					effectdata:SetFlags( 0x0001 ) -- TRACER_FLAG_WHIZ
				end
				effectdata:SetScale(5000) -- Tracer travel speed
				util.Effect(tracer or "Tracer", effectdata)
			end
		end
	end

	-- No knockback vs. players. Do this ONLY once to migitate lag compensation issues instead of per bullet. Might just disable lag comp here.
	for ent, vel in pairs(temp_vel_ents) do
		ent:SetLocalVelocity(vel)
	end
	table.Empty(temp_vel_ents)
end

function meta:GetBulletPattern(baseAngle, numShots, Cone)
	--generate a random spray pattern of numShots,
	--or if numShots is a BULLETPATTERN, manipulate that pattern to match the cone
	if numShots >= 0 then -- random pattern
		for i=1, numShots do
			temp_angle:Set(baseAngle)
			temp_angle:RotateAroundAxis(
				temp_angle:Forward(),
				util_SharedRandom("bulletrotate" .. i, 0, 360)
			)
			temp_angle:RotateAroundAxis(
				temp_angle:Up(),
				util_SharedRandom("bulletangle" .. i, -Cone, Cone)
			)
			temp_dirs[i] = temp_angle:Forward()
		end

		--set the n+1th entry to be nil, so extra bullets aren't created
		temp_dirs[numShots + 1] = nil
	elseif BULLETPATTERNS[numShots] then -- set pattern weapons
		for i=1, #BULLETPATTERNS[numShots] do
			temp_angle:Set(baseAngle)
			temp_angle:RotateAroundAxis(
				temp_angle:Forward(),
				BULLETPATTERNS[numShots][i][2]
			)
			temp_angle:RotateAroundAxis(
				temp_angle:Up(),
				BULLETPATTERNS[numShots][i][1] * Cone
			)

			--set the n+1th entry to be nil, so extra bullets aren't created
			temp_dirs[i] = temp_angle:Forward()
		end
		temp_dirs[#BULLETPATTERNS[numShots] + 1] = nil
	else
		ErrorNoHalt("no such bulletpattern " .. numShots .. " or invalid numShots (<0)")
	end

	return temp_dirs
end

function meta:IsValidPlayer()
	return E_IsValid(self) and self:IsPlayer()
end

function meta:IsValidHuman()
	return E_IsValid(self) and self:IsPlayer() and P_Team(self) == TEAM_HUMAN
end

function meta:IsValidZombie()
	return E_IsValid(self) and self:IsPlayer() and P_Team(self) == TEAM_UNDEAD
end

function meta:IsHuman()
	return self:IsPlayer() and P_Team(self) == TEAM_HUMAN
end

function meta:IsZombie()
	return self:IsPlayer() and P_Team(self) == TEAM_UNDEAD
end

function meta:IsValidLivingPlayer()
	return self:IsValidPlayer() and self:Alive()
end

function meta:IsValidLivingHuman()
	return self:IsValidHuman() and self:Alive()
end

function meta:IsValidLivingZombie()
	return self:IsValidZombie() and self:Alive()
end

function meta:ApplyPlayerProperties(ply)
	self.GetPlayerColor = function() return ply:GetPlayerColor() end
	self:SetBodygroup( ply:GetBodygroup(1), 1 )
	self:SetMaterial( ply:GetMaterial() )
	self:SetSkin( ply:GetSkin() or 1 )
end

function meta:GetVolume()
	local mins, maxs = self:OBBMins(), self:OBBMaxs()
	return (maxs.x - mins.x) + (maxs.y - mins.y) + (maxs.z - mins.z)
end

function meta:TakeSpecialDamage(damage, damagetype, attacker, inflictor, hitpos, damageforce)
	if self:IsPlayer() and not self:Alive() then return end
	if not attacker or not E_IsValid(attacker) then attacker = game.GetWorld() end
	if not inflictor or not E_IsValid(inflictor) then inflictor = attacker end

	local dmginfo = DamageInfo()
	dmginfo:SetDamage(damage)
	if attacker then
		dmginfo:SetAttacker(attacker)
	end

	local nearestpos = self:NearestPoint(inflictor:NearestPoint(self:LocalToWorld(self:OBBCenter())))

	if inflictor then
		dmginfo:SetInflictor(inflictor)
		if hitpos then
			dmginfo:SetDamagePosition(hitpos)
		elseif E_IsValid(inflictor) then
			dmginfo:SetDamagePosition(nearestpos)
		end
	else
		dmginfo:SetDamagePosition(hitpos or nearestpos)
	end
	dmginfo:SetDamageType(damagetype)

	local vel = self:GetVelocity()
	self:TakeDamageInfo(dmginfo)
	if self:IsPlayer() and attacker ~= self then
		self:SetLocalVelocity(vel)
	end

	return dmginfo
end

function meta:NearestBone(pos)
	local count = self:GetBoneCount()
	if count == 0 then return end

	local nearest
	local nearestdist

	for boneid = 1, count - 1 do
		local bonepos = self:GetBonePositionMatrixed(boneid)
		local dist = bonepos:DistToSqr(pos)

		if not nearest or dist < nearestdist then
			nearest = boneid
			nearestdist = dist
		end
	end

	return nearest
end

function meta:IsProjectile()
	return self:GetCollisionGroup() == COLLISION_GROUP_PROJECTILE or self.AlwaysProjectile
end

function meta:SetupGenericProjectile(gravity)
	self:SetCustomCollisionCheck(true)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(1)
		phys:SetBuoyancyRatio(0.0001)
		phys:EnableMotion(true)
		if not gravity then phys:EnableGravity(gravity) end
		phys:EnableDrag(false)
		phys:Wake()
	end
end

function meta:ProjectileDamageSource()
	return (self.ProjSource and E_IsValid(self.ProjSource)) and self.ProjSource or self
end

function meta:ResetBones(onlyscale)
	local v = Vector(1, 1, 1)
	local bcount = self.BuildingBones or self:GetBoneCount() - 1
	if onlyscale then
		for i=0, bcount do
			self:ManipulateBoneScale(i, v)
		end
	else
		local a = Angle(0, 0, 0)
		for i=0, bcount do
			self:ManipulateBoneScale(i, v)
			self:ManipulateBoneAngles(i, a)
			self:ManipulateBonePosition(i, vector_origin)
		end
	end
end

function meta:GetBarricadeHealth()
	return self:GetDTFloat(1)
end

function meta:GetMaxBarricadeHealth()
	return self:GetDTFloat(2)
end

function meta:GetBarricadeRepairs()
	return self:GetDTFloat(3)
end

function meta:GetMaxBarricadeRepairs()
	return GAMEMODE.BarricadeRepairCapacity - self:GetMaxBarricadeHealth()
end

function meta:GetBonePositionMatrixed(index)
	local matrix = self:GetBoneMatrix(index)
	if matrix then
		return matrix:GetTranslation(), matrix:GetAngles()
	end

	return self:GetPos(), self:GetAngles()
end

-- This needs to be done otherwise the physics might crash.
function meta:CollisionRulesChanged()
	if not self.m_OldCollisionGroup then self.m_OldCollisionGroup = self:GetCollisionGroup() end
	self:SetCollisionGroup(self.m_OldCollisionGroup == COLLISION_GROUP_DEBRIS and COLLISION_GROUP_WORLD or COLLISION_GROUP_DEBRIS)
	self:SetCollisionGroup(self.m_OldCollisionGroup)
	self.m_OldCollisionGroup = nil
end

function meta:GetAlpha()
	return self:GetColor().a
end

function meta:SetAlpha(a)
	local col = self:GetColor()
	col.a = a
	self:SetColor(col)
end

function meta:IsBarricadeProp()
	return self.IsBarricadeObject or self:IsNailed()
end

function meta:GetHolder()
	for _, ent in pairs(ents.FindByClass("status_human_holding")) do
		if ent:GetObject() == self then
			local owner = ent:GetOwner()
			if owner:IsPlayer() and owner:Alive() then return owner, ent end
		end
	end
end

function meta:ThrowFromPosition(pos, force, noknockdown)
	if force == 0 or self:IsProjectile() or self.NoThrowFromPosition then return false end

	if self:IsPlayer() then
		if self:ActiveBarricadeGhosting() then return false end

		force = force * (self.KnockbackScale or 1)
	end

	if self:GetMoveType() == MOVETYPE_VPHYSICS then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() and phys:IsMoveable() then
			local nearest = self:NearestPoint(pos)
			phys:ApplyForceOffset(force * 50 * (nearest - pos):GetNormalized(), nearest)
		end

		return true
	elseif self:GetMoveType() >= MOVETYPE_WALK and self:GetMoveType() < MOVETYPE_PUSH then
		self:SetGroundEntity(NULL)
		if SERVER and not noknockdown and self:IsPlayer() then
			local absforce = math.abs(force)
			if absforce >= 512 or self.IsClumsy and P_Team(self) == TEAM_HUMAN and absforce >= 32 then
				self:KnockDown()
			end
		end
		self:SetVelocity(force * (self:LocalToWorld(self:OBBCenter()) - pos):GetNormalized())

		return true
	end
end

function meta:ThrowFromPositionSetZ(pos, force, zmul, noknockdown)
	if force == 0 or self:IsProjectile() or self.NoThrowFromPosition then return false end
	zmul = zmul or 0.7

	if self:IsPlayer() then
		if self:ActiveBarricadeGhosting() or self.SpawnProtection then return false end

		force = force * (self.KnockbackScale or 1)
	end

	if self:GetMoveType() == MOVETYPE_VPHYSICS then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() and phys:IsMoveable() then
			local nearest = self:NearestPoint(pos)
			local dir = nearest - pos
			dir.z = 0
			dir:Normalize()
			dir.z = zmul
			phys:ApplyForceOffset(force * 50 * dir, nearest)
		end

		return true
	elseif self:GetMoveType() >= MOVETYPE_WALK and self:GetMoveType() < MOVETYPE_PUSH then
		self:SetGroundEntity(NULL)
		if SERVER and not noknockdown and self:IsPlayer() then
			local absforce = math.max(math.abs(force) * math.abs(zmul), math.abs(force))
			if absforce >= 512 or self.IsClumsy and P_Team(self) == TEAM_HUMAN and absforce >= 32 then
				self:KnockDown()
			end
		end

		local dir = self:LocalToWorld(self:OBBCenter()) - pos
		dir.z = 0
		dir:Normalize()
		dir.z = zmul
		self:SetVelocity(force * dir)

		return true
	end
end

util.PrecacheSound("player/pl_pain5.wav")
util.PrecacheSound("player/pl_pain6.wav")
util.PrecacheSound("player/pl_pain7.wav")
function meta:PoisonDamage(damage, attacker, inflictor, hitpos, noreduction, instant)
	damage = damage or 1

	local dmginfo = DamageInfo()

	if self:IsPlayer() then
		if P_Team(self) ~= TEAM_HUMAN then return end

		--[[if self.BuffResistant then
			damage = damage / 2
		end]]

		if self.PoisonDamageTakenMul then
			damage = damage * self.PoisonDamageTakenMul
		end

		if inflictor:IsProjectile() and self.ProjDamageTakenMul then
			damage = damage * self.ProjDamageTakenMul
		end

		self:ViewPunch(Angle(math.random(-10, 10), math.random(-10, 10), math.random(-20, 20)))
		self:EmitSound(string.format("player/pl_pain%d.wav", math.random(5, 7)))

		if not instant then
			if SERVER then
				local dmg = math.floor(damage * 0.5)
				if dmg > 0 then
					self:AddPoisonDamage(dmg, attacker)
				end
			end

			damage = math.ceil(damage * 0.5)
		end

		dmginfo:SetDamageType(DMG_ACID)
	elseif self.GetObjectHealth then
		dmginfo:SetDamageType(DMG_ACID)
	else
		--[[if not noreduction then
			damage = damage / 3
		end]]
		dmginfo:SetDamageType(DMG_SLASH) -- Fixes not doing damage to props.
	end

	attacker = attacker or self
	inflictor = inflictor or attacker

	dmginfo:SetDamagePosition(hitpos or self:NearestPoint(inflictor:NearestPoint(self:LocalToWorld(self:OBBCenter()))))
	dmginfo:SetDamage(damage)
	dmginfo:SetAttacker(attacker)
	dmginfo:SetInflictor(inflictor)
	self:TakeDamageInfo(dmginfo)
end

-- Fix sequence duration being able to be nil
local OldSequenceDuration = meta.SequenceDuration
function meta:SequenceDuration(seqid)
	return OldSequenceDuration(self, seqid) or 0
end

-- Workaround for DispatchTraceAttack not interacting with some entities. Replace me after appropriate binding exists.
local OldDispatch = meta.DispatchTraceAttack
function meta:DispatchTraceAttack(dmginfo, tr, dir)
	if self.NoTraceAttack then
		self:TakeDamageInfo(dmginfo)
	else
		OldDispatch(self, dmginfo, tr, dir)
	end
end

function meta:IsPhysicsModel(mdl)
	return string.sub(self:GetClass(), 1, 12) == "prop_physics" and (not mdl or string.lower(self:GetModel()) == string.lower(mdl))
end

function meta:IsWeaponType(class)
	return self:GetClass() == "prop_weapon" and self:GetWeaponType() == class or (self:IsWeapon() and self:GetClass() == class)
end

function meta:HealPlayer(pl, amount, pointmul, nobymsg, overhealFrac, statusCureMul)
	local originalAmount = amount
	local healed, rmv = 0, 0
	local overhealFrac = overhealFrac or 1
	local statusCureMul = statusCureMul or 1

	local health, maxhealth = pl:Health(), (pl:IsSkillActive(SKILL_D_FRAIL) and math.floor(pl:GetMaxHealth() * 0.25) or pl:GetMaxHealth()) * overhealFrac
	local missing_health = maxhealth - health

	--multiply amount by statusCureMul first for status healing
	amount = amount * statusCureMul

	--heal bleed first
	local amount = pl:HealBleedDamage(amount)

	--then heal radiation
	local amount = pl:HealRadiationDamage(amount)

	--then divide it back down to regular health
	amount = amount / statusCureMul

	--then heal actual health
	if missing_health > 0 and amount > 0 then
		rmv = math.min(amount, missing_health)
		pl:SetHealth(health + rmv)
		healed = healed + rmv
		amount = amount - rmv
	end

	--do the cure mul again
	amount = amount * statusCureMul

	--then heal poison
	local amount = pl:HealPoisonDamage(amount)

	--then go back to regular points again
	amount = amount / statusCureMul

	pointmul = 0 --(pointmul or 1) / (math.max(healed, regamount) / regamount)

	if SERVER and healed > 0 and self:IsPlayer() then
		gamemode.Call("PlayerHealedTeamMember", self, pl, healed, self:GetActiveWeapon(), pointmul, nobymsg, healed >= 10)
		pl:SetPhantomHealth(math.max(0, pl:GetPhantomHealth() - healed))
	end

	return originalAmount - amount
end

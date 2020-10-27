SWEP.ZombieOnly = false --debug
SWEP.IsMelee = true

SWEP.PrintName = "Base Zombie Arms"

SWEP.ViewModel = Model("models/Weapons/v_zombiearms.mdl")
SWEP.WorldModel = ""

--SWEP.Alt = {
	--SpeedMul = 1, --multiplier to apply to player's speed
	--Regen = 25, --health to restore per second
	--NoDamageInterruptsRegen = false
	--DamageTakenMul = 2, --multiplier to damage taken while active
	--DamageDealtMul = 1, --multiplier to damage dealt while active
	--CanAttack = false, --whether or not the player can perform other attacks while alting
	--DamageTakenStatus = "hitstun",
	--DamageTakenStatusDuration = 1
	--DoOverrideDescriptor = false
	--DescriptorText = "" --text is appended to the end
	--WinddownTime
--}
SWEP.Attack1 = {
	--AttackAnim = ACT_VM_SECONDARYATTACK,
	WindupTime = 0.74, --how long passes after clicking before DoAttack() happens
	WinddownTime = 0.46, --how long passes after DoAttack() before you can click again
	Type = ZATTACK_MELEE,
	MeleeDamage = 30,
	MeleeForceScale = 1,
	MeleeDamageType = DMG_SLASH,
	MeleeDoPreHit = true,
	MeleeReach = 48, --range of melee attack
	MeleeSize = 4.5 --size of melee attack
	--[[
	--example overriding of attackSound
	PlayAttackSound = function(swep)
		swep:EmitSound("npc/zombie/zo_attack"..math.random(2)..".wav")
	end
	]]
	--PlayHitSound = function(swep) end
	--PlayMissSound = function(swep) end
	--AnimationDelay, the time to wait before starting attack animation
	--AnimationMul, the multiplier to apply to the speed the animation plays (2 is twice as fast)
	--SpeedMul, multiplier to apply to speed while in progress
}
--SWEP.Attack2
--SWEP.Attack3

--[[
--example ranged attack
SWEP.Attack2 = {
	WindupTime = 0.74,
	WinddownTime = 0.46,
	AnimationDelay = 0.37,
	AnimationMul = 2,
	Type = ZATTACK_RANGED,
	RangedProjectile = "projectile_poisonflesh",
	RangedNumShots = BULLETPATTERN_CROSS,
	RangedCone = 5,
	RangedProjectileSpeed = 380,
	PlayAttackSound = function(swep)
		swep:EmitSound("NPC_PoisonZombie.Throw")
	end
	--PlayFireSound = function(swep) end
}
--example leap attack
SWEP.Attack3 = {
	AttackAnim = ACT_VM_SECONDARYATTACK,
	AnimationMul = 2,
	WindupTime = 0.5,
	WinddownTime = 0.5,
	Type = ZATTACK_LEAP,
	LeapSpeed = 900,
	LeapMinVertical = 0.1,
	LeapCanAirControl = false,
	LeapDamage = 8,
	LeapDamageType = DMG_IMPACT,
	LeapCanInterrupt = true,
	LeapCanAirControl = false,
	PlayAttackSound = function(swep)
		swep:EmitSound("npc/fast_zombie/leap1.wav", nil, nil, nil, CHAN_AUTO)
	end
	--PlayHitSound, plays when you hit someone with a leap
	--LeapLandStatus
	--LeapForceScale
}
]]


SWEP.CanClimb = false
SWEP.ClimbSpeedVertical = 120
SWEP.ClimbSpeedHorizontal = 60
SWEP.ClimbIntervalLong = 1
SWEP.ClimbIntervalShort = 0.75

--default swep vars - don't touch
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

local climbtrace = {mask = MASK_SOLID_BRUSHONLY, mins = Vector(-5, -5, -5), maxs = Vector(5, 5, 5)}
SWEP.NextClimbSound = 0

--SWEP.ActiveAttack, the currently active attack
--SWEP.ActiveLeap, the currently active leap attack
SWEP.NextAltRegen = 0
SWEP.AltRegenInterval = 0.2
local ALTSTATE_DISABLED = 0
local ALTSTATE_ENABLED = 1
local ALTSTATE_ENABLING = 2
local ALTSTATE_DISABLING = 3

--debug stuff
/*
SWEP.DoDebug = true --set this to true so SWEP:Move() works right from human team for debugging
function SWEP:Deploy()
	if self.DoDebug then
		hook.Add("Move","DebugZombieArms" .. tostring(self:EntIndex()), function(pl, move)

			if pl == self:GetOwner() then
				return self:Move(pl, move)
			end
		end)
	end

	return true
end
function SWEP:Holster()
	if self.DoDebug then
		hook.Remove("Move","DebugZombieArms" .. tostring(self:EntIndex()))
	end

	return true
end
*/

--empty functions - hooks..?
function SWEP:OnStartAttack(Attack)
end
function SWEP:OnResolveAttack(Attack)
end
function SWEP:MeleeHitWorld(trace)
end
function SWEP:AltThink()
end
function SWEP:OnStartAlting()
end
function SWEP:OnStopAlting()
end
function SWEP:OnMeleeHitPlayer(pl, tr, dmginfo)
end

--sound functions. if it's "default" you can overwrite it per-attack
function SWEP:PlayDefaultAttackSound()
	self:EmitSound("npc/zombie/zo_attack"..math.random(2)..".wav")
end
function SWEP:PlayDefaultHitSound()
	self:EmitSound("npc/zombie/claw_strike"..math.random(3)..".wav", nil, nil, nil, CHAN_AUTO)
end
function SWEP:PlayDefaultMissSound()
	self:EmitSound("npc/zombie/claw_miss"..math.random(2)..".wav", nil, nil, nil, CHAN_AUTO)
end
function SWEP:PlayDefaultLeapSound()
	self:EmitSound("npc/zombie/claw_miss"..math.random(2)..".wav", nil, nil, nil, CHAN_AUTO)
end
function SWEP:PlayDefaultFireSound()
	self:EmitSound(string.format("physics/body/body_medium_break%d.wav", math.random(2, 4)), 72, math.random(70, 80))
end
function SWEP:PlayClimbSound()
	self:GetOwner():EmitSound("player/footsteps/metalgrate"..math.random(4)..".wav")
end
function SWEP:PlayAltStartSound()
	if CLIENT then
		self:GetOwner():EmitSound("player/suit_sprint.wav")
	end
end

--base weapon functions
function SWEP:Think()
	self:CheckAltState()
	self:CheckIdleAnimation()
	self:CheckAttackAnimation()
	self:CheckAttack()
	self:CheckLeaping()
	self:DoClimbing()
	self:AltThink()
end

function SWEP:PrimaryAttack()
	self:TryAttack(self.Attack1)
end
function SWEP:SecondaryAttack()
	if self:IsClimbing() then return end

	if self.CanClimb and not self:GetOwner():IsOnGround()
	and self:GetClimbSurface() and (self:IsLeaping() or self:IsIdle()) then
		self:StartClimbing()
	else
		self:TryAttack(self.Attack2)
	end
end
function SWEP:Reload()
	self:TryAttack(self.Attack3)
end

--Externally called functions
function SWEP:Move(mv)
	if self:IsLeaping() and not self.ActiveLeap.LeapCanAirControl then
		mv:SetSideSpeed(0)
		mv:SetForwardSpeed(0)
	elseif self:IsClimbing() then
		mv:SetMaxSpeed(0)
		mv:SetMaxClientSpeed(0)

		local owner = self:GetOwner()
		local tr = self:GetClimbSurface()
		local angs = mv:GetAngles() --owner:SyncAngles()
		local dir = tr and tr.Hit and (tr.HitNormal.z <= -0.5 and (angs:Forward() * -1) or math.abs(tr.HitNormal.z) < 0.75 and tr.HitNormal:Angle():Up()) or Vector(0, 0, 1)
		local vel = Vector(0, 0, 4)

		if owner:KeyDown(IN_FORWARD) then
			vel = vel + dir * self.ClimbSpeedVertical
		end
		if owner:KeyDown(IN_BACK) then
			vel = vel - dir * self.ClimbSpeedVertical
		end

		if vel.z == 4 then
			if owner:KeyDown(IN_MOVERIGHT) then
				vel = vel + angs:Right() * self.ClimbSpeedHorizontal
			end
			if owner:KeyDown(IN_MOVELEFT) then
				vel = vel - angs:Right() * self.ClimbSpeedHorizontal
			end
		end

		mv:SetVelocity(vel)

		return true
	elseif self:IsAlting() then
		if self.Alt.SpeedMul then
			local spd = mv:GetMaxSpeed() * self.Alt.SpeedMul
			mv:SetMaxSpeed(spd)
			mv:SetMaxClientSpeed(spd)
		end
	elseif not self:IsIdle() then
		if self.ActiveAttack and self.ActiveAttack.SpeedMul then
			local spd = mv:GetMaxSpeed() * self.ActiveAttack.SpeedMul
			mv:SetMaxSpeed(spd)
			mv:SetMaxClientSpeed(spd)
		end
	end
end
function SWEP:AltUse()
	if not self.Alt then return end

	if self:GetAlting() == ALTSTATE_DISABLING then
		self:SetAlting(ALTSTATE_ENABLED)
	elseif (not self:IsIdle() and not self.Alt.CanAttack) or not self:GetOwner():IsOnGround() then
		self:SetAlting(ALTSTATE_ENABLING)
	else
		self:StartAlting()
	end
end
function SWEP:AltRelease()
	if not self.Alt then return end

	if(self.Alt.WinddownTime) then
		self:SetAlting(ALTSTATE_DISABLING)
		self:SetNextIdle(CurTime() + self.Alt.WinddownTime)
	else
		self:StopAlting()
	end
end

--Generic Attack Functions
function SWEP:TryAttack(Attack, force)
	--if this is an empty attack then just return
	if not Attack or Attack.Type == ZATTACK_NONE then return end

	if self:IsAlting() and not self.Alt.CanAttack then return end

	--if we aren't idle yet, just return
	--unless we're forcing this attack to interrupt
	if not self:IsIdle() and not force then --or IsValid(self:GetOwner().FeignDeath)
		return
	end

	--if we are trying to leap but also airborn, just return
	if Attack.Type == ZATTACK_LEAP and not self:GetOwner():IsOnGround() then return end

	--set the next time we can attack
	self:SetNextIdle(CurTime() + (Attack.WindupTime or 0) + (Attack.WinddownTime or 0))

	self:StartAttack(Attack)
end
function SWEP:StartAttack(Attack)
	if not IsFirstTimePredicted() then return end

	local owner = self:GetOwner()

	self.ActiveAttack = Attack
	self:OnStartAttack(Attack)

	if Attack.AnimationDelay then
		--we should wait to perform the attack animation
		self.NextAttackAnim = CurTime() + Attack.AnimationDelay
	else
		self:SendAttackAnim(Attack)

		if Attack.ModelAnimation then
			owner:DoAnimationEvent(Attack.ModelAnimation)
		else
			owner:DoZombieEvent() --i think this plays the 3rd person anim?
		end
	end

	--play attack sound
	if Attack.PlayAttackSound then
		--play the attack sound supplied for the attack, if it exists
		Attack.PlayAttackSound(self)
	else
		--if not, play the default weapon_zs_basezombie attack sound
		self:PlayDefaultAttackSound()
	end

	if Attack.WindupTime and Attack.WindupTime > 0 then
		self:SetAttackResolveTime(CurTime() + Attack.WindupTime)

		if Attack.Type == ZATTACK_MELEE and Attack.MeleeDoPreHit then
			local trace = owner:CompensatedMeleeTrace(Attack.MeleeReach, Attack.MeleeSize)
			if trace.HitNonWorld and not trace.Entity:IsPlayer() then
				trace.IsPreHit = true
				self.PreHit = trace
			else
				self.PreHit = nil
			end
		end

		self.NextIdleAnim = (
			CurTime() + self:SequenceDuration() + (Attack.AnimationDelay or 0)
		)
	else
		self:ResolveAttack(Attack)
	end
end
function SWEP:SendAttackAnim(Attack)
	--get the proper ACT_ animation to play
	local act = Attack.AttackAnim or self:GetAttackAnim(Attack)
	if act == ACT_INVALID then return end

	local owner = self:GetOwner()

	--play the animation
	self:SendWeaponAnim(act)

	--speed up the animation if necessary
	--assume another animation might use this, so just set it back to 1 otherwise.
	owner:SetPlaybackRate(Attack.AnimationMul or 1)
end
function SWEP:GetAttackAnim(Attack)
	if Attack.Type == ZATTACK_MELEE then
		self.SwapAnims = not self.SwapAnims
		if not self.SwapAnims then
			return ACT_VM_HITCENTER
		else
			return ACT_VM_SECONDARYATTACK
		end
	else
		--if your melee RIGHT after leaping and it plays the same animation twice, it bugs
		--out. even if it didnt it would look weird, so just play the secondary attack anim
		self.SwapAnims = false
		return ACT_VM_HITCENTER
	end
end
function SWEP:ResolveAttack(Attack)
	if not IsFirstTimePredicted() or not Attack then return end

	self:OnResolveAttack(Attack)

	if Attack.Type == ZATTACK_MELEE then
		self:ResolveMeleeAttack(Attack)
	elseif Attack.Type == ZATTACK_RANGED then
		self:ResolveRangedAttack(Attack)
	elseif Attack.Type == ZATTACK_LEAP then
		self:ResolveLeapAttack(Attack)
	end
end


--Melee Attack Functions
function SWEP:ResolveMeleeAttack(Attack)
	local owner = self:GetOwner()
	local hit = false
	local traces = owner:CompensatedZombieMeleeTrace(Attack.MeleeReach,Attack.MeleeSize)
	local prehit = self.PreHit
	if prehit then
		local ins = true
		for _, tr in pairs(traces) do
			if tr.HitNonWorld then
				ins = false
				break
			end
		end
		if ins then
			local eyepos = owner:EyePos()
			if prehit.Entity:IsValid() and prehit.Entity:NearestPoint(eyepos):DistToSqr(eyepos) <= Attack.MeleeReach * Attack.MeleeReach then
				table.insert(traces, prehit)
			end
		end
		self.PreHit = nil
	end

	--scale swing damage based on number of players hit
	local damage = Attack.MeleeDamage * CalcMeleeDamageScale(GetTracesNumPlayers(traces))
	if self:IsAlting() and self.Alt.DamageDealtMul then
		damage = damage * self.Alt.DamageDealtMul
	end
	local effectdata = EffectData()
	local ent
	local forceScale = Attack.MeleeForceScale or 1
	local damageType = Attack.MeleeDamageType or DMG_SLASH

	--hit every human / prop in the trace list
	for _, trace in ipairs(traces) do
		if not trace.Hit then continue end

		ent = trace.Entity

		hit = true

		if trace.HitWorld then
			self:MeleeHitWorld(trace)
		elseif ent and ent:IsValid() then
			self:MeleeHit(ent, trace, damage, forceScale, damageType)
		end
		effectdata:SetOrigin(trace.HitPos)
		effectdata:SetStart(trace.StartPos)
		effectdata:SetNormal(trace.HitNormal)
		util.Effect("RagdollImpact", effectdata)
		if not trace.HitSky then
			effectdata:SetSurfaceProp(trace.SurfaceProps)
			effectdata:SetDamageType(damageType)
			effectdata:SetHitBox(trace.HitBox)
			effectdata:SetEntity(ent)
			util.Effect("Impact", effectdata)
		end
	end

	--play the swing sound effect
	if hit then
		if Attack.PlayHitSound then
			Attack.PlayHitSound(self)
		else
			self:PlayDefaultHitSound()
		end
	else
		if Attack.PlayMissSound then
			Attack.PlayMissSound(self)
		else
			self:PlayDefaultMissSound()
		end
	end
end
function SWEP:MeleeHit(ent, trace, damage, forcescale, damagetype)
	if ent:IsPlayer() then
		self:MeleeHitPlayer(ent, trace, damage, forcescale)
	else
		self:MeleeHitEntity(ent, trace, damage, forcescale)
	end

	self:ApplyMeleeDamage(ent, trace, damage, damagetype)
end
function SWEP:MeleeHitEntity(ent, trace, damage, forcescale)
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() and phys:IsMoveable() then
		if trace.IsPreHit then
			phys:ApplyForceOffset(damage * 750 * (forcescale or 1) * self:GetOwner():GetAimVector(), (ent:NearestPoint(self:GetOwner():EyePos()) + ent:GetPos() * 5) / 6)
		else
			phys:ApplyForceOffset(damage * 750 * (forcescale or 1) * trace.Normal, (ent:NearestPoint(trace.StartPos) + ent:GetPos() * 2) / 3)
		end

		ent:SetPhysicsAttacker(self:GetOwner())
	end
end
function SWEP:MeleeHitPlayer(ent, trace, damage, forcescale)
	ent:ThrowFromPositionSetZ(self:GetOwner():GetPos(), damage * 2.5 * (forcescale or 1))
	ent:MeleeViewPunch(damage)
	local nearest = ent:NearestPoint(trace.StartPos)
	util.Blood(nearest, math.Rand(damage * 0.5, damage * 0.75), (nearest - trace.StartPos):GetNormalized(), math.Rand(damage * 5, damage * 10), true)
end
function SWEP:ApplyMeleeDamage(hitent, tr, damage, damagetype)
	if not IsFirstTimePredicted() then return end

	local owner = self:GetOwner()

	local dmginfo = DamageInfo()
	dmginfo:SetDamagePosition(tr.HitPos)
	dmginfo:SetAttacker(owner)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamageType(damagetype)
	dmginfo:SetDamage(damage)
	dmginfo:SetDamageForce(math.min(damage, 50) * 50 * owner:GetAimVector())

	local vel
	if hitent:IsPlayer() then
		self:OnMeleeHitPlayer(hitent, tr, dmginfo)
		if SERVER then
			hitent:SetLastHitGroup(tr.HitGroup)
			if tr.HitGroup == HITGROUP_HEAD then
				hitent:SetWasHitInHead()
			end

			if hitent:WouldDieFrom(damage, tr.HitPos) then
				dmginfo:SetDamageForce(math.min(damage, 50) * 400 * owner:GetAimVector())
			end
		end

		vel = hitent:GetVelocity()
	end

	hitent:DispatchTraceAttack(dmginfo, tr, owner:GetAimVector())

	-- No knockback vs. players
	if vel then
		hitent:SetLocalVelocity(vel)
	end
end


--Ranged Attack Functions
function SWEP:ResolveRangedAttack(Attack)
	--play the sound effect
	if Attack.PlayFireSound then
		Attack.PlayFireSound(self)
	else
		self:PlayDefaultFireSound()
	end

	--fire the actual projectiles
	self:FireRangedAttack(Attack)
end
function SWEP:FireRangedAttack(Attack)
	if not SERVER then return end
	local owner = self:GetOwner()
	local startpos = owner:GetShootPos()
	local aimang = owner:EyeAngles()
	local ang

	local dirs = owner:GetBulletPattern(aimang, Attack.RangedNumShots,Attack.RangedCone)
	local count = Attack.RangedNumShots >= 0 and Attack.RangedNumShots or BULLETPATTERNS[Attack.RangedNumShots]

	for _, dir in ipairs(dirs) do
		local ent = ents.Create(Attack.RangedProjectile)
		if ent:IsValid() then
			ent:SetPos(startpos + dir * 8)
			ent:SetOwner(owner)
			ent:Spawn()

			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous(dir * Attack.RangedProjectileSpeed)
			end
		end
	end
end

--Leap Attack Functions
function SWEP:ResolveLeapAttack(Attack)
	local owner = self:GetOwner()
	if not owner:IsOnGround() then return end

	--play the sound effect
	if Attack.PlayLeapSound then
		Attack.PlayLeapSound(self)
	else
		self:PlayDefaultLeapSound()
	end

	--actually leap
	self:DoLeap(Attack)
	self:SetIsLeaping(true)
	self.ActiveLeap = Attack

	--do leap animation
	if Attack.LeapAnimation then
		owner:DoAnimationEvent(Attack.LeapAnimation)
	end

	--if you can't interrupt this, make sure the player doesn't do anything else until they land
	if not Attack.LeapCanInterrupt then
		self:SetNextIdle(math.huge)
	end
end
function SWEP:DoLeap(Attack)
	local owner = self:GetOwner()

	local dir = owner:GetAimVector()
	if Attack.LeapMinVertical then
		dir.z = math.max(Attack.LeapMinVertical, dir.z)
	end
	if dir:LengthSqr() > 1 then
		--if you don't check if length is > 1, aiming straight down makes you jump
		--straight up at full force, which is counter intuitive
		dir:Normalize()
	end

	owner:SetGroundEntity(NULL)
	owner:SetLocalVelocity(dir * Attack.LeapSpeed)
end
function SWEP:CheckLeapCollision(Attack)
	local owner = self:GetOwner()

	local traces = owner:CompensatedZombieMeleeTrace(8,12,shootpos, owner:GetForward())
	local damage = (Attack.LeapDamage or 0) * CalcMeleeDamageScale(GetTracesNumPlayers(traces))
	if self:IsAlting() and self.Alt.DamageDealtMul then
		damage = damage * self.Alt.DamageDealtMul
	end

	local hit = false
	for _, trace in ipairs(traces) do
		if not trace.Hit then continue end

		if trace.HitWorld then
			if trace.HitNormal.z < 0.8 then
				hit = true
				self:MeleeHitWorld(trace)
			end
		else
			local ent = trace.Entity
			if ent and ent:IsValid() then
				hit = true
				self:MeleeHit(ent, trace, damage, Attack.LeapForceScale or 1, Attack.LeapDamageType or DMG_SLASH )
			end
		end
	end

	if hit then
		self:SetIsLeaping(false)
		if not self.ActiveLeap.LeapCanInterrupt then
			self:SetNextIdle(CurTime() + (self.ActiveLeap.WinddownTime or 0))
		end

		if IsFirstTimePredicted() then
			if Attack.PlayHitSound then
				Attack.PlayHitSound(self)
			else
				self:PlayDefaultHitSound()
			end
		end
	end
end

--Alt Ability functions
function SWEP:StartAlting()
	if self:IsAlting() or not self.Alt then return end
	self:SetAlting(ALTSTATE_ENABLED)

	self:OnStartAlting()

	if IsFirstTimePredicted() then
		self:PlayAltStartSound()
	end

	if SERVER then
		self.NextAltRegen = CurTime() + self.AltRegenInterval
	end
end
function SWEP:StopAlting()
	self:SetAlting(ALTSTATE_DISABLED)
	self:OnStopAlting()
end
function SWEP:AltThink()

	--do alt regen
	if SERVER and self:IsAlting() and self.Alt.Regen then
		if self.NextAltRegen <= CurTime() then

			self.NextAltRegen = CurTime() + self.AltRegenInterval

			local owner = self:GetOwner()
			if owner:GetStatus("waveburn") or (not self.Alt.NoDamageInterruptsRegen and (owner.LastDamaged or 0) + 0.5 > CurTime()) then return end


			owner:HealPlayer(owner,self.Alt.Regen * self.AltRegenInterval, 0)
		end
	end
end
function SWEP:CheckAltState()
	if self:GetAlting() == ALTSTATE_ENABLING then
		if self:IsIdle() and self:GetOwner():IsOnGround() then
			self:StartAlting()
		end
	elseif self:GetAlting() == ALTSTATE_DISABLING then
		if self:IsIdle() then
			self:StopAlting()
		end
	end
end

--One-liner functions
function SWEP:CheckAttackAnimation()
	if self.NextAttackAnim and self.NextAttackAnim <= CurTime() then
		self.NextAttackAnim = nil
		self:SendAttackAnim(self.ActiveAttack)

		if self.ActiveAttack.ModelAnimation then
			self:GetOwner():DoAnimationEvent(self.ActiveAttack.ModelAnimation)
		else
			self:GetOwner():DoZombieEvent() --i think this plays the 3rd person anim?
		end
	end
end
function SWEP:CheckIdleAnimation()
	if self.NextIdleAnim and self.NextIdleAnim <= CurTime() then
		self.NextIdleAnim = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end
function SWEP:CheckAttack()
	local resolveTime = self:GetAttackResolveTime()
	if resolveTime > 0 and CurTime() > resolveTime then
		self:SetAttackResolveTime(-1)
		self:ResolveAttack(self.ActiveAttack)
	end
end
function SWEP:CheckLeaping()
	if not self:IsLeaping() then
		return
	end

	local owner = self:GetOwner()
	if owner:IsOnGround() or 1 < owner:WaterLevel() then
		self:SetIsLeaping(false)
		if not self.ActiveLeap.LeapCanInterrupt then
			self:SetNextIdle(CurTime() + (self.ActiveLeap.WinddownTime or 0))
		end
	end

	self:CheckLeapCollision(self.ActiveLeap)
end
function SWEP:IsSwinging()
	return self:GetAttackResolveTime() > 0
end

--climbing functions
function SWEP:GetClimbSurface()
	local owner = self:GetOwner()

	local fwd = owner:SyncAngles():Forward()
	local up = owner:GetUp()
	local pos = owner:GetPos()
	local tr
	for i=5, owner:OBBMaxs().z, 5 do
		if not tr or not tr.Hit then
			climbtrace.start = pos + up * i
			climbtrace.endpos = climbtrace.start + fwd * 28
			tr = util.TraceHull(climbtrace)
			if tr.Hit and not tr.HitSky then break end
		end
	end

	if tr.Hit and not tr.HitSky then
		climbtrace.start = tr.HitPos + tr.HitNormal
		climbtrace.endpos = climbtrace.start + owner:SyncAngles():Up() * 72
		local tr2 = util.TraceHull(climbtrace)
		if tr2.Hit and not tr2.HitSky then
			return tr2
		end

		return tr
	end
end
function SWEP:StartClimbing()
	if self:IsClimbing() then
		return
	end

	self:SetIsClimbing(true)

	self:SetNextIdle(math.huge)
end
function SWEP:StopClimbing()
	if not self:IsClimbing() then return end

	self:SetIsClimbing(false)

	self:SetNextIdle(CurTime() + 0.1)
end
function SWEP:DoClimbing()
	if not self.CanClimb or not self:IsClimbing() then
		return
	end
	local owner = self:GetOwner()

	if owner:KeyDown(IN_ATTACK2) and self:GetClimbSurface() then
		if SERVER and CurTime() > self.NextClimbSound then
			local sqrSpeed = owner:GetVelocity():LengthSqr()
			if sqrSpeed > 256 then
				if sqrSpeed > 2500 then
					self.NextClimbSound = CurTime() + self.ClimbIntervalShort
				else
					self.NextClimbSound = CurTime() + self.ClimbIntervalLong
				end
				self:PlayClimbSound()
			end
		end
	else
		self:StopClimbing()
	end
end

--Get/Set Functions
function SWEP:GetNextIdle()
	return self:GetNextPrimaryFire()
end
function SWEP:SetNextIdle(time)
	self:SetNextPrimaryFire(time)
end
function SWEP:IsIdle()
	return (CurTime() >= self:GetNextIdle())
end
function SWEP:SetAttackResolveTime(time)
	self:SetDTFloat(0,time)
end
function SWEP:GetAttackResolveTime()
	return self:GetDTFloat(0)
end
function SWEP:IsLeaping()
	return self:GetDTBool(1)
end
function SWEP:SetIsLeaping(isLeaping)
	self:SetDTBool(1,isLeaping)
end
function SWEP:IsClimbing()
	return self:GetDTBool(2)
end
function SWEP:SetIsClimbing(isClimbing)
	self:SetDTBool(2,isClimbing)
end
function SWEP:IsAlting()
	return self:GetAlting() == ALTSTATE_ENABLED
end
function SWEP:GetAlting()
	return self:GetDTInt(3)
end
function SWEP:SetAlting(altstate)
	self:SetDTInt(3,altstate)
end

--Descriptor functions
function SWEP:DescribeAttack(Attack)
	if not Attack or Attack.Type == ZATTACK_NONE then return end

	if Attack.DoOverrideDescriptor then
		return Attack:GetDescriptorText()
	end

	local txttab = {}

	if Attack.Type == ZATTACK_MELEE then
		--table.insert(txttab, "Claws for " .. Attack.MeleeDamage .. " Damage.\n")
		table.insert(txttab, translate.GetFormatted("attack_claw",Attack.MeleeDamage))
		table.insert(txttab, "\n")
	elseif Attack.Type == ZATTACK_LEAP then
		local adj
		if Attack.LeapSpeed > 750 then
			table.insert(txttab, translate.GetFormatted("attack_leap_long", Attack.LeapDamage or 0))
		elseif Attack.LeapSpeed < 450 then
			table.insert(txttab, translate.GetFormatted("attack_leap_short", Attack.LeapDamage or 0))
		else
			table.insert(txttab, translate.GetFormatted("attack_leap", Attack.LeapDamage or 0))
		end
		table.insert(txttab, "\n")

		if Attack.LeapCanAirControl then
			table.insert(txttab, translate.Get("can_change_direction"))
			table.insert(txttab, "\n")
		end

		if Attack.LeapCanInterrupt then
			table.insert(txttab, translate.Get("can_attack_leaping"))
			table.insert(txttab, "\n")
		end
	elseif Attack.Type == ZATTACK_RANGED then
		local projName = translate.Get(Attack.RangedProjectile, Attack.RangedProjectile)
			table.insert(txttab, translate.GetFormatted("attack_ranged", projName))
			table.insert(txttab, "\n")
	else
		table.insert(txttab, translate.Get("attack_special"))
		table.insert(txttab, "\n")
	end

	if Attack.GetDescriptorText then
		table.insert(txttab, Attack:GetDescriptorText())
	end

	return table.concat(txttab)
end
function SWEP:DescribeAlt()
	if not self.Alt then return end

	if self.Alt.DoOverrideDescriptor then
		return self.Alt.GetDescriptorText()
	end

	local txttab = {}

	--Speed Mul
	local SpeedMul = self.Alt.SpeedMul
	if SpeedMul and SpeedMul ~= 1 then
		if SpeedMul > 1.5 then
			table.insert(txttab, translate.Get("speed_very_fast"))
		elseif SpeedMul > 1 then
			table.insert(txttab, translate.Get("speed_fast"))
		elseif SpeedMul < 0.5 then
			table.insert(txttab, translate.Get("speed_very_slow"))
		else --if SpeedMul 0.5 < x < 1
			table.insert(txttab, translate.Get("speed_slow"))
		end
		table.insert(txttab, "\n")
	end

	--Regen
	local regen = self.Alt.Regen
	if regen and regen > 0 then
		table.insert(txttab, translate.GetFormatted("regenerates",regen))
		table.insert(txttab, "\n")
	end

	--DamageTaken
	local DamageTakenMul = self.Alt.DamageTakenMul
	if DamageTakenMul and DamageTakenMul ~= 1 then
		if DamageTakenMul > 1.5 then
			table.insert(txttab, translate.Get("damage_taken_much_more"))
		elseif DamageTakenMul > 1 then
			table.insert(txttab, translate.Get("damage_taken_more"))
		elseif DamageTakenMul < 0.5 then
			table.insert(txttab, translate.Get("damage_taken_much_less"))
		else
			table.insert(txttab, translate.Get("damage_taken_less"))
		end
		table.insert(txttab, "\n")
	end

	--DamageDealt
	local DamageDealtMul = self.Alt.DamageDealtMul
	if DamageDealtMul and DamageDealtMul ~= 1 then
		if DamageDealtMul > 1.5 then
			table.insert(txttab, translate.Get("damage_dealt_much_more"))
		elseif DamageDealtMul > 1 then
			table.insert(txttab, translate.Get("damage_dealt_more"))
		elseif DamageDealtMul < 0.5 then
			table.insert(txttab, translate.Get("damage_dealt_much_less"))
		else
			table.insert(txttab, translate.Get("damage_dealt_less"))
		end
		table.insert(txttab, "\n")
	end

	if self.Alt.CanAttack and #txttab > 0 then
		table.insert(txttab, translate.Get("can_attack"))
		table.insert(txttab, "\n")
	end

	if self.Alt.GetDescriptorText then
		table.insert(txttab, self.Alt.GetDescriptorText())
	end

	return table.concat(txttab)
end

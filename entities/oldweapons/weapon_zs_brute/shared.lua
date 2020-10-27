DEFINE_BASECLASS("weapon_zs_zombie")

SWEP.PrintName = "Brute"

SWEP.MeleeReach = 48
SWEP.MeleeDelay = 0.9
SWEP.MeleeSize = 4.5
SWEP.MeleeDamage = 40
SWEP.MeleeDamageType = DMG_SLASH
SWEP.MeleeAnimationDelay = 0.35

SWEP.MeleeForceScale = 5

SWEP.Primary.Delay = 1.6
SWEP.Secondary.Delay = 4

SWEP.PoisonThrowDelay = 1
SWEP.PoisonThrowSpeed = 380

SWEP.ViewModel = Model("models/weapons/v_pza.mdl")
SWEP.WorldModel = ""

function SWEP:Think()
	BaseClass.Think(self)

	local time = CurTime()

	if self.NextThrowAnim and time >= self.NextThrowAnim and IsFirstTimePredicted() then
		self.NextThrowAnim = nil

		self:EmitSound(string.format("physics/body/body_medium_break%d.wav", math.random(2, 4)), 72, math.random(70, 83))
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		self.IdleAnimation = time + self:SequenceDuration()
	end

	if self.NextThrow then
		if time >= self.NextThrow and IsFirstTimePredicted() then
			self.NextThrow = nil

			local owner = self:GetOwner()

			owner.LastRangedAttack = CurTime()

			owner:ResetSpeed()
			owner:RawCapLegDamage(CurTime() + 1.5)

			self:EmitSound(string.format("physics/body/body_medium_break%d.wav", math.random(2, 4)), 72, math.random(70, 80))

			if SERVER then
				self:DoThrow()
			end
		end

		self:NextThink(time)
		return true
	end
end

function SWEP:PrimaryAttack()
	if not self.NextThrow then
		BaseClass.PrimaryAttack(self)
	end
end

function SWEP:StartSwinging()
	if not IsFirstTimePredicted() then return end

	local owner = self:GetOwner()
	local armdelay = owner:GetMeleeSpeedMul()

	self.MeleeAnimationMul = 1 / armdelay
	if self.MeleeAnimationDelay then
		self.NextAttackAnim = CurTime() + self.MeleeAnimationDelay * armdelay
	else
		self:SendAttackAnim()
	end

	self:DoSwingEvent()

	self:PlayAttackSound()

	self:StopMoaning()

	if self.FrozenWhileSwinging then
		self:GetOwner():SetSpeed(1)
	end

	if self.MeleeDelay > 0 then
		self:SetSwingEndTime(CurTime() + self.MeleeDelay * armdelay)

		local trace = owner:CompensatedMeleeTrace(self.MeleeReach, self.MeleeSize, owner:GetShootPos(), owner:GetAimVector(), true)
		if trace.HitNonWorld and not trace.Entity:IsPlayer() then
			trace.IsPreHit = true
			self.PreHit = trace
		end

		self.IdleAnimation = CurTime() + (self:SequenceDuration() + (self.MeleeAnimationDelay or 0)) * armdelay
	else
		self:Swung()
	end
end

function SWEP:Swung()
	if not IsFirstTimePredicted() then return end

	local owner = self:GetOwner()

	local hit = false
	local traces = owner:CompensatedZombieMeleeTrace(self.MeleeReach, self.MeleeSize, owner:GetShootPos(), owner:GetAimVector(), true)
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
			if prehit.Entity:IsValid() and prehit.Entity:NearestPoint(eyepos):DistToSqr(eyepos) <= self.MeleeReach * self.MeleeReach then
				table.insert(traces, prehit)
			end
		end
		self.PreHit = nil
	end

	local damage = self:GetDamage(self:GetTracesNumPlayers(traces))
	local effectdata = EffectData()
	local ent

	for _, trace in ipairs(traces) do
		if not trace.Hit then continue end

		ent = trace.Entity

		hit = true

		if trace.HitWorld then
			self:MeleeHitWorld(trace)
		elseif ent and ent:IsValid() then
			if ent:IsPlayer() then
				local isFriend = ent:Team() == owner:Team()
				ent:ThrowFromPositionSetZ(self:GetOwner():GetPos(), damage * 2.5 * self.MeleeForceScale, 0.7, true)
				ent:MeleeViewPunch(damage)

				if not isFriend then
					self:ApplyMeleeDamage(ent, trace, damage)
					local nearest = ent:NearestPoint(trace.StartPos)
					util.Blood(nearest, math.Rand(damage * 0.5, damage * 0.75), (nearest - trace.StartPos):GetNormalized(), math.Rand(damage * 5, damage * 10), true)
				end
			else
				self:MeleeHitEntity(ent, trace, damage)
				self:ApplyMeleeDamage(ent, trace, damage)
			end
		end

		--if IsFirstTimePredicted() then
			effectdata:SetOrigin(trace.HitPos)
			effectdata:SetStart(trace.StartPos)
			effectdata:SetNormal(trace.HitNormal)
			util.Effect("RagdollImpact", effectdata)
			if not trace.HitSky then
				effectdata:SetSurfaceProp(trace.SurfaceProps)
				effectdata:SetDamageType(self.MeleeDamageType) --effectdata:SetDamageType(DMG_BULLET)
				effectdata:SetHitBox(trace.HitBox)
				effectdata:SetEntity(ent)
				util.Effect("Impact", effectdata)
			end
		--end
	end

	--if IsFirstTimePredicted() then
		if hit then
			self:PlayHitSound()
		else
			self:PlayMissSound()
		end
	--end

	if self.FrozenWhileSwinging then
		owner:ResetSpeed()
	end
end

function SWEP:MeleeHit(ent, trace, damage, forcescale, phantomDamage)
	phantomDamage = phantomDamage or false
	if ent:IsPlayer() then
		self:MeleeHitPlayer(ent, trace, damage, forcescale)
	else
		self:MeleeHitEntity(ent, trace, damage, forcescale)
	end
	if not phantomDamage then
		self:ApplyMeleeDamage(ent, trace, damage)
	end
end

function SWEP:MeleeHitPlayer(ent, trace, damage, forcescale)
	ent:ThrowFromPositionSetZ(self:GetOwner():GetPos(), damage * 2.5 * (forcescale or self.MeleeForceScale))
	ent:MeleeViewPunch(damage)
	local nearest = ent:NearestPoint(trace.StartPos)
	util.Blood(nearest, math.Rand(damage * 0.5, damage * 0.75), (nearest - trace.StartPos):GetNormalized(), math.Rand(damage * 5, damage * 10), true)
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end

	local time = CurTime()
	if time < self:GetNextPrimaryFire() or time < self:GetNextSecondaryFire() then return end

	local owner = self:GetOwner()

	owner:DoAnimationEvent(ACT_RANGE_ATTACK2)
	owner:SetSpeed(60)

	self:EmitSound("NPC_PoisonZombie.Throw")

	self:SetNextSecondaryFire(time + self.Secondary.Delay)
	self:SetNextPrimaryFire(time + self.Primary.Delay)

	self.NextThrow = time + self.PoisonThrowDelay
	self.NextThrowAnim = self.NextThrow - 0.4
end

function SWEP:Reload()
	if not self.NextThrow then
		BaseClass.SecondaryAttack(self)
	end
end

function SWEP:CheckMoaning()
end

function SWEP:StopMoaningSound()
end

function SWEP:StartMoaningSound()
end

function SWEP:PlayHitSound()
	self:EmitSound("npc/zombie/claw_strike"..math.random(1, 3)..".wav", 75, 80, nil, CHAN_AUTO)
end

function SWEP:PlayMissSound()
	self:EmitSound("npc/zombie/claw_miss"..math.random(1, 2)..".wav", 75, 80, nil, CHAN_AUTO)
end

function SWEP:PlayAttackSound()
	self:EmitSound("NPC_PoisonZombie.ThrowWarn")
end

function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("NPC_PoisonZombie.Alert")
end
SWEP.PlayIdleSound = SWEP.PlayAlertSound

INC_SERVER()

function ENT:Initialize()
	self.DieTime = CurTime() + 30

	self:SetModel("models/weapons/w_eq_flashbang.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetTrigger(true)
	self:SetupGenericProjectile(true)
end

function ENT:Think()
	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal)
	end

	if self.DieTime <= CurTime() then
		self:Remove()
	end
end

function ENT:PhysicsCollide(data, phys)
	if data.Speed >= 50 then
		self.PhysicsData = data
		self:NextThink(CurTime())
	end
end

function ENT:StartTouch(ent)
	if self.DieTime ~= 0 and ent:IsValidLivingPlayer() then
		local owner = self:GetOwner()
		if not owner:IsValid() then owner = self end

		if ent ~= owner and ent:Team() ~= self.Team then
			ent:EmitSound("weapons/crossbow/hitbod"..math.random(2)..".wav")
			self:Explode()
		end
	end
end

function ENT:Explode(hitpos, hitnormal)
	if self.DieTime == 0 then return end
	self.DieTime = 0

	local owner = self:GetOwner()
	if owner:IsValidHuman() then
		local pos = self:GetPos()

		--knock back everyone
		util.BlastDamagePlayer(self, owner, pos, self.GrenadeRadius or 256, 0, DMG_ALWAYSGIB, .25, false, self.GrenadeKnockback or 200)

		local effectdata = EffectData()
			effectdata:SetOrigin(pos + Vector(0, 0, -1))
			effectdata:SetNormal(Vector(0, 0, -1))
		util.Effect("decal_scorch", effectdata)
		util.Effect("explosion_impulse",effectdata)

		--self:EmitSound("npc/env_headcrabcanister/explosion.wav", 85, 100)
		--ParticleEffect("dusty_explosion_rockets", pos, angle_zero)
	end

	self:NextThink(CurTime())
end

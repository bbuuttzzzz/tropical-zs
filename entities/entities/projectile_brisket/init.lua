INC_SERVER()

ENT.LifeTime = 100
ENT.ESize = 250

function ENT:Initialize()
	self:SetModel("models/Gibs/HGIBS.mdl")
	self:PhysicsInitSphere(20) --self:PhysicsInitSphere(13)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetModelScale(0, 0) --self:SetModelScale(2.5, 0)
	self:SetupGenericProjectile(true)
	self:SetMaterial("models/charple/charple1_sheet")
	self:SetColor(Color(0,0,0,0))

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end

	self.DeathTime = CurTime() + self.LifeTime
	self.ExplodeTime = CurTime() + self.LifeTime
	self:EmitSound("NPC_FastZombie.Gurgle")
end

function ENT:Think()
	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end
	if self.DeathTime <= CurTime() then
		self:StopSound("NPC_FastZombie.Gurgle")
		self:Remove()
	end
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		local curVel = phys:GetVelocity()
		phys:SetVelocityInstantaneous(Vector(curVel.x,curVel.y,curVel.z-.3))
	end
	self:NextThink(CurTime())
	return true
end

function ENT:Explode(hitpos, hitnormal, hitent)
	self:StopSound("NPC_FastZombie.Gurgle")
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
	util.Effect("explosion_brisket", effectdata)

		for _, pl in pairs(ents.FindInSphere(hitpos, self.ESize)) do
			if pl:IsValidLivingHuman() then
					pl:AddCrippleDamage(35, attacker)
				  pl:GiveStatus("knockdown", 1)
			end
		end
		for _, pl in pairs(ents.FindInSphere(hitpos, self.ESize*2)) do
			if pl:IsValidLivingHuman() then
					pl:AddCrippleDamage(10, attacker)
			end
		end
end

function ENT:PhysicsCollide(data, physobj)
	self.PhysicsData = data
	self:NextThink(CurTime())
end

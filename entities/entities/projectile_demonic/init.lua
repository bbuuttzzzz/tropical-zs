INC_SERVER()

ENT.LifeTime = 5
ENT.ESize = 75
ENT.Damage = 1
ENT.DamagePoison = 4

function ENT:Initialize()
	self:SetModel("models/Gibs/HGIBS.mdl")
	self:PhysicsInitSphere(10) --self:PhysicsInitSphere(13)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetModelScale(0, 0) --self:SetModelScale(2.5, 0)
	self:SetupGenericProjectile(true)
	self:SetMaterial("models/charple/charple1_sheet")
	self:SetColor(Color(0,0,0,0))
	self:EmitSound("npc/scanner/scanner_blip1.wav",30,math.random(25,255))

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		//phys:EnableGravity(false)
		phys:Wake()
	end

	self.DeathTime = CurTime() + self.LifeTime
	self.ExplodeTime = CurTime() + self.LifeTime
	//self:EmitSound("NPC_FastZombie.Gurgle")
end

function ENT:Think()
	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	if self.DeathTime <= CurTime() then
		//self:StopSound("NPC_FastZombie.Gurgle")
		self:Remove()
	end



	self:NextThink(CurTime())
	return true
end

function ENT:Explode(hitpos, hitnormal, hitent)
	//self:StopSound("NPC_FastZombie.Gurgle")
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
	util.Effect("explosion_demonic", effectdata)

	for _, pl in pairs(ents.FindInSphere(hitpos, self.ESize)) do
		if pl:IsValidLivingHuman() then
			pl:AddPoisonDamage(self.DamagePoison,owner)
			pl:TakeSpecialDamage(self.Damage, DMG_GENERIC, owner, self)
		end
	end
end

function ENT:PhysicsCollide(data, physobj)
	self.PhysicsData = data
	self:NextThink(CurTime())
end

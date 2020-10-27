INC_SERVER()
function ENT:Initialize()
	self.DeathTime = CurTime() + 350

	self:PhysicsInitSphere(1)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetupGenericProjectile(false)
end

function ENT:Think()
	if self.DeathTime <= CurTime() then
		self:Remove()
	end
end

function ENT:Explode(vHitPos, vHitNormal, eHitEntity)
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end
end

function ENT:PhysicsCollide(data, phys)
	self:NextThink(CurTime())
end

INC_SERVER()

ENT.DamagePoison = 15
ENT.HeadshotCrippleDamage = 20

function ENT:Initialize()
	self:SetModel("models/props/cs_italy/orange.mdl")
	self:PhysicsInitSphere(1)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(Color(0, 255, 0, 255))
	self:SetupGenericProjectile(false)

	self:Fire("kill", "", 15)
	self.LastPhysicsUpdate = UnPredictedCurTime()
end

local vecDown = Vector()
function ENT:PhysicsUpdate(phys)
	local dt = (UnPredictedCurTime() - self.LastPhysicsUpdate)
	self.LastPhysicsUpdate = UnPredictedCurTime()

	vecDown.z = dt * -500
	phys:AddVelocity(vecDown)
end

function ENT:Think()
	if self.PhysicsData then
		self:Hit(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	if self.Exploded then
		self:Remove()
	end
end

function ENT:Hit(vHitPos, vHitNormal, eHitEntity)
	if self.Exploded then return end
	self.Exploded = true

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	vHitPos = vHitPos or self:GetPos()
	vHitNormal = vHitNormal or Vector(0, 0, 1)

	if eHitEntity:IsValidLivingPlayer() and gamemode.Call("PlayerShouldTakeDamage", eHitEntity, owner) then

		eHitEntity:AddPoisonDamage(self.DamagePoison, owner)

		local attach = eHitEntity:GetAttachment(1)
		if attach and vHitPos:DistToSqr(attach.Pos) <= 324 then --18^2
			eHitEntity:PlayEyePainSound()
			eHitEnitty:AddCrippleDamage(self.HeadshotCrippleDamage, owner)
			local status = eHitEntity:GiveStatus("dimvision", 5)
			if status then
				status.EyeEffect = true
			end
		end
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(vHitPos)
		effectdata:SetNormal(vHitNormal)
	util.Effect("hit_spit", effectdata)
end

function ENT:OnRemove()
	if not self.Exploded then
		local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetNormal(self:GetVelocity():GetNormalized())
		util.Effect("hit_spit", effectdata)
	end
end

function ENT:PhysicsCollide(data, phys)
	if not self:HitFence(data, phys) then
		self.PhysicsData = data
	end

	self:NextThink(CurTime())
end

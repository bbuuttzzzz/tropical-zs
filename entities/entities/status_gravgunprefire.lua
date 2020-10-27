AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "status__base"

ENT.LifeTime = 1

ENT.Ephemeral = true

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self.DieTime = CurTime() + self.LifeTime
end



function ENT:OnRemove()
	local owner = self:GetOwner()
	owner:SetGravity(1)
end

function ENT:Think()
	if not self.Activated and self:GetOwner():IsValid() then
		self.Activated = true
		local owner = self:GetOwner()
		owner:SetGravity(0)
		owner:SetGroundEntity(NULL)
		owner:SetVelocity(Vector(0,0,1))
	end
	if SERVER then
		if self.DieTime < CurTime() then
			self:Remove()
		end
	end
	self:NextThink( CurTime() )
	return true
end

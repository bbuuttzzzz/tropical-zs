INC_CLIENT()

function ENT:Draw()
end

function ENT:Initialize()
	self:GetOwner().Radiation = self
end

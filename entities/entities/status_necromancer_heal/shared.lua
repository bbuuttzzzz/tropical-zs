ENT.Type = "anim"
ENT.Base = "status__base"

ENT.Ephemeral = true
ENT.MaxAmount = 200

function ENT:AddAmount(amount, healer)

	local diff = self:GetAmount() + amount - self.MaxAmount

	self:SetAmount(self:GetAmount() + amount)

	if SERVER and attacker then
		self.Healer = healer
	end

	if diff > 0 then
		return amount - diff
	else
		return amount
	end
end

function ENT:SetAmount(amount)
	self:SetDTFloat(0, math.min(self.MaxAmount, amount))
end

function ENT:GetAmount()
	return self:GetDTFloat(0)
end

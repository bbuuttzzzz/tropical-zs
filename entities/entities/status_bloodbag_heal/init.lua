INC_SERVER()

local tickrate = 1
local tickheal = 10

function ENT:PlayerSet(pPlayer, bExists)
end

function ENT:Think()
	local owner = self:GetOwner()

	if self:GetAmount() <= 0 or owner.BossHealRemaining and owner.BossHealRemaining <= 0 then
		self:Remove()
		return
	end

	local amt = math.Clamp(self:GetAmount(), 1, tickheal)
	local healer = self.Healer and self.Healer:IsValid() and self.Healer:IsPlayer() and self.Healer or owner

	healer:HealPlayer(owner,amt,0,nil,1.25)
	self:AddAmount(-amt)

	if owner.BossHealRemaining and owner.BossHealRemaining > 0 then
		owner.BossHealRemaining = owner.BossHealRemaining - amt
	end

	self:NextThink(CurTime() + tickrate)
	return true
end

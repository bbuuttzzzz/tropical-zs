INC_SERVER()

local tickrate = 1
local tickdamage = 2

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer.Bleed = self
end

function ENT:Think()
	local owner = self:GetOwner()

	if self:GetDamage() <= 0 then
		self:Remove()
		return
	end

	local damage = math.Clamp(self:GetDamage(), 1, tickdamage)
	local attacker = self.Damager and self.Damager:IsValid() and self.Damager:IsPlayer() and self.Damager:Team() ~= owner:Team() and self.Damager or owner

	owner:TakeSpecialDamage(damage, DMG_ACID, attacker, self)
	self:AddDamage(-damage)

	owner:EmitSound("player/pl_pain"..math.random(5, 7)..".wav")


	self:NextThink(CurTime() + tickrate)
	return true
end

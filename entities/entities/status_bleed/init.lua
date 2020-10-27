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

	local dmg = math.Clamp(self:GetDamage(), 1, tickdamage)
	local attacker = self.Damager and self.Damager:IsValid() and self.Damager:IsPlayer() and self.Damager:Team() ~= owner:Team() and self.Damager or owner

	owner:TakeDamage(dmg, attacker, self)
	self:AddDamage(-dmg)

	local dir = VectorRand()
	dir:Normalize()
	util.Blood(owner:WorldSpaceCenter(), 3, dir, 32)

	self:NextThink(CurTime() + tickrate)
	return true
end

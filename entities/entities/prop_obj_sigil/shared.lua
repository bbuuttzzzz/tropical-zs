ENT.Type = "anim"

ENT.MaxHealth = 100
ENT.HealthRegen = .15
ENT.RegenDelay = 2

ENT.ModelScale = 0.55

ENT.m_NoNailUnfreeze = true
ENT.NoNails = true
ENT.IsBarricadeObject = true

ENT.HEAL = 1
ENT.HEALTIME = 3

AccessorFuncDT(ENT, "SigilHealthBase", "Float", 0)
AccessorFuncDT(ENT, "SigilHealthRegen", "Float", 1)
--AccessorFuncDT(ENT, "SigilLastDamaged", "Float", 2)

function ENT:SetSigilHealth(health)
	self:SetSigilHealthBase(health)
	--self:SetSigilLastDamaged(math.max(self:GetSigilLastDamaged(), self:GetSigilHealthRegen() - self.RegenDelay))
end

function ENT:GetSigilHealth()
  return self:GetSigilHealthBase()
end

function ENT:GetSigilMaxHealth()
	return self.MaxHealth
end

function ENT:Think()
	if self.HEALTIME <= CurTime() then
		for x, ent in pairs(ents.FindInBox(self:GetPos()+ Vector(-25,-25,0),self:GetPos() + Vector(25,25,75))) do
			if ent:IsValidLivingHuman() and gamemode.Call("PlayerCanBeHealed", ent) then
				self:HealPlayer(ent, self.HEAL * 2)
			end
		end
		self.HEALTIME = CurTime() + 3
	end

	if self.RegenDelay < CurTime() then

		if self:GetSigilHealth() > self:GetSigilMaxHealth() then
			self:SetSigilHealth(self:GetSigilMaxHealth())
		end
		if self:GetSigilHealth() < self:GetSigilMaxHealth() then
			self:SetSigilHealth(self:GetSigilHealth() + self.HealthRegen)
			self:NextThink( CurTime() )
			return true

		end
	end

end

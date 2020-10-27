ENT.Type = "anim"
ENT.Base = "status__base"

ENT.Ephemeral = true
ENT.InitialDamageFrac = 0.05 //frac of zombie max HP
ENT.DamageRampingFrac = 1 //frac if InitialDamageFrac to add each tick
ENT.DamageDelay = 1 //time in seconds between each proc

function ENT:Initialize()
	self:DrawShadow(false)
	if self:GetDTFloat(1) == 0 then
		self:SetDTFloat(1, CurTime())
	end
	self:SetDamage(-1)
end

function ENT:AddDamage(damage)
	self:SetDamage(self:GetDamage() + damage)
end

function ENT:SetDamage(damage)
	self:SetDTFloat(0, damage)
end

function ENT:GetDamage()
	return self:GetDTFloat(0)
end

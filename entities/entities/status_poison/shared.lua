ENT.Type = "anim"
ENT.Base = "status__base"

ENT.Ephemeral = true

function ENT:Initialize()
	self:DrawShadow(false)
	if self:GetDTFloat(1) == 0 then
		self:SetDTFloat(1, CurTime())
	end
end

function ENT:AddDamage(damage, attacker)

	local diff = self:GetDamage() + damage - GAMEMODE.MaxPoisonDamage or 1000

	self:SetDamage(self:GetDamage() + damage)
	
	if SERVER and attacker then
		self.Damager = attacker
	end

	if diff > 0 then
		return damage - diff
	else
		return damage
	end
end

--"amount" is the total healing possible
function ENT:ApplyHeal(amount)
	local power = amount * GAMEMODE.PoisonHealRate

	local remainder = power - self:GetDamage()

	if remainder >= 0 then
		self:SetDamage(0)
		return remainder / GAMEMODE.PoisonHealRate
	else
		self:SetDamage(-1 * remainder)
		return 0
	end
end

function ENT:SetDamage(damage)
	self:SetDTFloat(0, math.min(GAMEMODE.MaxPoisonDamage or 1000, damage))
end

function ENT:GetDamage()
	return self:GetDTFloat(0)
end

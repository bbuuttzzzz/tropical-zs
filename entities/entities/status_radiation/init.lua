INC_SERVER()

local tickrate = 2
local tickdamagefrac = 0.15
local mindamage = 2

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer.Radiation = self
end

function ENT:Think()
	local owner = self:GetOwner()

	if self:GetDamage() <= 0 then
		self:Remove()
		return
	end

	local damage = math.Clamp(self:GetDamage(), mindamage, self:GetDamage() * tickdamagefrac)
	local attacker = self.Damager and self.Damager:IsValid() and self.Damager:IsPlayer() and self.Damager:Team() ~= owner:Team() and self.Damager or owner

	owner:TakeSpecialDamage(damage, DMG_RADIATION, attacker, self)
	self:AddDamage(-damage)

	owner:EmitSound("npc/barnacle/neck_snap"..math.random(1, 2)..".wav")


	self:NextThink(CurTime() + tickrate)
	return true
end

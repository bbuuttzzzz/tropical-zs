INC_SERVER()

function ENT:SetDie(fTime)
	if fTime == 0 or not fTime then
		self.DieTime = 0
	elseif fTime == -1 then
		self.DieTime = 999999999
	elseif fTime == -2 then
		self.DieTime = math.max(CurTime(),self.DieTime)
	else
		self.DieTime = CurTime() + fTime
		self:SetDuration(fTime)
		self:SetStartTime(CurTime())
	end
end

function ENT:AddDamage(damage)
	local curtime = CurTime()
	local remainingDuration = self.DieTime - curtime

	local remainder = (remainingDuration + damage * 0.01 * self.MaxDuration) - self.MaxDuration
	--if we hit the cap, remainder should be > 0 by an amount in seconds over the cap
	--if we didn't hit the cap, remainder should be < 0 by an amount in seconds under the cap

	--remove the amount under the cap we are in seconds from max to get new ftime,
	--but if we are at or above the cap we should just set it to self.MaxDuration
	local ftime = self.MaxDuration + math.min(remainder,0)

	self:SetDie(ftime)

	--we should return the amount of damage actually applied
	return damage - math.max(remainder,0) / 0.01 / self.MaxDuration
end

function ENT:HumanKilledZombie(pl, attacker, inflictor, dmginfo, headshot, suicide)
	if attacker ~= self:GetOwner() then return end

	if attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN then
		local hermesStatus = attacker:GiveStatus("hermes", 5)
	end
end

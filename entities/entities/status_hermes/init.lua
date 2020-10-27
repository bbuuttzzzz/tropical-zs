INC_SERVER()

function ENT:SetDie(fTime)
	if fTime == 0 or not fTime then
		self.DieTime = 0
	elseif fTime == -1 then
		self.DieTime = 999999999
	else
		self.DieTime = CurTime() + fTime
		self:SetDuration(fTime)
	end
end

function ENT:HumanKilledZombie(pl, attacker, inflictor, dmginfo, headshot, suicide)
	if attacker ~= self:GetOwner() then return end

	if attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN then
		local hermesStatus = attacker:GiveStatus("hermes", 5)
	end
end

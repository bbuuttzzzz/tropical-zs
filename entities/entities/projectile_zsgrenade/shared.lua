ENT.Type = "anim"

ENT.LifeTime = 5

ENT.NoPropDamageDuringWave0 = true

function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN
end

--setting this effectively resets elapsed time to zero
function ENT:SetLifeTime(time)
	self:SetDTFloat(0,time + CurTime())
end

function ENT:SetDieTime(time)
	self:SetDTFloat(0,time)
end

function ENT:GetDieTime()
	return self:GetDTFloat(0)
end

util.PrecacheSound("physics/metal/metal_grenade_impact_hard1.wav")
util.PrecacheSound("physics/metal/metal_grenade_impact_hard2.wav")
util.PrecacheSound("physics/metal/metal_grenade_impact_hard3.wav")

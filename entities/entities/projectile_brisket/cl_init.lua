INC_CLIENT()

ENT.NextEmit = 0

function ENT:Initialize()
	self:SetModelScale(0, 0)
	self:SetMaterial("models/charple/charple1_sheet")
end

function ENT:Draw()
	self:DrawModel()
	self:SetColor(Color(0,0,0,0))
	if CurTime() >= self.NextEmit and self:GetVelocity():LengthSqr() >= 256 then
		self.NextEmit = CurTime() + 0.015

		local emitter = ParticleEmitter(self:GetPos())
		emitter:SetNearClip(16, 24)

		local particle = emitter:Add("!sprite_bloodspray"..math.random(8), self:GetPos())
		particle:SetVelocity(self:GetVelocity():GetNormalized() * math.Rand(-100,15) )
		particle:SetDieTime(1)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(25,100))
		particle:SetEndSize(math.Rand(10,25))
		particle:SetRoll(math.Rand(-1, 1))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetColor(math.Rand(0,100), 0, 0)
		particle:SetLighting(true)

		local particle2 = emitter:Add("!sprite_bloodspray"..math.random(8), self:GetPos())
		particle2:SetVelocity(VectorRand())
		particle2:SetDieTime(1)
		particle2:SetStartAlpha(255)
		particle2:SetEndAlpha(0)
		particle2:SetStartSize(math.random(20,50))
		particle2:SetEndSize(0)
		particle2:SetStartLength(math.random(100,150))
		particle2:SetEndLength(0)
		particle2:SetRoll(math.Rand(-1, 1))
		particle2:SetRollDelta(math.Rand(-1, 1))
		particle2:SetColor(math.Rand(0,100), 0, 0)
		particle2:SetLighting(true)

		emitter:Finish() emitter = nil collectgarbage("step", 64)
	end
end

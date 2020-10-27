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
		self.NextEmit = CurTime() + 0.05

		local emitter = ParticleEmitter(self:GetPos())
		emitter:SetNearClip(16, 24)

		local particle = emitter:Add("!sprite_bloodspray1", self:GetPos())
		particle:SetVelocity( self:GetVelocity():GetNormalized() * math.Rand(0,255) + (VectorRand():GetNormalized() * 150) )
		particle:SetDieTime(1)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(10,25))
		particle:SetEndSize(math.Rand(0,10))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-25, 25))
		particle:SetColor(96, 64, 32)
		particle:SetLighting(true)

		emitter:Finish() emitter = nil collectgarbage("step", 64)
	end
end

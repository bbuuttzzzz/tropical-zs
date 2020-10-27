function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

function EFFECT:Init(data)
	local pos = data:GetOrigin()

	sound.Play("npc/barnacle/barnacle_pull"..math.random(1,4)..".wav", pos, 80, math.Rand(65, 125))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 48)

	local particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos)
	particle:SetDieTime(0.3)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(1)
	particle:SetEndSize(200)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(40, 60) * (math.random(2) == 1 and -1 or 1))
	particle:SetColor(96, 64, 32)
	particle:SetLighting(true)

	for i = 1, math.random(5, 15) do
		particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos)
		particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(5, 300))
		particle:SetAirResistance(100)
		particle:SetDieTime(math.Rand(0.9, 2))
		particle:SetStartAlpha(math.Rand(100,255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(1, 8))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-30, 30))
		particle:SetColor(96, 64, 32)
		particle:SetLighting(true)
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)

end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

function EFFECT:Init(data)
	local pos = data:GetOrigin()

	for i = 1, 5 do
		self:EmitSound("weapons/gauss/fire1.wav",45,25 + (i*i) )
	end

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 48)

	for i = 1, 35 do
		local ang = data:GetAngles()

		ang:RotateAroundAxis(ang:Forward(),i*math.random(-1,1))
		ang:RotateAroundAxis(ang:Up(),i*math.random(-1,1))
		ang:RotateAroundAxis(ang:Right(),i*math.random(-1,1))

		local finalDir = ang:Forward()

		local particle = emitter:Add("effects/splash2", pos)
			particle:SetDieTime(math.random(4.5,5))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(75)
			particle:SetEndSize(300)
			particle:SetVelocity(finalDir * math.random(450,3550))
			particle:SetRoll(math.Rand(-10, 10))
			particle:SetRollDelta(math.Rand(-1, 1) * (math.random(2) == 1 and -1 or 1))
			particle:SetColor(25, 15, 7)
			particle:SetGravity(Vector(0,0,math.random(-20,-150)))
			particle:SetAirResistance(math.random(350,550))
		particle:SetLighting(false)

	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)

end

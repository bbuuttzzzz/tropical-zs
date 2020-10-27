function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

function EFFECT:Init(data)

	local pos = data:GetOrigin()

	for i = 1,5 do
		sound.Play("weapons/underwater_explode"..math.random(3,4)..".wav", pos, 60, 195 + (i * 10) + 5)
	end

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 48)

	for i = 1, 100 do
		local ang = data:GetAngles()

		ang:RotateAroundAxis(ang:Forward(),i*math.random(-0.3,0.3))
		ang:RotateAroundAxis(ang:Up(),i*math.random(-0.3,0.3))
		ang:RotateAroundAxis(ang:Right(),i*math.random(-0.3,0.3))

		local finalDir = ang:Forward()

		local particle = emitter:Add("effects/yellowflare", pos)
			particle:SetDieTime(math.random(10,25))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(5)
			particle:SetEndSize(0)
			particle:SetVelocity(finalDir * math.random(450,1550))
			particle:SetRoll(math.Rand(-10, 10))
			particle:SetRollDelta(math.Rand(-1, 1) * (math.random(2) == 1 and -1 or 1))
			particle:SetColor(math.random(100,255),math.random(100,255), math.random(100,255))
			particle:SetGravity(Vector(math.random(-30,30),math.random(-30,30),math.random(-20,-250)))
			particle:SetAirResistance(math.random(150,550))
			particle:SetCollide(true)
			particle:SetLighting(false)

	end

	for i = 1, 100 do
		local ang = data:GetAngles()

		ang:RotateAroundAxis(ang:Forward(),i*math.random(-0.3,0.3))
		ang:RotateAroundAxis(ang:Up(),i*math.random(-0.3,0.3))
		ang:RotateAroundAxis(ang:Right(),i*math.random(-0.3,0.3))

		local finalDir = ang:Forward()

		local particle = emitter:Add("effects/spark", pos)
			particle:SetDieTime(math.random(10,25))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(5)
			particle:SetEndSize(0)
			particle:SetVelocity(finalDir * math.random(450,1550))
			particle:SetRoll(math.Rand(-10, 10))
			particle:SetRollDelta(math.Rand(-1, 1) * (math.random(2) == 1 and -1 or 1))
			particle:SetColor(math.random(100,255),math.random(100,255), math.random(100,255))
			particle:SetGravity(Vector(math.random(-30,30),math.random(-30,30),math.random(-20,-250)))
			particle:SetAirResistance(math.random(150,550))
			particle:SetCollide(true)
			particle:SetLighting(false)

	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)

end

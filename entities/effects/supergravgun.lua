function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

function EFFECT:Init(data)

	local pos = data:GetOrigin()

	for i = 1,5 do
		sound.Play("weapons/physcannon/superphys_launch".. math.random(1,4)..".wav",pos, 155, 205 + (i*10))
		sound.Play("weapons/rpg/rocketfire1.wav", pos, 70, 15 + (i * 30))
	end

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 48)

	for i = 1, 2 do
		local ang = data:GetAngles()

		ang:RotateAroundAxis(ang:Forward(),i*math.random(-0.3,0.3))
		ang:RotateAroundAxis(ang:Up(),i*math.random(-0.3,0.3))
		ang:RotateAroundAxis(ang:Right(),i*math.random(-0.3,0.3))

		local finalDir = ang:Forward()

		local particle = emitter:Add("effects/rollerglow", pos)
		local col = math.random(180,230)
			particle:SetDieTime(.6*i)
			particle:SetStartAlpha(100*i)
			particle:SetEndAlpha(0)
			particle:SetStartSize(0)
			particle:SetEndSize(1550*i)
			particle:SetVelocity(Vector(0,0,0))
			particle:SetRoll(math.Rand(-10, 10))
			particle:SetRollDelta(math.Rand(-1, 1) * (math.random(2) == 1 and -1 or 1))
			particle:SetColor(225,225,225)
			particle:SetGravity(Vector(0,0,0))
			particle:SetAirResistance(500)
		particle:SetLighting(false)

	end

	for i = 1, 250 do
		local ang = data:GetAngles()

		ang:RotateAroundAxis(ang:Forward(),i*math.random(-0.3,0.3))
		ang:RotateAroundAxis(ang:Up(),i*math.random(-0.3,0.3))
		ang:RotateAroundAxis(ang:Right(),i*math.random(-0.3,0.3))

		local finalDir = ang:Forward()

		local particle = emitter:Add("effects/spark", pos)
		local col = math.random(180,230)
			particle:SetDieTime(math.random(2,4))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(math.random(.07,.1)*i)
			particle:SetEndSize(0)
			particle:SetStartLength(math.random(1,3)*i)
			particle:SetVelocity(finalDir * math.random(1,25)*i)
			particle:SetRoll(math.Rand(-10, 10))
			particle:SetRollDelta(math.Rand(-1, 1) * (math.random(2) == 1 and -1 or 1))
			particle:SetColor(col,col, 255)
			particle:SetGravity(Vector(0,0,math.random(-250,5)))
			particle:SetAirResistance(math.random(-5,-100))
		particle:SetLighting(false)

	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)

end

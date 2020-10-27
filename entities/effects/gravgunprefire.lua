function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

function EFFECT:Init(data)
  local pos = data:GetOrigin()

  local emitter = ParticleEmitter(pos)
  emitter:SetNearClip(16, 48)

  for i = 1, 250 do
		local ang = data:GetAngles()

		ang:RotateAroundAxis(ang:Forward(),i*math.random(-0.3,0.3))
		ang:RotateAroundAxis(ang:Up(),i*math.random(-0.3,0.3))
		ang:RotateAroundAxis(ang:Right(),i*math.random(-0.3,0.3))

		local finalDir = ang:Forward()

		local particle = emitter:Add("effects/yellowflare", pos)
			particle:SetDieTime(.1)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(math.random(1,5))
			particle:SetEndSize(0)
			particle:SetVelocity(finalDir * .1)
			particle:SetRoll(0)
			particle:SetRollDelta(0)
      particle:SetStartLength(math.random(25,2000))
      particle:SetEndLength(0)
			particle:SetColor(math.random(100,255),math.random(100,255), math.random(255,255))
			particle:SetGravity(Vector(0,0,0))
			particle:SetAirResistance(0)
			particle:SetCollide(false)
			particle:SetLighting(false)

	end
  	emitter:Finish() emitter = nil collectgarbage("step", 64)
end

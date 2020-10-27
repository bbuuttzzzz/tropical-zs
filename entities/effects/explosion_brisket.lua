function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

function EFFECT:Init(data)
	local pos = data:GetOrigin()

	for i = 1, 5 do
		self:EmitSound("weapons/fx/rics/ric".. i ..".wav",100, 5+ (i*i) )
		self:EmitSound("weapons/fx/rics/ric".. i ..".wav",100, 100+ (i*i) )
		self:EmitSound("weapons/physcannon/energy_bounce1.wav",100, 20+ (i*i) )
	end

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 48)

	local ang = data:GetAngles()
	local ang2 = data:GetAngles()
	local ang3 = data:GetAngles()


	for i = 1, 5 do
		local particle = emitter:Add("effects/blood_core", pos)
		particle:SetDieTime(1.5*i)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(5*i)
		particle:SetEndSize(100*i)
		particle:SetRoll(math.Rand(-.1, .1))
		particle:SetRollDelta(math.Rand(-.1, .1))
		particle:SetColor(25, 30, 30)
		particle:SetLighting(true)

		local particle2 = emitter:Add("effects/blood_core", pos)
		particle2:SetDieTime(.5*i)
		particle2:SetStartAlpha(255)
		particle2:SetEndAlpha(0)
		particle2:SetStartSize(5*i)
		particle2:SetEndSize(150*i)
		particle2:SetRoll(math.Rand(-.1, .1))
		particle2:SetRollDelta(math.Rand(-.1, .1))
		particle2:SetColor(25, 30, 30)
		particle2:SetLighting(true)

		local particle3 = emitter:Add("!sprite_bloodspray"..math.random(8), self:GetPos())
		particle3:SetDieTime(.3*i)
		particle3:SetStartAlpha(255)
		particle3:SetEndAlpha(0)
		particle3:SetStartSize(5*i)
		particle3:SetEndSize(250*i)
		particle3:SetRoll(math.Rand(-.1, .1))
		particle3:SetRollDelta(math.Rand(-.1, .1))
		particle3:SetColor(25, 30, 30)
		particle3:SetLighting(true)
	end

	for i = 1, 15 do
		local particle = emitter:Add("effects/blood_core", pos)
		particle:SetDieTime(math.random(1,5))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(10*i)
		particle:SetEndSize(50*i)
		particle:SetRoll(math.Rand(-.1, .1))
		particle:SetRollDelta(math.Rand(-.1, .1))
		particle:SetColor(25, 30, 30)
		particle:SetVelocity(Vector(math.random(-550,550),math.random(-550,550),math.random(-550,550)))
		particle:SetLighting(true)
		particle:SetAirResistance(math.random(50,250))
	end

	for i = 1, 250 do
		ang:RotateAroundAxis(ang:Right(),i*10)
		ang2:RotateAroundAxis(ang2:Up(),i*10)
		ang3:RotateAroundAxis(ang3:Forward(),i*10)

		local finalDir = ang:Forward()
		local finalDir2 = ang2:Forward()
		local finalDir3 = ang3:Right()

		local particle = emitter:Add("particles/smokey", pos)
		particle:SetVelocity(finalDir * i *10)
		particle:SetAirResistance(250)
		particle:SetDieTime(math.Rand(2, 3.5))
		particle:SetStartAlpha(math.Rand(100,255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(1)
		particle:SetStartLength(1)
		particle:SetEndLength(math.random(5,150))
		particle:SetEndSize(15)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-30, 30))
		particle:SetColor(25, 0, 0)
		particle:SetLighting(true)

		local particle2 = emitter:Add("particles/smokey", pos)
		particle2:SetVelocity(finalDir2 * i *10)
		particle2:SetAirResistance(250)
		particle2:SetDieTime(math.Rand(2, 3.5))
		particle2:SetStartAlpha(math.Rand(100,255))
		particle2:SetEndAlpha(0)
		particle2:SetStartSize(1)
		particle2:SetStartLength(1)
		particle2:SetEndLength(math.random(5,150))
		particle2:SetEndSize(15)
		particle2:SetRoll(math.Rand(0, 360))
		particle2:SetRollDelta(math.Rand(-30, 30))
		particle2:SetColor(25, 0, 0)
		particle2:SetLighting(true)

		local particle3 = emitter:Add("particles/smokey", pos)
		particle3:SetVelocity(finalDir3 * i *10)
		particle3:SetAirResistance(250)
		particle3:SetDieTime(math.Rand(2, 3.5))
		particle3:SetStartAlpha(math.Rand(100,255))
		particle3:SetEndAlpha(0)
		particle3:SetStartSize(1)
		particle3:SetStartLength(1)
		particle3:SetEndLength(math.random(5,150))
		particle3:SetEndSize(15)
		particle3:SetRoll(math.Rand(0, 360))
		particle3:SetRollDelta(math.Rand(-30, 30))
		particle3:SetColor(25, 0, 0)
		particle3:SetLighting(true)
	end


	emitter:Finish() emitter = nil collectgarbage("step", 64)

end

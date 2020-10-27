function EFFECT:Init(data)
	local ptable = {}
	ptable[1] = ( "decals/flesh/blood"..(math.Rand(1,5)).."_subrect" )
	ptable[2] = ( "decals/blood"..(math.Rand(1,6)).."_subrec" )

	local pos = data:GetOrigin()

	sound.Play("c4.explode",pos,100,100,1)
	sound.Play( Sound ( "physics/flesh/flesh_bloody_break.wav"), pos, 75, (math.Rand(5, 255)), 1)

	for i=1, math.Rand(25, 50) do
		local emitter = ParticleEmitter(Vector(pos), false)
		local lol1 = (math.Rand(-1000, 1000))
		local lol2 = (math.Rand(-1000, 1000))
		local lol3 = (math.Rand(-1000, 1000))

		if emitter != nil then

			local particle = emitter:Add(ptable[math.random(1,2)], pos)
			particle:SetAngles(Angle(math.random(1, 360), math.random(1, 360), math.random(1, 360)))
			particle:SetVelocity(Vector(lol1, lol2, lol3))
			particle:SetCollide(true)
			particle:SetDieTime(2.5)
			particle:SetStartAlpha(225)
			particle:SetEndAlpha(255)
			particle:SetStartSize(math.Rand(5, 35))
			particle:SetEndSize(0)
			particle:SetRollDelta(math.Rand(-5, 5))
			particle:SetAirResistance(55)
			particle:SetGravity((Vector(0, 0, -2000)))
			particle:SetBounce(0.4)
			emitter:Finish()
		end

	end

	for i=1, math.Rand(5, 10) do

		local emitter = ParticleEmitter(Vector(pos), false)
		local lol1 = (math.Rand(-955, 955))
		local lol2 = (math.Rand(-955, 955))
		local lol3 = (math.Rand(-955, 955))

		if emitter != nil then

			local particle = emitter:Add(ptable[math.random(1,2)], pos)
			particle:SetAngles(Angle(math.random(1, 360), math.random(1, 360), math.random(1, 360)))
			particle:SetVelocity(Vector(lol1, lol2, lol3))
			particle:SetCollide(false)
			particle:SetDieTime(math.random(0.2,0.35))
			particle:SetStartAlpha(225)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(150, 350))
			particle:SetEndSize(0)
			particle:SetRollDelta(math.Rand(-5, 5))
			particle:SetAirResistance(0)
			particle:SetGravity((Vector(0, 0, 0)))
			particle:SetBounce(0.4)

			emitter:Finish()

		end

	end

	for i=1, math.Rand(50, 150) do

		local emitter = ParticleEmitter(Vector(pos), false)
		local vec = Vector(math.Rand(-1,1), math.Rand(-1,1), math.Rand(-1,1)):GetNormalized() * math.Rand(0,1)


		if emitter != nil then
			local particle = emitter:Add(ptable[math.random(1,2)], pos)
			particle:SetAngles(Angle(math.random(1, 360), math.random(1, 360), math.random(1, 360)))
			particle:SetVelocity(vec*2400)
			particle:SetCollide(false)
			particle:SetDieTime(math.random(0.6,0.8))
			particle:SetStartAlpha(225)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(200, 350))
			particle:SetEndSize(0)
			particle:SetPos( pos )
			particle:SetStartLength( 0 )
			particle:SetEndLength( math.Rand(50, 350) )
			particle:SetRollDelta(0)
			particle:SetAirResistance(5)
			particle:SetGravity((Vector(0, 0, -55)))
			particle:SetBounce(0.4)

			emitter:Finish()

		end

	end

	for i=1, math.Rand(125, 150) do

		local emitter = ParticleEmitter(Vector(pos), false)
		local vec = Vector(math.Rand(-1,1), math.Rand(-1,1), 0.05):GetNormalized() * math.Rand(0.9,1)


		if emitter != nil then
			local particle = emitter:Add("effects/blood_puff", pos)
			particle:SetAngles(Angle(math.random(1, 360), math.random(1, 360), math.random(1, 360)))
			particle:SetColor(100,0,0)
			particle:SetVelocity(vec*math.random(800,900))
			particle:SetCollide(false)
			particle:SetDieTime(math.random(1.95,2.05))
			particle:SetStartAlpha(math.random(200,250))
			particle:SetEndAlpha(0)
			particle:SetStartSize(50)
			particle:SetEndSize(math.Rand(100,150))
			particle:SetPos( pos )
			particle:SetRollDelta(math.Rand(-5, 5))
			particle:SetAirResistance(5)
			particle:SetGravity((Vector(0, 0, -55)))
			particle:SetBounce(0.4)

			emitter:Finish()

		end

	end

	for i=1, math.Rand(50, 100) do

		local emitter = ParticleEmitter(Vector(pos), false)
		local vec = Vector(math.Rand(-1,1), math.Rand(-1,1), math.Rand(-1,1)):GetNormalized() * math.Rand(0.9,1)


		if emitter != nil then
			local particle = emitter:Add("effects/blood_puff", pos)
			particle:SetAngles(Angle(math.random(1, 360), math.random(1, 360), math.random(1, 360)))
			particle:SetColor(100,0,0)
			particle:SetVelocity(vec*math.random(5,600))
			particle:SetCollide(false)
			particle:SetDieTime(math.random(2,2.2))
			particle:SetStartAlpha(math.random(200,250))
			particle:SetEndAlpha(0)
			particle:SetStartSize(50)
			particle:SetEndSize(math.Rand(100,150))
			particle:SetPos( pos )
			particle:SetRollDelta(math.Rand(-5, 5))
			particle:SetAirResistance(5)
			particle:SetGravity((Vector(0, 0, -55)))
			particle:SetBounce(0.4)

			emitter:Finish()

		end

	end

end




function EFFECT:Think()
return false
end

function EFFECT:Render()
end

local vecGravity = Vector(0, 0, -500)
function EFFECT:Init(data)
	local basepos = data:GetOrigin()

	sound.Play("physics/glass/glass_sheet_break" .. math.random(1,3) .. ".wav", basepos, 77, math.Rand(95, 105))
	sound.Play("npc/ichthyosaur/water_growl5.wav", basepos, 100, math.Rand(95, 105))

	local maxbound = Vector(3, 3, 3)
	local minbound = maxbound * -1

	local maxOffset = Vector(0,0,50)

	local shards = {
		"models/gibs/glass_shard.mdl",
		"models/gibs/glass_shard01.mdl",
		"models/gibs/glass_shard02.mdl",
		"models/gibs/glass_shard03.mdl",
		"models/gibs/glass_shard04.mdl",
		"models/gibs/glass_shard05.mdl",
		"models/gibs/glass_shard06.mdl"
	}

	local imax = 10
	for i=1, imax do
		local pos = basepos + maxOffset * i / imax
		local dir = VectorRand()

		local ent = ClientsideModel(shards[math.random(1,7)], RENDERGROUP_OPAQUE)
		if ent:IsValid() then
			ent:SetModelScale(math.Rand(0.8, 1.2), 0)
			ent:SetColor(Color(150,150,255))
			ent:SetPos(pos)
			ent:PhysicsInitBox(minbound, maxbound)
			ent:SetCollisionBounds(minbound, maxbound)

			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetMaterial("rock")
				phys:ApplyForceOffset( dir * math.Rand(100, 200),ent:GetPos() + VectorRand() * 5)
			end

			SafeRemoveEntityDelayed(ent, math.Rand(6, 10))
		end
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

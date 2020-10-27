AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "status__base"

ENT.LifeTime = 60

ENT.Ephemeral = true

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self.DieTime = CurTime() + 9999
end

function ENT:Think()
	if SERVER then
		local owner = self:GetOwner()
		local frameTime = FrameTime()
			local tr = util.TraceHull({
			start = owner:GetPos(),
			endpos = owner:GetPos() + owner:GetVelocity() * frameTime,
			filter = owner,
			mins = Vector(-25,-25,-25),
			maxs = Vector(25,25,25)
		})

		if tr.Hit or owner:WaterLevel() > 0 then
			owner:TakeSpecialDamage(9999, DMG_SONIC, self.Giver, self)
		end
	end
	self:NextThink( CurTime() )
	return true
end

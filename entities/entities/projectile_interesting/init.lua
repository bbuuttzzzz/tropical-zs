INC_SERVER()


ENT.LifeTime = 350
ENT.Vel = Vector(0,0,0)
ENT.Acc = Vector(0,0,0)
ENT.Pos = Vector(0,0,0)
ENT.Size = 5

function ENT:Think()
	local frameTime = FrameTime()
	self.Vel = self.Vel * frameTime
	local newPos = self.Pos + self.Vel * frameTime
	local tr = util.TraceHull({
		start = self.Pos,
		endPos = newPos,
		filter = self:GetOwner(),
		mins = Vector(-self.Size, -self.Size, -self.Size),
		maxs = Vector(self.Size, self.Size, self.Size),
		mask = MASK_SHOT_HULL
	})

	if tr.Hit then
		self:Remove()
	end

	self.Pos = newPos
end

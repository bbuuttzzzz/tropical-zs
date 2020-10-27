GM.RayBasedProjectiles = {}

function GM:CreateRayBasedProjectile(_UID, _owner, _lifetime, _pos, _vel, _acc, _filter, _func, _size, _mask, index)
	table.insert( self.RayBasedProjectiles,{
		UID = _UID,
		owner = _owner,
		lifetime = _lifetime or CurTime() + 3,
		pos = _pos,
		vel = _vel and _vel or Vector(0,0,0),
		acc = _acc and _acc or Vector(0,0,0),
		filter = _filter,
		func = _func,
		size = _size,
		mask = _mask
	})
	net.Start( "RBProjectileCreated" )
		net.WriteFloat( _UID )
		net.WriteVector( _pos )
		net.WriteVector( _vel )
		net.WriteString( index )
	net.Broadcast()
end

function GM:DestroyProjectileAtIndex(index)
	net.Start( "RBProjectileDestroyed" )
		net.WriteFloat( self.RayBasedProjectiles[index].UID )
	net.Broadcast()
  self.RayBasedProjectiles[index] = nil
end

function GM:HandleRayBasedProjectiles()
  local frameTime = FrameTime()
	for index, proj in pairs(self.RayBasedProjectiles) do
		if proj.lifetime <= CurTime() then self:DestroyProjectileAtIndex(index) end
  	proj.vel = proj.vel + proj.acc * frameTime
  	local newPos = proj.pos + proj.vel * frameTime
		local tr = util.TraceHull({
			start = proj.pos,
			endpos = newPos,
			filter = proj.filter,
			mins = Vector(-proj.size, -proj.size, -proj.size),
			maxs = Vector(proj.size, proj.size, proj.size),
			mask = proj.mask
		})

		if proj.func.started(proj, tr)then
		else
		end

		if proj.func.think(proj, tr) then
		else
		end

		if tr.Hit then
			if proj.func.callback(proj, tr) then
    	else
				proj.lifetime = 0
    	end
		end
		proj.pos = newPos
	end
end

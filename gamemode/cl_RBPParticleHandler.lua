GM.ClientRBP = {}

function GM:CreateClientRBP(_UID, _pos, _vel, index)
  local RBP = self.RBP_BULLETS[index]
  table.insert( self.ClientRBP, {
    UID = _UID,
    pos = _pos,
    vel = _vel,
    lifetime = RBP.lifetime,
    acc = RBP.acc,
    effect = RBP.effect,
    size = RBP.size
  })
end

function GM:DestroyClientRBPAtIndex(index)
  	self.ClientRBP[index] = nil
end

hook.Add( "PreDrawEffects", "paintsprites", function()
  local frameTime = FrameTime()
  for ind, proj in pairs(GAMEMODE.ClientRBP) do
  	proj.vel = proj.vel + proj.acc * frameTime
    local newPos = proj.pos + proj.vel * frameTime
		proj.pos = newPos

    if proj.effect.start(proj) then
    else
    end

    if proj.effect.think(proj) then
    else
    end

    if proj.lifetime <= 0 then
      if proj.effect.ended(proj) then
      end
    end
	end
end)


net.Receive( "RBProjectileCreated", function(len, ply)
  GAMEMODE:CreateClientRBP(net.ReadFloat( UID ), net.ReadVector(), net.ReadVector(), net.ReadString())
end)

net.Receive( "RBProjectileDestroyed", function(len, ply)
  local UID = net.ReadFloat( UID )
  for k,v in pairs(GAMEMODE.ClientRBP) do
    if v.UID == UID then
      GAMEMODE:DestroyClientRBPAtIndex(k)
    end
  end
end)

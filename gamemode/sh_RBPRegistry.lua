GM.RBP_BULLETS = {}

function GM:AddRBPBullet(index, table)
    self.RBP_BULLETS[index] = table
end

GM:AddRBPBullet( "RBP_BULLET_EXAMPLE", {
  lifetime = 35,
  speed = 1000,
	acc = Vector(0,0,-600),
	func = {
    started = function(proj, tr)
      return false
    end,
    think = function(proj, tr)
      return false
    end,
    callback = function(proj, tr)
      return false
    end
  },
  effect = {
    started = function(proj)
    return false
    end,
    think = function(proj)
    return false
    end,
    ended= function(proj)
    return false
    end,
  },
	size = 1,
  mask = MASK_SHOT_HULL
})

GM:AddRBPBullet( "RBP_CBOLT", {
  lifetime = 35,
  speed = 1000,
	acc = Vector(0,0,-600),
  func = {
    started = function(proj, tr)
      return false
    end,

    think = function(proj, tr)
      return false
    end,

    callback = function(proj, tr)
      local ent = tr.Entity
			if ent:IsValid() and ent:IsValidLivingZombie() or ent.ZombieConstruction then
				ent:DealProjectileTraceDamage(90, tr, proj.owner)
				proj.filter[#proj.filter +1] = ent
				return true
			elseif ent:IsValidLivingHuman() then
				return true
			else
				return false
			end
    end
  },

	effect = {
    start = function(proj)
      proj.started = proj.started or false
      if proj.started then return false end
      emitter = ParticleEmitter(proj.pos)
      emitter:SetNearClip(16, 48)

      for i = 1, 25 do
        sound.Play("physics/metal/soda_can_impact_hard"..math.random(1,3)..".wav", proj.pos, 80, math.random(50,255),1)
    		local ang = proj.vel:Angle()
    		ang:RotateAroundAxis(ang:Forward(),i*math.random(-0.3,0.3))
    		ang:RotateAroundAxis(ang:Up(),i*math.random(-0.3,0.3))
    		ang:RotateAroundAxis(ang:Right(),i*math.random(-0.3,0.3))
    		local finalDir = ang:Forward()
    		local particle = emitter:Add("effects/spark", proj.pos)
    		local col = math.random(180,230)
    			particle:SetDieTime(math.random(.5,1))
    			particle:SetStartAlpha(255)
    			particle:SetEndAlpha(255)
    			particle:SetStartSize(math.random(1,3))
    			particle:SetEndSize(0)
    			particle:SetStartLength(math.random(1,10))
    			particle:SetVelocity(finalDir * math.random(25,150))
    			particle:SetRoll(math.Rand(-10, 10))
    			particle:SetRollDelta(math.Rand(-1, 1) * (math.random(2) == 1 and -1 or 1))
    			particle:SetColor(255, 150, 150)
    			particle:SetGravity(Vector(0,0,math.random(-100,-50)))
    			particle:SetAirResistance(math.random(0,5))
    		particle:SetLighting(false)
    	end

      emitter:Finish() emitter = nil collectgarbage("step", 64)
      proj.started = true
    end,

    think = function(proj)
      proj.trailpos = proj.trailpos or {}
      trailpos = proj.trailpos
      render.Model( { model = Model("models/crossbow_bolt.mdl"), pos = proj.pos, angle = proj.vel:Angle() } )
      render.SetMaterial(Material("sprites/light_glow02_add"))
      render.DrawSprite(proj.pos, 15, 2, Color(250, 40, 40))
      render.DrawSprite(proj.pos, 2, 30, Color(250, 40, 40))
      local colTrail = Color(255,0,0,255)
      render.SetMaterial(Material("trails/physbeam"))
      table.insert(trailpos, 1, proj.pos)
      if trailpos[18] then
        table.remove(trailpos, 18)
      end
      for i = 1, #trailpos do
        if trailpos[i+1] then
          colTrail.a = 255 - 255 * (i/#trailpos)
          render.DrawBeam(trailpos[i],trailpos[i+1], 7, 1, 0, colTrail)
        end
      end
    end,

    ended = function(proj)
      return false
    end
  },
	size = 1.1,
  mask = MASK_SHOT_HULL
})

GM:AddRBPBullet( "RBP_DEMONIC", {
  lifetime = 65,
  speed = 350,
	acc = Vector(0,0,-600),
	func = {
    started = function(proj, tr)
      return false
    end,
    think = function(proj, tr)
      return false
    end,
    callback = function(proj, tr)
      for _, pl in pairs(ents.FindInSphere(proj.pos, 25)) do
        if pl:IsValidLivingHuman() then
          pl:AddPoisonDamage(1)
          pl:TakeSpecialDamage(0.1, DMG_GENERIC, owner)
        end
      end
    end
  },
  effect = {

    start = function(proj)
    proj.starter = proj.starter or false
    if proj.starter then return false end
    sound.Play("npc/scanner/scanner_blip1.wav", proj.pos, 80, math.random(25,255),1)
    proj.starter = true
    end,

    think = function(proj)
      local pos = proj.pos
        render.SetMaterial(Material("!sprite_bloodspray7"))
        render.DrawSprite(pos +(VectorRand() * math.random(-1,1)), 30, 30, Color(96,64,32))
    end,

    ended = function(proj)
      local pos = proj.pos
    	sound.Play("npc/barnacle/barnacle_pull"..math.random(1,4)..".wav", pos, 80, math.Rand(65, 125))
    	local emitter = ParticleEmitter(pos)
    	emitter:SetNearClip(16, 48)
    	local particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos)
    	particle:SetDieTime(0.3)
    	particle:SetStartAlpha(255)
    	particle:SetEndAlpha(0)
    	particle:SetStartSize(35)
    	particle:SetEndSize(100)
    	particle:SetRoll(math.Rand(0, 360))
    	particle:SetRollDelta(math.Rand(40, 60) * (math.random(2) == 1 and -1 or 1))
    	particle:SetColor(96, 64, 32)
    	particle:SetLighting(true)
    	for i = 1, math.random(2, 5) do
    		particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos)
    		particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(5, 300))
    		particle:SetAirResistance(100)
    		particle:SetDieTime(math.Rand(0.9, 2))
    		particle:SetStartAlpha(math.Rand(100,255))
    		particle:SetEndAlpha(0)
    		particle:SetStartSize(math.Rand(1, 8))
    		particle:SetEndSize(0)
    		particle:SetRoll(math.Rand(0, 360))
    		particle:SetRollDelta(math.Rand(-30, 30))
    		particle:SetColor(96, 64, 32)
    		particle:SetLighting(true)
    	end
    	emitter:Finish() emitter = nil collectgarbage("step", 64)
      return true
    end,
  },
	size = 3.5,
  mask = MASK_SHOT_HULL
})

GM:AddRBPBullet( "RBP_PUKE", {
  lifetime = 65,
  speed = 450,
	acc = Vector(0,0,-600),
	func = {
    started = function(proj, tr)
      return false
    end,
    think = function(proj, tr)
      return false
    end,
    callback = function(proj, tr)
      if tr.Entity:IsValidLivingHuman() then
        tr.Entity:AddPoisonDamage(1)
        tr.Entity:TakeSpecialDamage(0.3, DMG_GENERIC, owner)
      end
    end
  },
  effect = {
    start = function(proj)
      return false
    end,
    think = function(proj)
      local pos = proj.pos
      for i = 1, 5 do
        render.SetMaterial(Material("decals/Yblood1"))
        render.DrawSprite(pos + VectorRand() * 5, 5, 5, Color(255,255,255))
      end
    end,
    ended = function(proj)
      return true
    end,
  },
	size = 3,
  mask = MASK_SHOT_HULL
})

GM:AddRBPBullet( "RBP_STANK", {
  lifetime = 25,
  speed = 0,
	acc = Vector(0,0,-1),
	func = {
    started = function(proj, tr)
      return false
    end,
    think = function(proj, tr)
      return false
    end,
    callback = function(proj, tr)
      if tr.Entity:IsValidLivingHuman() then
        tr.Entity:AddPoisonDamage(0.3)
        tr.Entity:TakeSpecialDamage(0.1, DMG_GENERIC, owner)
      end
      if tr.Entity:IsWorld() then
        return false
      else return true
      end
    end
  },
  effect = {
    start = function(proj)
      return false
    end,
    think = function(proj)
      local pos = proj.pos
        render.SetMaterial(Material("particle/smokesprites_0003"))
        render.DrawSprite(pos + VectorRand(), 150, 150, Color(50,150,50,(proj.lifetime - CurTime() * 6 )- 1))
    end,
    ended = function(proj)
      return true
    end,
  },
	size = 35,
  mask = MASK_SHOT_HULL
})

GM:AddRBPBullet( "RBP_STANK", {
  speed = 0,
	acc = Vector(0,0,0),
  lifetime = CurTime() + 25,
	func = {
    started = function(proj, tr)
      return false
    end,
    think = function(proj, tr)
      return false
    end,
    callback = function(proj, tr)
      if tr.Entity:IsValidLivingHuman() then
        tr.Entity:AddPoisonDamage(0.3)
        tr.Entity:TakeSpecialDamage(0.1, DMG_GENERIC, owner)
      end
      if tr.Entity:IsWorld() then
        return false
      else return true
      end
    end
  },
  effect = {
    start = function(proj)
      proj.el = ( CurTime() + 25)
      return true
    end,
    think = function(proj)
      local pos = proj.pos
        render.SetMaterial(Material("particle/smokesprites_0003"))
        render.DrawSprite(pos, 150, 150, Color(255,255,255, (proj.el and proj.el or (25 + CurTime()))  - CurTime() * 10 ))
    end,
    ended = function(proj)
      return true
    end,
  },
	size = 35,
  mask = MASK_SHOT_HULL
})

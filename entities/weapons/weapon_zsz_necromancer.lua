SWEP.Base = "weapon_zs_basemelee"
DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.PrintName = "Necromancer"

SWEP.ViewModel = Model("models/weapons/c_stunstick.mdl")
SWEP.WorldModel = Model("models/weapons/w_crowbar.mdl")

SWEP.MeleeDamage = 25
SWEP.CrippleDamage = 20
SWEP.MeleeRange = 55
SWEP.MeleeSize = 1.5
SWEP.MeleeKnockBack = 125

SWEP.SwingTime = 1.2
SWEP.SwingRotation = Angle(0, -20, -40)
SWEP.SwingOffset = Vector(10, 0, 0)
SWEP.SwingHoldType = "melee"

SWEP.HitDecal = "Manhackcut"

SWEP.Secondary.Damage = 2
SWEP.TracerName = "tracer_necromancer"
SWEP.Secondary.MaxDistance = 500

SWEP.NestSelfDamage = 250


function SWEP:PrimaryAttack()
  if not self:CanPrimaryAttack() then return end
  self:SetNextAttack()

  self:DoMeleeAttackAnim()

  self.ActiveAttack = 1
  if self.SwingTime == 0 then
		self:MeleeSwing()
	else
		self:StartSwinging()
	end
end

function SWEP:SecondaryAttack()
  if not self:CanPrimaryAttack() then return end
  self:SetNextAttack()

  self:DoMeleeAttackAnim()

  self.ActiveAttack = 2
  if self.SwingTime == 0 then
		self:MeleeSwing()
	else
		self:StartSwinging()
	end
end

function SWEP:Reload()
  if not self:CanPrimaryAttack() then return end
  self:SetNextAttack()

  self:DoMeleeAttackAnim()

  self.ActiveAttack = 3
  if self.SwingTime == 0 then
    self:MeleeSwing()
  else
    self:StartSwinging()
  end
end

function SWEP:Think()
	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end

	if self:IsSwinging() and self:GetSwingEnd() <= CurTime() then
		self:StopSwinging()
    if self.ActiveAttack == 1 then
	    self:MeleeSwing()
    elseif self.ActiveAttack == 2 then
      local owner = self:GetOwner()
      local dmginfo = DamageInfo()
        dmginfo:SetAttacker(owner)
        dmginfo:SetDamageType(DMG_GENERIC + DMG_DIRECT)
        dmginfo:SetDamage(25)
        dmginfo:SetDamageForce(Vector(1,0,0))
      owner:TakeDamageInfo(dmginfo)
      self:FireRangedAttack()
    elseif self.ActiveAttack == 3 then
      local owner = self:GetOwner()
      if self:TryBuilding() then
        local dmginfo = DamageInfo()
          dmginfo:SetAttacker(owner)
          dmginfo:SetDamageType(DMG_GENERIC + DMG_DIRECT)
          dmginfo:SetDamage(self.NestSelfDamage)
          dmginfo:SetDamageForce(Vector(1,0,0))
        owner:TakeDamageInfo(dmginfo)
        self:SetNextPrimaryFire(CurTime() + 1)
        if SERVER then
          self:SpawnNest()
        end
      else
        self:SetNextPrimaryFire(CurTime() + 0.5)
      end
    end
	end
end

function SWEP.BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	if ent:IsValidLivingHuman() then
    //add cripple and poison damage to target
    if SERVER then
      ent:AddPoisonDamage(8, attacker)
      ent:AddCrippleDamage(15, attacker)
    end

    //add necro heal to caster
    local status = attacker:GiveStatus("necromancer_heal")
    if status and status:IsValid() then
      amount = status:AddAmount(150, attacker)
    end
    attacker:EmitSound("npc/strider/striderx_alert4.wav")
	end
end

function SWEP:FireRangedAttack()
  local owner = self:GetOwner()
  owner:LagCompensation(true)
  owner:FireBulletsLua(owner:GetShootPos(),owner:GetAimVector(),0,1,self.Secondary.Damage,nil,0,self.TracerName, self.BulletCallback,self.Secondary.HullSize,nil,self.Secondary.MaxDistance,nil,self)
  owner:LagCompensation(false)

  self:SetNextPrimaryFire(CurTime() + 1)
  self:EmitSound("npc/vort/attack_shoot.wav")
end

function SWEP:TryBuilding()
  local owner = self:GetOwner()

  if owner:Health() <= self.NestSelfDamage then
    self:SendMessage("not_enough_hp_to_cast")
    return
  end

  local allzombies = team.GetPlayers(TEAM_UNDEAD)
  local pos = owner:WorldSpaceCenter()
	local ang = owner:EyeAngles()
	ang.pitch = 0
	ang.roll = 0
	local forward = ang:Forward()
	local right = ang:Right()
  local endpos = pos + forward * 32

  tr = util.TraceLine({start = endpos, endpos = endpos + Vector(0,0,-48), filter = allzombies, mask = MASK_PLAYERSOLID})
	local hitnormal = tr.HitNormal
	local z = hitnormal.z
	if not tr.HitWorld or tr.HitSky or z < 0.75 then
		self:SendMessage("not_enough_room_for_a_nest")
		return
	end

  local hitpos = tr.HitPos

  self.HitNormal = hitnormal
  self.HitPos = hitpos


  local spawnpositions = {
		Vector(17, 17, 0),
		Vector(-17, -17, 0),
		Vector(17, 17, 64),
		Vector(-17, -17, 64)
	}
	for _, spos in pairs(spawnpositions) do
		if bit.band(util.PointContents(hitpos + spos), CONTENTS_SOLID) == CONTENTS_SOLID then
			self:SendMessage("not_enough_room_for_a_nest")
			return
		end
	end

  for _, sigil in pairs(ents.FindByClass("prop_obj_sigil")) do
		if util.SkewedDistance(sigil:GetPos(), hitpos, 1.5) <= GAMEMODE.CreeperNestDistBuildNest then
			self:SendMessage("too_close_to_uncorrupt")
			return
		end
	end

	for _, human in pairs(team.GetPlayers(TEAM_HUMAN)) do
		if util.SkewedDistance(human:GetPos(), hitpos, 1.5) <= GAMEMODE.CreeperNestDistBuild then
			self:SendMessage("too_close_to_a_human")
			return
		end
	end
  return true
end
function SWEP:SpawnNest()
  local hitnormal = self.HitNormal
  local hitpos = self.HitPos

  local ent = ents.Create("prop_darknest")
  if ent:IsValid() then
    nestang = hitnormal:Angle()
    nestang:RotateAroundAxis(nestang:Right(), 270)

    ent:SetPos(hitpos)
    ent:SetAngles(nestang)
    ent:Spawn()

    ent.OwnerUID = uid
    ent:SetNestOwner(owner)
    ent:SetNestBuilt(true)

    ent:EmitSound("physics/flesh/flesh_bloody_break.wav")

    local name = self:GetOwner():Name()
    for _, pl in pairs(team.GetPlayers(TEAM_UNDEAD)) do
      pl:CenterNotify(COLOR_GREEN, translate.ClientFormat(pl, "dark_nest_built_by_x", name))
    end

    net.Start("zs_nestbuilt")
    net.Broadcast()
  end
end

function SWEP:SendMessage(msg, friendly)
  if not SERVER then return end

	if not self.NextMessage or CurTime() >= self.NextMessage then
		self.NextMessage = CurTime() + 2
		self:GetOwner():CenterNotify(friendly and COLOR_GREEN or COLOR_RED, translate.ClientGet(self:GetOwner(), msg))
	end
end

function SWEP:IsAlting()
  return false
end

/*
["head"] = { type = "Model", model = "models/Humans/corpse1.mdl", bone = "ValveBiped.Bip01_Head1", rel = "",
  pos = Vector(-65.5, 0, 0), angle = Angle(0, -90, -90), size = Vector(1, 1, 1), color = Color(125, 225, 125, 255),
  surpresslightning = false, material = "", skin = 0, bodygroup = {},	clippos = Vector(-2.2,0,0), clipdir = Vector(1,0,0)
},
*/

if CLIENT then
  SWEP.ShowWorldModel = false
  SWEP.ShowViewModel = false
  SWEP.WElements = {
    ["skull"] = { type = "Model", model = "models/Gibs/HGIBS.mdl", bone = "ValveBiped.Bip01_Head1", rel = "", pos = Vector(2.581, 1.699, 0), angle = Angle(0, -90, -90), size = Vector(1.299, 1.299, 1.299), color = Color(140, 255, 140, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
    ["staffskull"] = { type = "Model", model = "models/gibs/hgibs.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "staff", pos = Vector(-0.207, 0.001, -5.638), angle = Angle(-180, 80.693, -8.238), size = Vector(0.697, 0.697, 0.697), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
  	["glow"] = { type = "Sprite", sprite = "effects/exit1", bone = "ValveBiped.Bip01_R_Hand", rel = "skull", pos = Vector(0, 0, 0), size = { x = 10, y = 10 }, color = Color(0, 255, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
  	["staff"] = { type = "Model", model = "models/gibs/hgibs_spine.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.146, 1.322, -4.785), angle = Angle(10.685, 45.543, -20.434), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
  }
  SWEP.VElements = {
  	["skull"] = { type = "Model", model = "models/gibs/hgibs.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "staff", pos = Vector(-0.207, 0.001, -5.638), angle = Angle(-180, 60.168, -22.209), size = Vector(0.697, 0.697, 0.697), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
  	["glow"] = { type = "Sprite", sprite = "effects/exit1", bone = "ValveBiped.Bip01_R_Hand", rel = "skull", pos = Vector(0, 0, 0), size = { x = 10, y = 10 }, color = Color(0, 255, 0, 255), nocull = true, additive = false, vertexalpha = true, vertexcolor = true, ignorez = false},
  	["staff"] = { type = "Model", model = "models/gibs/hgibs_spine.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.039, 1.25, -3.418), angle = Angle(-0.195, 81.942, -8.874), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
  }

  function SWEP:Anim_DrawWorldModel()
    //check if we need to draw spawn-protection colored
		local protected = self:IsSpawnProtected()
		local pcolor = Color(255,255,255,255)
    --Color(0,0,255,(0.02 + (CurTime() + self:EntIndex() * 0.2) % 0.05) * 255)


    if (self.ShowWorldModel == nil or self.ShowWorldModel) then
      if protected then
        self:SetColor(pcolor)
      else
        self:SetColor(Color(255,255,255,255))
      end
      self:DrawModel()
    end

    if (!self.WElements) then	return end

    if (!self.wRenderOrder) then
      self.wRenderOrder = {}

      for k, v in pairs( self.WElements ) do
        if (v.type == "Model") then
          table.insert(self.wRenderOrder, 1, k)
        elseif (v.type == "Sprite" or v.type == "Quad") then
          table.insert(self.wRenderOrder, k)
        end
      end

    end

    if (IsValid(self:GetOwner())) then
      bone_ent = self:GetOwner()
    else
      -- when the weapon is dropped
      bone_ent = self
    end

    for k, name in pairs( self.wRenderOrder ) do
      local v = self.WElements[name]
      if (!v) then self.wRenderOrder = nil break end
      if (v.hide) then continue end

      local pos, ang

      if (v.bone) then
        pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
      else
        pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
      end

      if (!pos) then continue end

      local model = v.modelEnt
      local sprite = v.spriteMaterial

      if (v.type == "Model" and IsValid(model)) then

        if v.clippos then
          local clipNormal = ang:Forward() * v.clipdir.x + ang:Right() * v.clipdir.y + ang:Up() * v.clipdir.z
          local clipposW = pos + ang:Forward() * v.clippos.x + ang:Right() * v.clippos.y + ang:Up() * v.clippos.z
          local clipDist = clipposW:Dot(clipNormal)

          render.PushCustomClipPlane( clipNormal , clipDist )
        end

        model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
        ang:RotateAroundAxis(ang:Up(), v.angle.y)
        ang:RotateAroundAxis(ang:Right(), v.angle.p)
        ang:RotateAroundAxis(ang:Forward(), v.angle.r)

        model:SetAngles(ang)
        --model:SetModelScale(v.size)
        local matrix = Matrix()
        matrix:Scale(v.size)
        model:EnableMatrix( "RenderMultiply", matrix )

        if (v.material == "") then
          model:SetMaterial("")
        elseif (model:GetMaterial() != v.material) then
          model:SetMaterial( v.material )
        end

        if (v.skin and v.skin != model:GetSkin()) then
          model:SetSkin(v.skin)
        end

        if (v.bodygroup) then
          for k, v in ipairs( v.bodygroup ) do
            if (model:GetBodygroup(k) != v) then
              model:SetBodygroup(k, v)
            end
          end
        end

        if (v.surpresslightning or protected) then
          render.SuppressEngineLighting(true)
        end

        local col = protected and pcolor or v.color
				render.SetColorModulation(col.r/255, col.g/255, col.b/255)
				render.SetBlend(col.a/255)
        model:DrawModel()
        render.SetBlend(1)
        render.SetColorModulation(1, 1, 1)

        if (v.surpresslightning or protected) then
          render.SuppressEngineLighting(false)
        end
        if v.clippos then
          render.PopCustomClipPlane()
        end

      elseif (v.type == "Sprite" and sprite) then

        local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
        render.SetMaterial(sprite)
        render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

      elseif (v.type == "Quad" and v.draw_func) then

        local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
        ang:RotateAroundAxis(ang:Up(), v.angle.y)
        ang:RotateAroundAxis(ang:Right(), v.angle.p)
        ang:RotateAroundAxis(ang:Forward(), v.angle.r)

        cam.Start3D2D(drawpos, ang, v.size)
          v.draw_func( self )
        cam.End3D2D()

      end
    end
  end

  function SWEP:IsSpawnProtected()
  	local owner = self:GetOwner()
  	if owner:IsValid() and (not owner:IsPlayer() or owner:Alive()) then
  		if owner.SpawnProtection then
  			return true
  		end
  	end
  	return false
  end
end

if SERVER then
  function SWEP:OnMeleeHit(hitent, hitflesh, tr)
    if not hitent:IsValid() then return end

    if not hitent:IsValidLivingHuman() then return end

    hitent:AddCrippleDamage(self.CrippleDamage)
  end
end

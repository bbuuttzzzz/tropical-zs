EFFECT.Particle = nil
EFFECT.Emitter = nil


function EFFECT:Init(data)
  self.Parent = data:GetEntity()
  local pos = data:GetOrigin()
  local ent = self.Parent:GetOwner()

    self.Emitter = ParticleEmitter(Vector(pos), false)
    if self.Emitter != nil then
      self.Particle = self.Emitter:Add("effects/exit1", pos)
      self.Particle:SetPos( pos )
      self.Particle:SetVelocity(Vector(0,0,0))
      self.Particle:SetCollide(false)
      self.Particle:SetStartAlpha(225)
      self.Particle:SetDieTime(-1)
      self.Particle:SetColor(0.5,1,0.5)
      self.Particle:SetEndAlpha(255)
      self.Particle:SetStartSize(10)
      self.Particle:SetEndSize(0)
      self.Particle:SetRollDelta(0)
      self.Particle:SetAirResistance(0)
      self.Particle:SetGravity(Vector(0, 0, 1))
      self.Particle:SetBounce(0)
      self.Emitter:Finish()
    end
end

function EFFECT:Think()
  if not (self.Parent and self.Parent:IsValid()) then
    self.Particle:SetDieTime(CurTime())
    return false
  end

  local ent = self.Parent:GetOwner()

  local pos, ang = Vector(0,0,0), Angle(0,0,0)
  local m = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_R_Hand"))
  if (m) then
    pos, ang = m:GetTranslation(), m:GetAngles()
  end
  vpos = Vector(4,1.5,-8.5)
  local drawpos = pos + ang:Forward() * vpos.x + ang:Right() * vpos.y + ang:Up() * vpos.z
  self.Particle:SetPos(drawpos)

  if !ent:Alive() or !ent:GetWeapon("weapon_zsz_necromancer") then
    self.Particle:SetDieTime(CurTime())
  end

  return true
end

/*
  local ent = self:GetOwner()

  local pos, ang = Vector(0,0,0), Angle(0,0,0)
  local m = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_R_Hand"))
  if (m) then
    pos, ang = m:GetTranslation(), m:GetAngles()
  end

  vpos = (whatever offset it should be)

  local drawpos = pos + ang:Forward() * vpos.x + ang:Right() * vpos.y + ang:Up() * vpos.z

*/

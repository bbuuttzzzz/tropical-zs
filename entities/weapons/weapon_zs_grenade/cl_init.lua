INC_CLIENT()

function SWEP:Think()
  self.BaseClass.Think(self)

  --jet does this idk if it REALLY matters lol
  local curtime = CurTime()

  --make ticking sounds while grenade is cooking
  if self.NextTickSound and curtime >= self.NextTickSound then
    local dieTime = self:GetCookStart() + self.MaxFuse

    local timeleft = self:GetCookStart() + self.MaxFuse - curtime

    self.NextTickSound = curtime + math.max(0.2, timeleft * 0.25)
    self:EmitSound("weapons/grenade/tick1.wav", 75, math.Clamp((1 - timeleft / self.MaxFuse) * 160, 100, 160))
    if curtime > dieTime then
      --grenade was fully cooked self.MinFuse ago. stop making sounds
      self.NextTickSound = nil
    end
  end

end

GM.StatusFloaters = {}

function GM:AddStatusFloater(_name, _color, _materialName)
  local floater = {
    name = _name,
    color = _color,
    materialName = _materialName,
    index = #self.StatusFloaters + 1
  }

  self.StatusFloaters[#self.StatusFloaters + 1] = floater
  self.StatusFloaters[_name] = floater
end

GM:AddStatusFloater("poison", Color(150, 180, 150), "tropical/killicons/poison")
GM:AddStatusFloater("bleed", Color(255, 100, 100), "zombiesurvival/killicons/bleed")
GM:AddStatusFloater("radiation", Color(120, 240, 0), "tropical/killicons/radiation")
GM:AddStatusFloater("cripple", Color(255, 255, 0), "tropical/killicons/cripple")
GM:AddStatusFloater("heal", Color(0,255,0),"tropical/killicons/heal")

--this version of basezombie should work with swep construction kit
SWEP.Base = "weapon_zsz_basezombie"
DEFINE_BASECLASS("weapon_zsz_basezombie")

SWEP.WorldModel = "models/weapons/w_pistol.mdl"

function SWEP:Initialize()
  BaseClass.Initialize(self)

  if CLIENT then
    self:Anim_Initialize()
  end
end

function SWEP:Holster()
  if CLIENT and BaseClass.Holster(this) then
    self:Anim_Holster()
  end

  return BaseClass.Holster(self)
end

INC_CLIENT()
DEFINE_BASECLASS("weapon_zsz_basezombie")

include("animations.lua")

function SWEP:OnRemove()
  self:Anim_OnRemove()

  return BaseClass.OnRemove(this)
end

function SWEP:ViewModelDrawn()
  self:Anim_ViewModelDrawn()
  return BaseClass.ViewModelDrawn(self)
end

function SWEP:DrawWorldModel()
  --self:DrawModel()
  self:Anim_DrawWorldModel()
  --self:OldDrawWorldModel()
end

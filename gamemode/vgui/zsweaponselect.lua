local PANEL = {}

SLOTCOLOR_NORMAL = 1 --regular undeployed slot
SLOTCOLOR_LOW = 2 --low ammo
SLOTCOLOR_EMPTY = 3 --no ammo
SLOTCOLOR_SELECTED = 4 --selected slot
SLOTCOLOR_NONE = 5 --slot with no weapon
local SLOT_COLORS = {
  [SLOTCOLOR_SELECTED] = {
    alpha = 255,
    height = 0,
    dark = Color(0,0,0,255),
    light = Color(255,255,255,255)
  },
  [SLOTCOLOR_NORMAL] = {
    alpha = 255,
    height = 15,
    dark = Color(50,50,50,220),
    light = Color(255,255,255,220)
  },
  [SLOTCOLOR_LOW] = {
    alpha = 100,
    height = 15,
    dark = Color(100,100,0,220),
    light = Color(255,255,120,220)
  },
  [SLOTCOLOR_EMPTY] = {
    alpha = 100,
    height = 15,
    dark = Color(100,0,0,220),
    light = Color(255,120,120,220)
  },
  [SLOTCOLOR_NONE] = {
    alpha = 255,
    height = 40,
    dark = Color(50,50,50,220),
    light = Color(255,255,255,220)
  }
}

local slotWidth = 110
local slotHeight = 82
local slotSpacing = 10

local timerColor = Color(0,180,0,220)
local timerThickness = 16

function PANEL:Init()
  local screenscale = BetterScreenScale()

  local w = (slotWidth + slotSpacing) * GAMEMODE.WeaponSlots - slotSpacing

  self:SetSize(screenscale * w, screenscale * (slotHeight))
  self:AlignLeft(screenscale * 500 + slotSpacing)
  self:AlignBottom()

  self.Slots = {}
  for n = 1, GAMEMODE.WeaponSlots do
    local slot = vgui.Create("ZSWeaponSlot", self)
    slot.Slot = n
    slot:AlignLeft((slotWidth + slotSpacing) * (n-1) * screenscale)

    self.Slots[n] = slot
  end
end

vgui.Register("ZSWeaponSelect", PANEL, "Panel")


local SLOT = {}

function SLOT:SetWeapon(weaponTable)
  self.WeaponName = weaponTable:GetClass()
  self.AmmoText = "1/1"
end

function SLOT:SetEmpty()
  self.WeaponName = nil
  self.AmmoText = ""
  self.SlotColorType = SLOTCOLOR_NONE
  self:UpdateHeight()
  self.TimerFunction = nil
  self.TimerCallback = nil
end

function SLOT:UpdateHeight()
  self:SetPos(self:GetPos(),SLOT_COLORS[self.SlotColorType].height)
end

function SLOT:UpdateAmmo(clip,spare,ammoType,fakeClip)
  if ammoType == "none" or ammoType == "dummy" then
    self.AmmoText = ""
    self.SlotColorType = SLOTCOLOR_NORMAL
  elseif fakeClip then
    self.AmmoText = clip + spare
    if clip + spare > 0 then
      self.SlotColorType = SLOTCOLOR_NORMAL
    else
      self.SlotColorType = SLOTCOLOR_EMPTY
    end
  else
    self.AmmoText = string.format("%d|%d",clip,spare)
    if clip == 0 then
      if spare == 0 then
        self.SlotColorType = SLOTCOLOR_EMPTY
      else
        self.SlotColorType = SLOTCOLOR_LOW
      end
    else
      self.SlotColorType = SLOTCOLOR_NORMAL
    end
  end
end

function SLOT:Init()
  local screenscale = BetterScreenScale()

  self.Slot = 1
  self.AmmoText = ""
  self.SlotColorType = SLOTCOLOR_NORMAL

  self:SetSize(screenscale * slotWidth, screenscale * slotHeight)
  self:AlignBottom()
  self.Paint = function(self, w, h)
    local hovered = self.Button:IsHovered()
    local coldark = SLOT_COLORS[self.SlotColorType].dark
    local collight = SLOT_COLORS[self.SlotColorType].light
    surface.SetDrawColor(coldark.r,coldark.g,coldark.b,coldark.a)
    surface.DrawRect(0,0,w,h)

    surface.SetDrawColor(collight.r,collight.g,collight.b,collight.a)
    surface.DrawOutlinedRect(0,0,w,h)
    if hovered then surface.DrawOutlinedRect(2,2,w-4,h-4) end

    if self.WeaponName then
      --draw killicon
      local kw, kh = killicon.GetSize(self.WeaponName)
      killicon.Draw(w/2, kh/4 + 5,self.WeaponName, SLOT_COLORS[self.SlotColorType].alpha)

      --draw ammo
      draw.SimpleText(self.AmmoText,"AmmoFont",4,h * 0.6, collight, TEXT_ALIGN_TOP,TEXT_ALIGN_LEFT)
    end

    if self.TimerFunction then
      local t = self.TimerFunction()
      if t < 0 then
        self.TimerFunction = nil
        if self.TimerCallback then
          print(self.TimerCallback)
          self.TimerCallback()
          self.TimerCallback = nil
        end
      else
        surface.SetDrawColor(collight.r,collight.g,collight.b,collight.a)
        surface.DrawRect(w-timerThickness,0,w,h * t)
      end
    end

    --draw slot number
    local txt = GAMEMODE.ResupplySlot == self.Slot and string.format("[%d]",self.Slot) or self.Slot
    draw.SimpleText(txt,"SlotFont",4,0, collight, TEXT_ALIGN_TOP,TEXT_ALIGN_LEFT)

    return true
  end

  local button = vgui.Create("DButton",self)
  button:SetSize(self:GetWide(),self:GetTall())
  button.Paint = function() end
	button:SetText("")
  button.DoClick = function()
    GAMEMODE:SwapEquippedWithSlot(self.Slot)
  end
  button.DoRightClick = function()
    GAMEMODE:TrySetResupplySlot(self.Slot)
  end
  self.Button = button

  self:SetEmpty()
end

vgui.Register("ZSWeaponSlot", SLOT, "Panel")

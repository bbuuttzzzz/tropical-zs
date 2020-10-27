local swapDelay = 0.1

//call this whenever the player picks up or drops a weapon
function GM:RefreshWeaponSelect()
  if not self.WeaponSelectHUD then return end

  local weapons = MySelf:GetWeapons()

  if not self.SelectWeapons then
    self.SelectWeapons = {}
  end

  --first, remove weapons the player doesn't have
  for n, weapon in pairs(self.SelectWeapons) do
    if not weapon:IsValid() or not MySelf:HasWeapon(weapon:GetClass()) then
      self.SelectWeapons[n] = nil
    end
  end

  local addWeapons = {}
  for n, weapon in pairs(weapons) do
    --try and find weapons that we don't already have in SelectWeapons
    local contains = false
    for n, selectWeapon in pairs(self.SelectWeapons) do
      if weapon:GetClass() == selectWeapon:GetClass() then
        contains = true
        break
      end
    end
    --if we don't already have it, we should add it
    if not contains then
      addWeapons[#addWeapons+1] = weapon
    end
  end

  --add any weapons we found that weren't already added
  for _, wep in ipairs(addWeapons) do
    --check if we have a slot
    local success = false
    for n = 1, GAMEMODE.WeaponSlots do
      if not self.SelectWeapons[n] then
        //we have a slot, so stick the gun in it
        self.SelectWeapons[n] = wep
        success = true
        break
      end
    end
    if not success then
      //this gun didn't fit which means something went wrong
      //server SHOULD guarantee this doesn't happen
      ErrorNoHalt("Error: weapon count exceeds display cap")
    end
  end

  --update every weapon
  for n = 1, self.WeaponSlots do
    self:UpdateWeaponSlot(n)
  end

  --check if our resupply weapon is invalid
  if not self:GetWeaponFromSlot(self.ResupplySlot) then
    self:ResetResupplySlot()
  end

  --update ammo family for equipped weapon
  self:UpdateAmmoFamily()
end

//draw a timer on the side of this weapon's slot
function GM:AddTimerToWeapon(weapon, endTime, maxDuration, force, callback)
  if MySelf ~= weapon:GetOwner() then return end
  self:AddTimerToSlot(self:GetWeaponSlot(weapon),endTime, maxDuration, force, callback)
end

//draw a timer on the side of this slot
function GM:AddTimerToSlot(slotIndex, endTime, maxDuration, force, callback)
  //first, get the display slot we are adding the timer to
  local displaySlot = self.WeaponSelectHUD.Slots[slotIndex]

  //if we shouldn't force it and it already has a timer going just leave it
  if not force and displaySlot.TimerFunction then
    return
  end

  //make a function to use to calculate this time
  displaySlot.TimerFunction = function()
    return (endTime - CurTime())/maxDuration
  end
  displaySlot.TimerCallback = callback
end

//clear the timer on this weapon's slot
function GM:RemoveTimerFromWeapon(weapon)
  self:RemoveSlotTimer(self:GetWeaponSlot(weapon))
end

//clear the timer on this slot
function GM:RemoveSlotTimer(slotIndex)
  //first, get the display slot we are adding the timer to
  local displaySlot = self.WeaponSelectHUD.Slots[slotIndex]

  displaySlot.TimerFunction = nil
  displaySlot.TimerCallback = nil
end

//Called every frame. update the slot for your currently equipped weapon
function GM:UpdateWeaponEquipped()
  if not self.WeaponAmmoFamily then self:UpdateAmmoFamily() end
  local wep = MySelf:GetActiveWeapon()
  local slot = self:GetWeaponSlot(wep)
  if not slot then return end
  local ammoType = wep:GetPrimaryAmmoTypeString()

  --recalculate your equpped weapons ammo
  local clip = wep:Clip1()
  local spare = MySelf:GetAmmoCount(ammoType)
  local displaySlot = self.WeaponSelectHUD.Slots[slot]
  displaySlot:UpdateAmmo(clip,spare,ammoType,wep.FakeClip)
  displaySlot.SlotColorType = SLOTCOLOR_SELECTED

  --check if its spare ammo amount changed.
  if not self.CachedSpareAmmo or self.CachedSpareAmmo != spare then
    --if it did, we need to update the ammo of other weapons in the same ammo family
    self.CachedSpareAmmo = spare
    for _, n in ipairs(self.WeaponAmmoFamily) do
      self:UpdateWeaponSlot(n)
    end
  end
end

--We keep a list of all the other weapons of the same ammo type as the equipped weapon
--update that list
function GM:UpdateAmmoFamily()
  local heldWep = MySelf:GetActiveWeapon()
  if not heldWep or not heldWep:IsValid() then return end
  local ammoType = heldWep:GetPrimaryAmmoTypeString()

  local newFamily = {}
  for n, wep in pairs(self.SelectWeapons) do
    if wep ~= heldWep and wep:GetPrimaryAmmoTypeString() == ammoType then
      newFamily[#newFamily+1] = n
    end
  end
  self.WeaponAmmoFamily = newFamily
end

--update the slot this weapon is in, if that slot exists
function GM:UpdateWeapon(weapon)
  for n = 1, self.WeaponSlots do
    if weapon == self.SelectWeapons[n] then
      self:UpdateWeaponSlot(n)
      return
    end
  end
end

--update all the slots for weapons of the same ammo type.
--called whenever you pick up ammo of a particular type
function GM:UpdateWeaponsByAmmo(ammoType)
  for n, wep in pairs(self.SelectWeapons) do
    if wep:GetPrimaryAmmoTypeString() == ammoType then
      self:UpdateWeaponSlot(n)
    end
  end
end

--update all the slots for weapons that use oomph
--as they should have synced timers
function GM:UpdateOomphWeapons()
  for n, wep in pairs(self.SelectWeapons) do
    if wep.UsesOomph then
      self:UpdateWeaponSlot(n)
    end
  end
end

--update the display of this weapon slot
function GM:UpdateWeaponSlot(index)
  local trueSlot = self.SelectWeapons[index]
  local displaySlot = self.WeaponSelectHUD.Slots[index]

  --if the slot is now empty, just set the slot to be empty
  if not trueSlot then
    --also remove the resupplyslot if necessary
    if index == self.ResupplySlot then
      self:ResetResupplySlot()
    end
    displaySlot:SetEmpty()
    return
  end

  --if the slot has changed, swap all the stuff on it
  if trueSlot:GetClass() ~= displaySlot.WeaponName then
    displaySlot:SetWeapon(trueSlot)
  end

  --update the ammo amount & low ammo coloring
  local ammoType = trueSlot:GetPrimaryAmmoTypeString()
  local clip = trueSlot:Clip1() or 0
  local spare = MySelf:GetAmmoCount(ammoType) or 0
  displaySlot:UpdateAmmo(clip,spare,ammoType,trueSlot.FakeClip)

  --check if this is the currently held weapon
  if MySelf:GetActiveWeapon() == trueSlot then
    --if it is, override the color to the special deployed color
    displaySlot.SlotColorType = SLOTCOLOR_SELECTED
  end

  displaySlot:UpdateHeight()

  if trueSlot.UpdateDisplay then
    --this swep has some stuff to do with its timer, so let it
    trueSlot:UpdateDisplay()
  end
end

--get the weapon slot of the supplied weapon
function GM:GetWeaponSlot(weapon)
  for n = 1, self.WeaponSlots do
    if weapon == self.SelectWeapons[n] then
      return n
    end
  end
end

function GM:GetWeaponFromSlot(slot)
  return self.SelectWeapons[slot]
end

--get the slot of your currently equipped weapon
function GM:GetCurrentWeaponSlot()
  return self:GetWeaponSlot(MySelf:GetActiveWeapon())
end

--get the slot of the next weapon on your slot bar, looping from end to end
function GM:GetNextWeaponSlot()
  local initialSlot = (self:GetCurrentWeaponSlot() or 0) + 1
  local finalSlot = initialSlot + self.WeaponSlots

  local n
  for nTemp = initialSlot, finalSlot do
    n = (nTemp - 1) % self.WeaponSlots + 1
    if self.SelectWeapons[n] then return n end
  end

  --this is your only gun :/
  return false
end


--get the slot of the last weapon on your slot bar, looping from end to end
function GM:GetPrevWeaponSlot()
  local finalSlot = (self:GetCurrentWeaponSlot() or 2) - 1
  local initialSlot = finalSlot + self.WeaponSlots

  local n
  for nTemp = initialSlot, finalSlot, -1 do
    n = (nTemp - 1) % self.WeaponSlots + 1
    if self.SelectWeapons[n] then return n end
  end

  --this is your only gun :/
  return false
end

function GM:SelectNextWeapon()
  if self.NextSwitch and self.NextSwitch > CurTime() then return end
  self.NextSwitch = CurTime() + swapDelay

  self:SelectWeaponSlot(self:GetNextWeaponSlot())
end

function GM:SelectPrevWeapon()
  if self.NextSwitch and self.NextSwitch > CurTime() then return end
  self.NextSwitch = CurTime() + swapDelay

  self:SelectWeaponSlot(self:GetPrevWeaponSlot())
end

--select weapon in this slot
function GM:SelectWeaponSlot(index)
  if not index or not self.SelectWeapons[index] or self:GetCurrentWeaponSlot() == index then return end
  surface.PlaySound("common/talk.wav")
  input.SelectWeapon(self.SelectWeapons[index])
end

function GM:SwapNextWeapon()
  if self.NextSwitch and self.NextSwitch > CurTime() then return end
  self.NextSwitch = CurTime() + swapDelay

  self:SwapWeaponSlots(self:GetCurrentWeaponSlot(),self:GetNextWeaponSlot())
end

function GM:SwapPrevWeapon()
  if self.NextSwitch and self.NextSwitch > CurTime() then return end
  self.NextSwitch = CurTime() + swapDelay

  self:SwapWeaponSlots(self:GetCurrentWeaponSlot(),self:GetPrevWeaponSlot())
end

--swap equipped weapon to this slot & equip weapon in original slot
function GM:SwapEquippedWithSlot(index)
  if not index then return end

  local currentSlot = self:GetCurrentWeaponSlot()

  if currentSlot == index then return end

  self:SwapWeaponSlots(index,currentSlot)

  self:SelectWeaponSlot(currentSlot)
end

function GM:SwapWeaponSlots(index1,index2)
  if not index1 or not index2 or index1 == index2 then
    surface.PlaySound("common/wpn_denyselect.wav")
    return
  end

  //swap weapons in select weapons
  local temp = self.SelectWeapons[index1]
  self.SelectWeapons[index1] = self.SelectWeapons[index2]
  self.SelectWeapons[index2] = temp

  //swap any timers on the actual slots
  local displaySlot1 = self.WeaponSelectHUD.Slots[index1]
  local displaySlot2 = self.WeaponSelectHUD.Slots[index2]
  local tempFunc = displaySlot1.TimerFunction
  local tempCallback = displaySlot1.TimerCallback
  displaySlot1.TimerFunction = displaySlot2.TimerFunction
  displaySlot1.TimerCallback = displaySlot2.TimerCallback
  displaySlot2.TimerFunction = tempFunc
  displaySlot2.TimerCallback = tempCallback

  //swap ResupplySlot if applicable
  if self.ResupplySlot == index1 then
    self.ResupplySlot = index2
  elseif self.ResupplySlot == index2 then
    self.ResupplySlot = index1
  end


  surface.PlaySound("common/wpn_hudoff.wav")
  self:RefreshWeaponSelect()
end

function GM:TrySetResupplySlot(slot)
  local wep = self:GetWeaponFromSlot(slot)
  if not wep then return end

  if MySelf.MaxStockpiles and MySelf.Stockpiles and MySelf.Stockpiles > 0 then
    local ammotype = self:GetWeaponResupplyType(wep)
    if not ammotype then return end

    RunConsoleCommand("zs_claimstockpile",ammotype)
    return
  end

  if self.ResupplySlot and slot == self.ResupplySlot then
    self:SetResupplySlot(nil)
    surface.PlaySound("items/ammocrate_close.wav")
    return
  end

  if not self:GetWeaponResupplyType(wep) then
    surface.PlaySound("common/wpn_denyselect.wav")
    return
  end

  self:SetResupplySlot(slot)

  surface.PlaySound("items/ammopickup.wav")
end

function GM:SetResupplySlot(slot)
  if slot then
    MySelf.ResupplyChoice = self:GetWeaponResupplyType(self:GetWeaponFromSlot(slot))
    RunConsoleCommand("zs_resupplyammotype",MySelf.ResupplyChoice)
    self.ResupplySlot = slot
  else
    MySelf.ResupplyChoice = nil
    RunConsoleCommand("zs_resupplyammotype","default")
    self.ResupplySlot = nil
  end
end

function GM:ResetResupplySlot()
  MySelf.ResupplyChoice = nil
  RunConsoleCommand("zs_resupplyammotype","default")
  self.ResupplySlot = nil
end

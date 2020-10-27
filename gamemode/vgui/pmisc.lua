
--AFK POPUP---------------------------------------------------------------------

local function shouldStopAFK(pl, cmd)
	--if the real human at the computer moves their mouse, pressed WASD, or one of
	--a few other buttons they should get uncontrolled
	return (cmd:GetMouseX() ~= 0 or cmd:GetMouseY() ~= 0
		or cmd:GetSideMove() ~= 0 or cmd:GetForwardMove() ~= 0
		or cmd:GetButtons() ~= 0)
end

function GM:MakeAFKPopup()
  --make the interface visible again if it already exists
  if self.AFKPopup and self.AFKPopup:IsValid() then
    self.AFKPopup:SetVisible(true)
    return
  end
  local scale = BetterScreenScale()

  local panel = vgui.Create("DPanel")
  self.AFKPopup = panel
  panel:SetSize(500 * scale,100 * scale)
  panel:Center()
  function panel.Paint(self, w, h)
    draw.RoundedBox(6,0,0,w,h,PERKS_COLOR_DARK)
    draw.DrawText("You are being controlled by a bot while AFK.\n\n Try moving to wake up.","ZSHUDFontSmall",w/2,10,COLOR_WHITE,TEXT_ALIGN_CENTER)
  end

  /*
  local text = EasyLabel(panel,"You are being controlled by a bot while AFK. Try moving to wake up.","ZSHUDFontSmall",COLOR_WHITE)
  text:Dock( FILL )
  text:DockMargin(10,10,10,10)
  text:SetContentAlignment(8)
  text:SetWrap(true)
  text:SetMultiline(true)
  */

  hook.Add("StartCommand", "AFKPopupStartCommand", function(pl, cmd)
    if shouldStopAFK(pl, cmd) then
      self:RemoveAFKPopup()
    end
  end)
end

function GM:RemoveAFKPopup()
  hook.Remove("StartCommand", "AFKPopupStartCommand")
  if self.AFKPopup then self.AFKPopup:Remove() end
end

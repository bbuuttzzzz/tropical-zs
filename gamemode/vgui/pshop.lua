SHOP_ENTRY_COLOR = Color(100, 100, 100, 125)
SHOP_ENTRY_COLOR_HOVERED = Color(150, 150, 150, 125)
SHOP_ENTRY_COLOR_SELECTED = Color(100, 200, 100, 125)
SHOP_ENTRY_COLOR_BOTH = Color(150, 255, 150, 125)

hook.Add("Think", "ShopMenuThink", function()
	local pan = GAMEMODE.ShopInterface
	if pan and pan:IsValid() and pan:IsVisible() then
		--causes the menu to close if you mouse out of it
		local mx, my = gui.MousePos()
		local x, y = pan:GetPos()
		if mx < x - 16 or my < y - 16 or mx > x + pan:GetWide() + 16 or my > y + pan:GetTall() + 16 then
			pan:SetVisible(false)
		end

		--highlight hovered or selected entries
		if(GAMEMODE.ShopEntries and GAMEMODE.ShopCard) then

			for i, entry in ipairs(GAMEMODE.ShopEntries) do
				--if this entry is hovered, paint it gray
				local col
				if entry.button:IsHovered() then
					if entry.itemSignature == GAMEMODE.CardSignature then
						col = SHOP_ENTRY_COLOR_BOTH
					else
						col = SHOP_ENTRY_COLOR_HOVERED
					end
				else
					if entry.itemSignature == GAMEMODE.CardSignature then
						col = SHOP_ENTRY_COLOR_SELECTED
					else
						col = SHOP_ENTRY_COLOR
					end
				end

				entry.Paint = function(self, w, h)
					draw.RoundedBox( 10, 0, 0, w, h, col)
				end
			end
		end
	end



end)

--causes the points label's point value to update
local function pointsLabelThink(self)
	local scrap = MySelf:GetScrap()
	if self.m_LastScrap ~= scrap then
		self.m_LastScrap = scrap

		self:SetText(translate.Format("x_scrap",scrap))
		self:SizeToContents()
    self:AlignRight(8)
	end
end

--center mouse on arsenal crate
local function ShopMenuCenterMouse(self)
	local x, y = self:GetPos()
	local w, h = self:GetSize()
	gui.SetMousePos(x + w / 2, y + h / 2)
end

local debug = false
function GM:OpenShopMenu()
  if self.ShopInterface and self.ShopInterface:IsValid() then

    if debug then
      self.ShopInterface:Remove()
    else
      self.ShopInterface:SetVisible(true)
      self.ShopInterface:CenterMouse()
			return
    end
  end

  --creates some size variables
	local screenscale = BetterScreenScale()
	local widMax = ScrW()
	GUISCALE = (math.min(widMax, 1100) * screenscale) / 1100
	local scale = GUISCALE
	local wid, hei = scale * 1100, scale * 600
	local tabhei = 24 * screenscale
	--local categoryWidth = 150 * scale
	local color_unhovered = Color(0,0,0,200)
	local color_hovered = Color(100,100,100,200)

	--create the big box
	local frame = vgui.Create("DFrame")
	frame:SetSize(wid, hei)
	frame:Center()
	frame:SetDeleteOnClose(false)
	frame:SetTitle(" ")
	frame:SetDraggable(false)
	if frame.btnClose and frame.btnClose:IsValid() then frame.btnClose:SetVisible(false) end
	if frame.btnMinim and frame.btnMinim:IsValid() then frame.btnMinim:SetVisible(false) end
	if frame.btnMaxim and frame.btnMaxim:IsValid() then frame.btnMaxim:SetVisible(false) end
	frame.CenterMouse = ShopMenuCenterMouse
	frame.Think = UpgradeMenuThink
	self.ShopInterface = frame

  --create top part
	local topSpace = vgui.Create("DPanel", frame)
	topSpace:SetWide(wid - 20 * scale)
	topSpace:SetTall(70 * scale)
	topSpace:AlignTop(10 * scale)
	topSpace:CenterHorizontal()
	topSpace.Paint = function(self, w, h)
		draw.RoundedBox( 10, 0, 0, w, h, color_unhovered)
	end

  --add shop text
	local text = translate.Get("item_shop")
	local chooseLabel = EasyLabel(topSpace, text, "ZSHUDFontSmall", COLOR_WHITE)
	chooseLabel:CenterHorizontal()
	chooseLabel:CenterVertical()

  --add points text
  local pointsLabel = EasyLabel(topSpace,translate.Format("x_scrap",50), "ZSHUDFontSmall", COLOR_GREEN)
  pointsLabel:SetContentAlignment(6)
	pointsLabel:AlignRight(10 * scale)
	pointsLabel:CenterVertical()
	pointsLabel.Think = pointsLabelThink

  --draw a card to the right
	local card = self:CreateCard( frame, scale )
	card:AlignBottom( 10 * scale)
	card:AlignRight( 10 * scale )

	card.Button:Remove()
	self.ShopCard = card


	--draw the item window to the left (leave room for categories)
	local itemWindow = vgui.Create("DPanel", frame)
	itemWindow:SetWide( 710 * scale )
	itemWindow:SetTall( 500 * scale)
	itemWindow.Paint = function(self, w, h)
		draw.RoundedBox( 10, 0, 0, w, h, color_unhovered)
	end
	itemWindow:AlignBottom( 10 * scale)
	itemWindow:AlignLeft( 10 * scale )


	--draw a DScrollPanel
	local scrollPanel = vgui.Create("DScrollPanel", itemWindow)
	scrollPanel:Dock( FILL )

	--make grid
	local itemGrid = vgui.Create("DGrid", scrollPanel)
	itemGrid:SetPos(10 * scale,10 * scale)
	itemGrid:SetCols(2)
	itemGrid:SetColWide(itemWindow:GetWide() / 2 - 5 * scale)
	itemGrid:SetRowHeight(itemWindow:GetWide() / 8)

	local entryWidth = itemGrid:GetColWide()
	local entryHeight = itemGrid:GetRowHeight() - 10 * scale

	--for each item...

	self.ShopEntries = {}
	for i, shopTab in ipairs(self.ShopItems) do

		local itemTab = self.Items[shopTab.signature]

		if( itemTab.item ) then
			self:LazyLoadSwepStats( itemTab.item )
		end

		local sweptable = itemTab.item or weapons.Get(itemTab.swep)

		--draw the background
		local base = vgui.Create("DPanel")
		base:SetSize( entryWidth - 10 * scale, entryHeight )
		base:SetText( shopTab.signature )
		base.itemSignature = shopTab.signature
		base.Paint = function(self, w, h)
			local col = CARD_COLOR_BASE
			draw.RoundedBox( 10, 0, 0, w, h, col)
		end
		itemGrid:AddItem(base)

		--draw the model window
		local modelWindow = vgui.Create("DPanel", base)
		modelWindow:SetSize( entryHeight - 10 * scale, entryHeight - 10 * scale)
		modelWindow:AlignLeft( 5 * scale )
		modelWindow:CenterVertical()
		modelWindow.Paint = function(self, w, h)
			local col = CARD_COLOR_1
			draw.RoundedBox( 10, 0, 0, w, h, col)
		end

		--draw the model in the window
		local modelPanel = vgui.Create("DModelPanel", modelWindow)
		modelPanel:Dock( FILL )
		modelPanel:SetModel( sweptable.WorldModel )
		local mins, maxs = modelPanel.Entity:GetRenderBounds()
		modelPanel:SetCamPos(mins:Distance(maxs) * Vector(0.75, 0.75, 0.5))
		modelPanel:SetLookAt((mins + maxs) / 2)

		--add the cost in the top right
		local costText = EasyLabel(base, translate.Format("x_scrap",shopTab.price), "ZSHUDFontSmaller", COLOR_GREEN)
		costText:SetContentAlignment(9)
		costText:SizeToContents()
		costText:AlignTop( 5 * scale)
		costText:AlignRight( 5 * scale)

		--add the weapon name to the bottom left (leave room for model)
		local nameText = EasyLabel(base, translate.Get(sweptable.TranslationName), "ZSBodyTextFontBig", COLOR_WHITE)
		nameText:SetContentAlignment(1)
		nameText:SizeToContents()
		nameText:AlignLeft( modelWindow:GetWide() + 10 * scale )
		nameText:AlignBottom( 10 * scale )

		--draw the button on top
		local button = vgui.Create("DButton", base)
		button:SetText("")
		button:Dock( FILL )
		button.Paint = function(self, w, h)
		end
		button.DoClick = function()
			local newCard = base.itemSignature

			if newCard ~= self.CardSignature and self.ShopCard then
				self:SetCard(self.ShopCard, GUISCALE, self.Items[newCard])
			end

			self.CardSignature = newCard
		end
		button.DoDoubleClick = function()
			RunConsoleCommand("zs_shopbuy", shopTab.signature)
		end
		button.DoRightClick = function()
			RunConsoleCommand("zs_shopbuy", shopTab.signature)
		end

		base.button = button

		self.ShopEntries[i] = base
	end

	frame:MakePopup()
	frame:CenterMouse()
end

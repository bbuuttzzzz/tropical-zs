local Window
local HoveredClassWindow

--local texUpEdge = surface.GetTextureID("gui/gradient_up")
--local texDownEdge = surface.GetTextureID("gui/gradient_down")
local function MakeZombieGroup(self, description, parent)
	local panel = vgui.Create("DPanel", parent)
	/*
	panel.Paint = function(self, w, h)
		local edgesize = 16

		DisableClipping(true)
		surface.SetDrawColor(Color(0, 0, 0, 220))
		surface.DrawRect(0, 0, w, h)
		surface.SetTexture(texUpEdge)
		surface.DrawTexturedRect(0, -edgesize, w, edgesize)
		surface.SetTexture(texDownEdge)
		surface.DrawTexturedRect(0, h, w, edgesize)
		DisableClipping(false)
	end
	*/
	panel.Paint = function(self, w, h)
		local col = Color(0,0,0,220)
		draw.RoundedBox( 10, 0, 0, w, h, col)
	end

	return panel
end

function GM:CloseClassSelect()
	if self.ClassInterface and self.ClassInterface:IsValid() then
		--TODO this makes it regenerate every time. figure out how to just hide it
		self.ClassInterface:Remove()
	end
end

function GM:OpenClassSelect()

	local debug = true

	if self.ClassInterface and self.ClassInterface:IsValid() then
		if debug then
			self.ClassInterface:Remove()
		else
			self.ClassInterface:SetVisible(true)
			self.ClassInterface:CenterMouse()
			return
		end
	end

	--create an invisible block around the whole screen
	local frame = vgui.Create("DPanel")
	frame:SetSize(ScrW(),ScrH())
	frame:Center()
	frame.Paint = function(self, w, h)
	end
	frame.PerformLayout = function()
		self:PerformClassLayout(frame)
	end

	--create the class descriptor object
	local infopanel = vgui.Create("ClassInfo", frame)
	infopanel:ResetClassTable()
	frame.InfoPanel = infopanel

	PlayMenuOpenSound()
	frame:MakePopup()
	frame.OnKeyCodePressed = function(self, keycode)
		local bind = input.LookupKeyBinding(keycode) or ""
		if string.match(bind,"gm_showspare1") or string.match(bind,"+menu") then
			GAMEMODE:CloseClassSelect()
		end
	end

	self.ClassInterface = frame

	frame.Normal = {Description = "Choose Normal Class"}
	frame.Miniboss = {Description = "Choose Miniboss"}
	frame.Boss = {Description = "Choose Boss"}

	--add all the classes
	for _, tab in pairs({frame.Normal, frame.Miniboss, frame.Boss}) do
		tab.ClassButtons = {}

		--this is the panel the classes sit on
		local panel = MakeZombieGroup(self, tab.Description, frame)
		tab.Panel = panel

		--this is the grid the actual class buttons lie in
		local grid = vgui.Create("DGrid", panel)
		grid:SetContentAlignment(2)
		grid:Dock(BOTTOM)
		tab.ButtonGrid = grid

		--this is the text that describes each row
		local text = EasyLabel(frame, tab.Description, "ZSHUDFontSmall", COLOR_WHITE)
		tab.Text = text
	end

	local button = EasyButton(frame, "Close", 8, 4)
	button:SetFont("ZSHUDFontSmall")
	button:SizeToContents()
	button.DoClick = function() frame:Remove() end
	frame.CloseButton = button

	local already_added = {}
	local use_better_versions = GAMEMODE:ShouldUseBetterVersionSystem()


	for i=1, #GAMEMODE.ZombieClasses do
		local classtab = GAMEMODE.ZombieClasses[GAMEMODE:GetBestAvailableZombieClass(i)]

		if classtab and not classtab.Disabled and not already_added[classtab.Index] then

			already_added[classtab.Index] = true

			if not classtab.Type then
				continue
			end

			if classtab.Type == ZTYPE_NORMAL then
				self:MakeClassButton(classtab, frame.Normal)
			elseif classtab.Type == ZTYPE_MINIBOSS then
				self:MakeClassButton(classtab, frame.Miniboss)
			elseif classtab.Type == ZTYPE_BOSS then
				self:MakeClassButton(classtab, frame.Boss)
			end
		end
	end
end

function GM:PerformClassLayout(frame)
	local biggestEntryCount = math.max(#frame.Normal.ClassButtons,
		#frame.Miniboss.ClassButtons,
		#frame.Boss.ClassButtons)

	local cell_size = ScrW()/biggestEntryCount -- deine min right of the rows
	cell_size = math.min(ScrH() / 7, cell_size) -- define max height of a row

	for n, zGroup in ipairs({frame.Normal, frame.Miniboss, frame.Boss}) do
		--align panel
		zGroup.Panel:SetSize(cell_size * #zGroup.ClassButtons, cell_size)
		zGroup.Panel:AlignTop(cell_size * 1.5 * (n))
		zGroup.Panel:AlignLeft(32)

		--stick the text above the panel
		zGroup.Text:MoveAbove(zGroup.Panel, 0)
		zGroup.Text:AlignLeft(40)

		zGroup.ButtonGrid:SetCols(#zGroup.ClassButtons)
		zGroup.ButtonGrid:SetColWide(cell_size)
		zGroup.ButtonGrid:SetRowHeight(cell_size)
	end

	--stick the close button above the top panel
	frame.CloseButton:SetPos(24 + cell_size * #frame.Normal.ClassButtons - frame.CloseButton:GetWide(),0)
	frame.CloseButton:MoveAbove(frame.Normal.Panel, 16)
end

function GM:MakeClassButton(classtab, zGroup)
	local button = vgui.Create("ClassButton")
	button:SetClassTable(classtab)
	button.Wave = classtab.Wave or 1

	table.insert(zGroup.ClassButtons, button)
	zGroup.ButtonGrid:AddItem(button)
end

local ClassButtonPanel = {}

function ClassButtonPanel:Init()
	self:SetMouseInputEnabled(true)
	self:SetContentAlignment(5)

	self.NameLabel = vgui.Create("DLabel", self)
	self.NameLabel:SetFont("ZSHUDFontSmaller")
	self.NameLabel:SetAlpha(170)

	self.Image = vgui.Create("DImage", self)

	self:InvalidateLayout()
end

function ClassButtonPanel:PerformLayout()
	local cell_size = self:GetParent():GetColWide()

	self:SetSize(cell_size - 2, cell_size - 2)

	self.Image:SetSize(cell_size * 0.75, cell_size * 0.75)
	self.Image:AlignTop(8)
	self.Image:CenterHorizontal()

	self.NameLabel:SizeToContents()
	self.NameLabel:AlignBottom(8)
	self.NameLabel:CenterHorizontal()
end

function ClassButtonPanel:SetClassTable(classtable)
	self.ClassTable = classtable

	local len = #translate.Get(classtable.TranslationName)

	self.NameLabel:SetText(translate.Get(classtable.TranslationName))
	self.NameLabel:SetFont(len > 15 and "ZSHUDFontTiny" or len > 11 and "ZSHUDFontSmallest" or "ZSHUDFontSmaller")

	self.Image:SetImage(classtable.Icon)
	self.Image:SetImageColor(classtable.IconColor or color_white)
	self.ActiveMaterial = self.Image:GetMaterial()
	self.InactiveMaterial = self.ClassTable.StillMaterial
	self.Image:SetMaterial(self.InactiveMaterial)

	self:InvalidateLayout()
end

function ClassButtonPanel:DoClick()
	self:Click()
end

function ClassButtonPanel:DoDoubleClick()
	self:Click(true)
end

function ClassButtonPanel:DoRightClick()
	self:Click(true)
end

function ClassButtonPanel:Click(hard)
	if self.ClassTable then
		--these are validated by trySet~ on the first line anyway
		GAMEMODE:TrySetClass(self.ClassTable, hard)
		GAMEMODE:TrySetMiniBossClass(self.ClassTable)
		GAMEMODE:TrySetBossClass(self.ClassTable)
	end

	surface.PlaySound("buttons/button15.wav")


	--you might want to change multiple classes at once so you wouldn't want
	--to have to re-open the menu every time. this is also benefitted by a new
	--menu that's easier to exit quickly (like human menus)
	--Window:Remove()
end

local classButtonBackground = Color(30,30,30,255)
function ClassButtonPanel:Paint(w, h)
	if self.HighlightColor then

		draw.RoundedBox( 10, 2, 2, w-4, h-4,self.HighlightColor)
		if self.LastEnabledState == 4 then
			draw.RoundedBox( 10, 4, 4, w-8, h-8,COLOR_YELLOW)
			draw.RoundedBox( 10, 6, 6, w-12, h-12, classButtonBackground)
		else
			draw.RoundedBox( 10, 4, 4, w-8, h-8, classButtonBackground)
		end
	elseif self.Hovered then
		draw.RoundedBox( 10, 2, 2, w-4, h-4,COLOR_GRAY)
		draw.RoundedBox( 10, 4, 4, w-8, h-8,classButtonBackground)
	end
	return true
end

function ClassButtonPanel:OnCursorEntered()
	self.NameLabel:SetAlpha(230)
	self.Hovered = true
	self.Image:SetMaterial(self.ActiveMaterial)

	GAMEMODE.ClassInterface.InfoPanel:SetClassButton(self)
end

function ClassButtonPanel:OnCursorExited()
	self.Hovered = false
	self.NameLabel:SetAlpha(170)
	--resetting LastEnabledState "invalidates the layout" of the enabled meme
		--so that thing decides what self.Image's material should be
	self.LastEnabledState = nil

	GAMEMODE.ClassInterface.InfoPanel:ResetClassTable()
end

function ClassButtonPanel:Think()
	if not self.ClassTable then return end

	local enabled

	if MySelf:IsClassSelected(self.ClassTable.Index) then
		if MySelf:GetZombieClass() == self.ClassTable.Index then
			enabled = 4
		else
			enabled = 3
		end
	elseif MySelf:GetZombieClass() == self.ClassTable.Index then
		enabled = 2
	elseif gamemode.Call("IsClassUnlocked", self.ClassTable.Index) then
		enabled = 1
	else
		enabled = 0
	end

	if enabled ~= self.LastEnabledState then
		self.LastEnabledState = enabled

		if enabled == 3 or enabled == 4 then
			self.HighlightColor = COLOR_GREEN
			self.NameLabel:SetTextColor(COLOR_GREEN)
			self.Image:SetImageColor(self.ClassTable.IconColor or color_white)
			self.Image:SetAlpha(245)
			self.Image:SetMaterial(self.ActiveMaterial)
		elseif enabled == 2 then
			self.HighlightColor = COLOR_YELLOW
			self.NameLabel:SetTextColor(COLOR_YELLOW)
			self.Image:SetImageColor(self.ClassTable.IconColor or color_white)
			self.Image:SetAlpha(245)
			self.Image:SetMaterial(self.ActiveMaterial)
		elseif enabled == 1 then
			self.HighlightColor = nil
			self.NameLabel:SetTextColor(COLOR_GRAY)
			self.Image:SetImageColor(self.ClassTable.IconColor or color_white)
			self.Image:SetAlpha(245)
			self.Image:SetMaterial(self.InactiveMaterial)
		else
			self.HighlightColor = nil
			self.NameLabel:SetTextColor(COLOR_DARKRED)
			self.Image:SetImageColor(COLOR_DARKRED)
			self.Image:SetAlpha(170)
			self.Image:SetMaterial(self.InactiveMaterial)
		end
	end
end

vgui.Register("ClassButton", ClassButtonPanel, "Button")

local ClassInfoPanel = {}

function ClassInfoPanel:Init()
	self:SetZPos(10)
	self:SetSize(ScrW() / 8, ScrH() - 64)
	self:CenterVertical()

	self:ResetClassTable()

	local wall = EasyLabel(self, "", "ZSBodyTextFont", COLOR_GRAY)
	wall:SetSize(self:GetWide() - 10, self:GetTall() - 25)
	wall:SetContentAlignment(5)
	wall:CenterVertical()
	wall:CenterHorizontal()
	wall:SetWrap(true)
	wall:SetMultiline(true)
	self.Wall = wall

	self:InvalidateLayout()
end

function ClassInfoPanel:SetClassButton(classButton)
	if not classButton or not classButton.ClassTable then
		self:ResetClassTable()
		return
	end

	self.ClassButton = classButton
	self.ClassTable = classButton.ClassTable
	self:SetVisible(true)

	self:InvalidateLayout()
end

function ClassInfoPanel:ResetClassTable()
	self:SetVisible(false)
	self.x = 0
	self.ClassTable = nil

	self:InvalidateLayout()
end

function ClassInfoPanel:PerformLayout()
	if self.ClassTable then
		local txt = translate.Get(self.ClassTable.TranslationName) .. ":\n"
		local description = self.ClassTable:Describe()

		if description["$stats"] then
			txt = txt .. description["$stats"] .. "\n"
		end

		if description["$attack1"] then
			txt = txt .. (input.LookupBinding("+attack") or "Mouse1") .. ":\n" .. description["$attack1"] .. "\n"
		end

		if description["$attack2"] then
			txt = txt .. (input.LookupBinding("+attack2") or "Mouse2") .. ":\n" .. description["$attack2"] .. "\n"
		end

		if description["$reload"] then
			txt = txt .. (input.LookupBinding("+reload") or "Reload") .. ":\n" .. description["$reload"] .. "\n"
		end

		if description["$sprint"] then
			txt = txt .. (input.LookupBinding("+speed") or "Shift") .. ":\n" .. description["$sprint"] .. "\n"
		end

		for k, v in pairs(description) do
			if string.sub(k, 1, 1) == "$" then continue end

			txt = txt .. K .. ":\n" .. v
		end

		self.Wall:SetText(txt)
		self.Wall:SizeToContentsY()
		self:SetWide(self.Wall:GetWide() + 20)
		self:SetTall(self.Wall:GetTall() + 20)

		self.Wall:CenterVertical()
		self.Wall:CenterHorizontal()

	end
end

function ClassInfoPanel:Think()

	self.Wall:SizeToContentsY()
	self:SetWide(self.Wall:GetWide() + 20)
	self:SetTall(self.Wall:GetTall() + 20)

	self.Wall:CenterVertical()
	self.Wall:CenterHorizontal()

	local x, y = input.GetCursorPos()
	y = math.min(y + 20,ScrH() - self:GetTall())
	self:SetPos(x + 20, y)
end

function ClassInfoPanel:Paint(w, h)
	draw.RoundedBox( 10, 0, 0, w, h, COLOR_GRAY)
	draw.RoundedBox( 10, 2, 2, w-4, h-4, Color(0,0,0,255))
end

vgui.Register("ClassInfo", ClassInfoPanel, "DPanel")

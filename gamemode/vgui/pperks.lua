PERKS_COLOR_DARK = Color(0,0,0,200)
PERKS_COLOR_LIGHT = Color(100,100,100,200)
LOADOUT_DIR = "tropical/zsloadouts"

local BASE_W = 1005
local BASE_H = 800

/*
hook.Add("Think", "PerkMenuThink", function()
	local pan = GAMEMODE.PerkInterface
	if pan and pan:IsValid() and pan:IsVisible() then
		--highlight hovered or selected entries
	end
end)
*/

--center mouse on perk menu
local function PerkMenuCenterMouse(self)
	local x, y = self:GetPos()
	local w, h = self:GetSize()
	gui.SetMousePos(x + w / 2, y + h / 2)
end

local function SwapPerkBrowser(entryTable,oldBrowser,newBrowser)
	oldBrowser:RemovePerkEntry(entryTable)
	newBrowser:AddPerkEntry(entryTable)
	newBrowser:MarkUnsorted()
end

function GM:ClosePerkMenu()
	if self.PerkInterface and self.PerkInterface:IsValid() then
		--TODO this makes it regenerate every time. figure out how to just hide it
		self.PerkInterface.CloseButton:Remove()
		self.PerkInterface:Remove()
	end
end

function GM:GetMenuPerks()
	local perks = {}
	for k, v in ipairs(self.PerkInterface.ActiveBrowser.Perks) do
		perks[k] = v.ID
	end

	return perks
end

function GM:SetMenuPerksDesired()
	local perks = self:GetMenuPerks()

	MySelf:SendDesiredActiveSkills(perks)
	surface.PlaySound("items/suitchargeok1.wav")
end

local function FixBrowserEntries(frame)
	//where self is PerkInterface

	//check every entry in the allbrowser to see if it can fit in the current
	//activeBrowser, and turn it red if it cannot
	for i, entry in ipairs(frame.AllBrowser.Entries) do
		if frame.ActiveBrowser:CanAddPerkEntry(entry) then
			entry.Locked = false
		else
			entry.Locked = true
		end
	end
end

local function UpdateTracker(frame)
	local count = frame.ActiveBrowser.PerkWeight
	for i, slot in ipairs(frame.Tracker.Slots) do
		if i <= count then
			slot.Filled = true
		else
			slot.Filled = false
		end
	end

	frame.Tracker.Counter:SetText(string.format("%d/%d",frame.ActiveBrowser.PerkWeight,GAMEMODE.PerkSlots))
end
--[[
	move existing perks to the same side as newPerks says they should be
	only guaranteed to work if all perks in newPerks are allowed
	AND newPerks is a valid loadout (not too heavy, no double families)
	so do your checking first
]]
function GM:LoadPerkList(newPerks)
	if not self.PerkInterface or not self.PerkInterface.AllBrowser or not self.PerkInterface.ActiveBrowser then return end
	local screenscale = BetterScreenScale()
	surface.PlaySound("items/ammopickup.wav")

	local allBrowser = self.PerkInterface.AllBrowser
	local activeBrowser = self.PerkInterface.ActiveBrowser

	--first get all entries from both tables
	local entries = table.Copy(allBrowser.Entries)
	table.Add(entries, activeBrowser.Entries)

	--set both tables to be empty

	allBrowser:SetEmpty()
	activeBrowser:SetEmpty()

	--turn newPerks into an assoc table
	local assocPerks = table.ToAssoc(newPerks)

	for i, entry in ipairs(entries) do
		if assocPerks[entry.PerkTable.ID] then
			activeBrowser:AddPerkEntry(entry, screenscale)
		else
			allBrowser:AddPerkEntry(entry, screenscale)
		end
	end

	FixBrowserEntries(self.PerkInterface)
	UpdateTracker(self.PerkInterface)
	self.PerkInterface.AllBrowser:ReSort()
end

local saves = {
	"save1",
	"SAVE2",
	"Save 3"
}

local function SaveLoadout( saveName )
	if not saveName or saveName == "" then return end

	local perks = GAMEMODE:GetMenuPerks()

	file.CreateDir(LOADOUT_DIR)
	file.Write(LOADOUT_DIR .. "/" .. saveName .. ".txt", Serialize(perks))

	print("saved perks as " .. saveName)
end

local function LoadLoadout( saveName )
	if not saveName or saveName == "" then return end

	if not file.Exists(LOADOUT_DIR .. "/" .. saveName .. ".txt", "DATA") then
		print("error: loadout not found")
		return {}
	end

	local contents = file.Read(LOADOUT_DIR .. "/" .. saveName .. ".txt", "DATA")
	if not contents or #contents <= 0 then
		print("error: loadout not loading")
		return {}
	end

  contents = Deserialize(contents)

  if not contents then
    print("error: failed to deserialize")
    return {}
  end

	return contents
end

local function DeleteLoadout( saveName )
	if not saveName or saveName == "" then return end

	if not file.Exists(LOADOUT_DIR .. "/" .. saveName .. ".txt", "DATA") then
		print("error: loadout not found")
		return {}
	end

	file.Delete(LOADOUT_DIR .. "/" .. saveName .. ".txt", "DATA")
end

local function OpenLoadoutMenu(self)
	local menu = DermaMenu()

	local function SaveAsPopup()
		surface.PlaySound("buttons/button15.wav")
		local savePanel = vgui.Create("DFrame", GAMEMODE.PerkInterface)
		local x,y = gui.MousePos()
		savePanel:SetPos(x - 100,y - 25)
		savePanel:SetTitle("Save as...")
		savePanel.btnMinim:SetVisible(false)
		savePanel.btnMaxim:SetVisible(false)
		savePanel:SetSize(300,75)
		function savePanel:Paint(w,h)
			draw.RoundedBox(6,0,0,w,h,COLOR_WHITE)
			draw.RoundedBox(6,3,3,w-6,h-6,color_black)
		end
		savePanel:MakePopup()

		local textEntry = vgui.Create( "DTextEntry", savePanel)
		textEntry:SetTextColor(color_black)
		textEntry:SetSize(190,30)
		textEntry:AlignLeft(5)
		textEntry:AlignBottom(5)
		textEntry:SetText( "" )
		textEntry.OnEnter = function( self )
			surface.PlaySound("buttons/button14.wav")
			savePanel:Remove()
			SaveLoadout( self:GetValue() )
		end

		local textEnter = vgui.Create( "DButton", savePanel)
		textEnter:SetText("Save")
		textEnter:SetSize(80, 30)
		textEnter:AlignRight(5)
		textEnter:AlignBottom(5)
		textEnter.DoClick = function()
			surface.PlaySound("buttons/button14.wav")
			savePanel:Remove()
			SaveLoadout( textEntry:GetValue() )
		end
	end
	local function ConfirmPopup(confirmText, confirmFunction)
		surface.PlaySound("buttons/button15.wav")

		local panel = vgui.Create("DFrame", GAMEMODE.PerkInterface)
		local x,y = gui.MousePos()
		panel:SetPos(x - 100,y - 25)
		panel:SetTitle(confirmText)
		panel.btnMinim:SetVisible(false)
		panel.btnMaxim:SetVisible(false)
		panel:SetSize(275,75)
		function panel:Paint(w,h)
			draw.RoundedBox(6,0,0,w,h,COLOR_WHITE)
			draw.RoundedBox(6,3,3,w-6,h-6,color_black)
		end
		panel:MakePopup()

		local textAccept = vgui.Create( "DButton", panel)
		textAccept:SetText("Accept")
		textAccept:SetSize(80, 30)
		textAccept:AlignLeft(30)
		textAccept:AlignBottom(5)
		textAccept.DoClick = function()
			surface.PlaySound("buttons/button14.wav")
			confirmFunction()
			panel:Remove()
		end

		local textCancel = vgui.Create( "DButton", panel)
		textCancel:SetText("Cancel")
		textCancel:SetSize(80, 30)
		textCancel:AlignRight(30)
		textCancel:AlignBottom(5)
		textCancel.DoClick = function()
			panel:Remove()
		end
	end

	--CLear perks button - move all perks to the allbrowser
	menu:AddOption( "Clear Perks", function()
		GAMEMODE:LoadPerkList({})
	end)

	menu:AddSpacer()

	local saveMenu = menu:AddSubMenu( "Save...", SaveAsPopup )

	saveMenu:AddOption( "Save as New", SaveAsPopup )

	saveMenu:AddSpacer()

	local loadMenu = menu:AddSubMenu( "Load..." )

	local deleteMenu = menu:AddSubMenu( "Delete... ")

	local saves = file.Find( LOADOUT_DIR .. "/*", "DATA" )

	for i, saveName in ipairs(saves) do
		saveName = string.StripExtension(saveName)
		saveMenu:AddOption( "as " .. saveName, function()
			ConfirmPopup("Really Overwrite " .. saveName .. "?", function()
				SaveLoadout( saveName )
			end)
		end)

		loadMenu:AddOption( saveName, function()
			GAMEMODE:LoadPerkList(LoadLoadout( saveName ))
		end)

		deleteMenu:AddOption( saveName, function()
			ConfirmPopup("Really Delete " .. saveName .. "?", function()
				DeleteLoadout(saveName)
			end)
		end)
	end

	menu:Open()
end

function GM:OpenPerkMenu()
  if self.PerkInterface and self.PerkInterface:IsValid() then

    if debug then
      self.PerkInterface:Remove()
    else
      self.PerkInterface:SetVisible(true)
      self.PerkInterface:CenterMouse()
      return
    end
  end

  --create some size variables
  local screenscale = BetterScreenScale()
  local widMax = ScrW()
  GUISCALE = (math.min(widMax, BASE_W) * screenscale) / BASE_W
	local scale = GUISCALE
	local wid, hei = scale * BASE_W, scale * BASE_H

  --create the big box
	local frame = vgui.Create("DFrame")
	frame:SetSize(wid, hei)
	frame:Center()

	--frame:SetDeleteOnClose(false)
	frame:SetTitle(" ")
	frame:SetDraggable(false)
	if frame.btnClose and frame.btnClose:IsValid() then frame.btnClose:SetVisible(false) end
	if frame.btnMinim and frame.btnMinim:IsValid() then frame.btnMinim:SetVisible(false) end
	if frame.btnMaxim and frame.btnMaxim:IsValid() then frame.btnMaxim:SetVisible(false) end
	frame.CenterMouse = PerkMenuCenterMouse
	frame.OnKeyCodePressed = function(self, keycode)
		local bind = input.LookupKeyBinding(keycode) or ""
		if string.match(bind,"gm_showhelp") or string.match(bind,"+menu") then
			GAMEMODE:ClosePerkMenu()
		end
	end
	self.PerkInterface = frame

	--create the close button
	local button = EasyButton(nil, "Close Without Saving", 8, 4)
	button:SetFont("ZSHUDFontSmall")
	button:SizeToContents()
	button.DoClick = function()
		GAMEMODE:ClosePerkMenu()
	end
	local xx, yy = frame:GetPos()
	button:SetPos(xx, yy - button:GetTall() - 10)
	frame.CloseButton = button

  --make all-browser
  local allBrowser = vgui.Create("ZSPerkBrowser",frame)
  allBrowser:AlignLeft(10)
	allBrowser.Title:SetText("Perk Bank")
	allBrowser:AddSortButtons(screenscale)

	--make active-browser
  local activeBrowser = vgui.Create("ZSPerkBrowser",frame)
  activeBrowser:AlignRight(10)
	activeBrowser.Title:SetText("Loadout")

	allBrowser.EntryClickCallback = function(entryTable)
		if activeBrowser:CanAddPerkEntry(entryTable) then
			SwapPerkBrowser(entryTable,allBrowser,activeBrowser)
			surface.PlaySound("items/ammocrate_open.wav")
			FixBrowserEntries(frame)
			UpdateTracker(frame)
			activeBrowser:ReSort()
		else
			surface.PlaySound("buttons/combine_button_locked.wav")
		end
	end
	activeBrowser.EntryClickCallback = function(entryTable)
		SwapPerkBrowser(entryTable,activeBrowser,allBrowser)
		allBrowser:ReSort()
		surface.PlaySound("items/ammocrate_close.wav")
		FixBrowserEntries(frame)
		UpdateTracker(frame)
	end
	local activeSkillsAssoc
	if table.Count(MySelf:GetDesiredActiveSkills()) == 0 then
		activeSkillsAssoc = table.ToAssoc(self.DefaultPerks)
	else
		activeSkillsAssoc = table.ToAssoc(MySelf:GetDesiredActiveSkills())
	end
	local unlockedSkillsAssoc = table.ToAssoc(MySelf:GetUnlockedSkills())
	for id, skill in pairs(GAMEMODE.Skills) do
		if not GAMEMODE:GetIsFreeplay() and not unlockedSkillsAssoc[id] then
			continue
		elseif activeSkillsAssoc[id] then
			//if this perk is ACTIVE add it to the active browser
			activeBrowser:MakePerkEntry(skill,screenscale)
		else
			//this perk is inactive so add it to the all-browser
			allBrowser:MakePerkEntry(skill,screenscale)
		end
	end
	allBrowser:SortByName()
	activeBrowser:SortByName()
	frame.AllBrowser = allBrowser
	frame.ActiveBrowser = activeBrowser

	--make the Slot-Tracker
	local tracker = vgui.Create("DPanel",frame)
	tracker:SetSize(965 * screenscale,38 * screenscale)
	tracker:CenterHorizontal()
	tracker:AlignBottom(5 * screenscale)
	tracker.Paint = function(self, w, h)
		draw.RoundedBox(6,0,0,w,h,PERKS_COLOR_DARK)
	end
	frame.Tracker = tracker

	--add the counter
	local counterframe = vgui.Create("DPanel",tracker)
	counterframe:SetSize(84 * screenscale, 23 * screenscale)
	counterframe:AlignLeft(5 * screenscale)
	counterframe:CenterVertical()
	counterframe.Paint = function(self, w, h)
		draw.RoundedBox(4,0,0,w,h, COLOR_LIMEGREEN)
		draw.RoundedBox(4,2,2,w-4,h-4, color_black)
	end

	local counter = EasyLabel(counterframe,"000/000","ZSHUDFontSmaller", COLOR_LIMEGREEN)
	counter:SetSize(counterframe:GetWide(),counterframe:GetTall())
	counter:CenterVertical()
	counter:CenterHorizontal()
	counter:SetContentAlignment(5)
	tracker.Counter = counter

	--add the slots to the tracker
	tracker.Slots = {}
	for k = 1, self.PerkSlots do
		local slot = vgui.Create("DPanel", tracker)
		slot:SetSize(23 * screenscale,23 * screenscale)
		slot:AlignLeft(10 * screenscale + (28 * screenscale) * (k + 2))
		slot:CenterVertical()
		slot.Paint = function(self, w, h)
			draw.RoundedBox(0,0,0,w,h, slot.Filled and COLOR_LIMEGREEN or COLOR_DARKGRAY)
			draw.RoundedBox(4,2,2,w-4,h-4, slot.Filled and COLOR_DARKGRAY or color_black)
		end
		table.insert(tracker.Slots,slot)
	end

	--make the loadout button
	local loadoutButton = vgui.Create("ZSPerkFileButton", activeBrowser.TopWindow)
	local w = loadoutButton:GetWide()
	loadoutButton:SetPos(3 * screenscale, 3 * screenscale)
	loadoutButton.Image:SetImage("tropical/loadbutton.png")
	loadoutButton.Button.DoClick = OpenLoadoutMenu

	--add the apply button to the tracker
	local setActiveFrame = vgui.Create("DPanel",tracker)
	setActiveFrame:SetSize(194 * screenscale, 23 * screenscale)
	setActiveFrame:AlignRight(5 * screenscale)
	setActiveFrame:CenterVertical()
	setActiveFrame.Paint = function(self, w, h)
		draw.RoundedBox(4,0,0,w,h, COLOR_LIMEGREEN)
		draw.RoundedBox(4,2,2,w-4,h-4, tracker.ApplyButton:IsHovered() and COLOR_DARKGREEN or color_black)
	end

	local setActiveText = EasyLabel(setActiveFrame,"Set Active Loadout","ZSHUDFontSmaller", COLOR_LIMEGREEN)
	setActiveText:SetSize(setActiveFrame:GetWide(),setActiveFrame:GetTall())
	setActiveText:CenterVertical()
	setActiveText:CenterHorizontal()
	setActiveText:SetContentAlignment(5)

	local setActiveButton = vgui.Create("DButton", setActiveFrame)
	setActiveButton:SetText("")
	setActiveButton:Dock( FILL )
	setActiveButton.Paint = function() end
	setActiveButton.DoClick = function()
		self:SetMenuPerksDesired()
	end
	tracker.ApplyButton = setActiveButton

	FixBrowserEntries(frame)
	UpdateTracker(frame)

	frame:MakePopup()
	frame:CenterMouse()
end

local BROWSER = {}
local SORT_NAME = 1
local SORT_WEIGHT = 2
local SORT_FAMILY = 3
local SORTSTATE_OFF = 1
local SORTSTATE_ON = 2
local SORTSTATE_REVERSE = 3

function BROWSER:Init()
  local screenscale = BetterScreenScale()
  local w = 500
  local h = 762
  local tabHeight = 100
  self:SetSize(w * screenscale, h * screenscale)

	self.Entries = {}
	self.EntryBottom = 0
	self.Perks = {}
	self.PerkWeight = 0

	--draw the top window
  local topWindow = vgui.Create("DPanel", self)
  topWindow:SetWide( (w - 20) * screenscale)
  topWindow:SetTall( (tabHeight - 5 * screenscale ) * screenscale)
  topWindow.Paint = function(frame, w, h)
		--draw.SimpleText(tostring(self.PerkWeight),"ZSHUDFontSmall",w-20,0,COLOR_WHITE,TEXT_ALIGN_TOP,TEXT_ALIGN_RIGHT)
    draw.RoundedBox( 10, 0, 0, w, h, PERKS_COLOR_DARK)
  end
  topWindow:AlignTop( 10 * screenscale )
  topWindow:AlignLeft( 10 * screenscale )
	self.TopWindow = topWindow

	--add title to the top window
	local title = EasyLabel(topWindow, "              ", "ZSHUDFont", COLOR_GRAY)
	title:CenterHorizontal()
	title:CenterVertical()
	self.Title = title

	--draw the window
  local displayWindow = vgui.Create("DPanel", self)
  displayWindow:SetWide( (w - 20) * screenscale)
  displayWindow:SetTall( (h - 20 - tabHeight) * screenscale)
  displayWindow.Paint = function(window, w, h)
		--draw.SimpleText(tostring(self.PerkWeight),"ZSHUDFontSmall",w-20,0,COLOR_WHITE,TEXT_ALIGN_TOP,TEXT_ALIGN_RIGHT)
    draw.RoundedBox( 10, 0, 0, w, h, PERKS_COLOR_DARK)
  end
  displayWindow:AlignBottom( 10 * screenscale )
  displayWindow:AlignLeft( 10 * screenscale )

  --draw a DScrollPanel
  local scrollPanel = vgui.Create("DScrollPanel", displayWindow)
	scrollPanel:Dock( FILL )
	scrollPanel:SetBackgroundColor(PERKS_COLOR_DARK)

	--change how the bar looks
	local sbar = scrollPanel:GetVBar()
	function sbar.Paint() end
	function sbar.btnUp:Paint() end
	function sbar.btnDown:Paint() end
	function sbar.btnGrip:Paint(w, h)
		draw.RoundedBox(4,0,0,w,h,color_white)
	end

	self.ScrollPanel = scrollPanel


end

function BROWSER:AddSortButtons(screenscale)
	local screenscale = screenscale or BetterScreenScale()
	--draw the sort buttons
	local names = {
		[SORT_NAME] = "A",
		[SORT_WEIGHT] = "W",
		[SORT_FAMILY] = "F"
	}
	self.SortButtons = {}
	for n = 1, 3 do
		local sorter = vgui.Create("ZSPerkSorter", self.TopWindow)
		sorter.Name = names[n]
		sorter.Text:SetText(sorter.Name)
		sorter.ID = n
		self.SortButtons[n] = sorter
		sorter.Button.DoClick = function()
			self:SortButtonPressed(sorter.ID)
		end
		sorter:AlignLeft(5 * screenscale + (n - 1) * (sorter:GetWide() + 5 * screenscale))
		sorter:AlignTop(5 * screenscale)
	end
end

--bitmask for coloring with different modes. add multiple perk entry types to add effects
PERK_ENTRY_HOVERED = 1
PERK_ENTRY_SELECTED = 2
PERK_ENTRY_LOCKED = 4
PERK_ENTRY_COLORS = {
	Color(100, 100, 100, 125),
	Color(150, 150, 150, 125),
	Color(100, 200, 100, 125),
	Color(150, 255, 150, 125),
	Color(100, 20, 20, 125),
	Color(150, 30, 30, 125),
	Color(200, 200, 0, 125),
	Color(255, 255, 100, 125),
}
function BROWSER:MakePerkEntry(perkTable, screenscale)
	screenscale = screenscale or BetterScreenScale()

	--create the box
	local frame = vgui.Create("DPanel", self.ScrollPanel)
	frame.Paint = function(self, w, h)
		local i = ((frame.Button and frame.Button:IsHovered() and PERK_ENTRY_HOVERED or 0)
			+ (frame.Selected and PERK_ENTRY_SELECTED or 0)
			+ (frame.Locked and PERK_ENTRY_LOCKED or 0)
		)
		draw.RoundedBox(6, 0, 0, w, h, PERK_ENTRY_COLORS[i+1])

		/*
		if frame.Button and frame.Button:IsHovered() then
			if frame.Selected then
				draw.RoundedBox( 6, 0, 0, w, h, SHOP_ENTRY_COLOR_BOTH)
			else
				draw.RoundedBox( 6, 0, 0, w, h, SHOP_ENTRY_COLOR_HOVERED)
			end
		else
			if frame.Selected then
				draw.RoundedBox( 6, 0, 0, w, h, SHOP_ENTRY_COLOR_SELECTED)
			else
				draw.RoundedBox( 6, 0, 0, w, h, SHOP_ENTRY_COLOR)
			end
		end
		*/
	end
	frame:SetWide(self:GetWide() - 45 * screenscale)
	frame:SetTall(150 * screenscale)

	local xx = frame:GetWide()
	local yy = frame:GetTall()

	--create the top box
	topWindow = vgui.Create("DPanel", frame)
	topWindow:SetSize(xx - 10 * screenscale,(yy - 15 * screenscale)/4)
	topWindow:AlignLeft(5 * screenscale)
	topWindow:AlignTop(5 * screenscale)
	topWindow.Paint = function(self, w, h)
		local col = CARD_COLOR_1
		draw.RoundedBox(6, 0, 0, w, h, col)
	end

	--create the bottom box
	botWindow = vgui.Create("DPanel", frame)
	botWindow:SetSize(xx - 10 * screenscale,(yy - 15 * screenscale)*3/4)
	botWindow:AlignLeft(5 * screenscale)
	botWindow:AlignBottom(5 * screenscale)
	botWindow.Paint = function(self, w, h)
		local col = CARD_COLOR_1
		draw.RoundedBox(6, 0, 0, w, h, col)
	end

	--draw the family
	local txt = string.format("[%s]",perkTable.Family and perkTable.Family or "-")
	local familyText = EasyLabel(topWindow,txt,"ZSHUDFontSmall", COLOR_WHITE)
	familyText:AlignLeft(5 * screenscale)
	familyText:CenterVertical()

	--draw the name
	local nameText = EasyLabel(topWindow,perkTable.Name, "ZSHUDFontSmall", COLOR_WHITE)
	nameText:AlignLeft(40 * screenscale)
	nameText:CenterVertical()

	--draw the weight
	/*
	if perkTable.Weight > 4 then
		local slot = vgui.Create("DPanel", topWindow)
		slot:SetSize(topWindow:GetTall()-10*screenscale,topWindow:GetTall() - 10*screenscale)
		slot:AlignRight(5 * screenscale)
		slot:CenterVertical()
		slot.Paint = function(self, w, h)
			local col = COLOR_GREEN
			draw.RoundedBox(6,0,0,w,h,col)
		end
	else
	end
	*/
	for k = 1, perkTable.Weight do
		local slot = vgui.Create("DPanel", topWindow)
		slot:SetSize(topWindow:GetTall()-10*screenscale,topWindow:GetTall() - 10*screenscale)
		slot:AlignRight(5 * screenscale + (topWindow:GetTall() - 5 * screenscale) * (k - 1))
		slot:CenterVertical()
		slot.Paint = function(self, w, h)
			draw.RoundedBox(0,0,0,w,h,frame.Locked and COLOR_RED or COLOR_LIMEGREEN)
			draw.RoundedBox(4,2,2,w-4,h-4,COLOR_DARKGRAY)
		end
	end

	--add description
	local descText = EasyLabel(botWindow,perkTable.Description,"ZSBodyTextFont", COLOR_GRAY)
	descText:SetSize(botWindow:GetWide() - 10 * screenscale, botWindow:GetTall() - 20 * screenscale)
	descText:AlignLeft(5 * screenscale)
	descText:AlignTop(10 * screenscale)
	descText:SetContentAlignment(7) --topleft (look at nudmpad)
	descText:SetWrap(true)
	descText:SetMultiline(true)

	--draw a button over the top
	local button = vgui.Create("DButton", frame)
	button:SetText("")
	button:Dock( FILL )
	button.Paint = function() end
	frame.Button = button

	frame.PerkTable = perkTable

	return self:AddPerkEntry(frame, screenscale)
end

function BROWSER:AddPerkEntry(frame, screenscale)
	screenscale = screenscale or BetterScreenScale()

	frame:SetParent(self.ScrollPanel)

	self.Entries[#self.Entries + 1] = frame


	frame.Button.DoClick = function()
		self:EntryClicked(frame)
	end
	frame.Button.DoRightClick = function()
		self:EntryForceClicked(frame)
	end
	frame.Button.DoDoubleClick = function()
		self:EntryForceClicked(frame)
	end

	frame:SetPos(0,self.EntryBottom + 5 * screenscale)
	frame:AlignLeft(5 * screenscale)

	frame.Locked = false

	self.Perks[#self.Perks + 1] = frame.PerkTable
	self.PerkWeight = self.PerkWeight + frame.PerkTable.Weight

	self.EntryBottom = self.EntryBottom + 5 * screenscale + frame:GetTall()

	return frame
end

function BROWSER:CanAddPerkEntry(entryFrame)

	//if this perk would put you over your max slot count, it will not fit
	if self.PerkWeight + entryFrame.PerkTable.Weight > GAMEMODE.PerkSlots then
		return false
	end

	//if the family of this perk is already within the perk table, it will not fit
	if entryFrame.PerkTable.Family then
		for _, perk in ipairs(self.Perks) do
			if perk.Family == entryFrame.PerkTable.Family then
				return false
			end
		end
	end

	return true
end

//this DOES NOT delete the entry, only removes it from the list of entries
function BROWSER:RemovePerkEntry(entryFrame)
	return self:RemovePerkEntryAtIndex(table.KeyFromValue(self.Entries,entryFrame))
end

function BROWSER:RemovePerkEntryAtIndex(index)
	if not index then return end

	local entry = self.Entries[index]

	table.RemoveByValue(self.Perks,entry.PerkTable) --remove the perk from the table
	self.PerkWeight = self.PerkWeight - entry.PerkTable.Weight --remove its weight

	table.remove(self.Entries,index)

	self:FixEntries()
	return entry
end

function BROWSER:EntryClicked(entryFrame)
	if not entryFrame then return end

	/*
	if self.SelectedEntry then
		self.SelectedEntry.Selected = nil
	end
	self.SelectedEntry = entryFrame
	entryFrame.Selected = true
	*/

	if self.EntryClickCallback then
		self.EntryClickCallback(entryFrame)
	end
end

function BROWSER:EntryForceClicked(entryFrame)
	if not entryFrame then return end

	if self.EntryForceClickCallback then
		self.EntryForceClickCallback(entryFrame)
	end
end

function BROWSER:MarkUnsorted()
	if not self.SortButtons then return end
	--update sorting buttons to all display off
	for n = 1, 3 do
		self.SortButtons[n]:SetSortState(SORTSTATE_OFF)
	end
end

function BROWSER:ReSort()
	if self.CurrentSortName && self.CurrentSortState then
		self:SortByID(self.CurrentSortName,self.CurrentSortState)
	else
		self:SortByName()
	end
end

function BROWSER:SetEmpty()
	self.Perks = {}
	self.PerkWeight = 0
	self.Entries = {}
	self.EntryBottom = 0
end

function BROWSER:SortButtonPressed(id)
	--update the sorting buttons to display the new state
	--also save out the new sortstate of pressed button
	local newstate
	for n = 1, 3 do
		if n == id then
			--toggle the state of this button
			newstate = self.SortButtons[n]:ToggleSortState()
		else
			--reset the state of other sort buttons to off
			self.SortButtons[n]:SetSortState(SORTSTATE_OFF)
		end
	end

	self:SortByID(id,newstate)
end

function BROWSER:SortByID(id, newstate)
	--apply proper sorting
	if id == SORT_NAME then
		self:SortByName(newstate == SORTSTATE_REVERSE)
	elseif id == SORT_FAMILY then
		self:SortByFamily(newstate == SORTSTATE_REVERSE)
	elseif id == SORT_WEIGHT then
		self:SortByWeight(newstate == SORTSTATE_REVERSE)
	end

	self.CurrentSortName = id
	self.CurrentSortState = newstate
end

function BROWSER:SortByName(backwards)
	backwards = backwards or false
	table.sort(self.Entries, function(a,b)
		return (backwards ~= (a.PerkTable.Name < b.PerkTable.Name))
		--return a.PerkTable.Name < b.PerkTable.Name
	end)
	self:FixEntries()
end

function BROWSER:SortByWeight(backwards)
	backwards = backwards or false
	table.sort(self.Entries, function(a,b)
		if a.PerkTable.Weight == b.PerkTable.Weight then
			return (backwards ~= (a.PerkTable.Name > b.PerkTable.Name))
		end
		return (backwards ~= (a.PerkTable.Weight > b.PerkTable.Weight))
	end)
	self:FixEntries()
end

function BROWSER:SortByFamily(backwards)
	backwards = backwards or false
	table.sort(self.Entries, function(a,b)
		if a.PerkTable.Family == b.PerkTable.Family then
			return (backwards ~= (a.PerkTable.Name > b.PerkTable.Name))
		end
		return (backwards ~= ((a.PerkTable.Family and a.PerkTable.Family or "") > (b.PerkTable.Family and b.PerkTable.Family or "")))
	end)
	self:FixEntries()
end

function BROWSER:FixEntries()
	screenscale = screenscale or BetterScreenScale()

	self.EntryBottom = 0
	for _, entry in ipairs(self.Entries) do
		entry:SetPos(0, self.EntryBottom + 5 * screenscale)
		entry:AlignLeft(5 * screenscale)

		self.EntryBottom = self.EntryBottom + 5 * screenscale + entry:GetTall()
	end
end

function BROWSER:GetPerkList()
	local perks = {}
	for k, v in ipairs(self.Perks) do
		perks[k] = v.ID
	end

	return perks
end


vgui.Register("ZSPerkBrowser", BROWSER, "Panel")

local SORTER = {}

function SORTER:Init()
  local screenscale = BetterScreenScale()
  local w = 30
  local h = 30

  self:SetWide(w * screenscale)
  self:SetTall(h * screenscale)
	self.Color = SHOP_ENTRY_COLOR
  self.Paint = function(self, w, h)
    draw.RoundedBox( 4, 0, 0, w, h, self.Color)
  end

  local text = EasyLabel(self, "WW", "ZSHUDFontSmall", color_white)
  text:SetContentAlignment(5)
  text:CenterHorizontal()
  text:CenterVertical()
	self.Text = text

	local button = vgui.Create("DButton", self)
	button:SetText("")
	button:Dock( FILL )
	button.Paint = function() end
	self.Button = button

	self.SortState = SORTSTATE_OFF
end

function SORTER:SetSortState(newstate)
	if newstate == SORTSTATE_OFF then
		self.Color = SHOP_ENTRY_COLOR
	else
		self.Color = SHOP_ENTRY_COLOR_HOVERED
		if newstate == SORTSTATE_ON then
		end
	end

	self.SortState = newstate
end

function SORTER:ToggleSortState()
	--toggle between on and reverse for this sorter
	if self.SortState == SORTSTATE_ON then
		self:SetSortState(SORTSTATE_REVERSE)
		return SORTSTATE_REVERSE
	else
		self:SetSortState(SORTSTATE_ON)
		return SORTSTATE_ON
	end
end

vgui.Register("ZSPerkSorter", SORTER, "Panel")

local BUTTON = {}

function BUTTON:Init()
	local screenscale = BetterScreenScale()
	local w,h = 32, 32
	self:SetSize(w * screenscale, h * screenscale)
	self.Paint = function(self, w, h)
		draw.RoundedBox(6,0,0,w,h,COLOR_WHITE)
		draw.RoundedBox(6,1,1,w-2,h-2,self.Button:IsHovered() and PERKS_COLOR_LIGHT or color_black)
	end

	local image = vgui.Create("DImage", self)
	image:SetSize(24,24)
	image:CenterHorizontal()
	image:CenterVertical()
	image:SetImage("tropical/savebutton.png")
	self.Image = image

	local button = vgui.Create("DButton", self)
	button:SetText("")
	button:Dock( FILL )
	button.Paint = function() end
	self.Button = button
end

vgui.Register("ZSPerkFileButton", BUTTON, "Panel")

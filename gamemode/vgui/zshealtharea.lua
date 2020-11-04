local PANEL = {}

local colDark = Color(50,50,50,220)
local colLight = Color(255,255,255,220)

local texDownEdge = surface.GetTextureID("gui/gradient_down")
local colHealth = Color(0, 0, 0, 240)
local function HealthPaint(self, w, h)
	local lp = MySelf
	if lp:IsValid() then
		local screenscale = BetterScreenScale()
		local health = math.max(lp:Health(), 0)
		local healthperc = math.Clamp(health / lp:GetMaxHealth(), 0, 1)

		colHealth.r = (1 - healthperc) * 180
		colHealth.g = healthperc * 180
		colHealth.b = 0

		local subwidth = healthperc * (w - 2)

		--draw HP bar backfill
		surface.SetDrawColor(0, 0, 0, 230)
		surface.DrawRect(1, 0, w, h)

		--draw HP bar fill
		surface.SetDrawColor(colHealth.r * 0.6, colHealth.g * 0.6, colHealth.b, 160)
		surface.SetTexture(texDownEdge)
		surface.DrawTexturedRect(1, 1, subwidth, h - 2)
		surface.SetDrawColor(colHealth.r * 0.6, colHealth.g * 0.6, colHealth.b, 30)
		surface.DrawRect(1, 1, subwidth, h - 2)


		--make a little mark at the end
		surface.SetDrawColor(255,255,255,220)
		surface.SetTexture(texDownEdge)
		surface.DrawTexturedRect(2 + subwidth - 4, 1, 2, h-1)


		--write the text on top of the bar
		draw.SimpleTextBlurry(health, "ZSHUDFont", w - 10 * screenscale, h/2, colHealth, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

	end
end

local colSpeed = Color(255,255,255,220)
local function SpeedPaint(self,w,h)
	local lp = MySelf
	if lp:IsValid() then
		local screenscale = BetterScreenScale()
		local vel = lp:GetVelocity()
		vel.z = 0
		local speedTxt = Format("%6.1f u/s",vel:Length())

		//print speed
		draw.SimpleText(speedTxt, "SpeedometerFont", w - 5 * screenscale, h/2, colSpeed, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
end

local function AmmoThink(self)
	local lp = MySelf
	if not lp:IsValid() then return end

	if lp:IsValidZombie() then
		self.Icon:SetAlpha(0)
		self.Timer:SetAlpha(0)
		return
	else
		self.Icon:SetAlpha(255)
		self.Timer:SetAlpha(255)
	end

	local newType = lp:GetResupplyAmmoType()
	if not self.CachedType or self.CachedType ~= newType then
		self.CachedType = newType

		local ki = killicon.Get(GAMEMODE.AmmoIcons[newType])
		self.Icon:SetImage(ki[1])
		if ki[2] then
			self.Icon:SetImageColor(ki[2])
			self.Timer:SetColor(ki[2])
		else
			self.Timer:SetColor(color_white)
		end
	end

	local nextSupplyTime
	if GAMEMODE:GetWave() <= 0 then
		nextSupplyTime = GAMEMODE:GetWaveStart() + GAMEMODE:GetResupplyTime()
	else
		nextSupplyTime = GAMEMODE:GetNextResupply()
	end
	local timeLeft = math.max(0, nextSupplyTime - CurTime())
	if MySelf.MaxStockpiles and MySelf.Stockpiles and MySelf.Stockpiles > 0 then
		self.Timer:SetText(Format(translate.Get("x_seconds2"),timeLeft,MySelf.Stockpiles))
	else
		self.Timer:SetText(Format(translate.Get("x_seconds"),timeLeft))
	end
end

function PANEL:Init()
	local screenscale = BetterScreenScale()

	self:SetSize(screenscale * 500, screenscale * 67)
	self:AlignLeft()
	self:AlignBottom()

	local w, h = self:GetSize()
	local healthBar = vgui.Create("Panel", self)
	healthBar:SetSize(w * 0.7,h / 2 - 1)
	healthBar:AlignLeft()
	healthBar:AlignTop(1)
	healthBar.Paint = HealthPaint

	local speedometer = vgui.Create("Panel", self)
	speedometer:SetSize(w * 0.3, h/2)
	speedometer:AlignRight()
	speedometer:AlignTop()
	speedometer.Paint = SpeedPaint

	local ammometer = vgui.Create("Panel", self)
	ammometer:SetSize(w * 0.3, h/2 - 1)
	ammometer:AlignRight()
	ammometer:AlignBottom(1)
	ammometer.Think = AmmoThink

	local ammoIcon = vgui.Create("DImage", ammometer)

	local ki = killicon.Get(GAMEMODE.AmmoIcons["pistol"])
	ammoIcon:SetImage(ki[1])
	if ki[2] then ammoIcon:SetImageColor(ki[2]) end
	ammoIcon:SetSize(h/2 - 4, h/2 - 4)
	ammoIcon:AlignRight(6)
	ammometer.Icon = ammoIcon

	local timer = EasyLabel(ammometer, "0s","SlotFont", color_white)
	timer:SetSize(w * 0.3 - h/2, h/2 - 1)
	timer:AlignRight(h/2 + 8)
	timer:AlignBottom()
	timer:SetContentAlignment(6)
	ammometer.Timer = timer


	self:ParentToHUD()
	self:InvalidateLayout()
end

local matGradientLeft = CreateMaterial("gradient-l", "UnlitGeneric", {["$basetexture"] = "vgui/gradient-l", ["$vertexalpha"] = "1", ["$vertexcolor"] = "1", ["$ignorez"] = "1", ["$nomip"] = "1"})

function PANEL:Paint(w, h)

	surface.SetDrawColor(50, 50, 50, 220)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(255,255,255,220)
	surface.DrawOutlinedRect(0, 0, w, h)

	return true
end

vgui.Register("ZSHealthArea", PANEL, "Panel")

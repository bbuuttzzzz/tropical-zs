concommand.Add("printdxinfo", function()
	print("DX Level: "..tostring(render.GetDXLevel()))
	print("Supports HDR: "..tostring(render.SupportsHDR()))
	print("Supports Pixel Shaders 1.4: "..tostring(render.SupportsPixelShaders_1_4()))
	print("Supports Pixel Shaders 2.0: "..tostring(render.SupportsPixelShaders_2_0()))
	print("Supports Vertex Shaders 2.0: "..tostring(render.SupportsVertexShaders_2_0()))
end)

local ammonames = {
	["pistol"] = "pistolammo",
	["buckshot"] = "shotgunammo",
	["smg1"] = "smgammo",
	["ar2"] = "assaultrifleammo",
	["357"] = "rifleammo",
	["pulse"] = "pulseammo",
	["battery"] = "50mkit",
	["xbowbolt"] = "crossbowammo",
	["impactmine"] = "impactmine",
	["chemical"] = "chemical",
	["gaussenergy"] = "nail"
}

concommand.Add("zs_quickbuyammo", function()
	if ammonames[GAMEMODE.CachedResupplyAmmoType] then
		RunConsoleCommand("zs_pointsshopbuy", "ps_"..ammonames[GAMEMODE.CachedResupplyAmmoType])
	end
end)

local function GetViewModelPosition(self, pos, ang)
	return pos + ang:Forward() * -256, ang
end

function DontDrawViewModel()
	if SWEP then
		SWEP.GetViewModelPosition = GetViewModelPosition
	end
end

-- Scales the screen based around 1080p but doesn't make things TOO tiny on low resolutions.
function BetterScreenScale()
	return math.max(ScrH() / 1080, 0.851) * GAMEMODE.InterfaceSize
end

function render.GetLightRGB(pos)
	local vec = render.GetLightColor(pos)
	return vec.r, vec.g, vec.b
end

local FFRAME = {}

function FFRAME:Init()
	self:SetTitle(" ")
	self:SetDraggable(false)
	if self.btnClose and self.btnClose:IsValid() then self.btnClose:SetVisible(false) end
	if self.btnMinim and self.btnMinim:IsValid() then self.btnMinim:SetVisible(false) end
	if self.btnMaxim and self.btnMaxim:IsValid() then self.btnMaxim:SetVisible(false) end
end

vgui.Register("FlatFrame", FFRAME, "DFrame")

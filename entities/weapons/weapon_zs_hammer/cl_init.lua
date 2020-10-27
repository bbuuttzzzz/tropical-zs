INC_CLIENT()
DEFINE_BASECLASS("weapon_zs_baserepair")

SWEP.ViewModelFOV = 75

function SWEP:DrawHUD()
	local screenscale = BetterScreenScale()

	surface.SetFont("ZSHUDFont")
	local nails = self:GetPrimaryAmmoCount()
	local text = translate.Format("nails_x", nails)
	local nTEXW, nTEXH = surface.GetTextSize(text)

	draw.SimpleTextBlurry(text, "ZSHUDFont", ScrW() - nTEXW * 0.75 - 32 * screenscale, ScrH() - nTEXH * 2.6, nails > 0 and COLOR_LIMEGREEN or COLOR_RED, TEXT_ALIGN_CENTER)

	BaseClass.DrawHUD(self)
end

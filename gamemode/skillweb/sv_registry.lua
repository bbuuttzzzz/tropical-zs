//Supported skill mods

GM:SetSkillModifierFunction(SKILLMOD_HEALTH, function(pl, amount)
	local current = pl:GetMaxHealth()
	local new = 100 + math.Clamp(amount, -99, 1000)
	pl:SetMaxHealth(new)
	pl:SetHealth(math.max(1, pl:Health() / current * new))
end)

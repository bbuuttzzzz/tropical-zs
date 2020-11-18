GM.Skills = {}
GM.SkillModifiers = {}
GM.SkillFunctions = {}
GM.SkillModifierFunctions = {}

function GM:AddSkill(id, signature, valueTable, weight, family)
	local skill = {}

	if CLIENT then
		skill.Description = description
	end

  skill.Name = translate.Get(signature)
	skill.Signature = signature
  skill.Values = valueTable
	skill.Weight = weight or 1
	skill.Family = family or nil
	skill.ID = id

	self.Skills[id] = skill

	return skill
end

-- Use this after all skills have been added. It assigns dynamic IDs!
function GM:AddTrinket(name, swepaffix, pairedweapon, veles, weles, tier, description, status, stocks)
	local skill = {Connections = {}}

	skill.Name = name
	skill.Trinket = swepaffix
	skill.Status = status

	local datatab = {PrintName = name, DroppedEles = weles, Tier = tier, Description = description, Status = status, Stocks = stocks}

	if pairedweapon then
		skill.PairedWeapon = "weapon_zs_t_" .. swepaffix
	end

	self.ZSInventoryItemData["trinket_" .. swepaffix] = datatab
	self.Skills[#self.Skills + 1] = skill

	return #self.Skills, self.ZSInventoryItemData["trinket_" .. swepaffix]
end

-- I'll leave this here, but I don't think it's needed.
function GM:GetTrinketSkillID(trinketname)
	for skillid, skill in pairs(GM.Skills) do
		if skill.Trinket and skill.Trinket == trinketname then
			return skillid
		end
	end
end

function GM:AddSkillModifier(skillid, modifier, amount)
	self.SkillModifiers[skillid] = self.SkillModifiers[skillid] or {}
	self.SkillModifiers[skillid][modifier] = (self.SkillModifiers[skillid][modifier] or 0) + amount
end

function GM:AddSkillFunction(skillid, func)
	self.SkillFunctions[skillid] = self.SkillFunctions[skillid] or {}
	table.insert(self.SkillFunctions[skillid], func)
end


function GM:SetSkillModifierFunction(modid, func)
	self.SkillModifierFunctions[modid] = func
end

function GM:MkGenericMod(modifiername)
	return function(pl, amount) pl[modifiername] = math.Clamp(amount + 1.0, 0.0, 1000.0) end
end

SKILLMOD_HEALTH = 1
SKILLMOD_WEIGHT_REDUCTION = 2
SKILLMOD_SCRAP_MUL = 3
SKILLMOD_RESUPPLY_MUL = 4
SKILLMOD_CALM_THRESHOLD = 5
SKILLMOD_BACKPEDAL_PENALTY_MUL = 6
SKILLMOD_RESPITE_THRESHOLD = 7 --min fraction of max HP you get set to when you get respite heal
SKILLMOD_RESPITE_MIN = 8 --min fraction of max HP you gain when you get respite heal
SKILLMOD_STOCKPILE_COUNT = 9
SKILLMOD_SIGIL_HEAL_MUL = 10
SKILLMOD_PHASE_SPEED_INITIAL = 11
SKILLMOD_OOMPH_MAX_MUL = 12
SKILLMOD_OOMPH_CHARGE_TIME_MUL = 13
SKILLMOD_UPGRADE_COUNT = 14
SKILLMOD_STARTING_SCRAP = 15

--[[
lua_run local t = {} for n = 1, 5 do table.insert(t, n) end Entity(1):SetUnlockedSkills(t)
]]

SKILL_NONE = 0 -- Dummy skill used for "connecting" to their trees.
SKILL_LIGHTNESS_1 = 1
SKILL_LIGHTNESS_2 = 2
SKILL_SCROUNGER_1 = 5
SKILL_SCROUNGER_2 = 6
SKILL_SCRAP_HOUND_1 = 9
SKILL_SCRAP_HOUND_2 = 10
SKILL_HEALTHY_1 = 13
SKILL_HEALTHY_2 = 14
SKILL_RESPITE_2 = 18
SKILL_CALM_3 = 22
SKILL_MOONWALKER_1 = 23
SKILL_WOOISM = 25
SKILL_CRACKSHOT = 26
SKILL_HOARDER = 28
SKILL_STOCKPILE_1 = 29
SKILL_STOCKPILE_2 = 30
SKILL_PHASER_1 = 32
SKILL_PHASER_2 = 33
SKILL_BATTLE_CADER = 34
SKILL_BIG_OOMPH = 35
SKILL_HEAVY_LIFTER = 36
SKILL_QUICK_FIX = 37
SKILL_PICKY = 38
SKILL_HAND_OF_FATE = 39
SKILL_SUGAR_DADDY = 40

local GOOD = "^"..COLORID_GREEN
local BAD = "^"..COLORID_RED

GM:SetSkillModifierFunction(SKILLMOD_WEIGHT_REDUCTION, function(pl, amount)
	pl.WeaponWeightMul = math.Clamp(1 - amount, 0, 1)
end)

GM:SetSkillModifierFunction(SKILLMOD_SCRAP_MUL, function(pl, amount)
	pl.ScrapGainMul = math.Clamp(1+amount,0,1000)
end)

GM:SetSkillModifierFunction(SKILLMOD_RESUPPLY_MUL, function(pl, amount)
	pl.ResupplyMul = math.Clamp(1+amount,0,1000)
end)

GM:SetSkillModifierFunction(SKILLMOD_RESPITE_THRESHOLD, function(pl, amount)
	pl.RespiteThreshold = amount
end)

GM:SetSkillModifierFunction(SKILLMOD_RESPITE_MIN, function(pl, amount)
	pl.RespiteMin = amount
end)

GM:SetSkillModifierFunction(SKILLMOD_CALM_THRESHOLD, function(pl, amount)
	pl.CalmThreshold = math.Clamp(GAMEMODE.DefaultCalmThreshold - amount,0,GAMEMODE.DefaultCalmThreshold)
end)

GM:SetSkillModifierFunction(SKILLMOD_BACKPEDAL_PENALTY_MUL, function(pl, amount)
	pl.BackpedalPenaltyMul = math.Clamp(1-amount,0,1)
end)

GM:SetSkillModifierFunction(SKILLMOD_STOCKPILE_COUNT,function(pl, amount)
	pl.Stockpiles = 0
	pl.MaxStockpiles = math.Clamp(amount,0,3)
end)

GM:SetSkillModifierFunction(SKILLMOD_PHASE_SPEED_INITIAL, function(pl, amount)
	pl.PhaseSpeedInitial = math.max(amount,GAMEMODE.DefaultStartPhaseSpeed)
end)

GM:SetSkillModifierFunction(SKILLMOD_OOMPH_MAX_MUL, function(pl, amount)
	pl.OomphMaxMul = math.max(amount + 1, 0)
end)

GM:SetSkillModifierFunction(SKILLMOD_OOMPH_CHARGE_TIME_MUL, function(pl, amount)
	pl.OomphChargeTimeMul = math.max(amount + 1, 0)
end)
GM:SetSkillModifierFunction(SKILLMOD_UPGRADE_COUNT, function(pl, amount)
	pl.UpgradeCount = math.Clamp(3 + amount, 1, 5)
end)

GM:SetSkillModifierFunction(SKILLMOD_STARTING_SCRAP, function(pl, amount)
	pl.StartingScrap = math.Clamp(amount, 0, 200)
end)

// * pieces
GM:AddSkill(SKILL_LIGHTNESS_1, "lightness1", {50}, 3, "L")
GM:AddSkill(SKILL_LIGHTNESS_2, "lightness2", {100}, 6, "L")
GM:AddSkillModifier(SKILL_LIGHTNESS_1, SKILLMOD_WEIGHT_REDUCTION, 0.5)
GM:AddSkillModifier(SKILL_LIGHTNESS_2, SKILLMOD_WEIGHT_REDUCTION, 1)

GM:AddSkill(SKILL_SCROUNGER_1, "scrounger1", {30}, 2, "A")
GM:AddSkill(SKILL_SCROUNGER_2, "scrounger2", {50}, 4, "A")
GM:AddSkillModifier(SKILL_SCROUNGER_1, SKILLMOD_RESUPPLY_MUL, 0.3)
GM:AddSkillModifier(SKILL_SCROUNGER_2, SKILLMOD_RESUPPLY_MUL, 0.5)

GM:AddSkill(SKILL_SCRAP_HOUND_1, "scraphound1",{30}, 2, "A")
GM:AddSkill(SKILL_SCRAP_HOUND_2, "scraphound2",{50}, 4, "A")
GM:AddSkillModifier(SKILL_SCRAP_HOUND_1, SKILLMOD_SCRAP_MUL, 0.3)
GM:AddSkillModifier(SKILL_SCRAP_HOUND_2, SKILLMOD_SCRAP_MUL, 0.5)

GM:AddSkill(SKILL_HEALTHY_1, "healthy1", {10}, 1)
GM:AddSkill(SKILL_HEALTHY_2, "healthy2", {25}, 2)
GM:AddSkillModifier(SKILL_HEALTHY_1, SKILLMOD_HEALTH, 10)
GM:AddSkillModifier(SKILL_HEALTHY_2, SKILLMOD_HEALTH, 25)

GM:AddSkill(SKILL_RESPITE_2, "respite", {50, 25}, 2, "R")
GM:AddSkillModifier(SKILL_RESPITE_2, SKILLMOD_RESPITE_MIN,0.25)
GM:AddSkillModifier(SKILL_RESPITE_2, SKILLMOD_RESPITE_THRESHOLD,0.5)

GM:AddSkill(SKILL_CALM_3, "calm", nil, 3)
GM:AddSkillModifier(SKILL_CALM_3, SKILLMOD_CALM_THRESHOLD, 40)

GM:AddSkill(SKILL_MOONWALKER_1, "moonwalker", {25},2,"M")
GM:AddSkillModifier(SKILL_MOONWALKER_1, SKILLMOD_BACKPEDAL_PENALTY_MUL, 0.25)

GM:AddSkill(SKILL_WOOISM, "wooism", nil, 3,"W")
GM:AddSkillFunction(SKILL_WOOISM, function(pl, active)
	pl.Wooism = active
end)

GM:AddSkill(SKILL_CRACKSHOT, "crackshot", nil,3,"W")
GM:AddSkillFunction(SKILL_CRACKSHOT, function(pl, active)
	pl.Crackshot = active
end)

GM:AddSkill(SKILL_HOARDER, "hoarder", nil, 1)
GM:AddSkillFunction(SKILL_HOARDER, function(pl, active)
	pl.Hoarder = active
end)

GM:AddSkill(SKILL_STOCKPILE_2, "stockpile", {3}, 3,"S")
GM:AddSkillModifier(SKILL_STOCKPILE_2, SKILLMOD_STOCKPILE_COUNT, 3)

GM:AddSkill(SKILL_PHASER_1, "phaser1", nil,2,"P")
GM:AddSkill(SKILL_PHASER_2, "phaser2", nil,4,"P")
GM:AddSkillModifier(SKILL_PHASER_1, SKILLMOD_PHASE_SPEED_INITIAL, 36)
GM:AddSkillModifier(SKILL_PHASER_2, SKILLMOD_PHASE_SPEED_INITIAL, 150)

GM:AddSkill(SKILL_BATTLE_CADER, "battlecader", nil, 2)
GM:AddSkillFunction(SKILL_BATTLE_CADER, function(pl, active)
	pl.BattleCader = active
end)

GM:AddSkill(SKILL_BIG_OOMPH, "bigoomph", nil, 1)
GM:AddSkillModifier(SKILL_BIG_OOMPH, SKILLMOD_OOMPH_MAX_MUL, 1)
GM:AddSkillModifier(SKILL_BIG_OOMPH, SKILLMOD_OOMPH_CHARGE_TIME_MUL, 3)

GM:AddSkill(SKILL_HEAVY_LIFTER, "heavylifter", nil, 1)
GM:AddSkillFunction(SKILL_HEAVY_LIFTER, function(pl, active)
	pl.HeavyLifter = active
end)

GM:AddSkill(SKILL_QUICK_FIX, "quickfix", nil, 1)
GM:AddSkillFunction(SKILL_QUICK_FIX, function(pl, active)
	pl.QuickFix = active
end)

GM:AddSkill(SKILL_PICKY, "picky", nil, 6, "U")
GM:AddSkillModifier(SKILL_PICKY, SKILLMOD_UPGRADE_COUNT, 2)

GM:AddSkill(SKILL_HAND_OF_FATE, "handoffate", {10, 25, 25, 25}, 1, "U")
GM:AddSkillModifier(SKILL_HAND_OF_FATE, SKILLMOD_UPGRADE_COUNT, -2)
GM:AddSkillModifier(SKILL_HAND_OF_FATE, SKILLMOD_HEALTH, 10)
GM:AddSkillModifier(SKILL_HAND_OF_FATE, SKILLMOD_WEIGHT_REDUCTION, 0.25)
GM:AddSkillModifier(SKILL_HAND_OF_FATE, SKILLMOD_SCRAP_MUL, 0.25)
GM:AddSkillModifier(SKILL_HAND_OF_FATE, SKILLMOD_RESUPPLY_MUL, 0.25)

GM:AddSkill(SKILL_SUGAR_DADDY, "sugardaddy", {100}, 3)
GM:AddSkillModifier(SKILL_SUGAR_DADDY, SKILLMOD_STARTING_SCRAP, 100)

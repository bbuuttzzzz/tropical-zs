GM.Skills = {}
GM.SkillModifiers = {}
GM.SkillFunctions = {}
GM.SkillModifierFunctions = {}

function GM:AddSkill(id, name, description, weight, family)
	local skill = {}

	if CLIENT then
		skill.Description = description
	end

	if #name == 0 then
		name = "Skill "..id
		skill.Disabled = true
	end

	skill.Name = name

	local signature = string.lower(name)
	signature = string.gsub(signature, "%p", "")
	signature = string.gsub(signature, "%s", "")

	translate.GetTranslations("en")["skill_" .. signature] = name

	skill.Signature = signature
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

--[[
lua_run local t = {} for n = 1, 5 do table.insert(t, n) end Entity(1):SetUnlockedSkills(t)
]]

SKILL_NONE = 0 -- Dummy skill used for "connecting" to their trees.
SKILL_LIGHTNESS_1 = 1
SKILL_LIGHTNESS_2 = 2
SKILL_LIGHTNESS_3 = 3
SKILL_LIGHTNESS_4 = 4
SKILL_SCROUNGER_1 = 5
SKILL_SCROUNGER_2 = 6
SKILL_SCROUNGER_3 = 7
SKILL_SCROUNGER_4 = 8
SKILL_SCRAP_HOUND_1 = 9
SKILL_SCRAP_HOUND_2 = 10
SKILL_SCRAP_HOUND_3 = 11
SKILL_SCRAP_HOUND_4 = 12
SKILL_HEALTHY_1 = 13
SKILL_HEALTHY_2 = 14
SKILL_HEALTHY_3 = 15
SKILL_HEALTHY_4 = 16
SKILL_RESPITE_1 = 17
SKILL_RESPITE_2 = 18
SKILL_RESPITE_3 = 19
SKILL_CALM_1 = 20
SKILL_CALM_2 = 21
SKILL_CALM_3 = 22
SKILL_MOONWALKER_1 = 23
SKILL_MOONWALKER_2 = 24
SKILL_WOOISM = 25
SKILL_CRACKSHOT = 26
SKILL_BACKUP_PLAN = 27
SKILL_HOARDER = 28
SKILL_STOCKPILE_1 = 29
SKILL_STOCKPILE_2 = 30
SKILL_SIGIL_SERVANT = 31
SKILL_PHASER_1 = 32
SKILL_PHASER_2 = 33
SKILL_BATTLE_CADER = 34
SKILL_BIG_OOMPH = 35
SKILL_HEAVY_LIFTER = 36
SKILL_QUICK_FIX = 37
SKILL_PICKY = 38
SKILL_HAND_OF_FATE = 39

local GOOD = "^"..COLORID_GREEN
local BAD = "^"..COLORID_RED

// * pieces
GM:AddSkill(SKILL_LIGHTNESS_1, "Lightness: 1", "+5% weight reduction", 1)
GM:AddSkill(SKILL_LIGHTNESS_2, "Lightness: 2", "+10% weight reduction", 2)
GM:AddSkill(SKILL_LIGHTNESS_3, "Lightness: 3", "+15% weight reduction", 3)
GM:AddSkill(SKILL_LIGHTNESS_4, "Lightness: 4", "+20% weight reduction", 4)

GM:AddSkill(SKILL_SCROUNGER_1, "Scrounger: 1", "+10% Resupply Amount", 1)
GM:AddSkill(SKILL_SCROUNGER_2, "Scrounger: 2", "+20% Resupply Amount", 2)
GM:AddSkill(SKILL_SCROUNGER_3, "Scrounger: 3", "+30% Resupply Amount", 3)
GM:AddSkill(SKILL_SCROUNGER_4, "Scrounger: 4", "+40% Resupply Amount", 4)

GM:AddSkill(SKILL_SCRAP_HOUND_1, "Scrap Hound: 1", "+10% Scrap Gain", 1)
GM:AddSkill(SKILL_SCRAP_HOUND_2, "Scrap Hound: 2", "+20% Scrap Gain", 2)
GM:AddSkill(SKILL_SCRAP_HOUND_3, "Scrap Hound: 3", "+30% Scrap Gain", 3)
GM:AddSkill(SKILL_SCRAP_HOUND_4, "Scrap Hound: 4", "+40% Scrap Gain", 4)

GM:AddSkill(SKILL_HEALTHY_1, "Healthy: 1", "+5 Max Health", 1)
GM:AddSkill(SKILL_HEALTHY_2, "Healthy: 2", "+10 Max Health", 2)
GM:AddSkill(SKILL_HEALTHY_3, "Healthy: 3", "+15 Max Health", 3)
GM:AddSkill(SKILL_HEALTHY_4, "Healthy: 4", "+20 Max Health", 4)

GM:AddSkill(SKILL_RESPITE_1, "Respite: 1", "At the end of the wave, set health to 30% HP, or heal 10% if that’s more", 2, "R")
GM:AddSkill(SKILL_RESPITE_2, "Respite: 2", "At the end of the wave, set health to 50% HP, or heal 25% if that’s more", 4, "R")
GM:AddSkill(SKILL_RESPITE_3, "Respite: 3", "At the end of the wave, set health to 70% HP, or heal 40% if that’s more", 6, "R")

GM:AddSkill(SKILL_CALM_1, "Calm: 1", "Effects of low HP are slightly weaker. Effects now begin at 30 HP, reaching 100% effectiveness at 0 HP",2,"C")
GM:AddSkill(SKILL_CALM_2, "Calm: 2", "Effects of low HP are drastically weaker. Effects now begin at 20 HP, reaching 66% effectiveness at 0 HP",4,"C")
GM:AddSkill(SKILL_CALM_3, "Calm: 3", "Effects of low HP are completely removed.",6,"C")

GM:AddSkill(SKILL_MOONWALKER_1, "Moonwalker: 1", "25% reduced backpedaling penalty.",3,"M")
GM:AddSkill(SKILL_MOONWALKER_2, "Moonwalker: 2", "50% reduced backpedaling penalty.",6,"M")

GM:AddSkill(SKILL_WOOISM, "Wooism", "Accuracy no longer affected by movement or aiming.",3,"W")
GM:AddSkill(SKILL_CRACKSHOT, "Crackshot", "50% Increased accuracy while crouched and motionless",3,"W")

GM:AddSkill(SKILL_BACKUP_PLAN, "Backup Plan", "If no sigils exist on the map, sigil shards can still be used to teleport to the furthest possible teammate. Start the game with a sigil shard.",2)
GM:AddSkill(SKILL_HOARDER, "Hoarder", "Better drops from junkpacks. Start the game with a junk pack.",2)

GM:AddSkill(SKILL_STOCKPILE_1, "Stockpile: 1", "Stockpile resupplies. Hold ALT & Right click a weapon slot to claim. Max 1 Stored",1,"S")
GM:AddSkill(SKILL_STOCKPILE_2, "Stockpile: 2", "Stockpile resupplies. Hold ALT & Right click a weapon slot to claim. Max 3 Stored",3,"S")

GM:AddSkill(SKILL_SIGIL_SERVANT, "Sigil Servant", "Triple healing from sigils. Start the game with a sigil seed.", 2)

GM:AddSkill(SKILL_PHASER_1, "Phaser: 1", "Barricade phasing speed no longer takes a second to charge up",2,"P")
GM:AddSkill(SKILL_PHASER_2, "Phaser: 2", "Barricade phasing gives you an initial burst of speed",4,"P")

GM:AddSkill(SKILL_BATTLE_CADER, "Battle Cader", "Kills recharge 33% of (base) oomph", 2)
GM:AddSkill(SKILL_BIG_OOMPH, "Big Oomph", "Doubled maximum repair oomph, halved recharge rate.", 1)
GM:AddSkill(SKILL_HEAVY_LIFTER, "Heavy Lifter", "Start the game with worker's gloves.", 1)
GM:AddSkill(SKILL_QUICK_FIX, "Quick Fix", "Repairs between rounds are always empowered", 1)

GM:AddSkill(SKILL_PICKY, "Picky", "See 2 more options at each upgrade screen (Except T1 Pistols)", 6, "U")
GM:AddSkill(SKILL_HAND_OF_FATE, "Hand of Fate", "Only see 1 option on each upgrade screen (Except T1 Pistols). +10 Max Health, +10% weight reduction, +20% resupply amount, +20% scrap gain", 1, "U")

//skill mods
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


GM:AddSkillModifier(SKILL_LIGHTNESS_1, SKILLMOD_WEIGHT_REDUCTION, 0.05)
GM:AddSkillModifier(SKILL_LIGHTNESS_2, SKILLMOD_WEIGHT_REDUCTION, 0.10)
GM:AddSkillModifier(SKILL_LIGHTNESS_3, SKILLMOD_WEIGHT_REDUCTION, 0.15)
GM:AddSkillModifier(SKILL_LIGHTNESS_4, SKILLMOD_WEIGHT_REDUCTION, 0.20)

GM:AddSkillModifier(SKILL_SCROUNGER_1, SKILLMOD_RESUPPLY_MUL, 0.1)
GM:AddSkillModifier(SKILL_SCROUNGER_2, SKILLMOD_RESUPPLY_MUL, 0.2)
GM:AddSkillModifier(SKILL_SCROUNGER_3, SKILLMOD_RESUPPLY_MUL, 0.3)
GM:AddSkillModifier(SKILL_SCROUNGER_4, SKILLMOD_RESUPPLY_MUL, 0.4)

GM:AddSkillModifier(SKILL_SCRAP_HOUND_1, SKILLMOD_SCRAP_MUL, 0.1)
GM:AddSkillModifier(SKILL_SCRAP_HOUND_2, SKILLMOD_SCRAP_MUL, 0.2)
GM:AddSkillModifier(SKILL_SCRAP_HOUND_3, SKILLMOD_SCRAP_MUL, 0.3)
GM:AddSkillModifier(SKILL_SCRAP_HOUND_4, SKILLMOD_SCRAP_MUL, 0.4)

GM:AddSkillModifier(SKILL_HEALTHY_1, SKILLMOD_HEALTH, 5)
GM:AddSkillModifier(SKILL_HEALTHY_2, SKILLMOD_HEALTH, 10)
GM:AddSkillModifier(SKILL_HEALTHY_3, SKILLMOD_HEALTH, 15)
GM:AddSkillModifier(SKILL_HEALTHY_4, SKILLMOD_HEALTH, 20)

GM:AddSkillModifier(SKILL_RESPITE_1, SKILLMOD_RESPITE_THRESHOLD,0.3)
GM:AddSkillModifier(SKILL_RESPITE_2, SKILLMOD_RESPITE_THRESHOLD,0.5)
GM:AddSkillModifier(SKILL_RESPITE_3, SKILLMOD_RESPITE_THRESHOLD,0.7)

GM:AddSkillModifier(SKILL_RESPITE_1, SKILLMOD_RESPITE_MIN,0.1)
GM:AddSkillModifier(SKILL_RESPITE_2, SKILLMOD_RESPITE_MIN,0.25)
GM:AddSkillModifier(SKILL_RESPITE_3, SKILLMOD_RESPITE_MIN,0.4)

GM:AddSkillModifier(SKILL_CALM_1, SKILLMOD_CALM_THRESHOLD, 10)
GM:AddSkillModifier(SKILL_CALM_2, SKILLMOD_CALM_THRESHOLD, 20)
GM:AddSkillModifier(SKILL_CALM_3, SKILLMOD_CALM_THRESHOLD, 40)

GM:AddSkillModifier(SKILL_MOONWALKER_1, SKILLMOD_BACKPEDAL_PENALTY_MUL, 0.25)
GM:AddSkillModifier(SKILL_MOONWALKER_2, SKILLMOD_BACKPEDAL_PENALTY_MUL, 0.5)

GM:AddSkillModifier(SKILL_STOCKPILE_1, SKILLMOD_STOCKPILE_COUNT, 1)
GM:AddSkillModifier(SKILL_STOCKPILE_2, SKILLMOD_STOCKPILE_COUNT, 3)

GM:AddSkillModifier(SKILL_PHASER_1, SKILLMOD_PHASE_SPEED_INITIAL, 36)
GM:AddSkillModifier(SKILL_PHASER_2, SKILLMOD_PHASE_SPEED_INITIAL, 250)

GM:AddSkillModifier(SKILL_BIG_OOMPH, SKILLMOD_OOMPH_MAX_MUL, 1)
GM:AddSkillModifier(SKILL_BIG_OOMPH, SKILLMOD_OOMPH_CHARGE_TIME_MUL, 3)

GM:AddSkillModifier(SKILL_PICKY, SKILLMOD_UPGRADE_COUNT, 2)
GM:AddSkillModifier(SKILL_HAND_OF_FATE, SKILLMOD_UPGRADE_COUNT, -2)
GM:AddSkillModifier(SKILL_HAND_OF_FATE, SKILLMOD_HEALTH, 10)
GM:AddSkillModifier(SKILL_HAND_OF_FATE, SKILLMOD_WEIGHT_REDUCTION, 0.10)
GM:AddSkillModifier(SKILL_HAND_OF_FATE, SKILLMOD_SCRAP_MUL, 0.20)
GM:AddSkillModifier(SKILL_HAND_OF_FATE, SKILLMOD_RESUPPLY_MUL, 0.20)

GM:AddSkillFunction(SKILL_WOOISM, function(pl, active)
	pl.Wooism = active
end)
GM:AddSkillFunction(SKILL_CRACKSHOT, function(pl, active)
	pl.Crackshot = active
end)
GM:AddSkillFunction(SKILL_BACKUP_PLAN, function(pl, active)
	pl.BackupPlan = active
end)
GM:AddSkillFunction(SKILL_HOARDER, function(pl, active)
	pl.Hoarder = active
end)

GM:AddSkillFunction(SKILL_SIGIL_SERVANT, function(pl, active)
	pl.SigilServant = active
end)
GM:AddSkillFunction(SKILL_BATTLE_CADER, function(pl, active)
	pl.BattleCader = active
end)
GM:AddSkillFunction(SKILL_HEAVY_LIFTER, function(pl, active)
	pl.HeavyLifter = active
end)
GM:AddSkillFunction(SKILL_QUICK_FIX, function(pl, active)
	pl.QuickFix = active
end)

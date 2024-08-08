-- These are the honorable mentions that come at the end of the round.

local function genericcallback(pl, magnitude) return pl:Name(), magnitude end
GM.HonorableMentions = {}
GM.HonorableMentions[HM_MOSTZOMBIESKILLED] = {Name = translate.Get("hm_mostzombieskilled"), String = translate.Get("hm_mostzombieskilled_desc"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_MOSTDAMAGETOUNDEAD] = {Name = translate.Get("hm_mostdamagetoundead"), String = translate.Get("hm_mostdamagetoundead_desc"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_MOSTHEADSHOTS] = {Name = translate.Get("hm_mostheadshotkills"), String = translate.Get("hm_mostheadshotkills_desc"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_PACIFIST] = {Name = translate.Get("hm_pacifist"), String = translate.Get("hm_pacifist_desc"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_MOSTHELPFUL] = {Name = translate.Get("hm_mosthelpful"), String = translate.Get("hm_mosthelpful_desc"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_LASTHUMAN] = {Name = translate.Get("hm_lasthuman"), String = translate.Get("hm_lasthuman_desc"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_OUTLANDER] = {Name = translate.Get("hm_outlander"), String = translate.Get("hm_outlander_desc"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_GOODDOCTOR] = {Name = translate.Get("hm_gooddoc"), String = translate.Get("hm_gooddoc_desc"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_HANDYMAN] = {Name = translate.Get("hm_handyman"), String = translate.Get("hm_handyman_desc"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_SCARECROW] = {Name = translate.Get("hm_scarecrow"), String = translate.Get("hm_scarecrow_desc"), Callback = genericcallback, Color = COLOR_WHITE}
GM.HonorableMentions[HM_MOSTBRAINSEATEN] = {Name = translate.Get("hm_mostbrainate"), String = translate.Get("hm_mostbrainate_desc"), Callback = genericcallback, Color = COLOR_LIMEGREEN}
GM.HonorableMentions[HM_MOSTDAMAGETOHUMANS] = {Name = translate.Get("hm_mostdamagetohumans"), String = translate.Get("hm_mostdamagetohumans_desc"), Callback = genericcallback, Color = COLOR_LIMEGREEN}
GM.HonorableMentions[HM_LASTBITE] = {Name = translate.Get("hm_lastbite"), String = translate.Get("hm_lastbite_desc"), Callback = genericcallback, Color = COLOR_LIMEGREEN}
GM.HonorableMentions[HM_USEFULTOOPPOSITE] = {Name = translate.Get("hm_mostusefulopposite"), String = translate.Get("hm_mostusefulopposite_desc"), Callback = genericcallback, Color = COLOR_RED}
GM.HonorableMentions[HM_STUPID] = {Name = translate.Get("hm_stupid"), String = translate.Get("hm_stupid_desc"), Callback = genericcallback, Color = COLOR_RED}
GM.HonorableMentions[HM_SALESMAN] = {Name = translate.Get("hm_salesman"), String = translate.Get("hm_salesman_desc"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_WAREHOUSE] = {Name = translate.Get("hm_warehouse"), String = translate.Get("hm_warehouse_desc"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_DEFENCEDMG] = {Name = translate.Get("hm_defender"), String = translate.Get("hm_defender_desc"), Callback = genericcallback, Color = COLOR_WHITE}
GM.HonorableMentions[HM_STRENGTHDMG] = {Name = translate.Get("hm_alchemist"), String = translate.Get("hm_alchemist_desc"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_BARRICADEDESTROYER] = {Name = translate.Get("hm_barricadedestroyer"), String = translate.Get("hm_barricadedestroyer_desc"), Callback = genericcallback, Color = COLOR_LIMEGREEN}
GM.HonorableMentions[HM_NESTDESTROYER] = {Name = translate.Get("hm_nestdestroyer"), String = translate.Get("hm_nestdestroyer_desc"), Callback = genericcallback, Color = COLOR_LIMEGREEN}
GM.HonorableMentions[HM_NESTMASTER] = {Name = translate.Get("hm_nestmaster"), String = translate.Get("hm_nestmaster_desc"), Callback = genericcallback, Color = COLOR_LIMEGREEN}

-- Don't let humans use these models because they look like undead models. Must be lower case.
GM.RestrictedModels = {
	"models/player/zombie_classic.mdl",
	"models/player/zombie_classic_hbfix.mdl",
	"models/player/zombine.mdl",
	"models/player/zombie_soldier.mdl",
	"models/player/zombie_fast.mdl",
	"models/player/corpse1.mdl",
	"models/player/charple.mdl",
	"models/player/skeleton.mdl",
	"models/player/combine_soldier_prisonguard.mdl",
	"models/player/soldier_stripped.mdl",
	"models/player/zelpa/stalker.mdl",
	"models/player/fatty/fatty.mdl",
	"models/player/zombie_lacerator2.mdl"
}

-- If a person has no player model then use one of these (auto-generated).
GM.RandomPlayerModels = {}
for name, mdl in pairs(player_manager.AllValidModels()) do
	if not table.HasValue(GM.RestrictedModels, string.lower(mdl)) then
		table.insert(GM.RandomPlayerModels, name)
	end
end

GM.DeployableInfo = {}
function GM:AddDeployableInfo(class, name, wepclass)
	local tab = {Class = class, Name = name or "?", WepClass = wepclass}

	self.DeployableInfo[#self.DeployableInfo + 1] = tab
	self.DeployableInfo[class] = tab

	return tab
end
GM:AddDeployableInfo("prop_arsenalcrate", 		"Arsenal Crate", 		"weapon_zs_arsenalcrate")
GM:AddDeployableInfo("prop_resupplybox", 		"Resupply Box", 		"weapon_zs_resupplybox")
GM:AddDeployableInfo("prop_remantler", 			"Weapon Remantler", 	"weapon_zs_remantler")
GM:AddDeployableInfo("prop_messagebeacon", 		"Message Beacon", 		"weapon_zs_messagebeacon")
GM:AddDeployableInfo("prop_camera", 			"Camera",	 			"weapon_zs_camera")
GM:AddDeployableInfo("prop_gunturret", 			"Gun Turret",	 		"weapon_zs_gunturret")
GM:AddDeployableInfo("prop_gunturret_assault", 	"Assault Turret",	 	"weapon_zs_gunturret_assault")
GM:AddDeployableInfo("prop_gunturret_buckshot",	"Blast Turret",	 		"weapon_zs_gunturret_buckshot")
GM:AddDeployableInfo("prop_gunturret_rocket",	"Rocket Turret",	 	"weapon_zs_gunturret_rocket")
GM:AddDeployableInfo("prop_repairfield",		"Repair Field Emitter",	"weapon_zs_repairfield")
GM:AddDeployableInfo("prop_zapper",				"Zapper",				"weapon_zs_zapper")
GM:AddDeployableInfo("prop_zapper_arc",			"Arc Zapper",			"weapon_zs_zapper_arc")
GM:AddDeployableInfo("prop_ffemitter",			"Force Field Emitter",	"weapon_zs_ffemitter")
GM:AddDeployableInfo("prop_manhack",			"Manhack",				"weapon_zs_manhack")
GM:AddDeployableInfo("prop_manhack_saw",		"Sawblade Manhack",		"weapon_zs_manhack_saw")
GM:AddDeployableInfo("prop_drone",				"Drone",				"weapon_zs_drone")
GM:AddDeployableInfo("prop_drone_pulse",		"Pulse Drone",			"weapon_zs_drone_pulse")
GM:AddDeployableInfo("prop_drone_hauler",		"Hauler Drone",			"weapon_zs_drone_hauler")
GM:AddDeployableInfo("prop_rollermine",			"Rollermine",			"weapon_zs_rollermine")


GM.MaxSigils = 3

GM.DefaultRedeem = CreateConVar("zs_redeem", "4", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "The amount of kills a zombie needs to do in order to redeem. Set to 0 to disable."):GetInt()
cvars.AddChangeCallback("zs_redeem", function(cvar, oldvalue, newvalue)
	GAMEMODE.DefaultRedeem = math.max(0, tonumber(newvalue) or 0)
end)

GM.WaveOneZombies = 0.11--math.Round(CreateConVar("zs_waveonezombies", "0.1", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "The percentage of players that will start as zombies when the game begins."):GetFloat(), 2)
-- cvars.AddChangeCallback("zs_waveonezombies", function(cvar, oldvalue, newvalue)
-- 	GAMEMODE.WaveOneZombies = math.ceil(100 * (tonumber(newvalue) or 1)) * 0.01
-- end)

-- Game feeling too easy? Just change these values!
GM.ZombieSpeedMultiplier = math.Round(CreateConVar("zs_zombiespeedmultiplier", "1", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "Zombie running speed will be scaled by this value."):GetFloat(), 2)
cvars.AddChangeCallback("zs_zombiespeedmultiplier", function(cvar, oldvalue, newvalue)
	GAMEMODE.ZombieSpeedMultiplier = math.ceil(100 * (tonumber(newvalue) or 1)) * 0.01
end)

-- This is a resistance, not for claw damage. 0.5 will make zombies take half damage, 0.25 makes them take 1/4, etc.
GM.ZombieDamageMultiplier = math.Round(CreateConVar("zs_zombiedamagemultiplier", "1", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "Scales the amount of damage that zombies take. Use higher values for easy zombies, lower for harder."):GetFloat(), 2)
cvars.AddChangeCallback("zs_zombiedamagemultiplier", function(cvar, oldvalue, newvalue)
	GAMEMODE.ZombieDamageMultiplier = math.ceil(100 * (tonumber(newvalue) or 1)) * 0.01
end)

GM.TimeLimit = CreateConVar("zs_timelimit", "15", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Time in minutes before the game will change maps. It will not change maps if a round is currently in progress but after the current round ends. -1 means never switch maps. 0 means always switch maps."):GetInt() * 60
cvars.AddChangeCallback("zs_timelimit", function(cvar, oldvalue, newvalue)
	GAMEMODE.TimeLimit = tonumber(newvalue) or 15
	if GAMEMODE.TimeLimit ~= -1 then
		GAMEMODE.TimeLimit = GAMEMODE.TimeLimit * 60
	end
end)

GM.RoundLimit = CreateConVar("zs_roundlimit", "3", FCVAR_ARCHIVE + FCVAR_NOTIFY, "How many times the game can be played on the same map. -1 means infinite or only use time limit. 0 means once."):GetInt()
cvars.AddChangeCallback("zs_roundlimit", function(cvar, oldvalue, newvalue)
	GAMEMODE.RoundLimit = tonumber(newvalue) or 3
end)

GM.NailHealCooldownMax = CreateConVar("zs_nailhealcooldownmax", "200",FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "how much damage you can repair before having to wait."):GetInt()
cvars.AddChangeCallback("zs_nailhealcooldownmax", function(cvar, oldvalue, newvalue)
	GAMEMODE.NailHealCooldownMax = tonumber(newvalue) or 200
end)

--this is for tropical resupply, not the box. use GM.ResupplyBoxCooldown
GM.ResupplyTime = CreateConVar("zs_resupply_time", "60", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "Time between passive resupplies (in seconds).")

GM.DoGlory = CreateConVar("zs_glory_enabled", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Enable healing from point thresholds. disabling this turns on wave end healing")

GM.GloryHealth = CreateConVar("zs_glory_health", "10", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Health you receive every zs_glory_score score (integer)")

GM.GloryScore = CreateConVar("zs_glory_score", "25", FCVAR_ARCHIVE + FCVAR_NOTIFY, "receive zs_glory_health HP back every multiple of this much score (integer)")

GM.MaxBrainCells = CreateConVar("zs_max_braincells", "500", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "max amount of brain cells a zombie can have")

GM.RedeemFever = CreateConVar("zs_redeem_fever", "1", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "during last human, reduces redeem cost to 2 brains")

GM.FreeplayMode = CreateConVar("zs_freeplay_mode", "1", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "Enabling freeplay mode allows players to use they haven't locked yet")

GM.ManualRedeeming = CreateConVar("zs_manual_redeeming", "1", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "Zombies with enough brains can hit F2 to redeem, force-redeeming on wave end")

-- Static values that don't need convars...

--braincells values
GM.CellsFromLifetimeMax = 30
GM.CellsFromLifetimeRate = 1 --cells earned per second
GM.CellsFromBarricadesMax = 20
GM.CellsFromBarricadeRate = .2 --cells earned per damage point to cade
GM.CellsFromDamageMax = 50
GM.CellsFromDamageRate = 1 --cells earned per damage to player
GM.CellsFromDamageBrain = 50 --cells earned for eating a brain
GM.CellsFromDeathMin = 25 --when killed by a tier 1 weapon
GM.CellsFromDeathMax = 75 --when killed by a tier 5+ weapon

--wave end heal
GM.WaveHealMin = 30
GM.WaveHealThreshold = 60 --heal up to this amount, OR for GM.WaveHealMin, whichever is greater

-- Initial length for wave 1.
GM.WaveOneLength = 220

-- Add this many seconds for each additional wave.
GM.TimeAddedPerWave = 15

-- New players are put on the zombie team if the current wave is this or higher. Do not put it lower than 1 or you'll break the game.
GM.NoNewHumansWave = 2

-- Humans can not commit suicide if the current wave is this or lower.
GM.NoSuicideWave = 1

-- How long 'wave 0' should last in seconds. This is the time you should give for new players to join and get ready.
GM.WaveZeroLength = 90

-- Time humans have between waves to do stuff without NEW zombies spawning. Any dead zombies will be in spectator (crow) view and any living ones will still be living.
GM.WaveIntermissionLength = 60

-- Time in seconds between end round and next map.
GM.EndGameTime = 45

--how many clips upgrade items start with
GM.SurvivalClips = 2

-- How long do humans have to wait before being able to get more ammo from a resupply box?
GM.ResupplyBoxCooldown = 60

-- Put your unoriginal, 5MB Rob Zombie and Metallica music here.
GM.LastHumanSound = Sound("zombiesurvival/lasthuman.ogg")

-- Sound played when humans all die.
GM.AllLoseSound = Sound("zombiesurvival/music_lose_tropical.ogg")

-- Sound played when humans survive.
GM.HumanWinSound = Sound("zombiesurvival/music_win.ogg")

-- Sound played to a person when they die as a human.
GM.DeathSound = Sound("zombiesurvival/human_death_stinger.ogg")

-- Fetch map profiles and node profiles from noxiousnet database?
GM.UseOnlineProfiles = true

-- This multiplier of points will save over to the next round. 1 is full saving. 0 is disabled.
-- Setting this to 0 will not delete saved points and saved points do not "decay" if this is less than 1.
GM.PointSaving = 0

-- Lock item purchases to waves. Tier 2 items can only be purchased on wave 2, tier 3 on wave 3, etc.
-- HIGHLY suggested that this is on if you enable point saving. Always false if objective map, zombie escape, classic mode, or wave number is changed by the map.
GM.LockItemTiers = false

-- Don't save more than this amount of points. 0 for infinite.
GM.PointSavingLimit = 0

-- For Classic Mode
GM.WaveIntermissionLengthClassic = 20
GM.WaveOneLengthClassic = 120
GM.TimeAddedPerWaveClassic = 10

-- Max amount of damage left to tick on these. Any more pending damage is ignored.
GM.MaxPoisonDamage = 25
GM.MaxBleedDamage = 80
GM.MaxRadiationDamage = 200

-- Multiplier on healing done to apply to these stats
GM.PoisonHealRate = 1
GM.BleedHealRate = 5
GM.RadiationHealRate = 5

-- Give humans this many points when the wave ends.
GM.EndWavePointsBonus = 5

-- Also give humans this many points when the wave ends, multiplied by (wave - 1)
GM.EndWavePointsBonusPerWave = 1

GM.MaxNests = 12
GM.MaxPlayerNests = 3

GM.ZombieAFKTimer = 60

// is formatted like this
// [table index is wave number] { each entry in table is time until a reinforcement
// the first entry is time after the wave begins,
// additional entries are time after the previous entry
GM.ReinforcementTimes = {
	[1] = nil,
	[2] = {115},
	[3] = {80, 80},
	[4] = {80, 80, 40, 25},
}

//fraction of points the player who last hits gets
GM.LastHitPointFraction = 0.25

//infliction rate that is required for doubled ammo generation
GM.DoubleResupplyInfliction = 0.90

GM.WeaponSlots = 8

//perk variables
GM.PerkSlots = 12
GM.DefaultPerks = {SKILL_CALM_3,SKILL_PHASER_1,SKILL_RESPITE_2,SKILL_SCROUNGER_2,SKILL_HOARDER}
GM.DefaultCalmThreshold = 40
GM.DefaultMinCalm = 10
GM.MaxCalmSlow = 0.4
GM.PhaseDecayDuration = 1
GM.DefaultStartPhaseSpeed = -36
GM.BattleCaderOomphRegen = 4

GM.OomphMaxDefault = 12
GM.OomphChargeTimeDefault = 20

//map variables
GM.VoteMapCount = 5 --amount of maps to pick from
GM.MaxNominations = 3
GM.MaxPlayerNominations = 1
GM.MapVoteTime = 20

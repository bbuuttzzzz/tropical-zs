GM.Items = {}
GM.Upgrades = {}
GM.ShopItems = {}


--DONT USE EXTERNALLY
function GM:AddItem(_signature, _swep, _item)

  --items with the same signature are the same item, so they
  --only get added once
  if self.Items[_signature] then return end

  local tab = {
    signature = _signature,
    swep = _swep,
    item = _item
  }

  /*
    this is weird
    you'd think because you're adding the same item twice
    that this would fuck up your list somehow
    when using # or ipairs, only NUMBERED entries with no
    skips are counted. so this is totally safe and necessary
    in order for ipairs to work
  */


  self.Items[#self.Items + 1] = tab
  self.Items[_signature] = tab
end

--for when you add a swep to the item list
function GM:AddItemSwep(_signature, _swep)
  self:AddItem(_signature, _swep)
end

--for when you add a non-swep to the item list
function GM:AddItemItem(_signature, _itemname)

  local item = self:IncludeItem(_itemname)

  self:AddItem(_signature, nil, item)
end

--DONT USE EXTERNALLY
function GM:AddUpgrade(_signature, _group)
  local tab = {
    signature = _signature,
    group = _group
  }

  self.Upgrades[#self.Upgrades + 1] = tab
  self.Upgrades[_signature] = tab
end

--for when you add an upgrade swep to the item list
function GM:AddUpgradeItemSwep(_signature, _swep, _group)
  GM:AddUpgrade(_signature, _group)

  GM:AddItemSwep(_signature, _swep)
end

--for when you add an upgrade non-swep to the item list
function GM:AddUpgradeItemItem(_signature, _itemname, _group)
  GM:AddUpgrade(_signature, _group)

  GM:AddItemItem(_signature, _itemname)
end


function GM:AddShopItem(_signature, _category, _price)
  local tab = {
    signature = _signature,
    category = _category,
    price = _price
  }

  self.ShopItems[#self.ShopItems + 1] = tab
  self.ShopItems[_signature] = tab
end

function GM:AddShopItemSwep(_signature, _swep, _category, _price)
  GM:AddShopItem(_signature, _category, _price)

  GM:AddItemSwep(_signature, _swep)
end

function GM:AddShopItemItem(_signature, _item, _category, _price)
  GM:AddShopItem(_signature, _category, _price)

  GM:AddItemItem(_signature, _item)
end

function GM:IncludeItem(itemname)
  if not file.Exists(self.FolderName .. "/gamemode/scripteditems/" .. itemname .. ".lua", "LUA") then
    ErrorNoHalt("item " .. itemname .. " not found\n")
    return nil
  end

  ITEM = {}

  AddCSLuaFile("scripteditems/" .. itemname .. ".lua")
  include("scripteditems/" .. itemname .. ".lua")

  ITEM.ClassName = itemname

  return ITEM
end

function GM:LazyLoadSwepStats( ITEM )
  if(ITEM.DidLoadStats) then return end

  if(not ITEM.SWEP) then
    ITEM.DidLoadStats = true
    return
  end

  local sweptable = weapons.GetStored(ITEM.SWEP)

  if not sweptable then
    ErrorNoHalt( ITEM.SWEP .. " is't a valid weapon" )
    ITEM.DidLoadStats = true
    return
  end

  self:AddSwepStatsToItem( ITEM, sweptable )

  ITEM.DidLoadStats = true
end

function GM:AddSwepStatsToItem( ITEM, sweptable )

  if sweptable.Primary then

    if not ITEM.Primary then
      ITEM.Primary = {}
    end

    --Primary.Damage
    if not ITEM.Primary.Damage then
      ITEM.Primary.Damage = sweptable.Primary.Damage
    end
    --Primary.NumShots
    if not ITEM.NumShots then
      ITEM.NumShots = sweptable.NumShots
    end
    --Primary.Ammo
    if not ITEM.Primary.Ammo then
      ITEM.Primary.Ammo = sweptable.Primary.Ammo
    end
    --Primary.ClipSize
    if not ITEM.Primary.ClipSize then
      ITEM.Primary.ClipSize = sweptable.Primary.ClipSize
    end
    --Primary.Delay
    if not ITEM.Primary.Delay then
      ITEM.Primary.Delay = sweptable.Primary.Delay
    end
  end

  --PrintName
  if not ITEM.PrintName then
    ITEM.PrintName = sweptable.PrintName
  end
  --Description
  if not ITEM.Description then
    ITEM.Description = sweptable.Description
  end
  --StatDPS
  if not ITEM.StatDPS then
    ITEM.StatDPS = (sweptable.StatDPS or 0)
  end
  --StatDPR
  if not ITEM.StatDPR then
    ITEM.StatDPR = (sweptable.StatDPR or 0)
  end
  --StatRange
  if not ITEM.StatRange then
    ITEM.StatRange = (sweptable.StatRange or 0)
  end
  --StatSpecial
  if not ITEM.StatSpecial then
    ITEM.StatSpecial = (sweptable.StatSpecial or 0)
  end
  --ConeMin
  if not ITEM.ConeMin then
    ITEM.ConeMin = sweptable.ConeMin
  end
  --ConeMax
  if not ITEM.ConeMax then
    ITEM.ConeMax = sweptable.ConeMax
  end
  --ReloadSpeed
  if not ITEM.ReloadSpeed then
    ITEM.ReloadSpeed = sweptable.ReloadSpeed
  end
  --WalkSpeed
  if not ITEM.WalkSpeed then
    ITEM.WalkSpeed = sweptable.WalkSpeed
  end
  --MeleeDamage
  if not ITEM.MeleeDamage then
    ITEM.MeleeDamage = sweptable.MeleeDamage
  end
  --MeleeRange
  if not ITEM.MeleeRange then
    ITEM.MeleeRange = sweptable.MeleeRange
  end
  --WorldModel
  if not ITEM.WorldModel then
    ITEM.WorldModel = sweptable.WorldModel
  end

  --Base
  if not ITEM.Base then
    ITEM.Base = sweptable.Base
  end

  --do the same for the base weapon if it exists
  if ( sweptable.Base and sweptable.Base ~= "weapon_base" ) then

    local basetable = weapons.GetStored(sweptable.Base)

    if not basetable then
      ErrorNoHalt( basetable .. " is't a valid weapon" )
      return
    end

    self:AddSwepStatsToItem( ITEM, basetable )
  end

end

--ammo

-- How much ammo is considered one 'clip' of ammo? For use with setting up weapon defaults. Works directly with zs_survivalclips
-- Rebalanced such that pistol ammo is more plentiful than smg (and the below) for tropical
-- Pistol > SMG > AR > Shotgun > sniper
-- means later guns give you less ammo, so you have to resort to your backup weapons more
GM.AmmoCache = {}
GM.AmmoCache["ar2"]							  = 30		-- Assault rifles.
GM.AmmoCache["pistol"]						= 30		-- Pistols.
GM.AmmoCache["smg1"]						  = 30		-- SMG's
GM.AmmoCache["357"]							  = 12 		-- Rifles, especially of the sniper variety.
GM.AmmoCache["xbowbolt"]					= 8			-- Crossbows
GM.AmmoCache["buckshot"]					= 8		-- Shotguns
GM.AmmoCache["grenade"]						= 1			-- Grenades.
GM.AmmoCache["grenade_impulse"]   = 1	    -- Impulse grenades
GM.AmmoCache["grenade_impact"]    = 1
GM.AmmoCache["battery"]						= 30		-- Used with the Medical Kit.
GM.AmmoCache["gaussenergy"]				= 2			-- Nails used with the Carpenter's Hammer.
GM.AmmoCache["pulse"]             = 30
GM.AmmoCache["scrap"]             = 15

GM.AmmoResupply = table.ToAssoc({"ar2", "pistol", "smg1", "357", "xbowbolt", "buckshot", "gaussenergy", "pulse"})

--item shop

SHOPCAT_50 = 1
SHOPCAT_100 = 2
SHOPCAT_150 = 3
SHOPCAT_250 = 4

GM.ShopCategories = {
  [SHOPCAT_50] = "50 Points",
  [SHOPCAT_100] = "100 Points",
  [SHOPCAT_150] = "150 Points",
  [SHOPCAT_250] = "250 Points"
}

--50 point category
GM:AddShopItemSwep("confettigun", "weapon_zs_confetti",SHOPCAT_50, 0)
--GM:AddShopItemItem("grenades","item_grenades",SHOPCAT_50, 50)
GM:AddShopItemItem("impacts","item_impacts",SHOPCAT_50, 50)
GM:AddShopItemItem("impulses","item_impulses",SHOPCAT_50, 50)
GM:AddShopItemSwep("hammer", "weapon_zs_hammer",SHOPCAT_50, 50)
GM:AddShopItemSwep("sigilshard", "weapon_zs_sigilshard", SHOPCAT_50, 50)

--100 point category
GM:AddShopItemItem("bigammobox","item_bigammobox",SHOPCAT_100, 100)
GM:AddShopItemSwep("aegis","weapon_zs_barricadekit",SHOPCAT_100, 100)
GM:AddShopItemSwep("medkit","weapon_zs_medicalkit",SHOPCAT_100, 100)
GM:AddShopItemSwep("sigilseed", "weapon_zs_sigilseed", SHOPCAT_100, 100)

--150 point category


--Arsenal Upgrades

--maintain ascending order by UPGRADEGROUP key or it will cause problems
UPGRADEGROUP_NONE = 0
UPGRADEGROUP_T1 = 1
UPGRADEGROUP_T1_MELEE = 2
UPGRADEGROUP_T2 = 3
UPGRADEGROUP_T3 = 4
UPGRADEGROUP_T4 = 5
UPGRADEGROUP_T5 = 6
UPGRADEGROUP_T6 = 7

GM.UpgradeGroups = {}
function GM:AddUpgradeGroup(_groupkey, _points, _name, _clips)
	local tab = {points = _points, name = _name, clips = _clips}

	self.UpgradeGroups[_groupkey] = tab

	return tab
end

--maintain ascending order by UPGRADEGROUP key or it will cause problems
GM:AddUpgradeGroup(UPGRADEGROUP_T1, -1, "Tier 1: Starter Pistols")
GM:AddUpgradeGroup(UPGRADEGROUP_T1_MELEE, -1, "Tier 1: Starter Melee")
GM:AddUpgradeGroup(UPGRADEGROUP_T2, 25, "Tier 2: Pistols")
GM:AddUpgradeGroup(UPGRADEGROUP_T3, 75, "Tier 3: SMGs")
GM:AddUpgradeGroup(UPGRADEGROUP_T4, 125, "Tier 4: Shotguns")
GM:AddUpgradeGroup(UPGRADEGROUP_T5, 200, "Tier 5: Assault Weapons")
GM:AddUpgradeGroup(UPGRADEGROUP_T6, 300, "Tier 6: Pulse Weapons")

GM.Upgrades = {}

-- populating upgrade table
--GM:AddUpgrade(_signature, _swep, _group, _dps, _dpr, _range, _special)

-- T1
GM:AddUpgradeItemSwep("peashooter","weapon_zs_peashooter", UPGRADEGROUP_T1)
GM:AddUpgradeItemSwep("owens","weapon_zs_owens", UPGRADEGROUP_T1)
GM:AddUpgradeItemSwep("battleaxe","weapon_zs_battleaxe", UPGRADEGROUP_T1)
GM:AddUpgradeItemSwep("bandito","weapon_zs_bandito", UPGRADEGROUP_T1)
GM:AddUpgradeItemSwep("stubber","weapon_zs_stubber", UPGRADEGROUP_T1)


-- T1 melee
GM:AddUpgradeItemSwep("knife", "weapon_zs_swissarmyknife", UPGRADEGROUP_T1_MELEE)
GM:AddUpgradeItemSwep("sledgehammer", "weapon_zs_sledgehammer", UPGRADEGROUP_T1_MELEE)
GM:AddUpgradeItemSwep("hammer", "weapon_zs_hammer", UPGRADEGROUP_T1_MELEE)
GM:AddUpgradeItemItem("stones", "item_stones", UPGRADEGROUP_T1_MELEE)
GM:AddUpgradeItemSwep("golfclub", "weapon_zs_golfclub", UPGRADEGROUP_T1_MELEE)
--golf club?
--Barricade Equipment?
--Crossbow?

-- T2
GM:AddUpgradeItemSwep("magnum", "weapon_zs_magnum", UPGRADEGROUP_T2)
GM:AddUpgradeItemSwep("deagle", "weapon_zs_deagle", UPGRADEGROUP_T2)
GM:AddUpgradeItemSwep("glock", "weapon_zs_glock3", UPGRADEGROUP_T2)
GM:AddUpgradeItemSwep("eraser", "weapon_zs_eraser", UPGRADEGROUP_T2)
GM:AddUpgradeItemSwep("sprayer", "weapon_zs_uzi",UPGRADEGROUP_T2)

-- T3
GM:AddUpgradeItemSwep("crackler", "weapon_zs_crackler",UPGRADEGROUP_T3)
GM:AddUpgradeItemSwep("reaper", "weapon_zs_reaper",UPGRADEGROUP_T3)
GM:AddUpgradeItemSwep("bulletstorm", "weapon_zs_bulletstorm",UPGRADEGROUP_T3)
GM:AddUpgradeItemSwep("hermes", "weapon_zs_hermes",UPGRADEGROUP_T3)
GM:AddUpgradeItemSwep("impaler", "weapon_zs_crossbow", UPGRADEGROUP_T3)

-- T4
GM:AddUpgradeItemSwep("airstrike", "weapon_zs_airstrike", UPGRADEGROUP_T4)
GM:AddUpgradeItemSwep("annabelle", "weapon_zs_annabelle", UPGRADEGROUP_T4)
GM:AddUpgradeItemSwep("sweeper", "weapon_zs_sweepershotgun", UPGRADEGROUP_T4)
GM:AddUpgradeItemSwep("ender", "weapon_zs_ender", UPGRADEGROUP_T4)
GM:AddUpgradeItemSwep("duckbill", "weapon_zs_duckbill", UPGRADEGROUP_T4)

-- T5
GM:AddUpgradeItemSwep("akbar", "weapon_zs_akbar", UPGRADEGROUP_T5)
GM:AddUpgradeItemSwep("stalker", "weapon_zs_m4", UPGRADEGROUP_T5)
GM:AddUpgradeItemSwep("inferno", "weapon_zs_inferno", UPGRADEGROUP_T5)
GM:AddUpgradeItemSwep("tinyslug","weapon_zs_slugrifle", UPGRADEGROUP_T5)
GM:AddUpgradeItemSwep("shredder", "weapon_zs_smg",UPGRADEGROUP_T5)

-- T6
GM:AddUpgradeItemSwep("boomstick", "weapon_zs_boomstick", UPGRADEGROUP_T6)
GM:AddUpgradeItemSwep("pulserifle", "weapon_zs_pulserifle", UPGRADEGROUP_T6)
GM:AddUpgradeItemSwep("succubus", "weapon_zs_succubus", UPGRADEGROUP_T6)
GM:AddUpgradeItemSwep("gravgun", "weapon_zs_gravgun", UPGRADEGROUP_T6)
GM:AddUpgradeItemSwep("executioner","weapon_zs_executioner",UPGRADEGROUP_T6)

-- items that aren't in the shop but still in the game
GM:AddItemSwep("axe", "weapon_zs_axe")
GM:AddItemSwep("wrench", "weapon_zs_wrench")
GM:AddItemSwep("junkpack", "weapon_zs_junkpack")
GM:AddItemSwep("gloves", "weapon_zs_workers_gloves")
GM:AddItemSwep("longsword", "weapon_zs_longsword")

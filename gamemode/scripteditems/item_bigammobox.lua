ITEM.PrintName = "Big Ammo Box"
ITEM.Signature = "bigammobox"
ITEM.Description = "On Purchase, grants 2 boxes of each common ammo type"

ITEM.TranslationName = "bigammobox_name"
ITEM.TranslationDesc = "bigammobox_desc"

ITEM.WorldModel = "models/Items/item_item_crate.mdl"
ITEM.Stats = [[CONTAINS:
AR
Pistol
SMG
SR
Shotgun
Nails
Pulse
]]
ITEM.GiveFunction = function(pl)
  pl:GiveAmmo(GAMEMODE.AmmoCache["ar2"] * 2,"ar2", true)
  pl:GiveAmmo(GAMEMODE.AmmoCache["pistol"] * 2,"pistol", true)
  pl:GiveAmmo(GAMEMODE.AmmoCache["smg1"] * 2,"smg1", true)
  pl:GiveAmmo(GAMEMODE.AmmoCache["357"] * 2,"357", true)
  pl:GiveAmmo(GAMEMODE.AmmoCache["buckshot"] * 2,"buckshot", true)
  pl:GiveAmmo(GAMEMODE.AmmoCache["gaussenergy"] * 2,"gaussenergy", true)
  pl:GiveAmmo(GAMEMODE.AmmoCache["pulse"] * 2,"pulse", true)
end

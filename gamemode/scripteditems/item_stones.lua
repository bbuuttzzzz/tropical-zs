ITEM.PrintName = "Bag of 10 Stones"
ITEM.Signature = "stones"
ITEM.Description = "Gives you a bag of 10 stones"

ITEM.TranslationName = "stones_name"
ITEM.TranslationDesc = "stones_desc"
ITEM.Stats = [[
DAM: 100
SPEED: Quite Fast
]]

ITEM.SWEP = "weapon_zs_stone"
ITEM.GiveFunction = function(pl)
  pl:Give("weapon_zs_stone")
  pl:GiveAmmo(9,"stone", true)
end

ITEM.PrintName = "Grenades x5"
ITEM.Signature = "grenades"
ITEM.Description = "A set of 5 grenades. Right click to cook!"

ITEM.TranslationName = "grenades_name"
ITEM.TranslationDesc = "grenades_desc"

ITEM.SWEP = "weapon_zs_grenade"
ITEM.Stats = [[DAM MIN: 150
DAM MAX: 300
FUSE: 5s
RADIUS: 256u
SPEED: Quite Fast
]]

ITEM.GiveFunction = function(pl)
  local ammo = "grenade"
  local amt = 5

  if not pl:HasWeapon("weapon_zs_grenade") then
    pl:Give("weapon_zs_grenade")
    amt = amt - 1
  end
  pl:GiveAmmo(amt,ammo, true)
end

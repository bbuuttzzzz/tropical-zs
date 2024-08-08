ITEM.PrintName = "Impulse Grenade"
ITEM.Signature = "impulses"
ITEM.Description = "Does no damage, but sends you flying! Explodes on impact."

ITEM.TranslationName = "impulses_name"
ITEM.TranslationDesc = "impulses_desc"

--ITEM.WorldModel = "models/weapons/w_eq_flashbang_thrown.mdl"
ITEM.SWEP = "weapon_zs_impulsegrenade"
ITEM.Stats = [[
DAM: none
RADIUS: 256u
SPEED: Quite Fast
]]

ITEM.GiveFunction = function(pl)
  local ammo = "grenade_impulse"
  local amt = 1

  if not pl:HasWeapon("weapon_zs_impulsegrenade") then
    pl:Give("weapon_zs_impulsegrenade")
    amt = amt - 1
  end
  pl:GiveAmmo(amt,ammo, true)
end

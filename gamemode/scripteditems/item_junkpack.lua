ITEM.PrintName = "Junk Pack"
ITEM.Signature = "impulses"
ITEM.Description = "5 pieces of junk. Good for a makeshift barricade"

--ITEM.WorldModel = "models/weapons/w_eq_flashbang_thrown.mdl"
ITEM.SWEP = "weapon_zs_junkpack"
ITEM.Stats = [[
DAM: none
SPEED: Quite Fast
]]

ITEM.GiveFunction = function(pl)
  local ammo = "SniperRound"
  local amt = 5

  if not pl:HasWeapon("weapon_zs_junkpack") then
    pl:Give("weapon_zs_junkpack")
  else
    pl:GiveAmmo(amt,ammo, true)
  end
end

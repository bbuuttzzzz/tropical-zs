ITEM.PrintName = "Junk Pack"
ITEM.Signature = "impulses"
ITEM.Description = "5 pieces of junk. Good for a makeshift barricade"

ITEM.TranslationName = "junkpack_name"
ITEM.TranslationDesc = "junkpack_desc"

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
    pl:GiveAmmo(amt,2, true)

  else
    pl:GiveAmmo(amt,ammo, true)
    net.Start("zs_update_weaponhud")
    net.Send(pl)
  end
end

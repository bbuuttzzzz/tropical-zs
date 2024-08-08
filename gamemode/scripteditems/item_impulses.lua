ITEM.PrintName = "Impulse Grenades x3"
ITEM.Signature = "impulses"
ITEM.Description = "A set of 3 Impulse grenades. Do no damage, but send you flying! Explode on impact."

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
  local amt = 3

  if not pl:HasWeapon("weapon_zs_impulsegrenade") then
    pl:Give("weapon_zs_impulsegrenade")
    amt = amt - 1
  end
  pl:GiveAmmo(amt,ammo, true)
  net.Start("zs_update_weaponhud")
  net.Send(pl)
end

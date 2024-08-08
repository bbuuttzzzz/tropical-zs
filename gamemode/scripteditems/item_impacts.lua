ITEM.PrintName = "Impact Grenades x3"
ITEM.Signature = "impacts"
ITEM.Description = "A set of 3 Impact grenades. Explodes on impact in a small area, dealing bonus damage on direct hit."

ITEM.TranslationName = "impacts_name"
ITEM.TranslationDesc = "impacts_desc"

--ITEM.WorldModel = "models/weapons/w_eq_flashbang_thrown.mdl"
ITEM.SWEP = "weapon_zs_impactgrenade"
ITEM.Stats = [[
HIT DAM: 250
AOE DAM: 200
RADIUS: 64u
SPEED: Quite Fast
]]

ITEM.GiveFunction = function(pl)
  local ammo = "grenade_impact"
  local amt = 3

  if not pl:HasWeapon("weapon_zs_impactgrenade") then
    pl:Give("weapon_zs_impactgrenade")
    amt = amt - 1
  end
  pl:GiveAmmo(amt,ammo, true)
  net.Start("zs_update_weaponhud")
  net.Send(pl)
end

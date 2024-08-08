ITEM.PrintName = "Medkit"
ITEM.Signature = "medkit"
ITEM.Description = "Heal yourself and others for up to 60 HP. Cures status ailments"

ITEM.TranslationName = "item_medkit_name"
ITEM.TranslationDesc = "item_medkit_desc"

--ITEM.WorldModel = "models/weapons/w_eq_flashbang_thrown.mdl"
ITEM.SWEP = "weapon_zs_medicalkit"

ITEM.GiveFunction = function(pl)
  if not pl:HasWeapon("weapon_zs_medicalkit") then
    pl:Give("weapon_zs_medicalkit")
  else
    pl:GiveAmmo(60,"Battery", true)
  end
end

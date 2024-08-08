ITEM.PrintName = "Medkit"
ITEM.Signature = "medkit"
ITEM.Description = "Heal yourself and others for up to 60 HP. Cures status ailments"

SWEP.TranslationName = "item_medkit_name"
SWEP.TranslationDesc = "item_medkit_desc"

--ITEM.WorldModel = "models/weapons/w_eq_flashbang_thrown.mdl"
ITEM.SWEP = "weapon_zs_medicalkit"

ITEM.GiveFunction = function(pl)
  if not pl:HasWeapon(ITEM.SWEP) then
    pl:Give(ITEM.SWEP)
  end

  pl:GiveAmmo(60,"Battery", true)
end
ITEM.PrintName = "Full Heal"
ITEM.Signature = "fullheal"
ITEM.Description = "Instantly max out your health!"
ITEM.WorldModel = "models/props_combine/health_charger001.mdl"
ITEM.GiveFunction = function(pl)
  pl:HealPlayer(pl,pl:GetMaxHealth()+, 0, true)
end

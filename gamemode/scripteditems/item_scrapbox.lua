ITEM.PrintName = "Scrap Box"
ITEM.Signature = "scrapbox"
ITEM.Description = "Grants 150 Scrap"

ITEM.TranslationName = "scrapbox_name"
ITEM.TranslationDesc = "scrapbox_desc"
ITEM.Stats = [[CONTAINS:
150 Scrap
]]
ITEM.WorldModel = "models/Items/item_item_crate.mdl"

ITEM.GiveFunction = function(pl)
  pl:AddScrap(150)
  net.Start("zs_ammopickup")
    net.WriteUInt(150, 16)
    net.WriteString("scrap")
    net.Send(pl)
end

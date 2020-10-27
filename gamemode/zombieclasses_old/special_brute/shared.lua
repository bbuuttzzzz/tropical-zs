CLASS.Base = "poison_zombie"

CLASS.Name = "Brute"
CLASS.TranslationName = "class_brute"
CLASS.Description = "description_brute"
CLASS.Help = "controls_brute"

CLASS.Wave = 3 / 6
CLASS.Special = true
CLASS.SpecialCost = 500

CLASS.Health = 1200
CLASS.Speed = 140
CLASS.SWEP = "weapon_zs_brute"

CLASS.Points = CLASS.Health / GM.SpecialZombiePointRatio

local math_random = math.random

function CLASS:PlayPainSound(pl)
	pl:EmitSound("npc/zombie_poison/pz_pain"..math_random(3)..".wav", 74, math.random(88, 95))
	pl.NextPainSound = CurTime() + 0.5

	return true
end

ENT.Type = "anim"

ENT.BleedDamage = 5
ENT.ZombieHeal = 25

function ENT:ShouldNotCollide(ent)
	return false
end

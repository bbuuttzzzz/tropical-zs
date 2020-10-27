ENT.Type = "anim"

ENT.Damage = 2
ENT.CrippleDamage = 10

function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_UNDEAD
end

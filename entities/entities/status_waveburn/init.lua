INC_SERVER()

function ENT:Think()
	local owner = self:GetOwner()

	if not owner:Alive() then
		self:Remove()
		return
	end

	local dmg = self:GetDamage()

	if dmg == -1 then
		dmg = owner:GetMaxHealth() * self.InitialDamageFrac
		self:SetDamage(dmg)
		self.DamageRamping = dmg * self.DamageRampingFrac
	end

	if dmg > owner:Health() then
		--this is to force you to blow up when you die
		dmg = dmg + 100
	end

	local dmginfo = DamageInfo()
		dmginfo:SetAttacker(self.Damager and self.Damager:IsValid() and self.Damager:IsPlayer() and self.Damager:Team() ~= owner:Team() and self.Damager or owner)
		dmginfo:SetInflictor(self)
		dmginfo:SetDamageType(DMG_BURN + DMG_PREVENT_PHYSICS_FORCE + DMG_DIRECT)
		dmginfo:SetDamage(dmg)
		dmginfo:SetDamageForce(Vector(0,0,1))
	owner:TakeDamageInfo(dmginfo)

	--owner:TakeSpecialDamage(dmg, DMG_BURN + DMG_PREVENT_PHYSICS_FORCE + DMG_DIRECT, self.Damager and self.Damager:IsValid() and self.Damager:IsPlayer() and self.Damager:Team() ~= owner:Team() and self.Damager or owner, self)

	--increase damage
	self:SetDamage(dmg + self.DamageRamping)

	--using this means it's going to be a little big past ENT.DamageDelay in between
	--two thinks, which matters if we're trying to sync clientside burn effects
	--but as long as the animation doesnt change this should work fine
	self:NextThink(CurTime() + self.DamageDelay)
	return true
end

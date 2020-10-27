INC_SERVER()

function SWEP:ShootBullets(isSecondary, numshots, cone)
	local owner = self:GetOwner()
	self:SendWeaponAnim(ACT_VM_THROW)
	owner:DoAttackEvent()

	local ent = ents.Create(self.ThrownProjectile)
	if ent:IsValid() then
		local pos = owner:GetShootPos()
		pos.z = pos.z - (isSecondary and 16 or 0)
		ent:SetPos(pos)
		ent:SetOwner(owner)
		ent:Spawn()

		ent.GrenadeDamage = self.Damage
		ent.GrenadeRadius = self.GrenadeRadius

    if self:IsCooking() then
      local val = math.max(self.MinFuse, self.MaxFuse - (CurTime() - self:GetCookStart()))
      --subtract cook time from the fuse time, but dont go below MinFuse.
			--ent.LifeTime = val
			ent:SetLifeTime(val)

      self:SetCookStart(0)
    end

		ent.Team = owner:Team()

		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:AddAngleVelocity(VectorRand() * self.ThrowAngVel)
			phys:SetVelocityInstantaneous(self:GetOwner():GetAimVector() * self.ThrowVel * (isSecondary and 0.4 or 1) * (owner.ObjectThrowStrengthMul or 1))
		end

		ent:SetPhysicsAttacker(owner)
	end
end

AddCSLuaFile()

SWEP.PrintName = "Impact Grenade"
SWEP.Description = "Explodes on impact, dealing bonus damage on direct hit."

SWEP.TranslationName = "wep_impactgrenades"
SWEP.TranslationDesc = "wep_d_impactgrenades"

SWEP.WeightClass = WEIGHT_FEATHER

SWEP.Base = "weapon_zs_basethrown"

SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.WorldModel = "models/weapons/w_grenade.mdl"

SWEP.Primary.Ammo = "grenade_impact"
SWEP.Primary.Delay = 1

SWEP.ThrownProjectile = "projectile_impactgrenade"

SWEP.GrenadeKnockback = 0
SWEP.GrenadeRadius = 192
SWEP.DirectDamage = 250
SWEP.GrenadeDamage = 400
SWEP.OwnerDamage = 50
SWEP.DeploySpeedMultiplier = 3


if SERVER then
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

			ent.GrenadeKnockback = self.GrenadeKnockback
			ent.GrenadeRadius = self.GrenadeRadius
			ent.DirectDamage = self.DirectDamage
			ent.GrenadeDamage = self.GrenadeDamage
			ent.OwnerDamage = self.OwnerDamage


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

end

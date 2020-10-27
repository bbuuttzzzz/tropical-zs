AddCSLuaFile()

SWEP.PrintName = "Impulse Grenade"
SWEP.Description = "Explodes on impact to launch nearby players. Does no Damage"

SWEP.TranslationName = "wep_impulsegrenades"
SWEP.TranslationDesc = "wep_d_impulsegrenades"

SWEP.WeightClass = WEIGHT_FEATHER

SWEP.Base = "weapon_zs_basethrown"

SWEP.ViewModel = "models/weapons/cstrike/c_eq_flashbang.mdl"
SWEP.WorldModel = "models/weapons/w_eq_flashbang.mdl"

SWEP.Primary.Ammo = "grenade_impulse"
SWEP.Primary.Delay = 1

SWEP.ThrownProjectile = "projectile_impulsegrenade"

SWEP.GrenadeKnockback = 500
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

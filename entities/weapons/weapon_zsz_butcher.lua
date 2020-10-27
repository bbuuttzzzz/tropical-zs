SWEP.Base = "weapon_zs_butcherknife"

SWEP.Attack1 = true

SWEP.ZombieOnly = true
SWEP.MeleeDamage = 5
SWEP.PropMeleeDamage = 18
SWEP.BleedDamage = 15
SWEP.OriginalMeleeDamage = SWEP.MeleeDamage
SWEP.Primary.Delay = 0.45
SWEP.MeleeKnockBack = 100

function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if not hitent:IsPlayer() then
		self.MeleeDamage = self.PropMeleeDamage
	elseif SERVER then
    	hitent:AddBleedDamage(self.BleedDamage,self:GetOwner())
  end
end

function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	self.MeleeDamage = self.OriginalMeleeDamage
end

function SWEP:SetNextAttack()
	local owner = self:GetOwner()
	local armdelay = owner:GetMeleeSpeedMul()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay * armdelay)
end

function SWEP:DescribeAttack(Attack)
	if not Attack then return end

	return table.concat({
		translate.Format("swings_cleaver_for_x",self.MeleeDamage), "\n",
		translate.Format("applies_x_bleed",self.BleedDamage), "\n",
		translate.Format("deals_x_to_props",self.PropMeleeDamage), "\n"
	})
end

function SWEP:DescribeAlt()
	--doesn't have an alt ability
	return nil
end

function SWEP:IsAlting()
	return false
end

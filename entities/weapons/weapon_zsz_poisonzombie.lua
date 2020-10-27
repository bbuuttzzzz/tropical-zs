SWEP.Base = "weapon_zsz_basezombie"
DEFINE_BASECLASS("weapon_zsz_basezombie")

SWEP.PrintName = "Poison Zombie"

SWEP.ViewModel = Model("models/weapons/v_pza.mdl")

SWEP.Alt = {
  SpeedMul = 0.25,
  Regen = 15
}
SWEP.Attack1 = {
  WindupTime = 0.9,
  WinddownTime = 0.7,
  AnimationDelay = 0.35,
  Type = ZATTACK_MELEE,
  MeleeDamage = 40,
  MeleeForceScale = 1,
  MeleeDamageType = DMG_SLASH,
  MeleeDoPreHit = true,
  MeleeReach = 48,
  MeleeSize = 4.5,
  AttackAnim = ACT_VM_HITCENTER,
  PlayAttackSound = function(swep)
    swep:EmitSound("NPC_PoisonZombie.ThrowWarn")
  end
}

SWEP.Attack2 = {
	WindupTime = 1,
	WinddownTime = 1,
	AnimationDelay = 0.4,
	Type = ZATTACK_RANGED,
	RangedProjectile = "projectile_poisonflesh",
	RangedNumShots = BULLETPATTERN_TALL,
	RangedCone = 20,
	RangedProjectileSpeed = 450,
  LeapMinVertical = 0.2,
  LeapSpeed = 320,
  SelfDamage = 60,
	PlayAttackSound = function(swep)
		swep:EmitSound("NPC_PoisonZombie.Throw")
	end
	--PlayFireSound = function(swep) end
}

function SWEP:OnResolveAttack(Attack)
  if Attack == self.Attack2 then
    local owner = self:GetOwner()

    local dir = owner:GetAimVector() * -1

    if Attack.LeapMinVertical then
      dir.z = math.max(Attack.LeapMinVertical, dir.z)
    end
    if dir:LengthSqr() > 1 then
      dir:Normalize()
    end

    owner:SetGroundEntity(NULL)
    owner:SetVelocity(dir * Attack.LeapSpeed)

    local dmginfo = DamageInfo()
      dmginfo:SetAttacker(owner)
      dmginfo:SetDamageType(DMG_GENERIC)
      dmginfo:SetDamage(Attack.SelfDamage)
      dmginfo:SetDamageForce(Vector(1,0,0))
    owner:TakeDamageInfo(dmginfo)
  end
end

if CLIENT then
  SWEP.ViewModelFOV = 47
end

SWEP.Base = "weapon_zsz_basezombie"

SWEP.PrintName = "Poison Headcrab"

SWEP.ViewModel = "models/weapons/v_knife_t.mdl"
SWEP.WorldModel = ""

local STATE_NORMAL = 1
local STATE_LEAP = 2
local STATE_SPIT_WINDUP = 3

SWEP.Alt = {
  SpeedMul = 0.25,
  Regen = 15
}
SWEP.Attack1 = {
  SpeedMul = 0,
  WindupTime = 0.9,
  WinddownTime = 0.75,
  Type = ZATTACK_LEAP,
  LeapDamage = 5,
  LeapBleedDamage = 40,
  LeapSpeed = 470,
  LeapSize = 4,
  LeapDamageType = DMG_SLASH,
  LeapCanInterrupt = false,
  LeapCanAirControl = false,
  PlayAttackSound = function(swep)
		swep:EmitSound("NPC_BlackHeadcrab.Telegraph")
  end,
  PlayHitSound = function(swep)
    swep:EmitSound("NPC_BlackHeadcrab.Bite")
  end,
	GetDescriptorText = function(self)
		return table.concat({
			translate.Format("applies_x_bleed",self.LeapBleedDamage), "\n"
		})
	end
}
SWEP.Attack2 = {
  SpeedMul = 0.3,
  WindupTime = 0.8,
  WinddownTime = 0.8,
  Type = ZATTACK_RANGED,
  RangedProjectile = "projectile_poisonspit",
  RangedNumShots = 1,
  RangedCone = 0,
  RangedProjectileSpeed = 900,
  PlayAttackSound = function(swep)
		swep:EmitSound("npc/headcrab_poison/ph_scream"..math.random(3)..".wav")
  end,
  PlayFireSound = function(swep)
    swep:EmitSound("weapons/crossbow/bolt_fly4.wav", 74, 150)
  end,
	GetDescriptorText = function(self)
		return table.concat({
			translate.Format("applies_x_poison",15), "\n",
			translate.Format("headshot_blinds_slows_x",20), "\n"
		})
	end
}

function SWEP:Initialize()
	self:HideViewAndWorldModel()
end
function SWEP:OnMeleeHitPlayer(pl, tr, dmginfo)
  if SERVER and self.ActiveAttack == self.Attack1 then
    pl:AddBleedDamage(self.ActiveAttack.LeapBleedDamage, self:GetOwner())
  end
end

function SWEP:OnStartAttack(Attack)
  if Attack == self.Attack1 then
    --this is the leap
    self:SetAttackState(STATE_LEAP)
  elseif Attack == self.Attack2 then
    --this is the spit
    self:SetAttackState(STATE_SPIT_WINDUP)
  end
end
function SWEP:OnResolveAttack(Attack)
  if Attack == self.Attack2 then
    --the spit resolved
    self:SetAttackState(STATE_NORMAL)
  end
end
function SWEP:SetIsLeaping(isLeaping)
	self:SetDTBool(1,isLeaping)

  if not isLeaping then
    self:SetAttackState(STATE_NORMAL)
  end
end
function SWEP:CheckLeapCollision(Attack)
	local owner = self:GetOwner()

	local traces = owner:CompensatedZombieMeleeTrace(8,12,shootpos, owner:GetForward())
	local damage = (Attack.LeapDamage or 0) * CalcMeleeDamageScale(GetTracesNumPlayers(traces))
	if self:IsAlting() and self.Alt.DamageDealtMul then
		damage = damage * self.Alt.DamageDealtMul
	end

	local hit = false
	for _, trace in ipairs(traces) do
		if not trace.Hit then continue end

		if not trace.HitWorld then
			local ent = trace.Entity
			if ent and ent:IsValid() then
				hit = true
				self:MeleeHit(ent, trace, damage, Attack.LeapForceScale or 1, Attack.LeapDamageType or DMG_SLASH )
			end
		end
	end

	if hit then
		self:SetIsLeaping(false)
		if not self.ActiveLeap.LeapCanInterrupt then
			self:SetNextIdle(CurTime() + (self.ActiveLeap.WinddownTime or 0))
		end

		if IsFirstTimePredicted() then
			if Attack.PlayHitSound then
				Attack.PlayHitSound(self)
			else
				self:PlayDefaultHitSound()
			end
		end
	end
end

/*
  im using a redundant state machine here instead of interacting with the base
  zombie one because this gets called every frame for animations so it needs to
  be faster. does this need to be networked??? maybe not but it's cheap so I'll
  leave it for the minute
*/
function SWEP:SetAttackState(state)
  self:SetDTInt(4,state)
end
function SWEP:GetAttackState()
  self:GetDTInt(4)
end
function SWEP:ShouldPlaySpitAnimation()
  return self:GetAttackState() == STATE_SPIT_WINDUP
end
function SWEP:ShouldPlayLeapAnimation()
  return self:GetAttackState() == STATE_LEAP
end

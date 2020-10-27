AddCSLuaFile()

SWEP.PrintName = "Golf Club"
SWEP.Description = "Sends Props Flying! aim at what you want to hit before right clicking to line up the perfect shot"

SWEP.TranslationName = "wep_golfclub"
SWEP.TranslationDesc = "wep_d_golfclub"

SWEP.Tier = 1

SWEP.StatDPS = 1
SWEP.StatDPR = 5
SWEP.StatRange = 2
SWEP.StatSpecial =  5

if CLIENT then
	SWEP.ViewModelFOV = 55
	SWEP.ViewModelFlip = false


	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = true
	SWEP.VElements = {
	["pipe"] = { type = "Model", model = "models/props_canal/mattpipe.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.596, 1.131, 0), angle = Angle(0, -45.584, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

end

SWEP.Base = "weapon_zs_basemelee"

SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/props_canal/mattpipe.mdl"
SWEP.UseHands = true

SWEP.HoldType = "melee2"

SWEP.MeleeDamage = 30 --modify PropForceScale to compensate
SWEP.MeleeRange = 75
SWEP.MeleeSize = 1.5
SWEP.MeleeKnockBack = 200 --this is PLAYER knockback
SWEP.PropForceScale = 2 --multiplier to how hard you hit props... scaled by damage

SWEP.WeightClass = WEIGHT_LIGHT

SWEP.SwingTime = 0.8
SWEP.SwingRotation = Angle(0, -20, -40)
SWEP.SwingOffset = Vector(10, 0, 0)
SWEP.SwingHoldType = "melee"

SWEP.HitDecal = "Manhackcut"

SWEP.AllowQualityWeapons = true

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_RANGE, 3)

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(65, 70))
end

function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/golf club/golf_hit-0"..math.random(4)..".ogg")
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav")
end

function SWEP:StartSwinging()
	if not IsFirstTimePredicted() then return end

	local owner = self:GetOwner()

	--save a prehit object
	local trace = owner:CompensatedMeleeTrace(self.MeleeRange, self.MeleeSize)
	if trace.HitNonWorld and not trace.Entity:IsPlayer() then
		trace.IsPreHit = true
		self.PreHit = trace
	else
		self.PreHit = nil
	end

	--call baseclass StartSwing
	return self.BaseClass.StartSwinging(self)
end

function SWEP:MeleeSwing()
	if not IsFirstTimePredicted() then return end

	local owner = self:GetOwner()

	self:DoMeleeAttackAnim()

	local tr = owner:CompensatedMeleeTrace(self.MeleeRange * (owner.MeleeRangeMul or 1), self.MeleeSize)

	--this is the special part
	local preHit = self.PreHit

	if preHit and not tr.HitNonWorld then
		local eyepos = owner:EyePos()
		if preHit.Entity:IsValid() and preHit.Entity:NearestPoint(eyepos):DistToSqr(eyepos) <= self.MeleeRange * self.MeleeRange then
			tr = preHit
		end
	end

	if not (tr.Hit and tr.Entity and tr.Entity:IsValid() )then
		if self.MissAnim then
			self:SendWeaponAnim(self.MissAnim)
		end
		self.IdleAnimation = CurTime() + self:SequenceDuration()
		self:PlaySwingSound()

		if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
			self:SetPowerCombo(0)
		end

		if self.PostOnMeleeMiss then self:PostOnMeleeMiss(tr) end

		return
	end

	local damagemultiplier = owner:Team() == TEAM_HUMAN and owner.MeleeDamageMultiplier or 1 --(owner.BuffMuscular and owner:Team()==TEAM_HUMAN) and 1.2 or 1
	if owner:IsSkillActive(SKILL_LASTSTAND) then
		if owner:Health() <= owner:GetMaxHealth() * 0.25 then
			damagemultiplier = damagemultiplier * 2
		else
			damagemultiplier = damagemultiplier * 0.85
		end
	end

	local hitent = tr.Entity
	local hitflesh = tr.MatType == MAT_FLESH or tr.MatType == MAT_BLOODYFLESH or tr.MatType == MAT_ANTLION or tr.MatType == MAT_ALIENFLESH

	if self.HitAnim then
		self:SendWeaponAnim(self.HitAnim)
	end
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	if hitflesh then
		util.Decal(self.BloodDecal, tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		self:PlayHitFleshSound()

		if SERVER then
			self:ServerHitFleshEffects(hitent, tr, damagemultiplier)
		end

		if not self.NoHitSoundFlesh then
			self:PlayHitSound()
		end
	else
		--util.Decal(self.HitDecal, tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		self:PlayHitSound()
	end

	if self.OnMeleeHit and self:OnMeleeHit(hitent, hitflesh, tr) then
		return
	end

	if SERVER then
		self:ServerMeleeHitEntity(tr, hitent, damagemultiplier)
	end

	if hitent and hitent:IsValid() then
		self:MeleeHitEntity(tr, hitent, damagemultiplier, self.PropForceScale)
	end

	if self.PostOnMeleeHit then self:PostOnMeleeHit(hitent, hitflesh, tr) end

	if SERVER then
		self:ServerMeleePostHitEntity(tr, hitent, damagemultiplier)
	end
end

function SWEP:MeleeHitEntity(tr, hitent, damagemultiplier, forcescale)
	if not IsFirstTimePredicted() then return end

	if self.MeleeFlagged then self.IsMelee = true end

	--this is another special part
	local phys = hitent:GetPhysicsObject()
	if phys and phys:IsValid() and phys:IsMoveable() then
		if tr.IsPreHit then
			phys:ApplyForceOffset(self.MeleeDamage * damagemultiplier * 750 * (forcescale or 1) * self:GetOwner():GetAimVector(), hitent:NearestPoint(self:GetOwner():EyePos()) + hitent:GetPos() * 5 / 6)
		else
			--btw the 2/3 bit there is so that it's 2 lots closer to the trace hit pos than the center of mass
			phys:ApplyForceOffset(self.MeleeDamage * damagemultiplier * 750 * (forcescale or 1) * tr.Normal, (hitent:NearestPoint(tr.StartPos) + hitent:GetPos() * 2) / 3)
		end
	end

	local owner = self:GetOwner()

	if SERVER and hitent:IsPlayer() and not self.NoGlassWeapons and owner:IsSkillActive(SKILL_GLASSWEAPONS) then
		damagemultiplier = damagemultiplier * 3.5
		owner.GlassWeaponShouldBreak = not owner.GlassWeaponShouldBreak
	end

	local damage = self.MeleeDamage * damagemultiplier

	local dmginfo = DamageInfo()
	dmginfo:SetDamagePosition(tr.HitPos)
	dmginfo:SetAttacker(owner)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamageType(self.DamageType)
	dmginfo:SetDamage(damage)
	dmginfo:SetDamageForce(math.min(self.MeleeDamage, 50) * 50 * owner:GetAimVector())

	local vel
	if hitent:IsPlayer() then
		self:PlayerHitUtil(owner, damage, hitent, dmginfo)

		if tr.HitGroup == HITGROUP_HEAD then
			dmginfo:SetDamage(dmginfo:GetDamage() * (self.MeleeHeadshotMultiplier or 1))
		end

		if SERVER then
			hitent:SetLastHitGroup(tr.HitGroup)
			if tr.HitGroup == HITGROUP_HEAD then
				hitent:SetWasHitInHead()
			end

			if hitent:WouldDieFrom(damage, tr.HitPos) then
				dmginfo:SetDamageForce(math.min(self.MeleeDamage, 50) * 400 * owner:GetAimVector())
			end
		end

		vel = hitent:GetVelocity()
	else
		if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
			self:SetPowerCombo(0)
		end
	end

	self:PostHitUtil(owner, hitent, dmginfo, tr, vel)
end

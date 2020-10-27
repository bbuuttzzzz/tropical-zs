INC_SERVER()

ENT.HealthLock = 0

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderFX(kRenderFxDistort)

	self:SetModel("models/props_wasteland/medbridge_post01.mdl")
	self:PhysicsInitBox(Vector(-16.285, -16.285, -0.29) * self.ModelScale, Vector(16.285, 16.285, 104.29) * self.ModelScale)
	self:SetUseType(SIMPLE_USE)

	self:CollisionRulesChanged()

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end

	self:SetSigilHealthBase(self.MaxHealth)
	--self:SetSigilHealthRegen(self.HealthRegen)
	--self:SetSigilLastDamaged(0)

	/*
	local ent = ents.Create("prop_prop_blocker")
	if ent:IsValid() then
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:Spawn()
		ent:SetOwner(self)
		--ent:SetParent(self) -- Prevents collisions
		self:DeleteOnRemove(ent)
	end
	*/
end

function ENT:Use(pl)
	if pl.NextSigilTPTry and pl.NextSigilTPTry >= CurTime() then return end

	if pl:Team() == TEAM_HUMAN and pl:Alive() then
		local tpexist = pl:GetStatus("sigilteleport")
		if tpexist and tpexist:IsValid() then return end

		if GAMEMODE:NumSigils() >= 2 then
			local status = pl:GiveStatus("sigilteleport")
			if status:IsValid() then
				status:SetFromSigil(self)
				status:SetEndTime(CurTime() + 2 * (pl.SigilTeleportTimeMul or 1))

				pl.NextSigilTPTry = CurTime() + 1
			end
		end
	end
end

function ENT:OnTakeDamage(dmginfo)
	if self:GetSigilHealth() <= 0 or dmginfo:GetDamage() <= 0 then return end

	local attacker = dmginfo:GetAttacker()
	if attacker:IsValidLivingZombie() then
		local oldhealth = self:GetSigilHealth()
		self:SetSigilHealthBase(oldhealth - dmginfo:GetDamage())

		if self:GetSigilHealth() <= 0 then
			self:DoDestroy()
		end
	end
	self.RegenDelay = CurTime() + 2
end

function ENT:DoDestroy()
	--self:EmitSound("physics/glass/glass_sheet_break" .. math.random(1,3) .. ".wav")
	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
	util.Effect("gib_sigil", effectdata, true, true)

	self:Remove()
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

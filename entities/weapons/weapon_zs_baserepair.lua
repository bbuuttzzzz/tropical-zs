AddCSLuaFile()

SWEP.Base = "weapon_zs_basemelee"

SWEP.PrintName = "Base Repairer"
SWEP.Description = "You really shouldn't have this"

SWEP.ViewModel = "models/weapons/v_hammer/c_hammer.mdl"
SWEP.WorldModel = "models/weapons/w_hammer.mdl"
SWEP.UseHands = true

SWEP.UsesOomph = true
SWEP.OomphCost = 4
SWEP.OomphRepairAmount = 50
SWEP.RepairAmount = 10
SWEP.DoorMeleeDamage = 1337

function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	self:UpdateDisplay()

	return true
end

function SWEP:UpdateDisplay()
	if not CLIENT then return end
	local owner = self:GetOwner()
	if owner:GetOomph() < owner:GetMaxOomph() then
		GAMEMODE:AddTimerToWeapon(self,owner.OomphTimeMax,owner:GetOomphChargeTime(),true)
	end
end

//attempts to use up an oomph, returning true if successful, else false
function SWEP:ConsumeOomphCharge()
	local owner = self:GetOwner()

	if owner.QuickFix and not GAMEMODE:GetWaveActive() then
		return true
	end

	local oomph = owner:GetOomph()

	if oomph >= self.OomphCost then
		owner:SetOomph(oomph - self.OomphCost)
		return true
	else
		owner:SetOomph(0)
		return false
	end
end

//try and repair this thing if it's a prop or other repairable
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if not IsFirstTimePredicted() then return end
	if not hitent:IsValid() then return end

	local owner = self:GetOwner()

	/*
	if hitent.HitByHammer and hitent:HitByHammer(self, owner, tr) then
		return
	end
	*/

	if hitent:IsNailed() then //is this a nailed prop?
		//dont waste an oomph charge if the prop is already fully healed
		local oldhealth = hitent:GetBarricadeHealth()
		if oldhealth <= 0 or oldhealth >= hitent:GetMaxBarricadeHealth() or hitent:GetBarricadeRepairs() <= 0.01 then return end

		//first, check if this is an oomph swing
		local isEmpowered = self:ConsumeOomphCharge()
		local healstrength = isEmpowered and self.OomphRepairAmount or self.RepairAmount

		--make sure healStrength is less than the remaining repair amount, and the health left to fix
		--if it isn't, clamp it to the lowest value
		healstrength = math.min(healstrength,hitent:GetBarricadeRepairs(),hitent:GetMaxBarricadeHealth() - oldhealth)

		if SERVER then
			hitent:SetBarricadeHealth(oldhealth + healstrength)
			hitent:SetBarricadeRepairs(math.max(hitent:GetBarricadeRepairs() - healstrength, 0))
		end
		self:PlayRepairSound(hitent, isEmpowered)
		gamemode.Call("PlayerRepairedObject", owner, hitent, healstrength, self)

		if isEmpowered then
			local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetNormal(tr.HitNormal)
				effectdata:SetMagnitude(1)
			util.Effect("nailrepairedoomph", effectdata, true, true)
		else
			local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetNormal(tr.HitNormal)
				effectdata:SetMagnitude(1)
			util.Effect("nailrepaired", effectdata, true, true)
		end

		return true
	elseif hitent:GetClass() == "prop_door_rotating" then
		--this is a door prop, maybe we should do a lot of damage
		if not ((SERVER and hitent:GetKeyValues().damagefilter == "invul") or hitent:HasSpawnFlags(2048) and hitent:IsDoorLocked() or hitent.Broken) then
			--this door is a real door that opens so let the player break it off with oomph
			if self:ConsumeOomphCharge() then
				hitent:EmitSound(string.format("npc/dog/dog_pneumatic%d.wav",math.random(1,2)),70, math.random(100,105))
				self.m_DoorHitting = true
				self.m_StoredDamage = self.MeleeDamage
				self.MeleeDamage = self.DoorMeleeDamage

				local effectdata = EffectData()
					effectdata:SetOrigin(tr.HitPos)
					effectdata:SetNormal(tr.HitNormal)
					effectdata:SetMagnitude(1)
				util.Effect("nailrepairedoomph", effectdata, true, true)
			end
		end
	elseif hitent.GetObjectHealth then //is this another object with health?
		//dont waste an oomph charge if the prop is already fully healed
		local oldhealth = hitent:GetObjectHealth()
		if oldhealth <= 0 or oldhealth >= hitent:GetMaxObjectHealth() then return end

		local isEmpowered = self:ConsumeOomphCharge()
		local healstrength = isEmpowered and self.OomphRepairAmount or self.RepairAmount

		hitent:SetObjectHealth(math.min(hitent:GetMaxObjectHealth(), hitent:GetObjectHealth() + healstrength))
		local healed = hitent:GetObjectHealth() - oldhealth
		self:PlayRepairSound(hitent, isEmpowered)
		gamemode.Call("PlayerRepairedObject", owner, hitent, healstrength, self)

		if isEmpowered then
			local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetNormal(tr.HitNormal)
				effectdata:SetMagnitude(1)
			util.Effect("nailrepairedoomph", effectdata, true, true)
		else
			local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetNormal(tr.HitNormal)
				effectdata:SetMagnitude(1)
			util.Effect("nailrepaired", effectdata, true, true)
		end

		return true
	end
end

function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	if self.m_DoorHitting then
		print(self.MeleeDamage)
		self.m_DoorHitting = nil
		self.MeleeDamage = self.m_StoredDamage
	end
end

function SWEP:PlayRepairSound(hitent, isEmpowered)
	if(isEmpowered) then
		hitent:EmitSound(string.format("npc/dog/dog_pneumatic%d.wav",math.random(1,2)),70, math.random(100,105))
	else
		hitent:EmitSound("npc/dog/dog_servo"..math.random(7, 8)..".wav", 70, math.random(100, 105))
	end
end

function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/crowbar/crowbar_hit-"..math.random(4)..".ogg", 75, math.random(110, 115))
end

if CLIENT then
	local texGradDown = surface.GetTextureID("VGUI/gradient_down")
	function SWEP:DrawHUD()
		local screenscale = BetterScreenScale()
		local owner = self:GetOwner()

		local wid, hei = 384, 16
		local x, y = ScrW() - wid - 32, ScrH() - hei - 72
		local texty = y - 4 - draw.GetFontHeight("ZSHUDFontSmall")

		local oomph = owner:GetOomph()
		local maxOomph = owner:GetMaxOomph()

		surface.SetDrawColor(5, 5, 5, 180)
		surface.DrawRect(x, y, wid, hei)

		surface.SetDrawColor(50, 255, 50, 180)
		surface.SetTexture(texGradDown)
		surface.DrawTexturedRect(x, y, math.min(1, oomph / maxOomph) * wid, hei)

		surface.SetDrawColor(50, 255, 50, 180)
		surface.DrawOutlinedRect(x, y, wid, hei)
		//
		for n = 0, maxOomph/self.OomphCost do
			local xx = x+wid*(n*self.OomphCost/maxOomph)
			surface.DrawLine(xx,y,xx,y+hei)
		end

		if GetConVar("crosshair"):GetInt() ~= 1 then return end
		self:DrawCrosshairDot()
	end
end

AddCSLuaFile()

SWEP.PrintName = "Damaged Gravity Gun"
SWEP.Description = "Takes a long time to recharge, releases violent gravitational bursts"

SWEP.TranslationName = "wep_gravgun"
SWEP.TranslationDesc = "wep_d_gravgun"

SWEP.Slot = 5
SWEP.Tier = 1

SWEP.StatDPS = 2
SWEP.StatDPR = 0
SWEP.StatRange = 1
SWEP.StatSpecial =  5

if CLIENT then
	SWEP.ViewModelFOV = 55
	SWEP.ViewModelFlip = false
end

SWEP.Base = "weapon_zs_base"

SWEP.ViewModel = "models/weapons/v_physcannon.mdl"
SWEP.WorldModel = "models/weapons/w_physics.mdl"
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 10
SWEP.Primary.Damage = 100

SWEP.Recoil = 6

SWEP.Range = 200
--cone is always 180 degrees

SWEP.Falloff = 0.25
SWEP.BlastForce = 1200
SWEP.LaunchStatus = "launched"

SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "dummy"
SWEP.Secondary.Automatic = true

SWEP.WeightClass = WEIGHT_HEAVY

SWEP.HoldType = "physgun"
SWEP.DeploySpeedMultiplier = 3

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()


	self:SetNextCharge(CurTime() + self.Primary.Delay)
	owner.NextGravGunUse = self:GetNextCharge()
	if CLIENT then
		GAMEMODE:AddTimerToWeapon(self, self:GetNextCharge(), self.Primary.Delay,false)
	end

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	self:DoShoot()


	owner:DoAttackEvent()
	self.IdleAnimation = CurTime() + self:SequenceDuration()
end

function SWEP:DoShoot()
	self:DoShootEffect()
	if not SERVER then return end

	local owner = self:GetOwner()
	if not owner:IsValidHuman() then return end


	local center = owner:GetShootPos()
	local dir = owner:GetAimVector()
	local range = self.Range
	local cone = self.Cone
	local maxFalloffFrac = self.Falloff
	local damage = self.Primary.Damage
	local force = self.BlastForce
	local ents = ents.FindInSphere(center,range)

	for _, ent in pairs(ents) do
		if ent:IsValid() then
			if ent == owner then
				continue
			end

			--throw out any found objects that are behind the player
			local localPos = ent:GetPos() - owner:GetPos()
			if localPos:Dot(dir) < 0 then
				continue
			end

			local nearest = ent:NearestPoint(center)
			local dist = nearest:Distance(center)/range

			if TrueVisibleFilters(center, nearest, self, owner, ent)
				or TrueVisibleFilters(center, ent:EyePos(), self, owner, ent)
				or TrueVisibleFilters(center, ent:WorldSpaceCenter(), self, owner, ent) then
					--calculate frac of what force to apply
					local frac = 1 - (dist * maxFalloffFrac)
					ent:ThrowFromPosition(center + Vector(0,0,-50), force * frac, true)
					if(ent:IsPlayer()) then ent:GiveStatus(self.LaunchStatus, 1) end
					ent:TakeSpecialDamage(frac * damage, DMG_SONIC, owner, self, nearest)
			end
		end
	end

	for _, ent in pairs(ents) do
		if ent:IsValid() then
			if ent == owner then
				continue
			end

			local nearest = ent:NearestPoint(center)
			local dist = nearest:Distance(center)/range
			if(dist > range) then
				--cone is actually sqrt(2) times bigger along the diagonal
				--see ents.FindInCone on wiki
				continue
			end

			if TrueVisibleFilters(center, nearest, self, owner, ent)
				or TrueVisibleFilters(center, ent:EyePos(), self, owner, ent)
				or TrueVisibleFilters(center, ent:WorldSpaceCenter(), self, owner, ent) then

				--calculate frac of what force to apply
				local frac = 1 - (dist * maxFalloffFrac)
				ent:ThrowFromPosition(center + Vector(0,0,-50), force * frac, true)
				if(ent:IsPlayer()) then ent:GiveStatus(self.LaunchStatus, 1) end
				ent:TakeSpecialDamage(frac * damage, DMG_SONIC, owner, self, nearest)
			end
		end
	end

end

function SWEP:DoShootEffect()
	if SERVER then
		self:EmitSound("weapons/physcannon/superphys_launch1.wav")
		return
	end
	local owner = self:GetOwner()

	local effectdata = EffectData()
		effectdata:SetOrigin(owner:GetShootPos() + owner:GetAimVector() * 16)
		effectdata:SetNormal(owner:GetAimVector())
	util.Effect("explosion_impulse",effectdata)
end

function SWEP:SecondaryAttack()

end

function SWEP:CanPrimaryAttack()
	local owner = self:GetOwner()
	if owner:IsHolding() or owner:GetBarricadeGhosting() then return false end

	return self:GetNextCharge() <= CurTime() and (owner.NextGravGunUse or 0) <= CurTime()

end

function SWEP:GetNextCharge()
	return self:GetDTFloat(1)
end

function SWEP:SetNextCharge(time)
	self:SetDTFloat(1, time)
end

function SWEP:Reload()
end

function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	self.IdleAnimation = CurTime() + self:SequenceDuration()

	local nextCharge = self:GetNextCharge()
	local nextUse = self:GetOwner().NextGravGunUse or 0

	if nextCharge < nextUse then
		self:SetNextCharge(nextUse)
	end

	return true
end

if not CLIENT then return end

local texGradDown = surface.GetTextureID("VGUI/gradient_down")
function SWEP:DrawHUD()
	local wid, hei = 384, 16
	local x, y = ScrW() - wid - 32, ScrH() - hei - 72
	local texty = y - 4 - draw.GetFontHeight("ZSHUDFontSmall")

	local timeleft = self:GetNextCharge() - CurTime()
	if 0 < timeleft then
		surface.SetDrawColor(5, 5, 5, 180)
		surface.DrawRect(x, y, wid, hei)

		surface.SetDrawColor(50, 255, 50, 180)
		surface.SetTexture(texGradDown)
		surface.DrawTexturedRect(x, y, math.min(1, timeleft / self.Primary.Delay) * wid, hei)

		surface.SetDrawColor(50, 255, 50, 180)
		surface.DrawOutlinedRect(x, y, wid, hei)
	end

	--draw.SimpleText(self.PrintName, "ZSHUDFontSmall", x, texty, COLOR_GREEN, TEXT_ALIGN_LEFT)

	if GetConVar("crosshair"):GetInt() == 1 then
		self:DrawCrosshairDot()
	end
end

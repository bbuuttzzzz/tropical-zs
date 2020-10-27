AddCSLuaFile()

SWEP.PrintName = "Epic Gravity Gun"
SWEP.Description = "This grav gun is pretty epic if you ask me!"

SWEP.TranslationName = "wep_epicgravgun"
SWEP.TranslationDesc = "wep_d_epicgravgun"

SWEP.Slot = 5
SWEP.Tier = 1

SWEP.StatDPS = 2
SWEP.StatDPR = 0
SWEP.StatRange = 3
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
SWEP.Primary.Delay = 2
SWEP.Primary.Damage = 50

SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "dummy"
SWEP.Secondary.Automatic = true

SWEP.WalkSpeed = SPEED_SLOW

SWEP.HoldType = "physgun"
SWEP.DeploySpeedMultiplier = 1

SWEP.AffectedPlayers = {}
SWEP.Range = 1500
SWEP.Falloff = 0.1
SWEP.RaySize = 100
SWEP.BlastForce = 1200
SWEP.PreFire = false
SWEP.Shot = true
SWEP.NextFire = 9999999999
SWEP.TimeToAttack = .5

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()

	if not self:CanPrimaryAttack() then return end
	self:EmitSound("weapons/physcannon/physcannon_charge.wav",90,255)
	self.AffectedPlayers = self:TestVisibleZombies()
	self:DoPreFire()
	self.NextFire = CurTime() + self.TimeToAttack
	self.PreFire = true

	self:SetNextCharge(CurTime() + self.Primary.Delay)
	owner.NextGravGunUse = self:GetNextCharge()

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	self.IdleAnimation = CurTime() + self:SequenceDuration()
end

function SWEP:Think()
	if self.NextFire <= CurTime() then
		self.AffectedPlayers = {}
		self:DoShoot(self:TestVisibleZombies())
		self.NextFire = 9999999999
	end
	self:NextThink(CurTime()) return true
end

function SWEP:TestVisibleZombies()
	local owner = self:GetOwner()
	local center = owner:GetShootPos()
	local dir = owner:GetAimVector()
	local range = self.Range
	local zombies = {}
	local filth = {}

	if SERVER then
		for x, ent in pairs(ents.FindInSphere(center,range)) do
			if ent:IsValidLivingHuman() then
				filth[#filth +1] = ent
			end
			if ent:IsValidLivingZombie() then
				local localPos = ent:GetPos() - owner:GetPos()
				if localPos:Dot(dir) < 0 then
					filth[#filth + 1] = ent
				end
				for i=-5, ent:GetBoneCount() do
					tr = util.TraceLine({
					start = center+(dir* -5),
					endpos = ent:GetBonePosition(i),
					mask = MASK_SHOT,
					filter = filth
					})
					if tr.Entity == ent then
						zombies[#zombies +1] = ent
						filth[#filth +1] = ent
						break
					end
				end
			end
		end
	end
	return zombies
end

function SWEP:DoShoot(zombies)
	local owner = self:GetOwner()
	local center = owner:GetShootPos()
	local dir = owner:GetAimVector()
	local range = self.Range
	local maxFalloffFrac = self.Falloff
	local damage = self.Primary.Damage
	local force = self.BlastForce

	owner:SetVelocity(dir * -200)

	if not owner:IsValidHuman() then return end
	if zombies then
		for k,v in pairs(zombies) do
			local nearest = v:NearestPoint(center)
			local dist = nearest:Distance(center)/range
			local frac = 1 - (dist * maxFalloffFrac)
			v:ThrowFromPosition(center + Vector(0,0,-50), force * frac, true)
			if v:IsValidLivingZombie() then
				v:AddLegDamage(50, owner)
			end
			v:TakeSpecialDamage(frac * damage, DMG_SONIC, owner, self, nearest)
		end
	end
	self.Shot = true
	self:DoShootEffect()

end


function SWEP:DoPreFire(zombies)
	local owner = self:GetOwner()
	local center = owner:GetShootPos()
	local dir = owner:GetAimVector()
	local range = self.Range
	local maxFalloffFrac = self.Falloff
	local ownervel = owner:GetVelocity()

	owner:GiveStatus("gravgunprefire", .5)
	local effectdata = EffectData()
		effectdata:SetOrigin(owner:GetShootPos() + owner:GetAimVector() * 30 + owner:EyeAngles():Right() *5 + owner:EyeAngles():Up() *-5)
		effectdata:SetNormal(owner:GetAimVector())
		effectdata:SetAngles(owner:GetAimVector():Angle())
	util.Effect("gravgunprefire",effectdata)

	if not owner:IsValidHuman() then return end
	if zombies then
		for k,v in pairs(zombies) do
			if v:IsValidLivingZombie() then
				v:GiveStatus("gravgunprefire", .5)
			end
		end
	end
end


function SWEP:DoShootEffect()
	self:EmitSound("weapons/physcannon/superphys_launch2.wav", 75,math.random(200,255))
	local owner = self:GetOwner()
	owner:ViewPunch(Angle(2,0,0))
	local effectdata = EffectData()
		effectdata:SetOrigin(owner:GetShootPos() + owner:GetAimVector() * 30 + owner:EyeAngles():Right() *5 + owner:EyeAngles():Up() *-5)
		effectdata:SetNormal(owner:GetAimVector())
		effectdata:SetAngles(owner:GetAimVector():Angle())
	util.Effect("supergravgun",effectdata)
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

function SWEP:GetPreFire()
	return self:GetDTFloat(2)
end

function SWEP:SetPreFireTime(time)
	self:SetDTFloat(2, time)
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

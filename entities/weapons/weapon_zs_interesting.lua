AddCSLuaFile()

SWEP.PrintName = "'Interesting test gun"
SWEP.Description = "epic tracer based projectile"

SWEP.TranslationName = "wep_deagle"
SWEP.TranslationDesc = "wep_d_deagle"

SWEP.Slot = 1
SWEP.Tier = 2
SWEP.SlotPos = 0

SWEP.WalkSpeed = SPEED_FASTEST

SWEP.StatDPS = 2
SWEP.StatDPR = 4
SWEP.StatRange = 3
SWEP.StatSpecial = 4

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55

	SWEP.HUD3DBone = "v_weapon.Deagle_Slide"
	SWEP.HUD3DPos = Vector(-1, 0, 1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015

	SWEP.IronSightsPos = Vector(-6.35, 5, 1.7)
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "revolver"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_MegaPhysCannon.Launch")
SWEP.Primary.Damage = 50
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0
SWEP.Primary.KnockbackScale = 2

SWEP.Primary.ClipSize = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.Secondary.Delay = 0.3
SWEP.Secondary.Automatic = false

SWEP.ConeMax = 3.4
SWEP.ConeMin = 1.25

SWEP.FireAnimSpeed = 1.3
SWEP.FireMode = 0

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	if SERVER then
		if self.FireMode == 0 then
			for i = 1, 25 do

				local dir = self:GetOwner():GetAimVector()
				local dirang = dir:Angle()
				local start = self:GetOwner():GetShootPos()
				dirang:RotateAroundAxis(dirang:Forward(), util.SharedRandom("bulletrotate1".. i, 0, 360))
				dirang:RotateAroundAxis(dirang:Up(), util.SharedRandom("bulletangle1".. i, -10, 10))
				dir = dirang:Forward()
				print(util.SharedRandom("bulletangle1", -1, 1))

				self:EasyRayBasedProjectile("RBP_BULLET1", self:GetOwner(), self:GetOwner():GetShootPos(), dir, {self:GetOwner()}, MASK_SHOT_HULL, function(proj,tr) if tr.Entity:IsValid() then tr.Entity:TakeSpecialDamage(5, DMG_SONIC, self:GetOwner()) end end)
			end
		elseif self.FireMode == 1 then

			local ent1 = ents.Create("projectile_interesting")
			if ent1:IsValid() then
				ent1.Vel = dir * 50
				ent1.Pos = self:GetOwner():GetShootPos()
				ent1:SetOwner(self:GetOwner())
				ent1:Spawn()
			end

		elseif self.FireMode == 2 then

			local ent = ents.Create("projectile_interesting2")
			if ent:IsValid() then
				ent:SetPos(self:GetOwner():GetShootPos())
				ent:SetOwner(self:GetOwner())

				ent:Spawn()
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:SetVelocityInstantaneous(self:GetOwner():GetAimVector() * 50)
				end
			end
		end
	end
end

function SWEP:SecondaryAttack()
	if SERVER then
		self.FireMode = self.FireMode + 1
		if self.FireMode >= 3 then
			self.FireMode = 0
		end

		print("Changed FireMode to: ".. self.FireMode .."\n FiredNum reset")
	end

	self.firednum = 0
end

function SWEP:Think()

end

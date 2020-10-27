AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

SWEP.PrintName = "'Bandito' Sidearm"
SWEP.Description = "Draws fast as lightning. Fills itself up when you aren't using it."

SWEP.TranslationName = "wep_bandito"
SWEP.TranslationDesc = "wep_d_bandito"

SWEP.Slot = 1
SWEP.Tier = 1
SWEP.SlotPos = 0

SWEP.WeightClass = WEIGHT_FEATHER

SWEP.StatDPS = 4
SWEP.StatDPR = 4
SWEP.StatRange = 3
SWEP.StatSpecial = 1

if CLIENT then
	SWEP.ViewModelFOV = 60
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "ValveBiped.square"
	SWEP.HUD3DPos = Vector(1.1, 0.25, -2)
	SWEP.HUD3DScale = 0.015


	SWEP.ShowViewModel = false

	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/weapons/w_pist_elite_single.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 1, 3), angle = Angle(0, 0, 180), size = Vector(1.1, 1.1, 1.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pist_elite_single.mdl"
SWEP.UseHands = true

SWEP.ReloadSound = Sound("weapons/elite/elite_clipout.wav")
SWEP.Primary.Sound = Sound("Weapon_ELITE.Single")
SWEP.Primary.Damage = 28
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.15
SWEP.ReloadSpeed = 1

SWEP.Primary.ClipSize = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.IronSightsPos = Vector(-5.9, 12, 2.3)

SWEP.ConeMax = 3
SWEP.ConeMin = 1

SWEP.DeploySpeedMultiplier = 4
SWEP.AutoFillTime = 2


function SWEP:Deploy()
	timer.Remove("banditoRefill" .. tostring(self:EntIndex()))
	if CLIENT then
		GAMEMODE:RemoveTimerFromWeapon(self)
	end

	return BaseClass.Deploy(self)
end

function SWEP:DoFillClip()
	if not self:IsValid() then return end
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	local clip = self:Clip1()
	local dif = math.min(
		self.Primary.ClipSize - clip,
		owner:GetAmmoCount(self:GetPrimaryAmmoType())
	)

	if(dif > 0) then
		self:SetClip1(clip + dif)
		if SERVER then
			owner:RemoveAmmo(dif,self:GetPrimaryAmmoType())
		end
	end
end

function SWEP:Holster()
	if self:Clip1() < self.Primary.ClipSize then
		--refill the weapon after a delay
		timer.Create("banditoRefill" .. tostring(self:EntIndex()),self.AutoFillTime,1,function()
			if self then
				self:DoFillClip()
			end
		end)
		--add a timer to the GUI while it's holstered
		if CLIENT then
			GAMEMODE:AddTimerToWeapon(self, CurTime() + self.AutoFillTime, self.AutoFillTime, true, function()
				timer.Simple(0.1, function()
					GAMEMODE:UpdateWeapon(self)
				end)
			end)
		end
	end

	return true
end

AddCSLuaFile()

SWEP.Base = "weapon_zs_baseshotgun"
SWEP.Slot = 3
SWEP.SlotPos = 0

SWEP.StatDPS = 2
SWEP.StatDPR = 2
SWEP.StatRange = 3
SWEP.StatSpecial = 4

SWEP.PrintName = "'Airstrike' Shotgun"
SWEP.Description = "Prevents fall damage, movement speed on kill."
SWEP.TranslationName = "wep_airstrike"
SWEP.TranslationDesc = "wep_d_airstrike"

if CLIENT then
	SWEP.ViewModelFlip = false

	SWEP.HUD3DPos = Vector(4, -3.5, -1.2)
	SWEP.HUD3DAng = Angle(90, 0, -30)
	SWEP.HUD3DScale = 0.02
	SWEP.HUD3DBone = "SS.Grip.Dummy"
end

SWEP.HoldType = "shotgun"

SWEP.ViewModel = "models/weapons/v_supershorty/v_supershorty.mdl"
SWEP.WorldModel = "models/weapons/w_supershorty.mdl"
SWEP.UseHands = false

SWEP.ReloadDelay = 0.45

SWEP.Primary.Sound = Sound("Weapon_Shotgun.NPC_Single")
SWEP.Primary.Damage = 270
SWEP.Primary.NumShots = BULLETPATTERN_SHOTGUN
SWEP.Primary.Delay = 0.6
SWEP.HeadshotMulti = 1.5

SWEP.Primary.ClipSize = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "buckshot"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 9
SWEP.ConeMin = 5

SWEP.WeightClass = WEIGHT_FEATHER

SWEP.LastSound = 0
SWEP.SoundInterval = .1

SWEP.PumpSound = Sound("Weapon_M3.Pump")
SWEP.ReloadSound = Sound("Weapon_Shotgun.Reload")

SWEP.PumpActivity = ACT_SHOTGUN_PUMP


function SWEP:OnZombieKilled()
	local killer = self:GetOwner()

	if killer:IsValid() then
		local hermesStatus = killer:GiveStatus("hermes", 2)
		if hermesStatus and hermesStatus:IsValid() then
			killer:EmitSound("hl1/ambience/particle_suck1.wav", 55, 150, 0.45)
		end

		--this really sucks lol... don't need to check that these exist
		--because it's about to do 2 separate find commands to get every status
		--and check them all for us...
		killer:RemoveStatus("cripple")
		killer:RemoveStatus("slow")
	end
end


function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())

	self:EmitFireSound()
	self:TakeAmmo()

	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone())
	self.IdleAnimation = CurTime() + self:SequenceDuration()
end

function SWEP:SendWeaponAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:GetOwner():GetViewModel():SetPlaybackRate(self.FireAnimSpeed)

	timer.Simple(0.15, function()
		if IsValid(self) then
			self:SendWeaponAnim(ACT_SHOTGUN_PUMP)
			self:GetOwner():GetViewModel():SetPlaybackRate(self.FireAnimSpeed)

			if CLIENT and self:GetOwner() == MySelf then
				self:EmitSound("weapons/m3/m3_pump.wav", 65, 100, 0.4, CHAN_AUTO)
			end
		end
	end)
end

function SWEP:Deploy()
	--tell the player to start ignoring fall damage
	local pl = self:GetOwner()
	self.StoredDamageMul = pl.FallDamageDamageMul or nil
	pl.FallDamageDamageMul = 0

	return self.BaseClass.Deploy(self)
end

function SWEP:Holster()
	self:DoReset()

	return self.BaseClass.Holster(self)
end

function SWEP:OnRemove()
	self:DoReset()

	return self.BaseClass.OnRemove(self)
end

function SWEP:DoReset()
	--tell the player to stop ignoring fall damage
	local pl = self:GetOwner()
	pl.FallDamageDamageMul = self.StoredDamageMul or nil
end

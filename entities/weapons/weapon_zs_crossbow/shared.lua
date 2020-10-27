SWEP.PrintName = "'Impaler' Crossbow"
SWEP.Description = "skewers a whole row of zombies at once"

SWEP.TranslationName = "wep_crossbow"
SWEP.TranslationDesc = "wep_d_crossbow"

SWEP.Base = "weapon_zs_baseproj"

SWEP.Slot = 4

SWEP.StatDPS = 1
SWEP.StatDPR = 4
SWEP.StatRange = 1
SWEP.StatSpecial = 5

SWEP.HoldType = "crossbow"

SWEP.ViewModel = "models/weapons/c_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"
SWEP.UseHands = true

SWEP.CSMuzzleFlashes = false

SWEP.Primary.Sound = Sound("Weapon_Crossbow.Single")
SWEP.Primary.Delay = 0.3
SWEP.Primary.Automatic = true
SWEP.Primary.Damage = 90

SWEP.Primary.ClipSize = 1
SWEP.Primary.Ammo = "XBowBolt"
SWEP.Primary.DefaultClip = 15

SWEP.SecondaryDelay = 0.5

SWEP.WeightClass = WEIGHT_HEAVY

SWEP.Tier = 4
SWEP.MaxStock = 2

SWEP.ConeMax = 0
SWEP.ConeMin = 0

SWEP.NextZoom = 0

SWEP.ReloadSpeed = 1 -- Since it works with it now.

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())
	self:EmitFireSound()
	self:TakeAmmo()

	local owner = self:GetOwner()
	local dir = owner:GetAimVector()
	self:SendWeaponAnimation()
	owner:DoAttackEvent()
	if SERVER then
		local filter = {owner}
		self:EasyRayBasedProjectile("RBP_CBOLT", owner, owner:GetShootPos(), dir, filter)
	end



	self.IdleAnimation = CurTime() + self:SequenceDuration()
end


function SWEP:EmitReloadSound()
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/crossbow/bolt_load"..math.random(2)..".wav", 65, 100, 0.9, CHAN_WEAPON + 21)
		self:EmitSound("weapons/crossbow/reload1.wav", 65, 100, 0.9, CHAN_WEAPON + 22)
	end
end

function SWEP:IsScoped()
	return self:GetIronsights() and self.fIronTime and self.fIronTime + 0.25 <= CurTime()
end

util.PrecacheSound("weapons/crossbow/bolt_load1.wav")
util.PrecacheSound("weapons/crossbow/bolt_load2.wav")

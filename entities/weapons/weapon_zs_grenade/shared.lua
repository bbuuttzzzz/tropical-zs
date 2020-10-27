SWEP.PrintName = "Grenade"
SWEP.Description = "A Simple Frag Grenade with a 5 second fuse. Right click to pull the pin early"

SWEP.TranslationName = "wep_grenade"
SWEP.TranslationDesc = "wep_d_grenade"

SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"//"models/weapons/c_grenade.mdl"
SWEP.WorldModel = "models/weapons/w_eq_fraggrenade.mdl"//"models/weapons/w_grenade.mdl"

SWEP.Base = "weapon_zs_basethrown"

SWEP.MaxFuse = 5
SWEP.MinFuse = 0.3

SWEP.Damage = 300

SWEP.GrenadeRadius = 256

function SWEP:SecondaryAttack()
  if not self:CanSecondaryAttack() then return end

  self:SetCookStart(CurTime())

  self:SendWeaponAnim(ACT_VM_PULLPIN)

  if CLIENT then
    self.NextTickSound = 0
  end
end


function SWEP:CanSecondaryAttack()
  return not self:IsCooking()
end

function SWEP:IsCooking()
  return self:GetCookStart() and self:GetCookStart() > 0
end

function SWEP:SetCookStart(time)
  self:SetDTFloat(0,time)
end

function SWEP:GetCookStart()
  return self:GetDTFloat(0)
end

function SWEP:Deploy()
	GAMEMODE:WeaponDeployed(self:GetOwner(), self)

	if self:GetPrimaryAmmoCount() <= 0 then
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	end

  self:SetCookStart(0)

	return true
end

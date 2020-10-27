AddCSLuaFile()

SWEP.Base = "weapon_zs_baseshotgun"
SWEP.Slot = 3
SWEP.SlotPos = 0

SWEP.StatDPS = 2
SWEP.StatDPR = 2
SWEP.StatRange = 3
SWEP.StatSpecial = 4

SWEP.PrintName = "'Airstrike' Shotgun"
SWEP.Description = "Prevents fall damage, deals extra damage based on how fast you were falling. Resets on reload."
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
SWEP.Primary.Damage = 200
SWEP.Primary.NumShots = BULLETPATTERN_SHOTGUN
SWEP.Primary.Delay = 0.6
SWEP.HeadshotMulti = 1.5

SWEP.Primary.ClipSize = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "buckshot"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 5
SWEP.ConeMin = 5

SWEP.WeightClass = WEIGHT_LIGHT

SWEP.LastSound = 0
SWEP.SoundInterval = .1

/*
FallMuls is a table of tables
each subtable contains two entries:
	1: the speed at which this entry is reached
	2: the multiplier reached at this damage
in between two speed checkpoints, the damage is linearly interpolated
*/
SWEP.FallMuls =
{
	{speed=300, mul=1},
	{speed=500, mul=1.5},
	{speed=1100, mul=3}
}

SWEP.PumpSound = Sound("Weapon_M3.Pump")
SWEP.ReloadSound = Sound("Weapon_Shotgun.Reload")

SWEP.PumpActivity = ACT_SHOTGUN_PUMP

function SWEP:GetDamageMul()
	return self:GetDTFloat(1)
end
function SWEP:SetDamageMul(mul)
	self:SetDTFloat(1,mul)
end
function SWEP:UpdateDamageMul(fallSpeed)
	--calculate what the multiplier should be

	--if it's not overwritten by the for loop, it's because
	--the fall speed is > the fastest speed, so make it the last mul
	local mul = self.FallMuls[#self.FallMuls].mul

	for n, tab in ipairs(self.FallMuls) do

		if tab.speed > fallSpeed then
			if n == 1 then
				--it is slower than slowest speed
				--so use first mul
				mul = self.FallMuls[1].mul
			else
				local tab2 = self.FallMuls[n-1]

				--it is between two speeds,
				--so linearly interpolate the value
				mul = Lerp2(fallSpeed,tab2.speed,tab.speed,tab2.mul,tab.mul)
			end

			break
		end
	end

	if mul > self:GetDamageMul() then
		self:SetDamageMul(mul)

		if CLIENT then
			if self.LastSound + self.SoundInterval < CurTime() then
				self.LastSound = CurTime()
				local p = Lerp2(mul,self.FallMuls[1].mul,self.FallMuls[#self.FallMuls].mul,75,255)
				EmitSound("items/flashlight1.wav",self:GetPos(),self:EntIndex(),nil,nil,nil,nil,p)
			end
		end
	end
end


function SWEP:StopReloading()
	self:ResetDamageMul()
	return self.BaseClass.StopReloading(self)
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())

	self:EmitFireSound()
	self:TakeAmmo()

	local damage = self.Primary.Damage * (self:GetDamageMul() or 1)

	self:ShootBullets(damage, self.Primary.NumShots, self:GetCone())
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

function SWEP:Think()
	local owner = self:GetOwner()

	if not owner:OnGround() and self:GetDamageMul() < self.FallMuls[#self.FallMuls].mul then
		local fallSpeed = math.max(-1 * self:GetOwner():GetVelocity().z,0)

		self:UpdateDamageMul(fallSpeed)
	end

	return self.BaseClass.Think(self)
end
function SWEP:Deploy()
	if SERVER then
		--add the hitGround hook to capture player fall speed
		hook.Add("OnPlayerHitGround","AirstrikeOnPlayerHitGround" .. tostring(self:EntIndex()),function(pl, inwater, hitfloater, speed)
			self:OnPlayerHitGround(pl, inwater, hitfloater, speed)
		end)
	end

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
	self:ResetDamageMul()

	return self.BaseClass.OnRemove(self)
end

function SWEP:DoReset()
	if SERVER then
		--remove hitground hook
		hook.Remove("OnPlayerHitGround","AirstrikeOnPlayerHitGround" .. tostring(self:EntIndex()))
	end

	--tell the player to stop ignoring fall damage
	local pl = self:GetOwner()
	pl.FallDamageDamageMul = self.StoredDamageMul or nil
end

function SWEP:ResetDamageMul()
	self:SetDamageMul(1)
end

function SWEP:OnPlayerHitGround(pl, inwater, hitfloater, speed)

	if pl ~= self:GetOwner() then return end

	self:UpdateDamageMul(speed)
end

if not CLIENT then return end

function SWEP:Draw3DHUD(vm, pos, ang)
	self.BaseClass.Draw3DHUD(self, vm, pos, ang)

	local wid, hei = 180, 200
	local x, y = wid * -0.6, hei * -0.5

	cam.Start3D2D(pos, ang, self.HUD3DScale)
		local mul = self:GetDamageMul()
		if mul and mul > self.FallMuls[1].mul then
			local gb = Lerp2(mul,self.FallMuls[1].mul,self.FallMuls[#self.FallMuls].mul,255,50)
			local col = Color(255,gb,gb,230)
			local text = tostring(math.Round(mul,1)) .. "*"
			draw.SimpleTextBlurry(text, "ZS3D2DFontSmall", x + wid/2, y + hei * 0.15, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	cam.End3D2D()
end

function SWEP:Draw2DHUD()
	self.BaseClass.Draw2DHUD(self)

	local screenscale = BetterScreenScale()
	local wid, hei = 180 * screenscale, 64 * screenscale
	local x, y = ScrW() - wid - screenscale * 128, ScrH() - hei - screenscale * 72

	local mul = self:GetDamageMul()
	if mul and mul > self.FallMuls[1].mul then
		local gb = Lerp2(mul,self.FallMuls[1].mul,self.FallMuls[#self.FallMuls].mul,255,50)
		local col = Color(255,gb,gb,230)
		local text = tostring(math.Round(mul,1)) .. "*"
		draw.SimpleTextBlurry(text, "ZS3D2DFontSmall", x + 1 * wid, y - hei/3, col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
end

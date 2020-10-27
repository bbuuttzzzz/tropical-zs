AddCSLuaFile()

SWEP.PrintName = "Confetti Gun"
SWEP.Description = "Let's party!"

SWEP.TranslationName = "wep_confetti"
SWEP.TranslationDesc = "wep_d_confetti"

SWEP.Slot = 1
SWEP.Tier = 1
SWEP.SlotPos = 0

SWEP.WalkSpeed = SPEED_FAST

SWEP.StatDPS = 0
SWEP.StatDPR = 0
SWEP.StatRange = 0
SWEP.StatSpecial =  5

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "ValveBiped.square"
	SWEP.HUD3DPos = Vector(1.1, 0.25, -2)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true

SWEP.CSMuzzleFlashes = false

SWEP.ReloadSound = Sound("Weapon_Pistol.Reload")
SWEP.Primary.Sound = Sound("buttons/lightswitch2.wav")
SWEP.Primary.Damage = 1
SWEP.HeadshotMulti = 0
SWEP.Primary.NumShots = 0
SWEP.Primary.Delay = 3

SWEP.Primary.ClipSize = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 10
SWEP.ConeMin = 10

SWEP.IronSightsPos = Vector(-5.95, 3, 2.75)
SWEP.IronSightsAng = Vector(-0.15, -1, 2)


SWEP.used = false
SWEP.dist = 200

function SWEP:PrimaryAttack()
 if not self:CanPrimaryAttack() then return end
	local ironsights = self:GetIronsights()
	local owner = self:GetOwner()
	local origin = owner:GetShootPos()
	local dir = owner:GetAimVector()

	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay() * (ironsights and 1.3333 or 1))
 	--commenting this out until bots can dance for now it can just be a waste of points
	--[[
	for k, v in pairs(self:TestVisibleZombies()) do
		if v:IsBot() then

		else
			v:ConCommand("act dance")
		end
	end
	]]--

	self:EmitFireSound()
	local effectdata = EffectData()
		effectdata:SetOrigin(origin)
		effectdata:SetAngles(dir:Angle())
	util.Effect("confetti", effectdata)

	self.used = true
	self.IdleAnimation = CurTime() + self:SequenceDuration()
end

function SWEP:TestVisibleZombies()
	local owner = self:GetOwner()
	local center = owner:GetShootPos()
	local dir = owner:GetAimVector()
	local range = self.dist
	local zombies = {}

	local filth = {}

	for k,v in pairs(player.GetAll()) do
		if v:IsValidLivingHuman() then
			table.insert(filth, v)
		end
	end

	if SERVER then
	owner:LagCompensation(true)
		for x, ent in pairs(ents.FindInSphere(center,range)) do
			if ent:IsValidLivingZombie() then

				--if zombies are behind the player ignore them
				local localPos = ent:GetPos() - owner:GetPos()
				if localPos:Dot(dir) < 0 then
					table.insert(filth, ent)
				end

				--im starting at -25 because i know theres gotta be some negative numbered bones in some of the models and this really isnt expensive at all.
				for i=-25, ent:GetBoneCount() do
					tr = util.TraceLine({
					start = center+(dir* -5),
					endpos = ent:GetBonePosition(i),
					mask = MASK_SHOT,
					filter = filth
					})
					if tr.Entity == ent then
						table.insert(zombies, ent)
						table.insert(filth,ent)
						break
					end
				end
			end
		end
	end
	owner:LagCompensation(false)
	filth = {}
	return zombies
end

function SWEP:CanPrimaryAttack()
	if !self.used then return true end
end

function SWEP:Think()
	local owner = self:GetOwner()
	if self.used && owner:KeyDown(IN_ATTACK) && SERVER && owner:HasWeapon(self:GetClass()) then
		self:GetOwner():StripWeapon(self:GetClass())
	end
end

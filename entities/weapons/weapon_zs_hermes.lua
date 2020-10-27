AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

SWEP.PrintName = "'Hermes' SMG"
SWEP.Description = "Grants a speed boost on kill"

SWEP.TranslationName = "wep_hermes"
SWEP.TranslationDesc = "wep_d_hermes"

SWEP.WeightClass = WEIGHT_FEATHER

SWEP.Slot = 2
SWEP.SlotPos = 0

SWEP.StatDPS = 3
SWEP.StatDPR = 3
SWEP.StatRange = 3
SWEP.StatSpecial = 5

if CLIENT then
	SWEP.HUD3DBone = "ValveBiped.base"
	SWEP.HUD3DPos = Vector(1.5, 0.25, -2)
	SWEP.HUD3DScale = 0.02

	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "smg"

SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"
SWEP.UseHands = true

SWEP.CSMuzzleFlashes = false

SWEP.ReloadSound = Sound("Weapon_SMG1.Reload")
SWEP.Primary.Sound = Sound("Weapon_AR2.NPC_Single")
SWEP.Primary.Damage = 26
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.13

SWEP.Primary.ClipSize = 24
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SMG1

SWEP.ReloadSpeed = 0.78
SWEP.FireAnimSpeed = 0.55

SWEP.ConeMax = 4.5
SWEP.ConeMin = 2.5

SWEP.IronSightsPos = Vector(-6.425, 5, 1.02)


function SWEP:OnZombieKilled()
	local killer = self:GetOwner()

	if killer:IsValid() then
		local hermesStatus = killer:GiveStatus("hermes", 3)
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

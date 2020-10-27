CLASS.Base = "_base"

CLASS.Name = "Blood Bag"
CLASS.TranslationName = "class_blood_bag"

CLASS.Type = ZTYPE_MINIBOSS

CLASS.SWEP = "weapon_zsz_bloodbag"
CLASS.Speed = 200
CLASS.Health = 1000
CLASS.Points = 10

CLASS.Model = Model("models/Zombie/Poison.mdl")

CLASS.VoicePitch = 0.5


CLASS.ViewOffset = Vector(0, 0, 50)
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 64)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 35)}

CLASS.BloodColor = BLOOD_COLOR_YELLOW

local math_random = math.random
local math_min = math.min

local ACT_IDLE = ACT_IDLE
local STEPSOUNDTIME_NORMAL = STEPSOUNDTIME_NORMAL
local STEPSOUNDTIME_WATER_FOOT = STEPSOUNDTIME_WATER_FOOT
local STEPSOUNDTIME_ON_LADDER = STEPSOUNDTIME_ON_LADDER
local STEPSOUNDTIME_WATER_KNEE = STEPSOUNDTIME_WATER_KNEE

function CLASS:CalcMainActivity(pl, velocity)
	if velocity:Length2DSqr() <= 1 then
		return ACT_IDLE, -1
	end

	return 1, 2
end

local StepSounds = {
	"npc/zombie_poison/pz_left_foot1.wav"
}
local ScuffSounds = {
	"npc/zombie_poison/pz_right_foot1.wav"
}
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 and math_random() < 0.333 then
		pl:EmitSound(ScuffSounds[math_random(#ScuffSounds)], 80, 90)
	else
		pl:EmitSound(StepSounds[math_random(#StepSounds)], 80, 90)
	end

	return true
end

function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return (365 - pl:GetVelocity():Length()) * 1.5
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 450
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 600
	end

	return 200
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local len2d = velocity:Length2D()
	if len2d > 1 then
		pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed * 0.5, 3))
	else
		pl:SetPlaybackRate(0.5)
	end

	return true
end

if SERVER then
	function CLASS:OnSpawned(pl)
		pl:CreateAmbience("chemzombieambience")
	end
end

local BonesToZero = {
	"ValveBiped.Bip01_L_UpperArm",
	"ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_L_Hand",
	"ValveBiped.Bip01_L_Finger1",
	"ValveBiped.Bip01_L_Finger11",
	"ValveBiped.Bip01_L_Finger12",
	"ValveBiped.Bip01_L_Finger2",
	"ValveBiped.Bip01_L_Finger21",
	"ValveBiped.Bip01_L_Finger22",
	"ValveBiped.Bip01_L_Finger3",
	"ValveBiped.Bip01_L_Finger31",
	"ValveBiped.Bip01_L_Finger32",
	"ValveBiped.Bip01_R_UpperArm",
	"ValveBiped.Bip01_R_Forearm",
	"ValveBiped.Bip01_R_Hand",
	"ValveBiped.Bip01_R_Finger1",
	"ValveBiped.Bip01_R_Finger11",
	"ValveBiped.Bip01_R_Finger12",
	"ValveBiped.Bip01_R_Finger2",
	"ValveBiped.Bip01_R_Finger21",
	"ValveBiped.Bip01_R_Finger22",
	"ValveBiped.Bip01_R_Finger3",
	"ValveBiped.Bip01_R_Finger31",
	"ValveBiped.Bip01_R_Finger32"
}
function CLASS:BuildBonePositions(pl)
	for _, bone in pairs(BonesToZero) do
		local boneid = pl:LookupBone(bone)
		if boneid and boneid > 0 then
			pl:ManipulateBoneScale(boneid, vector_tiny)
		end
	end
end

function CLASS:DescribeStats()
	local wep = weapons.GetStored(self.SWEP)

	txt = table.concat({
		translate.Format("health_x",self:CalcMaxHealth()), "\n",
		translate.Format("speed_x", self.Speed) , "\n",
		((wep.CanClimb) and (translate.Get("can_climb") .. "\n") or ("")),
		translate.Get("blood_bag_explodes"), "\n"
	})

	return txt
end

if SERVER then

	hook.Add("InitPostEntityMap", "MakeChemDummy", function()
		DUMMY_CHEMZOMBIE = ents.Create("dummy_chemzombie")
		if DUMMY_CHEMZOMBIE:IsValid() then
			DUMMY_CHEMZOMBIE:Spawn()
		end
	end)

	local function DoExplode(pl, pos, DUMMY_CHEMZOMBIE)
		if not SERVER then return end

		local radius = 200
		local maxFalloffFrac = 0.5
		local radiationDamage = 70
		local heal = 200

		local ents = util.FindVisibleInSphere(DUMMY_CHEMZOMBIE, pl, pos, radius)
		for _, ent in pairs(ents) do
			local nearest = ent:NearestPoint(pos)
			local frac = 1 - (nearest:Distance(pos)/radius * maxFalloffFrac)
			if ent:IsValidLivingZombie() then
				ent:HealPlayer(ent,frac * heal,0)
			elseif ent:IsValidLivingHuman() then
				ent:AddRadiationDamage(frac * radiationDamage,pl)
			else
				ent:TakeSpecialDamage(frac * 100, DMG_GENERIC, pl)
			end
		end


	end

	local function ChemBomb(pl, pos)
		/*
		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
		util.Effect("explosion_bloodbag", effectdata, true)
		*/

		if DUMMY_CHEMZOMBIE:IsValid() then
			DUMMY_CHEMZOMBIE:SetPos(pos)
		end

		DoExplode(pl, pos, DUMMY_CHEMZOMBIE)

		pl:CheckRedeem(pl, pos)
	end



	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
		if attacker ~= pl and not suicide then
			local pos = pl:LocalToWorld(pl:OBBCenter())

			pl:Gib(dmginfo)
			timer.Simple(0, function() ChemBomb(pl, pos) end)

			return true
		end
	end
end



if not CLIENT then return end

CLASS.Icon = "tropical/killicons/blood_bag"

local matSkin = Material("models/flesh")
function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
end

function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
end

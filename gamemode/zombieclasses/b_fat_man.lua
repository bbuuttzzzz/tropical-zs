CLASS.Base = "_base"

CLASS.Name = "Fat Man"
CLASS.TranslationName = "class_fat_man"

CLASS.Type = ZTYPE_BOSS

CLASS.SWEP = "weapon_zsz_fatman"
CLASS.Speed = 125
CLASS.Health = 2000
CLASS.IsDefault = true
CLASS.Points = 30

CLASS.Model = Model("models/player/fatty/fatty.mdl")

CLASS.VoicePitch = 0.5

CLASS.BloodColor = BLOOD_COLOR_RED

local math_ceil = math.ceil
local math_random = math.random
local string_format = string.format
local math_Rand = math.Rand

local ACT_HL2MP_IDLE_CROUCH_ZOMBIE = ACT_HL2MP_IDLE_CROUCH_ZOMBIE
local ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01

function CLASS:PlayPainSound(pl)
	pl:EmitSound(string_format("npc/zombie_poison/pz_idle%d.wav", math_random(2, 3)), 72, math_Rand(75, 85))
	pl.NextPainSound = CurTime() + 0.5

	return true
end

function CLASS:CalcMainActivity(pl, velocity)
	if pl:WaterLevel() >= 3 then
		return self.act_Swim, -1
	end

	local wep = pl:GetActiveWeapon()

	--[[
	if wep:IsValid() then
		if wep.IsClimbing and wep:IsClimbing() then
			return self.act_Climb, -1
		elseif wep.IsLeaping and wep:IsLeaping() then
			return self.act_Leap, -1
		elseif wep.IsAlting and wep:IsAlting() and not pl:Crouching() then
			return self.act_Walk - 1 + math_ceil((CurTime() / 3 + pl:EntIndex()) % 3), -1
		end
	end
	]]

	if velocity:Length2DSqr() <= 1 then
		if pl:Crouching() and pl:OnGround() then
			return ACT_HL2MP_IDLE_CROUCH_ZOMBIE, -1
		end

		return self.act_Walk, -1
	end

	if pl:Crouching() and pl:OnGround() then
		return ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 - 1 + math_ceil((CurTime() / 4 + pl:EntIndex()) % 3), -1
	end


	return self.act_Alt, -1
end

function CLASS:DescribeStats()
	local wep = weapons.GetStored(self.SWEP)

	txt = table.concat({
		translate.Format("health_x",self:CalcMaxHealth()), "\n",
		translate.Format("speed_x", self.Speed) , "\n",
		((wep.CanClimb) and (translate.Get("can_climb") .. "\n") or ("")),
		translate.Get("fat_man_explodes"), "\n"
	})

	return txt
end

if SERVER then

	/*
	hook.Add("InitPostEntityMap", "MakeChemDummy", function()
		DUMMY_CHEMZOMBIE = ents.Create("dummy_chemzombie")
		if DUMMY_CHEMZOMBIE:IsValid() then
			DUMMY_CHEMZOMBIE:Spawn()
		end
	end)
	*/

	local function DoExplode(pl, pos, DUMMY_CHEMZOMBIE)
		if not SERVER then return end

		local radius = 1000
		local maxFalloffFrac = 1
		local radiationDamage = 120
		local invisFrac = 0.5

		local visents, invisents = util.FindVisibleInSphere(DUMMY_CHEMZOMBIE, pl, pos, radius)
		for _, ent in pairs(visents) do
			local nearest = ent:NearestPoint(pos)
			local frac = 1 - (nearest:Distance(pos)/radius * maxFalloffFrac)
			if ent:IsValidLivingZombie() then
			elseif ent:IsValidLivingHuman() then
				ent:AddRadiationDamage(frac * radiationDamage,pl)
			else
				ent:TakeSpecialDamage(frac * 100, DMG_GENERIC, pl)
			end
		end
		for _, ent in pairs(invisents) do
			local nearest = ent:NearestPoint(pos)
			local frac = 1 - (nearest:Distance(pos)/radius * maxFalloffFrac)
			if ent:IsValidLivingZombie() then
			elseif ent:IsValidLivingHuman() then
				ent:AddRadiationDamage(frac * radiationDamage * invisFrac,pl)
			else
				ent:TakeSpecialDamage(frac * 100, DMG_GENERIC * invisFrac,pl)
			end
		end


	end

	local function ChemBomb(pl, pos)
		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
		util.Effect("explosion_fatman", effectdata, true)

		if DUMMY_CHEMZOMBIE:IsValid() then
			DUMMY_CHEMZOMBIE:SetPos(pos)
		end

		DoExplode(pl, pos, DUMMY_CHEMZOMBIE)
	end



	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
		if not suicide or dmginfo:GetDamageCustom() == 1 then
			local pos = pl:LocalToWorld(pl:OBBCenter())

			pl:Gib(dmginfo)
			timer.Simple(0, function() ChemBomb(pl, pos) end)

			return true
		end
	end
end



if not CLIENT then return end

CLASS.Icon = "tropical/killicons/fat_man"

local matSkin = Material("models/flesh")
function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
end

function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
end

--s.frac is fraction of HP at which the set bones should be scaled by s.scale
local scales = {
	{frac = 1, scale = 1},
	{frac = 0.8, scale = 1.1},
	{frac = 0.6, scale = 1.2},
	{frac = 0.4, scale = 1.4},
	{frac = 0.2, scale = 1.6},
	{frac = 0, scale = 2}
}
local function CreateBoneScales(pl)
	pl.m_FatManScaleNext = CurTime() + 0.2

	local hpfrac = pl:Health() / pl:GetMaxHealth()

	if hpfrac == 1 and pl.m_FatManScale and pl.m_FatManScale ~= scales[1] then

	end

	if not pl.m_FatManScale or pl.m_FatManScale.frac > hpfrac then
		--select new scale
		for _, s in ipairs(scales) do
			if s.frac <= hpfrac then
				pl.m_FatManScale = s
				break
			end
		end

		--if we didnt pick bones yet do that
		if not pl.m_FatManBones then
			pl.m_FatManBones = {}

			--pick 5-10 random bones
			local count = pl:GetBoneCount()
			for n = 1, 10 do
				local b = math.random(1, pl:GetBoneCount() - 1)
				pl.m_FatManBones[n] = b
			end

			--remove duplicates
			local hash = {}
			local res = {}
			for _, v in pairs(pl.m_FatManBones) do
				if not hash[v] then
					hash[v] = true
					res[#res+1] = v
				end
			end
			pl.m_FatManBones = res
		end

		--also play a gross sound :D
		if pl.m_FatManScale ~= scales[1] then
			EmitSound("physics/body/body_medium_break".. math.random(2,4) ..".wav", pl:GetPos(), 1, CHAN_AUTO, 1, 100, 0, pl.m_FatManScale.scale * 35)
		end
	end
end

function CLASS:BuildBonePositions(pl)
	if not pl:Alive() then
		pl.m_FatManScale = nil
		return
	end

	if not pl.m_FatManScale or CurTime() >= pl.m_FatManScaleNext then
		CreateBoneScales(pl)
	end

	local scale = Vector(pl.m_FatManScale.scale,pl.m_FatManScale.scale,pl.m_FatManScale.scale)
	--local scale = Vector(2,2,2)
	for _, bone in ipairs(pl.m_FatManBones) do
		pl:ManipulateBoneScale(bone, scale)
	end
end

CLASS.Base = "_base"

CLASS.Name = "Wraith"
CLASS.TranslationName = "class_wraith"
CLASS.Type = ZTYPE_MINIBOSS

CLASS.SWEP = "weapon_zsz_wraith"
CLASS.Model = Model("models/player/zelpa/stalker.mdl")

CLASS.Speed = 150
CLASS.Health = 200
CLASS.Points = 5

CLASS.VoicePitch = 0.65

CLASS.PainSounds = {Sound("npc/barnacle/barnacle_pull1.wav"), Sound("npc/barnacle/barnacle_pull2.wav"), Sound("npc/barnacle/barnacle_pull3.wav"), Sound("npc/barnacle/barnacle_pull4.wav")}
CLASS.DeathSounds = {Sound("zombiesurvival/wraithdeath1.ogg"), Sound("zombiesurvival/wraithdeath2.ogg"), Sound("zombiesurvival/wraithdeath3.ogg"), Sound("zombiesurvival/wraithdeath4.ogg")}

CLASS.NoShadow = true
CLASS.IgnoreTargetAssist = true
CLASS.RenderMode = RENDERMODE_TRANSALPHA -- Prevents flashlight shadows

CLASS.BloodColor = BLOOD_COLOR_MECH

local ACT_HL2MP_RUN_KNIFE = ACT_HL2MP_RUN_KNIFE
local ACT_HL2MP_WALK_CROUCH_KNIFE = ACT_HL2MP_WALK_CROUCH_KNIFE
local ACT_HL2MP_IDLE_CROUCH_FIST = ACT_HL2MP_IDLE_CROUCH_FIST
local ACT_HL2MP_IDLE_KNIFE = ACT_HL2MP_IDLE_KNIFE

local math_ceil = math.ceil
local math_min = math.min
local math_Clamp = math.Clamp

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	return true
end
function CLASS:CalcMainActivity(pl, velocity)
	if pl:WaterLevel() >= 3 then
		return self.act_Swim, -1
	end

	local len = velocity:Length2DSqr()
	if len <= 1 then
		if pl:Crouching() and pl:OnGround() then
			return ACT_HL2MP_IDLE_CROUCH_FIST, -1
		end

		return ACT_HL2MP_IDLE_KNIFE, -1
	end

	if pl:Crouching() and pl:OnGround() then
		return ACT_HL2MP_WALK_CROUCH_KNIFE, -1
	end

	if len < 2800 then
		return ACT_HL2MP_WALK_KNIFE, -1
	end

	return ACT_HL2MP_RUN_KNIFE, -1
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local len = velocity:Length()
	if len > 1 then
		--pl:SetPlaybackRate(math_min(len / maxseqgroundspeed * 0.666, 3))
		pl:SetPlaybackRate(math_min(len / maxseqgroundspeed, 3))
	else
		pl:SetPlaybackRate(1)
	end

	return true
end

function CLASS:GetAlpha(pl)
	local wep = pl:GetActiveWeapon()
	local mul = 1
	local rbmul = 1
	local team = MySelf and MySelf:IsValidLivingHuman() and TEAM_HUMAN or TEAM_UNDEAD

	if wep:IsValid() and wep.GetAlphaMul then
		mul = wep:GetAlphaMul()
		rbmul = team == TEAM_UNDEAD and 1/(mul + 0.1) or 1
	end

	local eyepos = EyePos()
	local nearest = pl:WorldSpaceCenter()
	local norm = nearest - eyepos
	norm:Normalize()
	local dot = EyeVector():Dot(norm)

	local vis = mul * (dot * 0.4 + pl:GetVelocity():Length() / self.Speed / 2 - eyepos:Distance(nearest) / 400) * dot

	return math_Clamp(vis, team == TEAM_UNDEAD and 0.2 or 0, 0.7), rbmul
end

function CLASS:DescribeStats()
	local wep = weapons.GetStored(self.SWEP)

	txt = table.concat({
		translate.Format("health_x",self:CalcMaxHealth()), "\n",
		translate.Format("speed_x", self.Speed) , "\n",
		((wep.CanClimb) and (translate.Get("can_climb") .. "\n") or ("")),
		translate.Get("hard_to_see"), "\n"
	})

	return txt
end

if SERVER then
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
		local effectdata = EffectData()
			effectdata:SetOrigin(pl:GetPos())
			effectdata:SetNormal(pl:GetForward())
			effectdata:SetEntity(pl)
		util.Effect("death_wraith", effectdata, nil, true)

		return true
	end
end

if CLIENT then
	CLASS.Icon = "zombiesurvival/killicons/wraithv2"
end

function CLASS:PrePlayerDraw(pl)
	--pl:RemoveAllDecals()

	local alpha, rbmul = self:GetAlpha(pl)
	if alpha == 0 then return true end

	render.SetBlend(alpha)
	render.SetColorModulation(0.1 * rbmul, 0.1, 0.1 * rbmul)
	render.SuppressEngineLighting(true)
end

function CLASS:PostPlayerDraw(pl)
	render.SuppressEngineLighting(false)
	render.SetColorModulation(1, 1, 1)
	render.SetBlend(1)
end

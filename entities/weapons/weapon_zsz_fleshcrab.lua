SWEP.Base = "weapon_zsz_basezombie"
DEFINE_BASECLASS("weapon_zsz_basezombie")

SWEP.PrintName = "Flesh Crab"

SWEP.ViewModel = "models/weapons/v_knife_t.mdl"
SWEP.WorldModel = ""

local STATE_NORMAL = 1
local STATE_LEAP = 2
local STATE_SPIT_WINDUP = 3

SWEP.Attack1 = {
  SpeedMul = 0.25,
  WindupTime = 0,
  WinddownTime = 0.5,
  Type = ZATTACK_LEAP,
  LeapDamage = 3,
  LeapSpeed = 550,
  LeapSize = 4,
  LeapDamageType = DMG_SLASH,
  LeapCanInterrupt = false,
  LeapCanAirControl = false,
  PlayAttackSound = function(swep)
		swep:EmitSound("NPC_HeadCrab.Attack")
  end,
  PlayHitSound = function(swep)
    swep:EmitSound("NPC_HeadCrab.Bite")
  end
}

SWEP.Attack2 = {
  SpeedMul = 0.5,
  WindupTime = 0.5,
  WinddownTime = 0,
  Type = ZATTACK_SPECIAL,
  PlayAttackSound = function(self)
  end,
  DoOverrideDescriptor = true,
	GetDescriptorText = function(self)
    return table.concat({
      translate.Get("dies_to_build_nest"), "\n"
    })
  end
}

SWEP.Attack3 = {
  SpeedMul = 0,
  WindupTime = 0.5,
  WinddownTime = 0.5,
  Type = ZATTACK_SPECIAL,
  PlayAttackSound = function(self)
    self:EmitSound("physics/body/body_medium_impact_hard"..math.random(6)..".wav", 70, math.random(110, 120), nil, CHAN_AUTO)
  end,
  SearchRange = 50,
  DoOverrideDescriptor = true,
	GetDescriptorText = function(self)
    return table.concat({
      translate.Get("destroys_nearby_nests"), "\n"
    })
  end
}

SWEP.BuildAttack = {
  SpeedMul = 0,
  WindupTime = 2,
  WinddownTime = 0,
  Type = ZATTACK_SPECIAL,
  PlayAttackSound = function(swep)
    swep:GetOwner():EmitSound("npc/barnacle/barnacle_die2.wav", 75, 140, 1, CHAN_VOICE)
  end
}

//other stuff
function SWEP:Initialize()
	self:HideViewAndWorldModel()
  self.BuildSound = CreateSound(self, "npc/antlion/charge_loop1.wav")
  self.BuildSound:PlayEx(0, 100)
end
function SWEP:OnRemove()
  self.BuildSound:Stop()
end

function SWEP:Think()
  self.BaseClass.Think(self)

  if not self:GetOwner():KeyDown(IN_ATTACK2) then
    self:StopPlacingStuff()
  end
end

function SWEP:OnStartAttack(Attack)
  if Attack == self.Attack1 then
    --this is the leap
    self:SetAttackState(STATE_LEAP)
  elseif Attack == self.Attack2 then
    self:StartPlacingStuff()
  elseif Attack == self.BuildAttack then
    self:GetOwner():SetMoveType(MOVETYPE_NONE)
  end
end
function SWEP:OnResolveAttack(Attack)
  if Attack == self.Attack2 then
    if SERVER then
      self:TryBuilding()
    end
  elseif Attack == self.BuildAttack then
    self:StopPlacingStuff()
    self:GetOwner():SetMoveType(MOVETYPE_WALK)
    self:SpawnNest()
    self:GetOwner():Kill()
  elseif Attack == self.Attack3 && SERVER then
    local targs = ents.FindInSphere(self:GetOwner():GetPos(),Attack.SearchRange)
    for _, ent in pairs(targs) do
      if ent:GetClass() == "prop_creepernest" then
        ent:TakeDamage(100,self:GetOwner(),self)
      end
    end
  end
end
function SWEP:SetIsLeaping(isLeaping)
	self:SetDTBool(1,isLeaping)

  if not isLeaping then
    self:SetAttackState(STATE_NORMAL)
  end
end
function SWEP:CheckLeapCollision(Attack)
	local owner = self:GetOwner()

	local traces = owner:CompensatedZombieMeleeTrace(8,12,shootpos, owner:GetForward())
	local damage = (Attack.LeapDamage or 0) * CalcMeleeDamageScale(GetTracesNumPlayers(traces))
	if self:IsAlting() and self.Alt.DamageDealtMul then
		damage = damage * self.Alt.DamageDealtMul
	end

	local hit = false
	for _, trace in ipairs(traces) do
		if not trace.Hit then continue end

		if not trace.HitWorld then
			local ent = trace.Entity
			if ent and ent:IsValid() then
				hit = true
				self:MeleeHit(ent, trace, damage, Attack.LeapForceScale or 1, Attack.LeapDamageType or DMG_SLASH )
			end
		end
	end

	if hit then
		self:SetIsLeaping(false)
		if not self.ActiveLeap.LeapCanInterrupt then
			self:SetNextIdle(CurTime() + (self.ActiveLeap.WinddownTime or 0))
		end

		if IsFirstTimePredicted() then
			if Attack.PlayHitSound then
				Attack.PlayHitSound(self)
			else
				self:PlayDefaultHitSound()
			end
		end
	end
end
function SWEP:StartPlacingStuff()
  if not SERVER then return end
  if self:GetIsPlacing() then return end
  self:SetIsPlacing(true)

  self.BuildSound:ChangeVolume(0.45,0.5)

  local owner = self:GetOwner()
  if owner and owner:IsValid() then
    owner:GiveStatus("ghost_flesh_nest")
  end
end
function SWEP:StopPlacingStuff()
  if not SERVER then return end
  if not self:GetIsPlacing() then return end
  self:SetIsPlacing(false)

  self.BuildSound:ChangeVolume(0,0.5)

  local owner = self:GetOwner()
  if owner and owner:IsValid() then
    owner:RemoveStatus("ghost_flesh_nest", false, true)
  end
end
function SWEP:GetIsPlacing()
  return self:GetDTBool(5)
end
function SWEP:SetIsPlacing(isGhost)
  self:SetDTBool(5,isGhost)
end

/*
  im using a redundant state machine here instead of interacting with the base
  zombie one because this gets called every frame for animations so it needs to
  be faster. does this need to be networked??? maybe not but it's cheap so I'll
  leave it for the minute
*/
function SWEP:SetAttackState(state)
  self:SetDTInt(4,state)
end
function SWEP:GetAttackState()
  self:GetDTInt(4)
end
function SWEP:ShouldPlaySpitAnimation()
  return self:GetAttackState() == STATE_SPIT_WINDUP
end
function SWEP:ShouldPlayLeapAnimation()
  return self:GetAttackState() == STATE_LEAP
end

function SWEP:TryBuilding()
  local owner = self:GetOwner()
  local allzombies = team.GetPlayers(TEAM_UNDEAD)
  local pos = owner:WorldSpaceCenter()
	local ang = owner:EyeAngles()
	ang.pitch = 0
	ang.roll = 0
	local forward = ang:Forward()
	local right = ang:Right()
  local endpos = pos + forward * 32

  local uid = owner:UniqueID()
  local count = 0
  local personal_count = 0
  for _, ent in pairs(ents.FindByClass("prop_creepernest")) do
		if ent.OwnerUID == uid then
			personal_count = personal_count + 1
		end
		count = count + 1
	end

  if count >= GAMEMODE.MaxNests then
		if CurTime() >= self.NextMessage then
			self.NextMessage = CurTime() + 2
			owner:CenterNotify(COLOR_RED, translate.ClientGet(owner, "there_are_too_many_nests"))
		end
		return
	end

	if personal_count >= GAMEMODE.MaxPlayerNests then
		self:SendMessage("you_have_made_too_many_nests")
		return
	end

  tr = util.TraceLine({start = endpos, endpos = endpos + Vector(0,0,-48), filter = allzombies, mask = MASK_PLAYERSOLID})
	local hitnormal = tr.HitNormal
	local z = hitnormal.z
	if not tr.HitWorld or tr.HitSky or z < 0.75 then
		self:SendMessage("not_enough_room_for_a_nest")
		return
	end

  local hitpos = tr.HitPos

  self.HitNormal = hitnormal
  self.HitPos = hitpos

  local spawnpositions = {
		Vector(17, 17, 0),
		Vector(-17, -17, 0),
		Vector(17, 17, 64),
		Vector(-17, -17, 64)
	}
	for _, spos in pairs(spawnpositions) do
		if bit.band(util.PointContents(hitpos + spos), CONTENTS_SOLID) == CONTENTS_SOLID then
			self:SendMessage("not_enough_room_for_a_nest")
			return
		end
	end

	for _, ent in pairs(team.GetValidSpawnPoint(TEAM_UNDEAD)) do
		if ent.Disabled then continue end

		if util.SkewedDistance(ent:GetPos(), hitpos, 1.5) < GAMEMODE.CreeperNestDistBuildZSpawn then
			self:SendMessage("too_close_to_a_spawn")
			return
		end
	end

	-- See if there's a nest nearby.
	for _, ent in pairs(ents.FindByClass("prop_creepernest")) do
		if util.SkewedDistance(ent:GetPos(), hitpos, 1.5) <= GAMEMODE.CreeperNestDistBuildNest then
			self:SendMessage("too_close_to_another_nest")
			return
		end
	end

  for _, sigil in pairs(ents.FindByClass("prop_obj_sigil")) do
		if util.SkewedDistance(sigil:GetPos(), hitpos, 1.5) <= GAMEMODE.CreeperNestDistBuildNest then
			self:SendMessage("too_close_to_uncorrupt")
			return
		end
	end

	for _, human in pairs(team.GetPlayers(TEAM_HUMAN)) do
		if util.SkewedDistance(human:GetPos(), hitpos, 1.5) <= GAMEMODE.CreeperNestDistBuild then
			self:SendMessage("too_close_to_a_human")
			return
		end
	end

  -- I didn't make this check where trigger_hurt entities are. Rather I made it check the time since the last time you were hit with a trigger_hurt.
  -- I'm not sure if it's possible to check if a trigger_hurt is enabled or disabled through the Lua bindings.
  if owner.LastHitWithTriggerHurt and CurTime() < owner.LastHitWithTriggerHurt + 2 then
    return
  end
  self:TryAttack(self.BuildAttack,true)
end
function SWEP:SpawnNest()
  local hitnormal = self.HitNormal
  local hitpos = self.HitPos

  local ent = ents.Create("prop_creepernest")
  if ent:IsValid() then
    nestang = hitnormal:Angle()
    nestang:RotateAroundAxis(nestang:Right(), 270)

    ent:SetPos(hitpos)
    ent:SetAngles(nestang)
    ent:Spawn()

    ent.OwnerUID = uid
    ent:SetNestOwner(owner)
    ent:SetNestBuilt(true)

    ent:EmitSound("physics/flesh/flesh_bloody_break.wav")

    local name = self:GetOwner():Name()
    for _, pl in pairs(team.GetPlayers(TEAM_UNDEAD)) do
      pl:CenterNotify(COLOR_GREEN, translate.ClientFormat(pl, "nest_built_by_x", name))
    end

    net.Start("zs_nestbuilt")
    net.Broadcast()
  end
end
function SWEP:SendMessage(msg, friendly)
	if not self.NextMessage or CurTime() >= self.NextMessage then
		self.NextMessage = CurTime() + 2
		self:GetOwner():CenterNotify(friendly and COLOR_GREEN or COLOR_RED, translate.ClientGet(self:GetOwner(), msg))
	end
end
function SWEP:CancelBuilding()
  self:GetOwner():SetMoveType(MOVETYPE_NONE)
end

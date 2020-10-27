SWEP.Base = "weapon_zsz_basezombie"
DEFINE_BASECLASS("weapon_zsz_basezombie")

SWEP.PrintName = "Flesh Creeper"


SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

SWEP.Alt = {
  Lift = 15,
  MaxUpSpeed = 250,
  MaxFuel = 2,
  CanAttack = true
}

SWEP.AltLeapAttack = {
  WindupTime = 0,
  WinddownTime = 0,
  Type = ZATTACK_LEAP,
  LeapSpeed = 350,
  LeapMinVertical = 0.45,
  LeapCanAirControl = true,
  LeapCanInterrupt = true,
  LeapDamage = 0,
  PlayAttackSound = function(swep)
  	swep:EmitSound("physics/body/body_medium_impact_hard"..math.random(6)..".wav", 70, math.random(110, 120), nil, CHAN_AUTO)
  end
}

SWEP.Attack1 = {
  WindupTime = 0,
  WinddownTime = 1,
  Type = ZATTACK_MELEE,
  PlayAttackSound = function(self)
  end,
  PlayHitSound = function(self)
    self:EmitSound("physics/body/body_medium_impact_hard"..math.random(6)..".wav", 70, math.random(110, 120), nil, CHAN_AUTO)
  end,
}

SWEP.Attack2 = {
  WindupTime = 0.5,
  WinddownTime = 0.5,
  Type = ZATTACK_SPECIAL,
  PlayAttackSound = function(self)
    self:EmitSound("npc/antlion/land1.wav", 65, 140, 0.65)
  end
}


SWEP.AltStartTime = 0

function SWEP:PlayAltStartSound()
	self:GetOwner():EmitSound("player/suit_sprint.wav")
end

function SWEP:Initialize()
	self:HideViewAndWorldModel()
  hook.Add("OnPlayerHitGround",self,function(pl, inwater, hitfloater, speed)
    self:OnPlayerHitGround(pl, inwater, hitfloater, speed)
  end)
  self:SetFuel(self.Alt.MaxFuel)
end
function SWEP:OnResolveAttack(Attack)
  if Attack ~= self.Attack2 then return end

  if SERVER then
    self:TryBuilding()
  end
end
function SWEP:OnStartAlting()
  self:TryAttack(self.AltLeapAttack)
  self.AltStartTime = CurTime()
end
function SWEP:OnStopAlting()
  local fuelUsed = CurTime() - self.AltStartTime
  self:SetFuel(self:GetFuel() - fuelUsed)
end
function SWEP:Move(mv)
  if self:IsAlting() then
    local owner = self:GetOwner()

    local vel = mv:GetVelocity()
    if vel.z < self.Alt.MaxUpSpeed then
      vel.z = math.min(vel.z + self.Alt.Lift,self.Alt.MaxUpSpeed)
      mv:SetVelocity(vel)
    end

    return true
  end
end

function SWEP:AltUse()
	if not self:IsIdle() and not self.Alt.CanAttack then
		self:SetAlting(ALTSTATE_ENABLING)
	elseif self:GetFuel() > 0 then
    self:StartAlting()
	end
end
function SWEP:AltThink()
  if not self:IsAlting() then return end

  local fuel = self:GetFuel() - (CurTime() - self.AltStartTime)

  if fuel <= 0 then
    self:SetFuel(0)
    self:StopAlting()
  end

  return self.BaseClass.AltThink(self)
end

function SWEP:OnPlayerHitGround(pl, inwater, hitfloater, speed)
  self:StopAlting()
  self:SetFuel(self.Alt.MaxFuel)
end
function SWEP:SetFuel(fuel)
  self:SetDTFloat(7,fuel)
end
function SWEP:GetFuel(fuel)
  return self:GetDTFloat(7)
end

if not SERVER then return end

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

    print(1)
		return
	end

	if personal_count >= GAMEMODE.MaxPlayerNests then
		self:SendMessage("you_have_made_too_many_nests")

    print(2)
		return
	end

  tr = util.TraceLine({start = endpos, endpos = endpos + Vector(0,0,-48), filter = allzombies, mask = MASK_PLAYERSOLID})
	local hitnormal = tr.HitNormal
	local z = hitnormal.z
	if not tr.HitWorld or tr.HitSky or z < 0.75 then
		self:SendMessage("not_enough_room_for_a_nest")
    print(3)
		return
	end

  local hitpos = tr.HitPos

  for x = -20, 20, 20 do
    for y = -20, 20, 20 do
      local start = endpos + x * right + y * forward
      tr = util.TraceLine({start = start, endpos = endpos, filter = allzombies, mask = MASK_PLAYERSOLID})
      if not tr.HitWorld or tr.HitSky or math.abs(tr.HitNormal.z - z) >= 0.2 then
        self:SendMessage("not_enough_room_for_a_nest")
        print(4)
        --return
      end
    end
  end


  local spawnpositions = {
		Vector(17, 17, 0),
		Vector(-17, -17, 0),
		Vector(17, 17, 64),
		Vector(-17, -17, 64)
	}
	for _, spos in pairs(spawnpositions) do
		if bit.band(util.PointContents(hitpos + spos), CONTENTS_SOLID) == CONTENTS_SOLID then
			self:SendMessage("not_enough_room_for_a_nest")
      print(5)
			return
		end
	end

	for _, ent in pairs(team.GetValidSpawnPoint(TEAM_UNDEAD)) do
		if ent.Disabled then continue end

		if util.SkewedDistance(ent:GetPos(), hitpos, 1.5) < GAMEMODE.CreeperNestDistBuildZSpawn then
			self:SendMessage("too_close_to_a_spawn")
      print(6)
			return
		end
	end

	-- See if there's a nest nearby.
	for _, ent in pairs(ents.FindByClass("prop_creepernest")) do
		if util.SkewedDistance(ent:GetPos(), hitpos, 1.5) <= GAMEMODE.CreeperNestDistBuildNest then
			self:SendMessage("too_close_to_another_nest")
      print(7)
			return
		end
	end

  for _, sigil in pairs(ents.FindByClass("prop_obj_sigil")) do
		if sigil:GetSigilCorrupted() then continue end

		if util.SkewedDistance(sigil:GetPos(), hitpos, 1.5) <= GAMEMODE.CreeperNestDistBuildNest then
			self:SendMessage("too_close_to_uncorrupt")
      print(8)
			return
		end
	end

	for _, human in pairs(team.GetPlayers(TEAM_HUMAN)) do
		if util.SkewedDistance(human:GetPos(), hitpos, 1.5) <= GAMEMODE.CreeperNestDistBuild then
      print(9)
			self:SendMessage("too_close_to_a_human")
			return
		end
	end

  -- I didn't make this check where trigger_hurt entities are. Rather I made it check the time since the last time you were hit with a trigger_hurt.
  -- I'm not sure if it's possible to check if a trigger_hurt is enabled or disabled through the Lua bindings.
  if owner.LastHitWithTriggerHurt and CurTime() < owner.LastHitWithTriggerHurt + 2 then
    print(10)
    return
  end

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

    owner:KillSilent()
  end

  print(11)
end

function SWEP:SendMessage(msg, friendly)
	if not self.NextMessage or CurTime() >= self.NextMessage then
		self.NextMessage = CurTime() + 2
		self:GetOwner():CenterNotify(friendly and COLOR_GREEN or COLOR_RED, translate.ClientGet(self:GetOwner(), msg))
	end
end

SWEP.Base = "weapon_zsz_basezombie_sck"
DEFINE_BASECLASS("weapon_zsz_basezombie_sck")

SWEP.PrintName = "Demonic Gorilla"

SWEP.ViewModel = Model("models/weapons/v_pza.mdl")
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.ShowWorldModel = false
SWEP.WElements = {}

SWEP.Alt = nil

SWEP.MaxFlaps = 5
SWEP.Flaps = 0
SWEP.NextFlap = 0
SWEP.FlapSpeedVertical = 250
SWEP.FlapSpeedHorizontal = 380
SWEP.Slams = 0

SWEP.Nasties = 0

SWEP.NextSlam = 0
SWEP.ESize = 250

SWEP.Attack1 = {
  WindupTime = 0.9,
  WinddownTime = 0.7,
  AnimationDelay = 0.35,
  Type = ZATTACK_MELEE,
  MeleeDamage = 40,
  MeleeForceScale = 1,
  MeleeDamageType = DMG_SLASH,
  MeleeDoPreHit = true,
  MeleeReach = 75,
  MeleeSize = 4.5,
  LeapSpeed = 1050,
  AttackAnim = ACT_VM_HITCENTER,
  PlayAttackSound = function(swep)
    swep:EmitSound("NPC_PoisonZombie.ThrowWarn")
  end
}

SWEP.Attack2 = {
	WindupTime = 1,
	WinddownTime = 1,
	AnimationDelay = 0.4,
	Type = ZATTACK_RANGED,
	RangedProjectile = "projectile_demonic",
	RangedNumShots = 5,
	RangedCone = 15,
	RangedProjectileSpeed = 450,
	PlayAttackSound = function(swep)
		swep:EmitSound("npc/barnacle/barnacle_crunch2.wav",85, 40)
	end,
  DoOverrideDescriptor = true,
  GetDescriptorText = function(self)
    local shotcount = (BULLETPATTERNS[self.RangedNumShots] and #BULLETPATTERNS[self.RangedNumShots]) or self.RangedNumShots
    return table.concat({
      "launches 5 poison projectiles that are very close together \n"
    })
  end
}

function SWEP:DescribeAlt()
 local alttext = "Sprouts fragile wings which can flap 5 times before falling apart. \n If it attacks while flying it will launch it's self at a very high speed at the cost of it's wings."
 return alttext
end

function SWEP:PlayHitSound()
	self:EmitSound("npc/zombie/claw_strike"..math.random(3)..".wav")
end

function SWEP:OnResolveAttack(Attack)
  local owner = self:GetOwner()
  if Attack == self.Attack1 && self:GetFlightState(1) == 1 && !owner:IsOnGround() && owner:WaterLevel() < 2  && CurTime() > self.NextFlap then
    local dir = owner:GetAimVector() * 2
    self.Slams = 1
    if Attack.LeapMinVertical then
      dir.z = math.max(Attack.LeapMinVertical, dir.z)
    end
    if dir:LengthSqr() > 1 then
      dir:Normalize()
    end
    owner:SetGroundEntity(NULL)
    owner:SetVelocity(dir * Attack.LeapSpeed)
    self:StopFlight()
  end
end


function SWEP:Think()
	self.BaseClass.Think(self)

  self:CheckIfForFlapsAndSlams()
  if self.Nasties >= 0 then
    self:MakeNasties(1)
  end
  self:ShouldDrawWings()
end


function SWEP:AltUse()
  self:TryFlight()
end

function SWEP:MakeNasties(n)
  local owner = self:GetOwner()
  if SERVER then
    for i=1, n do
    	local filter = {owner}

      for i = 1,3 do
        local ang = owner:EyeAngles()
        ang:RotateAroundAxis(ang:Forward(),math.random(-180,180))
        ang:RotateAroundAxis(ang:Up(),math.random(-180,180))
        local finalDir = ang:Forward()
    	self:EasyRayBasedProjectile("RBP_DEMONIC", owner, owner:GetShootPos(), finalDir, filter)
      end
    end
    owner:EmitSound("physics/body/body_medium_break3.wav",40,math.random(50,100))
    owner:EmitSound("npc/scanner/scanner_blip1.wav",30,math.random(45,255))
    self.Nasties = self.Nasties - 1
  end
end

function SWEP:CheckIfForFlapsAndSlams()
  local owner = self:GetOwner()
  local tr = util.TraceHull({
    start = owner:GetPos(),
    endpos = owner:GetPos() + (owner:GetVelocity():GetNormalized() * 20),
    filter = owner,
    mins = Vector(-15,-15,-15),
    maxs = Vector(15,15,15)
  })

  if tr.Hit && tr.Entity:IsWorld() && owner:GetVelocity():Length() > 500 && self.NextSlam < CurTime()  && self.Slams > 0 then
    local effectdata = EffectData()
      effectdata:SetOrigin(owner:GetPos())
    util.Effect("explosion_demonicslam", effectdata)
    owner:ViewPunch(Angle(math.random(-15,15),math.random(-15,15),math.random(-15,15)))
    for _, pl in pairs(ents.FindInSphere(owner:GetPos(), self.ESize)) do
      if pl:IsValidLivingHuman() then
        pl:AddPoisonDamage(15,owner)
        pl:TakeSpecialDamage(5, DMG_GENERIC, owner, self)
        pl:GiveStatus("knockdown", 1)
      end
    end
    self.Slams = 0
    self.NextSlam = CurTime() + 2
  end


  if self:GetFlightState() == 0 && owner:GetGravity() < 1 then
    owner:SetGravity(1)
  elseif self:GetFlightState() == 1 then
    if self.Flaps <= 0 then self:StopFlight() end
    if !owner:IsOnGround() then
      if owner:KeyPressed(IN_JUMP) && CurTime() > self.NextFlap then
        self:Flap()
      end
    end
  end
end

function SWEP:TryFlight()
  local owner = self:GetOwner()
  if self:GetFlightState() == 0 && self:GetNextStateTime() < CurTime() then
    self:StartFlight()
  else
    owner:ViewPunch(Angle(0,0,math.random(-.2,.2)))
    for i = 1, 15 do
      owner:EmitSound("physics/concrete/concrete_block_impact_hard".. math.random(1,3) ..".wav",85,math.random(45,255))
    end
  end
end

function SWEP:StartFlight()
  local owner = self:GetOwner()
  owner:SetGravity(0.25)
  self:SetFlightState(1)
  self.Flaps = self.MaxFlaps
  self.Nasties = 50
  self.NextFlap = CurTime() + .15
end

function SWEP:StopFlight()
	local owner = self:GetOwner()
	self:EmitSound("physics/body/body_medium_break3.wav",55,50)
	self:SetDTFloat(2,CurTime() + 10)
	self:SetDTInt(1,0)
  self.Nasties = 100
  self.Flaps = 0
	owner:ViewPunch( Angle( -10, 0, math.random(-5,5) ) )
end

function SWEP:Flap()
  local owner = self:GetOwner()
  local vel = owner:GetVelocity()
  local aimvec = owner:GetAimVector()
  aimvec = Vector(aimvec.x,aimvec.y,0):GetNormalized()
	owner:SetVelocity(Vector(-vel.x + aimvec.x*self.FlapSpeedHorizontal,-vel.y +aimvec.y*self.FlapSpeedHorizontal,-vel.z +self.FlapSpeedVertical))
	self.Nasties = self.Nasties + 35
  self.NextFlap = CurTime() + 0.1
  self.Flaps = self.Flaps - 1
  owner:ViewPunch( Angle( 2, 0, 0 ) )
end

function SWEP:PlayAltStartSound()
	self:GetOwner():EmitSound("npc/barnacle/barnacle_die2.wav",180,80)
end


function SWEP:ShouldDrawWings()
  if CLIENT && self:GetFlightState() == 1 then
    self.WElements = {
  	 ["mouth"] = { type = "Model", model = "models/Gibs/Fast_Zombie_Legs.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "head", pos = Vector(-0.348, 0.279, -1.599), angle = Angle(115.609, 12.975, 0), size = Vector(0.367, 0.367, 0.009), color = Color(165, 165, 161, 255), surpresslightning = false, material = "models/charple/charple1_sheet", skin = 0, bodygroup = {} },
     ["rightEye"] = { type = "Model", model = "models/props/cs_office/snowman_eye1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "head", pos = Vector(-7.854, -8.954, 5.076), angle = Angle(22.208, -122.889, 47.299), size = Vector(1.304, 1.304, 1.304), color = Color(255, 130, 130, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
  	 ["rightEyeLid"] = { type = "Model", model = "models/props/cs_office/snowman_eye1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "rightEye", pos = Vector(0.054, -0.41, 0), angle = Angle(0, 0, 0), size = Vector(1.59, 1.59, 1.59), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/charple/charple1_sheet", skin = 0, bodygroup = {} },
  	 ["head"] = { type = "Model", model = "models/headcrabblack.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "", pos = Vector(5.714, -4.527, 0), angle = Angle(10.519, 180, -92.338), size = Vector(0.754, 0.754, 0.754), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/charple/charple1_sheet", skin = 0, bodygroup = {} },
  	 ["LeftEyeLid"] = { type = "Model", model = "models/props/cs_office/snowman_eye1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "leftEye", pos = Vector(0, 0.243, 0.481), angle = Angle(-0.839, -3.211, 5.026), size = Vector(1.598, 1.598, 1.598), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/charple/charple1_sheet", skin = 0, bodygroup = {} },
  	 ["LeftEyePupil"] = { type = "Model", model = "models/props/cs_office/snowman_eye1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "leftEye", pos = Vector(0.225, -0.464, -0.634), angle = Angle(0, 0, 0), size = Vector(0.632, 0.632, 0.632), color = Color(0, 0, 0, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
     ["leftEye"] = { type = "Model", model = "models/props/cs_office/snowman_eye1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "head", pos = Vector(-6.565, 9.225, -0.461), angle = Angle(23.561, 107.385, -11.777), size = Vector(1.304, 1.304, 1.304), color = Color(255, 117, 117, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
  	 ["rightEyePupil"] = { type = "Model", model = "models/props/cs_office/snowman_eye1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "rightEye", pos = Vector(-0.145, 0.652, 0), angle = Angle(0, 0, 0), size = Vector(0.629, 0.629, 0.629), color = Color(0, 0, 0, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} }
    }
  else
    self.WElements = {}
  end
end

--get/set
function SWEP:GetFlightState()
	return self:GetDTInt(1)
end

function SWEP:SetFlightState(state)
	self:SetDTInt(1,state)
end

function SWEP:GetNextStateTime()
	return self:GetDTFloat(2)
end

function SWEP:SetNextStateTime(time)
	self:SetDTFloat(2,time)
end

if CLIENT then
  SWEP.ViewModelFOV = 47
end

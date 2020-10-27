SWEP.Base = "weapon_zsz_basezombie"
DEFINE_BASECLASS("weapon_zsz_basezombie")

SWEP.PrintName = "Wraith"

SWEP.ViewModel = Model("models/weapons/v_pza.mdl")
SWEP.WorldModel = ""

local STEALTH_DISABLED = 0
local STEALTH_ENABLED = 1
local STEALTH_ENABLING = 2
local STEALTH_DISABLING = 3


SWEP.Alt = {
  SpeedMul = 2,
  Regen = 15,
	GetDescriptorText = function(self)
		return table.concat({
			translate.Get("completely_invisible"), "\n",
			translate.Get("delayed_transition"), "\n"
		})
	end
}
SWEP.Attack1 = {
  WindupTime = 0.8,
  WinddownTime = 1,
  AnimationDelay = 0.25,
  Type = ZATTACK_MELEE,
  MeleeDamage = 45,
  MeleeForceScale = 2,
  MeleeDamageType = DMG_SLASH,
  MeleeDoPreHit = true,
  MeleeReach = 48,
  MeleeSize = 4.5,
  PlayAttackSound = function(swep)
  	swep:EmitSound("npc/antlion/distract1.wav")
  end,
  PlayHitSound = function(swep)
    swep:EmitSound("ambient/machines/slicer"..math.random(4)..".wav", 75, 80, nil, CHAN_AUTO)
  end,
  PlayMissSound = function(swep)
    swep:EmitSound("npc/zombie/claw_miss"..math.random(2)..".wav", 75, 80, nil, CHAN_AUTO)
  end,
}

SWEP.StealthInTime = 1 --time in seconds over which you become invisible
SWEP.StealthOutTime = 1 --time in seconds over which you become visible
SWEP.AlphaStealthedMul = 0
SWEP.AlphaUnstealthedMul = 1
SWEP.AlphaAttackingMul = 3

function SWEP:GetAlphaMul()
  local state = self:GetStealthState()

  if not self:IsIdle() then
    return self.AlphaAttackingMul
  end

  if state == STEALTH_ENABLED then return self.AlphaStealthedMul
  elseif state == STEALTH_DISABLED then return self.AlphaUnstealthedMul
  elseif state == STEALTH_ENABLING then
    local t = (self:GetNextStateTime() - CurTime())/self.StealthInTime
    return Lerp(t,self.AlphaStealthedMul,self.AlphaUnstealthedMul)
  else
    local t = (self:GetNextStateTime() - CurTime())/self.StealthOutTime

    return Lerp(t,self.AlphaUnstealthedMul,self.AlphaStealthedMul)
  end
end

function SWEP:TryToggleStealth()
  local state = self:GetStealthState()

  if state == STEALTH_DISABLED then
    self:StartStealth()
  elseif state == STEALTH_ENABLED then
    self:StopStealth()
  end
end
function SWEP:StartStealth()
  self:EmitSound("npc/ichthyosaur/water_growl5.wav")
  self:SetStealthState(STEALTH_ENABLING)
  self:SetNextStateTime(CurTime() + self.StealthInTime)
end
function SWEP:ResolveStealth()
  self:StartAlting()
  self:SetStealthState(STEALTH_ENABLED)
end
function SWEP:StopStealth()
  self:EmitSound("npc/scanner/scanner_nearmiss2.wav",75,50)
  self:StopAlting()
  self:SetStealthState(STEALTH_DISABLING)
  self:SetNextStateTime(CurTime() + self.StealthOutTime)
end
function SWEP:ResolveStopStealth()
  self:SetStealthState(STEALTH_DISABLED)
end

--overwritten functions
function SWEP:Think()
  local state = self:GetStealthState()

  if state == STEALTH_DISABLING and self:GetNextStateTime() <= CurTime() then
    self:ResolveStopStealth()
  elseif state == STEALTH_ENABLING and self:GetNextStateTime() <= CurTime() then
    self:ResolveStealth()
  end

  self.BaseClass.Think(self)
end
function SWEP:PrimaryAttack()
  local state = self:GetStealthState()

  if state == STEALTH_DISABLED then
    self:TryAttack(self.Attack1)
  elseif state == STEALTH_ENABLED then
    self:TryToggleStealth()
  end
end
function SWEP:SecondaryAttack()
  self:TryToggleStealth()
end
function SWEP:AltUse()
  self:TryToggleStealth()
end
function SWEP:AltRelease()
end
function SWEP:PlayAltStartSound()
	self:GetOwner():EmitSound("player/suit_sprint.wav")
end
--get/set
function SWEP:GetStealthState()
  return self:GetDTInt(4)
end
function SWEP:SetStealthState(state)
  self:SetDTInt(4,state)
end
function SWEP:GetNextStateTime()
  return self:GetDTFloat(5)
end
function SWEP:SetNextStateTime(time)
  self:SetDTFloat(5,time)
end

if CLIENT then

  SWEP.ViewModelFOV = 47

  function SWEP:PreDrawViewModel(vm)
  	self:GetOwner():CallZombieFunction0("PrePlayerDraw")
  end

  function SWEP:PostDrawViewModel(vm)
  	self:GetOwner():CallZombieFunction0("PostPlayerDraw")
  end
end

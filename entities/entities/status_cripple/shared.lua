AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "status__base"
ENT.MinSpeedLost = 0.2
ENT.MaxSpeedLost = 0.5
ENT.MaxDuration = 7
ENT.Ephemeral = true

AccessorFuncDT(ENT, "Duration", "Float", 0)
AccessorFuncDT(ENT, "StartTime", "Float", 4)

function ENT:PlayerSet()
	self:SetStartTime(CurTime())
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	hook.Add("Move", self, self.Move)
end

function ENT:Move(pl, move)
	if pl ~= self:GetOwner() then return end

	--local timeElapsedFrac = (CurTime() - self:GetStartTime())/self.MaxDuration
	--local speedEffect = Lerp(timeElapsedFrac,self.MaxSpeedLost,self.MinSpeedLost)

	local timeLeftFrac = (self:GetDuration() - CurTime() + self:GetStartTime())/self.MaxDuration
	local speedEffect = Lerp(timeLeftFrac,self.MinSpeedLost,self.MaxSpeedLost)

	move:SetMaxSpeed(move:GetMaxSpeed() * (1 - speedEffect))
	move:SetMaxClientSpeed(move:GetMaxSpeed())
end

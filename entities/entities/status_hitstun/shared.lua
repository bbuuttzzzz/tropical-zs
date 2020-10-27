AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "status__base"

AccessorFuncDT(ENT, "Duration", "Float", 0)
AccessorFuncDT(ENT, "StartTime", "Float", 4)
--DTFloat(1): the last time a zombie was killed.

function ENT:PlayerSet()
	self:SetStartTime(CurTime())
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	hook.Add("Move", self, self.Move)
end

function ENT:Move(pl, move)
	if pl ~= self:GetOwner() then return end

	local maxSpeedFrac = 0.25

	local timeElapsedFrac = (CurTime() - self:GetStartTime())/self:GetDuration()
	local speedEffectFrac = Lerp(timeElapsedFrac,1,maxSpeedFrac)

	move:SetMaxSpeed(move:GetMaxSpeed() * speedEffectFrac)
	move:SetMaxClientSpeed(move:GetMaxSpeed())
end

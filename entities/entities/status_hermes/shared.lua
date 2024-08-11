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

	self.CachedBackpedalPenaltyMul = self:GetOwner().BackpedalPenaltyMul
	hook.Add("Move", self, self.Move)
end

function ENT:Move(pl, move)
	if pl ~= self:GetOwner() then return end

	local maxBonusSpeed = 150

	local timeElapsedFrac = (CurTime() - self:GetStartTime())/self:GetDuration()
	local speedEffect = maxBonusSpeed * (1 - timeElapsedFrac)
	pl.BackpedalPenaltyMul = timeElapsedFrac * self.CachedBackpedalPenaltyMul

	move:SetMaxSpeed(move:GetMaxSpeed() + speedEffect)
	move:SetMaxClientSpeed(move:GetMaxSpeed())
end

function ENT:OnRemove()
	self:GetOwner().BackpedalPenaltyMul = self.CachedBackpedalPenaltyMul

	self.BaseClass.OnRemove(self)
end
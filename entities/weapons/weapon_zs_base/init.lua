INC_SERVER()

AddCSLuaFile("animations.lua")

function SWEP:EasyRayBasedProjectile(index, owner, shootpos, dir, _filter)

	local Bullet = GAMEMODE.RBP_BULLETS[index]

	local UID = CurTime() *math.random(-500,500)

	local lifetime = CurTime() + (GAMEMODE.RBP_BULLETS[index].lifetime and GAMEMODE.RBP_BULLETS[index].lifetime or 20)

	local vel = dir * (Bullet.speed and Bullet.speed or 800)

	local acc = Bullet.acc and Bullet.acc or	Vector(0,0,0)

	local filter = _filter and _filter or {	owner	}

	local func = Bullet.func and Bullet.func or nil

	local size = Bullet.size and Bullet.size or Vector(5,5,5)

	local mask = Bullet.mask and Bullet.mask or MASK_SHOT_HULL

	GAMEMODE:CreateRayBasedProjectile(UID, owner, lifetime, shootpos, vel, acc, filter, func, size, mask, index)

end

function SWEP:Think()
	if self:GetIronsights() and not self:GetOwner():KeyDown(IN_ATTACK2) then
		self:SetIronsights(false)
	end

	if self:GetReloadFinish() > 0 then
		if CurTime() >= self:GetReloadFinish() then
			self:FinishReload()
		end
	elseif self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(self.IdleActivity)
	end
end

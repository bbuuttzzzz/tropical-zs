INC_SERVER()

function SWEP:Eat()
	local owner = self:GetOwner()

	local max = owner:GetMaxHealth()


	local healing = self.FoodHealth

	owner:HealPlayer(owner,healing,0)

	self:TakePrimaryAmmo(1)
	
	if self:GetPrimaryAmmoCount() <= 0 then
		owner:StripWeapon(self:GetClass())
	end
end

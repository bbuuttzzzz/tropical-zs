CLASS.Base = "_base"

CLASS.Name = "Tar Zombie"
CLASS.TranslationName = "class_tar_zombie"
CLASS.Type = ZTYPE_MINIBOSS

CLASS.SWEP = "weapon_zsz_tar_zombie"
CLASS.Speed = 165
CLASS.Health = 1000
CLASS.Points = 15

local math_ceil = math.ceil

function CLASS:CalcMainActivity(pl, velocity)
	if pl:WaterLevel() >= 3 then
		return self.act_Swim, -1
	end

	local wep = pl:GetActiveWeapon()
	if wep:IsValid() then
		if wep.IsClimbing and wep:IsClimbing() then
			return self.act_Climb, -1
		elseif wep.IsLeaping and wep:IsLeaping() then
			return self.act_Leap, -1
		elseif wep.IsAlting and wep:IsAlting() and not pl:Crouching() then
			return self.act_Walk - 1 + math_ceil((CurTime() / 3 + pl:EntIndex()) % 3), -1
		end
	end

	if velocity:Length2DSqr() <= 1 then
		if pl:Crouching() and pl:OnGround() then
			return self.act_Crouch, -1
		end

		return self.act_Walk, -1
	end

	if pl:Crouching() and pl:OnGround() then
		return self.act_CrouchWalk - 1 + math_ceil((CurTime() / 4 + pl:EntIndex()) % 3), -1
	end


	return self.act_Alt, -1
end

if CLIENT then
	CLASS.Icon = "tropical/killicons/tar_zombie"

	local matFlesh = Material("Models/Charple/Charple1_sheet")
	function CLASS:PrePlayerDraw(pl)
		render.ModelMaterialOverride(matFlesh)
	end

	function CLASS:PostPlayerDraw(pl)
		render.ModelMaterialOverride()
	end
end

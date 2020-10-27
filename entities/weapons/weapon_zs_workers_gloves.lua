SWEP.Base = "weapon_zs_basemelee"
DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.PrintName = "Worker's Gloves"
SWEP.Description = "Pick up and hold up to 3 objects at once. Left click: grab. Right click: drop."

SWEP.MinWeightClass = WEIGHT_FEATHER
SWEP.MaxWeightClass = 125


SWEP.DeploySpeedMultiplier = 3

SWEP.MaxSlots = 3

local EMPTY_MODEL = "models/props_phx/misc/smallcannonball.mdl"
SWEP.HoldType = "slam"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.UseHands = false
SWEP.ViewModel = "models/weapons/v_hands.mdl"
SWEP.WorldModel = "models/weapons/w_eq_eholster.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.AlwaysDrawDroppedWorldModel = true
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 5.369), angle = Angle(0, 0, -12.223) }
}
SWEP.VElements = {
	[1] = { type = "Model", model = EMPTY_MODEL, bone = "ValveBiped.Bip01_Spine", rel = "", pos = Vector(10.909, -11.929, 7.126), angle = Angle(0, 0, 0), size = Vector(0.05, 0.05, 0.05), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	[2] = { type = "Model", model = EMPTY_MODEL, bone = "ValveBiped.Bip01_Spine", rel = "", pos = Vector(11.548, -11.778, 1.623), angle = Angle(0, 0, 0), size = Vector(0.05, 0.05, 0.05), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	[3] = { type = "Model", model = EMPTY_MODEL, bone = "ValveBiped.Bip01_Spine", rel = "", pos = Vector(11.625, -11.867, -4.059), angle = Angle(0, 0, 0), size = Vector(0.05, 0.05, 0.05), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	[1] = { type = "Model", model = EMPTY_MODEL, bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.65, 3.634, -0.16), angle = Angle(0, 0, 0), size = Vector(0.05, 0.05, 0.05), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

function SWEP:Holster()
	if SERVER then
		while self:GetFilledSlots() > 0 do
			local couldDrop = self:DropEntity()
			if not couldDrop then break end
		end
	end

	return BaseClass.Holster(self)
end

function SWEP:Deploy()
	self:SetFilledSlots(0)
	self.StoredEntities = {}

	return BaseClass.Deploy(self)
end

function SWEP:GetWalkSpeed()
	local owner = self:GetOwner()
	return (GAMEMODE.PlayerSpeed - (owner.WeaponWeightMul or 1) * self:GetCurrentWeight())
end

function SWEP:GetCurrentWeight()
	return (self:GetFilledSlots()/self.MaxSlots) * (self.MaxWeightClass - self.MinWeightClass) + self.MinWeightClass
end

local function SaveProp(prop)
	local propTab = {}

	propTab.Ent = duplicator.CopyEntTable(prop)
	propTab.BarricadeHealth = prop:GetBarricadeHealth()
	propTab.MaxBarricadeHealth = prop:GetMaxBarricadeHealth()
	propTab.BarricadeRepairs = prop:GetMaxBarricadeRepairs()

	return propTab
end

local function MakeSavedProp(propTab)
	local ent = ents.Create(propTab.Ent.Class)
	duplicator.DoGeneric(ent,propTab.Ent)
	ent:SetBarricadeHealth(propTab.BarricadeHealth)
	ent:SetMaxBarricadeHealth(propTab.MaxBarricadeHealth)
	ent:SetBarricadeRepairs(propTab.BarricadeRepairs)

	return ent
end

function SWEP:CanPickUp(ent)
	if self:GetFilledSlots() >= self.MaxSlots then return false end
	return GAMEMODE:HumanCanCarry(self:GetOwner(),ent)
end

function SWEP:PickUpEntity(ent)
	local newslot = self:GetFilledSlots() + 1
	self:SetFilledSlots(newslot)
	self.StoredEntities[newslot] = SaveProp(ent)

	self:SetSlotModel(newslot,ent:GetModel())

	ent:Remove()
end

function SWEP:DropEntity()
	local slot = self:GetFilledSlots()
	if slot <= 0 then return true end

	local aimvec = self:GetOwner():GetAimVector()
	local shootpos = self:GetOwner():GetShootPos()
	local tr = util.TraceLine({start = shootpos, endpos = shootpos + aimvec * 32, filter = self:GetOwner()})

	local ent = MakeSavedProp(self.StoredEntities[slot])
	if ent and ent:IsValid() then
		local ang = aimvec:Angle()
		ang:RotateAroundAxis(ang:Forward(), 90)
		ent:SetPos(tr.HitPos)
		ent:SetAngles(ang)
		ent:Spawn()
		ent:SetHealth(350)
		ent.NoDisTime = CurTime() + 15
		ent.NoDisOwner = self:GetOwner()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(math.min(phys:GetMass(), 50))
			phys:SetVelocityInstantaneous(self:GetOwner():GetVelocity())
		end
		ent:SetPhysicsAttacker(self:GetOwner())
		self:SetFilledSlots(slot - 1)
		return true
	end
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + 0.3)

	if self:GetFilledSlots() <= 0 then return end

	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(75, 80))

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.IdleAnimation = CurTime() + math.min(self.Primary.Delay, self:SequenceDuration())

	if not SERVER then return end

	self:GetOwner():RestartGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)
	self:DropEntity()
end

function SWEP:SecondaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + 0.3)

	if not SERVER then return end

	local ent = self:GetOwner():GetEyeTrace().Entity
	if self:CanPickUp(ent) then
		self:EmitSound("physics/metal/weapon_impact_soft" .. math.random(1,3) .. ".wav")
		self:PickUpEntity(ent)
	end
end

function SWEP:DrawWorldModel()
	local time = UnPredictedCurTime() * 45
	local vang = self.WElements[1].angle
	vang.p = time % 360
	vang.y = vang.p

	self.BaseClass.DrawWorldModel(self)
end
SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel

function SWEP:PostDrawViewModel(vm)
	local time = UnPredictedCurTime() * 45

	for i, slot in ipairs(self.VElements) do
		local vang = slot.angle
		vang.p = (time + 120 * i) % 360
		vang.y = vang.p
	end
end

function SWEP:UpdateDrawModels()
	local time = UnPredictedCurTime() * 45

	for i, slot in ipairs(self.VElements) do
		local vang = slot.angle
		vang.p = (time + 120 * i) % 360
		vang.y = vang.p
	end

	for i = 1, self.MaxSlots do
		if i > self:GetFilledSlots() then
			self.VElements[i].modelEnt:SetModel(EMPTY_MODEL)
		else
			self.VElements[i].model = self:GetSlotModel(i)
		end

		if i == self:GetFilledSlots() then
			self.VElements[i].modelEnt:SetModel(self:GetSlotModel(i))
			self.WElements[1].modelEnt:SetModel(self:GetSlotModel(i))
		end
	end
	if self:GetFilledSlots() == 0 then
		self.WElements[1].modelEnt:SetModel(EMPTY_MODEL)
	end
end

function SWEP:Think()
	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end

	if CLIENT and (not self.LastRefresh or self:GetLastRefresh() > self.LastRefresh) then
		self.LastRefresh = CurTime()
		self:UpdateDrawModels()
	end
end

function SWEP:SetFilledSlots(slots)
	self:SetLastRefresh(CurTime())
	self:SetDTInt(4,slots)
	local owner = self:GetOwner()
	if CLIENT or not owner then return end
	owner:ResetSpeed()
	owner:SendLua("MySelf:ResetSpeed()")
end

function SWEP:GetFilledSlots()
	return self:GetDTInt(4)
end

function SWEP:SetSlotModel(slot,model)
	if slot ~= 1 and slot ~= 2 and slot ~= 3 then return end
	self:SetLastRefresh(CurTime())
	self:SetDTString(slot,model)
end

function SWEP:GetSlotModel(slot)
	if slot ~= 1 and slot ~= 2 and slot ~= 3 then return end
	return self:GetDTString(slot)
end

function SWEP:SetLastRefresh(time)
	self:SetDTFloat(5,time)
end
function SWEP:GetLastRefresh()
	return self:GetDTFloat(5)
end

SWEP.Base = "weapon_zsz_basezombie_sck"
DEFINE_BASECLASS("weapon_zsz_basezombie_sck")

SWEP.PrintName = "Fat Man"

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.HealthySpeedFrac = 1
SWEP.HealthyBeepDelay = 1
SWEP.HealthyHealthFrac = 0.8
SWEP.UnhealthySpeedFrac = 1.3
SWEP.UnhealthyBeepDelay = 0.166
SWEP.UnhealthyHealthFrac = 0.2



if CLIENT then
	SWEP.ShowWorldModel = false
	SWEP.WElements = {
		["gib"] = { type = "Model", model = "models/gibs/antlion_gib_small_2.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "", pos = Vector(-0.519, -12.018, 1.396), angle = Angle(73.636, -139.092, 36.234), size = Vector(0.56, 1.014, 0.56), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/flesh", skin = 0, bodygroup = {} },
		["spine1"] = { type = "Model", model = "models/gibs/antlion_gib_small_1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "", pos = Vector(0, -13.264, 2.4), angle = Angle(0, 63.112, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/flesh", skin = 0, bodygroup = {} },
		["light"] = { type = "Sprite", sprite = "effects/blueflare1", bone = "ValveBiped.Bip01_Spine2", rel = "", pos = Vector(15.737, -15.62, -8.162), size = { x = 10, y = 10 }, color = Color(255, 0, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["Bomb"] = { type = "Model", model = "models/props_phx/mk-82.mdl", bone = "ValveBiped.Bip01_Spine2", rel = "", pos = Vector(8.166, -8.987, 3.635), angle = Angle(26.882, -146.105, 164.804), size = Vector(0.202, 0.6, 0.6), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["gib+"] = { type = "Model", model = "models/gibs/antlion_gib_small_2.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "", pos = Vector(-3.899, -11.891, -1.451), angle = Angle(11.616, 38.97, -68.722), size = Vector(0.986, 1.429, 1.067), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/flesh", skin = 0, bodygroup = {} },
		["spine2"] = { type = "Model", model = "models/gibs/antlion_gib_small_1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "spine1", pos = Vector(0, -2.118, -0.08), angle = Angle(-24.077, -1.15, -20.519), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/flesh", skin = 0, bodygroup = {} }
	}
end

function SWEP:Initialize()
	BaseClass.Initialize(self)
	self:HideViewModel()
end

SWEP.Attack1 = {
  WindupTime = 0.40,
  WinddownTime = 0.75,
  Type = ZATTACK_RANGED,
  RangedProjectile = "projectile_bloodbag",
  RangedNumShots = 10,
  RangedCone = 20,
	SelfDamage = 100,
  RangedProjectileSpeed = 380,
  PlayAttackSound = function(swep)
    swep:EmitSound("npc/antlion_guard/angry"..math.random(3)..".wav", 75, 140)
  end,
	GetDescriptorText = function(self)
    return table.concat({
			translate.Format("applies_x_to_y_bleed",5,5*self.RangedNumShots), "\n",
      translate.Format("takes_x_self_damage",self.SelfDamage), "\n"
    })
  end
}

function SWEP:OnResolveAttack(Attack)
	if SERVER and Attack == self.Attack1 then
		local owner = self:GetOwner()
		local dmginfo = DamageInfo()
			dmginfo:SetAttacker(owner)
			dmginfo:SetDamageType(DMG_GENERIC)
			dmginfo:SetDamageCustom(1)
			dmginfo:SetDamage(Attack.SelfDamage)
			dmginfo:SetDamageForce(Vector(0,0,0))
		owner:TakeDamageInfo(dmginfo)
	end
end

function SWEP:Move(mv)
	local owner = self:GetOwner()
	local hpfrac = owner:Health() / owner:GetMaxHealth()

	local spdfrac = Lerp2(hpfrac,self.HealthyHealthFrac,self.UnhealthyHealthFrac,self.HealthySpeedFrac,self.UnhealthySpeedFrac)
	local spd = spdfrac * mv:GetMaxSpeed()
	mv:SetMaxSpeed(spd)
	mv:SetMaxClientSpeed(spd)
end

function SWEP:Think()
	local owner = self:GetOwner()

	if (not self.NextBeep or self.NextBeep < CurTime()) then
		local hpfrac = owner:Health() / owner:GetMaxHealth()
		local delay = Lerp2(hpfrac,self.HealthyHealthFrac,self.UnhealthyHealthFrac,self.HealthyBeepDelay,self.UnhealthyBeepDelay)
		self.NextBeep = CurTime() + delay
		self:EmitSound("weapons/c4/c4_beep1.wav", 90, 100, 1, CHAN_AUTO)
	end

	if (not self.NextGeig or self.NextGeig < CurTime()) then
		--geiger1: 0.040s
		--geiger2: 0.283s
		--geiger3: 0.289s
		local rand = math.random(1,3)
		local sound = "player/geiger" .. rand .. ".wav"
		self.NextGeig = CurTime() + ((rand == 1) and 0.04 or 0.283)

		self:EmitSound(sound, 1, CHAN_AUTO, 1, 65, 0, math.random(50,200), CHAN_VOICE)

	end

	BaseClass.Think(self)
end

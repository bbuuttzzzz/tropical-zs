CLASS.Base = "_base"

CLASS.Name = "Necromancer"
CLASS.TranslationName = "class_necromancer"
CLASS.Type = ZTYPE_BOSS

CLASS.Model = Model("models/player/breen.mdl")

CLASS.SWEP = "weapon_zsz_necromancer"
CLASS.Speed = 210
CLASS.Health = 1000
CLASS.Points = 20

local ACT_HL2MP_SWIM_MELEE = ACT_HL2MP_SWIM_MELEE
local ACT_HL2MP_IDLE_CROUCH_MELEE = ACT_HL2MP_IDLE_CROUCH_MELEE
local ACT_HL2MP_WALK_MELEE = ACT_HL2MP_WALK_MELEE
local ACT_HL2MP_WALK_CROUCH_MELEE = ACT_HL2MP_WALK_CROUCH_MELEE

function CLASS:CalcMainActivity(pl, velocity)
	if pl:WaterLevel() >= 3 then
		return ACT_HL2MP_SWIM_MELEE, -1
	end

	local wep = pl:GetActiveWeapon()

	if velocity:Length2DSqr() <= 1 then
		if pl:Crouching() and pl:OnGround() then
			return ACT_HL2MP_IDLE_CROUCH_MELEE, -1
		end

		return ACT_HL2MP_WALK_MELEE, -1
	end

	if pl:Crouching() and pl:OnGround() then
		return ACT_HL2MP_WALK_CROUCH_MELEE, -1
	end

	return ACT_HL2MP_WALK_MELEE, -1
end

function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE, true)
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_RELOAD then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
		return ACT_INVALID
	end
end

function CLASS:Describe()
	//input.LookupBinding()
	/*
		so you have this table description that gets returned. each entry in this
		table gets added as its own richly formatted section. $ is the escape char
		and can hold the following values:
			$stats: gets put at the very start of the description with no header.
			$attack1/$attack2/$reload/$sprint: the header name gets replaced by the name
				of the key the player has bound to attack1/attack2/reload/sprint.
		all other entires get added with text of the same key added
	*/

	local wep = weapons.Get(self.SWEP)
	local description = {}

	description["$stats"] = self:DescribeStats()

	--don't need to check if these exist, will set to nil if it doesn't
	description["$attack1"] = table.concat({
		translate.Format("attack_claw",wep.MeleeDamage), "\n"
	})
	description["$attack2"] = table.concat({
		translate.Format("takes_x_self_damage",25), "\n",
		translate.Format("necro_ray",wep.Secondary.Damage), "\n",
		translate.Format("applies_x_poison",8), "\n",
		translate.Format("applies_x_cripple",15), "\n",
		translate.Format("necro_ray_heal",150), "\n"
	})
	description["$reload"] = table.concat({
		translate.Format("takes_x_self_damage",250), "\n",
		translate.Get("builds_dark_nest"), "\n"
	})

	return description
end

if CLIENT then
	CLASS.Icon = "tropical/killicons/necromancer"

  function CLASS:BuildBonePositions(pl)
    //shrink head
    pl:ManipulateBoneScale(6,Vector(.56,.56,.56))

		/*
		//shrink hand
    local bones = {11,47,48,49,50,51,52,53,54,55}
    local v = Vector(0.1,0.1,0.1)
    for i, bone in pairs(bones) do
      pl:ManipulateBoneScale(bone, v)
    end
		*/
  end
	function CLASS:PrePlayerDraw(pl)
		render.SetColorModulation(0.5, 0.9, 0.5)
	end

	function CLASS:PostPlayerDraw(pl)
		render.SetColorModulation(1, 1, 1)
	end
end

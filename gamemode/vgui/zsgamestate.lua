local PANEL = {}

function PANEL:Init()
	self.m_HumanCount = vgui.Create("DTeamCounter", self)
	self.m_HumanCount:SetTeam(TEAM_HUMAN)
	self.m_HumanCount:SetImage("zombiesurvival/humanhead")

	self.m_ZombieCount = vgui.Create("DTeamCounter", self)
	self.m_ZombieCount:SetTeam(TEAM_UNDEAD)
	self.m_ZombieCount:SetImage("zombiesurvival/zombiehead")

	self.m_Text1 = vgui.Create("DLabel", self)
	self.m_Text2 = vgui.Create("DLabel", self)
	self.m_Text3 = vgui.Create("DLabel", self)
	self.m_Text4 = vgui.Create("DLabel", self)
	self:SetTextFont("ZSHUDFontTiny")

	self.m_Text1.Paint = self.Text1Paint
	self.m_Text2.Paint = self.Text2Paint
	self.m_Text3.Paint = self.Text3Paint
	self.m_Text4.Paint = self.Text4Paint

	self:InvalidateLayout()
end

function PANEL:SetTextFont(font)
	self.m_Text1.Font = font
	self.m_Text1:SetFont(font)
	self.m_Text2.Font = font
	self.m_Text2:SetFont(font)
	self.m_Text3.Font = font
	self.m_Text3:SetFont(font)
	self.m_Text4.Font = font
	self.m_Text4:SetFont(font)

	self:InvalidateLayout()
end

function PANEL:PerformLayout()
	local hs = self:GetTall() * 0.5
	self.m_HumanCount:SetSize(hs, hs)
	self.m_ZombieCount:SetSize(hs, hs)
	self.m_ZombieCount:AlignTop(hs)

	local b = 2
	local ts = (self:GetTall() - 8*b) / 4
	self.m_Text1:SetWide(self:GetWide())
	self.m_Text1:SizeToContentsY()
	self.m_Text1:MoveRightOf(self.m_HumanCount, 12)
	self.m_Text1:AlignTop(b)
	self.m_Text2:SetWide(self:GetWide())
	self.m_Text2:SizeToContentsY()
	self.m_Text2:MoveRightOf(self.m_HumanCount, 12)
	self.m_Text2:AlignTop(2 * b + ts)
	self.m_Text3:SetWide(self:GetWide())
	self.m_Text3:SizeToContentsY()
	self.m_Text3:MoveRightOf(self.m_HumanCount, 12)
	self.m_Text3:AlignTop(2 * b + 2 * ts)
	self.m_Text4:SetWide(self:GetWide())
	self.m_Text4:SizeToContentsY()
	self.m_Text4:MoveRightOf(self.m_HumanCount, 12)
	self.m_Text4:AlignTop(2 * b + 3 * ts)
end

function PANEL:Text1Paint()
	local text
	local override = MySelf:IsValid() and GetGlobalString("hudoverride"..MySelf:Team(), "")

	if override and #override > 0 then
		text = override
	else
		local wave = GAMEMODE:GetWave()
		if GAMEMODE:IsEscapeSequence() then
			text = translate.Get(MySelf:IsValid() and MySelf:Team() == TEAM_UNDEAD and "prop_obj_exit_z" or "prop_obj_exit_h")
		elseif wave <= 0 then
			text = translate.Get("prepare_yourself")
		elseif GAMEMODE.ZombieEscape then
			text = translate.Get("zombie_escape")

			-- I'm gonna leave this as 2 for now, since it is 2 on NoX.
			--if GAMEMODE.RoundLimit > 0 then
				round = GAMEMODE.CurrentRound
				text = text .. " - " .. translate.Format("round_x_of_y", round, 2)
			--end
		else
			local maxwaves = GAMEMODE:GetNumberOfWaves()
			if maxwaves ~= -1 then
				text = translate.Format("wave_x_of_y", wave, maxwaves)
				if not GAMEMODE:GetWaveActive() then
					text = translate.Get("intermission").." - "..text
				end
			elseif not GAMEMODE:GetWaveActive() then
				text = translate.Get("intermission")
			end
		end
	end

	if text then
		draw.SimpleText(text, self.Font, 0, 0, COLOR_GRAY)
	end

	return true
end

function PANEL:Text2Paint()
	if GAMEMODE:GetWave() <= 0 then
		local col
		local timeleft = math.max(0, GAMEMODE:GetWaveStart() - CurTime())
		if timeleft < 10 then
			local glow = math.sin(RealTime() * 8) * 200 + 255
			col = Color(255, glow, glow)
		else
			col = COLOR_GRAY
		end

		draw.SimpleText(translate.Format("zombie_invasion_in_x", util.ToMinutesSecondsCD(timeleft)), self.Font, 0, 0, col)
	elseif GAMEMODE:GetWaveActive() then
		local waveend = GAMEMODE:GetWaveEnd()
		if waveend ~= -1 then
			local timeleft = math.max(0, waveend - CurTime())
			draw.SimpleText(translate.Format("wave_ends_in_x", util.ToMinutesSecondsCD(timeleft)), self.Font, 0, 0, 10 < timeleft and COLOR_GRAY or Color(255, 0, 0, math.abs(math.sin(RealTime() * 8)) * 180 + 40))
		end
	else
		local wavestart = GAMEMODE:GetWaveStart()
		if wavestart ~= -1 then
			local timeleft = math.max(0, wavestart - CurTime())
			draw.SimpleText(translate.Format("next_wave_in_x", util.ToMinutesSecondsCD(timeleft)), self.Font, 0, 0, 10 < timeleft and COLOR_GRAY or Color(255, 0, 0, math.abs(math.sin(RealTime() * 8)) * 180 + 40))
		end
	end

	return true
end

function PANEL:Text3Paint()
	if MySelf:IsValid() then
		if MySelf:Team() == TEAM_UNDEAD then
			local toredeem = GAMEMODE:GetRedeemBrains()
			if toredeem > 0 then
				if GAMEMODE:GetRedeemFever() and LASTHUMAN then
					if MySelf:Frags() > 0 then
						local rb = math.abs(math.sin(RealTime() * 8)) * 180 + 40
						col = Color(rb, 255, rb, 255)
						draw.SimpleText("CAN REDEEM CHAIN", self.Font, 0, 0, col)
					else
						local gb = math.abs(math.sin(RealTime() * 8)) * 180 + 40
						col = Color(255, gb, gb, 255)
						draw.SimpleText("STOP THE CHAIN", self.Font, 0, 0, col)
					end
				elseif MySelf:Frags() >= toredeem && not MySelf:IsBoss() then
					draw.SimpleText(translate.Get("press_f2_to_redeem"), self.Font, 0, 0, COLOR_WHITE)
				else
					draw.SimpleText(translate.Format("brains_eaten_x", MySelf:Frags().." / "..toredeem), self.Font, 0, 0, COLOR_SOFTRED)
				end
			else
				draw.SimpleText(translate.Format("brains_eaten_x", MySelf:Frags()), self.Font, 0, 0, COLOR_SOFTRED)
			end
		else
			--draw.SimpleText(translate.Format("points_x", MySelf:GetPoints().." / "..MySelf:Frags()), self.Font, 0, 0, COLOR_DARKRED)
			draw.SimpleText("Scrap: "..MySelf:GetScrap() .. "  Score: "..MySelf:Frags(), self.Font, 0, 0, COLOR_SOFTRED)
		end
	end

	return true
end

function PANEL:Text4Paint()
	if MySelf:IsValid() then
		if MySelf:Team() == TEAM_HUMAN then
			if GAMEMODE.IsUpgrade then
				local rb = math.abs(math.sin(RealTime() * 8)) * 180 + 40
				draw.SimpleText(translate.Get("press_f3_to_upgrade"), self.Font, 0, 0, Color(rb, 255, rb, 255))
			else
				local nextSupplyTime
				if GAMEMODE:GetWave() <= 0 then
					nextSupplyTime = GAMEMODE:GetWaveStart() + GAMEMODE:GetResupplyTime()
				else
					nextSupplyTime = GAMEMODE:GetNextResupply()
				end
				local timeLeft = math.max(0, nextSupplyTime - CurTime())

				local col
				if 10 >= timeLeft then
					local rb = math.abs(math.sin(RealTime() * 8)) * 180 + 40
					col = Color(rb, 255, rb, 255)
				else
					col = COLOR_GRAY
				end
				draw.SimpleText(translate.Format("next_resupply_x",util.ToMinutesSecondsCD(timeLeft)), self.Font, 0, 0, col)
			end
		else
			local txt
			local time = GAMEMODE:GetNextReinforcement()
			if time > CurTime() then
				local timeLeft = time - CurTime()

				local col = COLOR_GRAY
				if 10 >= timeLeft then
					local rb = math.abs(math.sin(RealTime() * 8)) * 180 + 40
					col = Color(rb, 255, rb, 255)
				end
				draw.SimpleText(translate.Format("next_reinforcements_x",util.ToMinutesSecondsCD(timeLeft)), self.Font, 0, 0, col)
			else
				draw.SimpleText(translate.Get("no_reinforcements"), self.Font, 0, 0, COLOR_GRAY)
			end
		end
	end

	return true
end

local matGradientLeft = CreateMaterial("gradient-l", "UnlitGeneric", {["$basetexture"] = "vgui/gradient-l", ["$vertexalpha"] = "1", ["$vertexcolor"] = "1", ["$ignorez"] = "1", ["$nomip"] = "1"})
function PANEL:Paint(w, h)
	surface.SetDrawColor(0, 0, 0, 180)
	surface.DrawRect(0, 0, w * 0.4, h)
	surface.SetMaterial(matGradientLeft)
	surface.DrawTexturedRect(w * 0.4, 0, w * 0.6, h)
	--surface.DrawLine(0, h - 1, w, h - 1)
	surface.SetDrawColor(0, 0, 0, 250)
	surface.SetMaterial(matGradientLeft)
	surface.DrawTexturedRect(0, h - 1, w, 1)

	return true
end

vgui.Register("ZSGameState", PANEL, "DPanel")

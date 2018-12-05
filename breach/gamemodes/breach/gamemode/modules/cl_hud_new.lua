local hide = {
	CHudHealth = true,
	CHudBattery = true,
	CHudAmmo = true,
	CHudSecondaryAmmo = true,
	CHudDeathNotice = true,
}

hook.Add( "HUDShouldDraw", "HideHUDElements", function( name )
	if name == "CHudWeaponSelection" and GetConVar( "br_new_eq" ):GetInt() == 1 then
		return false
	end
	if hide[ name ] then return false end
end )

local MATS = {
	menublack = Material("hud_scp/menublack.png"),
	blanc = Material("hud_scp/texture_blanc.png"),
	meter = Material("hud_scp/meter.png"),
	time = Material("hud_scp/timeicon.png"),
	user = Material("hud_scp/user.png"),
	scp = Material("hud_scp/scp.png"),
	ammo = Material("hud_scp/ammoicon.png"),
	mag = Material("hud_scp/magicon.png"),
	blink = Material("hud_scp/blinkicon.png"),
	hp = Material("hud_scp/hpicon.png"),
	sprint = Material("hud_scp/sprinticon.png"),
}

hook.Add( "HUDPaint", "Breach_HUD", function()
	if disablehud then return end
	if playing then return end
	local scale = hudScale
	local width = ScrW() * scale
	local height = ScrH() * scale
	local offset = ScrH() - height
	local ply = LocalPlayer()
	if ply:Alive() == false then return end

	if IsValid( ply ) then
		--spect box
		if ply:GTeam() == TEAM_SPEC then
			local ent = ply:GetObserverTarget()
			if IsValid(ent) then
				if ent:IsPlayer() then
					local w, h = 350, 35
					surface.SetDrawColor(255,255,255,255)
					surface.SetMaterial( MATS.menublack )
					surface.DrawTexturedRect( ScrW() / 2 - w / 2 , 0, w, h )
					draw.TextShadow( {
						text = string.sub(ent:Nick(), 1, 17),
						pos = { ScrW() / 2, 15 },
						font = "HealthAmmo",
						color = Color(255,255,255),
						xalign = TEXT_ALIGN_CENTER,
						yalign = TEXT_ALIGN_CENTER,
					}, 2, 255 )
				end
			end
		end 
		--Getting role and observer
		local role = "none"
		if not ply.GetNClass then
			player_manager.RunClass( ply, "SetupDataTables" )
		elseif LocalPlayer():GTeam() != TEAM_SPEC then
			role = GetLangRole(ply:GetNClass())
		else
			local obs = ply:GetObserverTarget()
			role = GetLangRole(ply:GetNClass())
			if IsValid(obs) then
				if obs.GetNClass != nil then
					role = "[REDACTED]"
					ply = obs
				end
			end
		end
		--apply stats
		local hp = ply:Health()
		local maxhp = ply:GetMaxHealth()
		local blink = blinkHUDTime
		local bd = GetConVar("br_time_blinkdelay"):GetFloat()
		if !LocalPlayer().Stamina then LocalPlayer().Stamina = 100 end
		local stamina = math.Round(LocalPlayer().Stamina)
		local exhausted = LocalPlayer().exhausted
		local color = gteams.GetColor(ply:GTeam())
		if ply:GTeam() == TEAM_CHAOS then
			color = Color(29, 81, 56)
		end
		--white bcg
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.blanc)
		surface.DrawTexturedRect( width * 0.015, height * 0.765 + offset, width * 0.3, height * 0.22)
		--main panel
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.menublack)
		surface.DrawTexturedRect( width * 0.016, height * 0.767 + offset, width * 0.198, height * 0.071)
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.menublack)
		surface.DrawTexturedRect( width * 0.016, height * 0.839 + offset, width * 0.198, height * 0.071)
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.menublack)
		surface.DrawTexturedRect( width * 0.016, height * 0.912 + offset, width * 0.198, height * 0.071)
		--left panel
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.menublack)
		surface.DrawTexturedRect( width * 0.215, height * 0.767 + offset, width * 0.099, height * 0.050)
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.menublack)
		surface.DrawTexturedRect( width * 0.215, height * 0.819 + offset, width * 0.099, height * 0.045)
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.menublack)
		surface.DrawTexturedRect( width * 0.215, height * 0.865 + offset, width * 0.099, height * 0.045)
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.menublack)
		surface.DrawTexturedRect( width * 0.215, height * 0.912 + offset, width * 0.099, height * 0.072)
		--info
		local timel = tostring( string.ToMinutesSeconds( cltime ) )
		local name = ply:GetName()
		local ammo = -1
		local mag = -1
		if ply:GetActiveWeapon() != nil then
			local wep = ply:GetActiveWeapon()
			if wep.Clip1 and wep:Clip1() > -1 then
				ammo = wep:Clip1()
				mag = ply:GetAmmoCount( wep:GetPrimaryAmmoType() )
			end
		end
		--time
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.time)
		surface.DrawTexturedRect( width * 0.23, height * 0.778 + offset, height * 0.03, height * 0.03)
		
		draw.Text( {
			text = timel,
			pos = { width * 0.275, height * 0.78 + offset },
			font = "HUDFontTitle",
			color = Color(255,255,255),
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_RIGHT,
		})
		--player name
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.user)
		surface.DrawTexturedRect( width * 0.26, height * 0.825 + offset, height * 0.02, height * 0.02)
		draw.Text( {
			text = string.sub(name, 1, 23),
			pos = { width * 0.265, height * 0.843 + offset },
			font = "HUDFontLittle",
			color = Color(255,255,255),
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_RIGHT,
		})
		--role
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.scp)
		surface.DrawTexturedRect( width * 0.26, height * 0.87 + offset, height * 0.02, height * 0.02)
		local ft = "HUDFontLittle"
		if string.len(role) > 25 then ft = "HUDFont" end
		draw.Text( {
			text = string.sub(role, 1, 30),
			pos = { width * 0.265, height * 0.888 + offset },
			font = ft,
			color = Color(255,255,255),
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_RIGHT,
		})
		--ammo
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.ammo)
		surface.DrawTexturedRect( width * 0.22, height * 0.915 + offset, height * 0.028, height * 0.028)
		if ammo < 0 then ammo = 0 end
		draw.Text( {
			text = ammo,
			pos = { width * 0.27, height * 0.917 + offset },
			font = "HUDFontMedium",
			color = Color(255,255,255),
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_RIGHT,
		})
		--mag
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.mag)
		surface.DrawTexturedRect( width * 0.22, height * 0.95 + offset, height * 0.028, height * 0.028)
		if mag < 0 then mag = 0 end
		draw.Text( {
			text = mag,
			pos = { width * 0.27, height * 0.952 + offset },
			font = "HUDFontMedium",
			color = Color(255,255,255),
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_RIGHT,
		})
		--blink icon & bar		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.blink)
		surface.DrawTexturedRect( width * 0.025, height * 0.785 + offset, height * 0.035, height * 0.035)
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.blanc)
		surface.DrawTexturedRect( width * 0.05, height * 0.785 + offset, width * 0.1525, height * 0.035)
		
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect( width * 0.051, height * 0.786 + offset, width * 0.1515, height * 0.033)
		local bbars = 0
		local bbars = blink / bd * 15
		if bbars > 15 then bbars = 15 end
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.meter)
		for i=1, bbars do
			surface.DrawTexturedRect( width * 0.052 + width * 0.01 * (i - 1), height * 0.7875 + offset, width * 0.009, height * 0.029)
		end
		blink = string.format("%.1f", blink)
		bd = string.format("%.1f", bd)
		draw.Text( {
			text = blink.." / ".. bd,
			pos = { width * 0.115, height * 0.82 + offset },
			font = "HUDFont",
			color = Color(255,255,255),
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_RIGHT,
		})
		--HP icon & bar		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.hp)
		surface.DrawTexturedRect( width * 0.025, height * 0.857 + offset, height * 0.035, height * 0.035)
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.blanc)
		surface.DrawTexturedRect( width * 0.05, height * 0.857 + offset, width * 0.1525, height * 0.035)
		
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect( width * 0.051, height * 0.858 + offset, width * 0.1515, height * 0.033)
		local hpb = math.Round(hp / maxhp * 15)
		if hpb > 15 then hpb = 15 end
		surface.SetDrawColor(255, 0, 0, 255)
		surface.SetMaterial(MATS.meter)
		for i=1, hpb do
			surface.DrawTexturedRect( width * 0.052 + width * 0.01 * (i - 1), height * 0.8595 + offset, width * 0.009, height * 0.029)
		end
		draw.Text( {
			text = hp.." / "..maxhp,
			pos = { width * 0.115, height * 0.893 + offset },
			font = "HUDFont",
			color = Color(255,255,255),
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_RIGHT,
		})
		--stamina icon/bar		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.sprint)
		surface.DrawTexturedRect( width * 0.025, height * 0.929 + offset, height * 0.035, height * 0.035)
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(MATS.blanc)
		surface.DrawTexturedRect( width * 0.05, height * 0.929 + offset, width * 0.1525, height * 0.035)
		
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect( width * 0.051, height * 0.930 + offset, width * 0.1515, height * 0.033)
		local staminab = math.Round(stamina / 100 * 15)
		if staminab > 15 then staminab = 15 end
		surface.SetDrawColor(0, 255, 0, 255)
		if exhausted then surface.SetDrawColor(160, 175, 75, 255) end
		surface.SetMaterial(MATS.meter)
		for i=1, staminab do
			surface.DrawTexturedRect( width * 0.052 + width * 0.01 * (i - 1), height * 0.9315 + offset, width * 0.009, height * 0.029)
		end
		draw.Text( {
			text = stamina.." / ".."100",
			pos = { width * 0.115, height * 0.965 + offset },
			font = "HUDFont",
			color = Color(255,255,255),
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_RIGHT,
		})
	end
	
end )
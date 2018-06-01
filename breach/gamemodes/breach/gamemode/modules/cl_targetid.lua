
function GM:HUDDrawTargetID()
	local trace = LocalPlayer():GetEyeTrace()
	if !trace.Hit then return end
	if !trace.HitNonWorld then return end
	
	local text = clang.class_unknown or "Unknown"
	local font = "TargetID"
	local ply =  trace.Entity
	
	local clr = color_white
	local clr2 = color_white
	
	if ply:IsPlayer() then
		if ply:Alive() == false then return end
		if ply:GetPos():Distance(LocalPlayer():GetPos()) > 500 then return end
		if not ply.GetNClass or not ply.GetLastRole then
			player_manager.RunClass( ply, "SetupDataTables" )
		end
		if ply:GTeam() == TEAM_SPEC then return end
		if ply:GetNClass() == ROLES.ROLE_SCP966 then
			local hide = true
			if IsValid(LocalPlayer():GetActiveWeapon()) then
				if LocalPlayer():GetActiveWeapon():GetClass() == "item_nvg" then
					hide = false
				end
			end
			if (LocalPlayer():GTeam() == TEAM_SCP) then
				hide = false
			end
			if hide == true then return end
		end
		if ply:GetNClass() == ROLES.ROLE_SCP9571 and LocalPlayer():GTeam() != TEAM_SCP then
			text = GetLangRole(ply:GetLastRole())
			clr = gteams.GetColor(ply:GetLastTeam())
			if !text or text == "" then
				text = clang.class_unknown or "Unknown"
			end
		elseif ply:GTeam() == TEAM_SCP then
			text = GetLangRole(ply:GetNClass())
			clr = gteams.GetColor(ply:GTeam())
		else
			for k,v in pairs(SAVEDIDS) do
				if v.pl == ply then
					if v.id != nil then
						if isstring(v.id) then
							text = v.pl.knownrole
							clr = gteams.GetColor(ply:GTeam())
							text = GetLangRole(v.pl.knownrole)
						end
					end
				end
			end
		end
		AddToIDS(ply)
	else
		return
	end
	
	local x = ScrW() / 2
	local y = ScrH() / 2 + 30

	local health = math.ceil( ply:Health() * 100 / math.max( 1, ply:GetMaxHealth() ) )

	draw.Text( {
		text = ply:Nick() .. " (" .. health .. "%)",
		pos = { x, y },
		font = "TargetID",
		color = clr2,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	})
	
	draw.Text( {
		text = text,
		pos = { x, y + 16 },
		font = "TargetID",
		color = clr,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	})
end

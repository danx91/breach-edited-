// Serverside file for all player related functions

function IsPremium( ply, silent )
	ply:SetNPremium( false )
	ply.Premium = false
	if CheckULXPremium( ply, silent ) == true then return end
	if GetConVar("br_premium_url"):GetString() == "" or GetConVar("br_premium_url"):GetString() == "none" then return end
	http.Fetch( GetConVar("br_premium_url"):GetString(), function( body, size, headers, code )
		if ( body == nil ) then return end
		local ID = string.find( tostring(body), "<ID64>"..ply:SteamID64().."</ID64>" )
			if ID != nil then
				ply.Premium = true
				ply:SetNPremium( true )
				if GetConVar("br_premium_display"):GetString() != "" and GetConVar("br_premium_display"):GetString() != "none" and !silent then
					print("Premium member "..ply:GetName().." has joined")
					PrintMessage(HUD_PRINTCENTER, string.format(GetConVar("br_premium_display"):GetString(), ply:GetName()))
				end
			end
	end,
	function( error )
		print("HTTP ERROR")
		print(error)
	end )
end

function CheckULXPremium( ply, silent )
	if GetConVar("br_ulx_premiumgroup_name"):GetString() == "" or GetConVar("br_ulx_premiumgroup_name"):GetString() == "none" then return end
	if !ply.CheckGroup then
		print( "To use br_ulx_premiumgroup_name you have to install ULX!" )
		return
	end
	local pgroups = string.Split( GetConVar("br_ulx_premiumgroup_name"):GetString(), "," )
	local ispremium
	for k,v in pairs( pgroups ) do
		if ply:CheckGroup( v ) then
			ispremium = true
			break
		end
	end
	if ispremium then
		ply.Premium = true
		ply:SetNPremium( true )
		if GetConVar("br_premium_display"):GetString() != "" and GetConVar("br_premium_display"):GetString() != "none" and !silent then
			print("Premium member "..ply:GetName().." has joined")
			PrintMessage(HUD_PRINTCENTER, string.format(GetConVar("br_premium_display"):GetString(), ply:GetName()))
		end
		return true
	end
end

function CheckStart()
	MINPLAYERS = GetConVar("br_min_players"):GetInt()
	if gamestarted == false and #GetActivePlayers() >= MINPLAYERS then
		RoundRestart()
	end
	if #GetActivePlayers() == MINPLAYERS and #GetActivePlayers() == #player.GetAll() then
		RoundRestart()
	end
	if gamestarted then
		BroadcastLua( 'gamestarted = true' )
	end
end

function GM:PlayerInitialSpawn( ply )
	ply:SetCanZoom( false )
	ply:SetNoDraw(true)
	ply.Active = false
	ply.freshspawn = true
	ply.isblinking = false
	ply.Premium = false
	if timer.Exists( "RoundTime" ) == true then
		net.Start("UpdateTime")
			net.WriteString(tostring(timer.TimeLeft( "RoundTime" )))
		net.Send(ply)
	end
	player_manager.SetPlayerClass( ply, "class_breach" )
	player_manager.RunClass( ply, "SetupDataTables" )
	IsPremium(ply)
	ply:SetActive( false )
	if ply:IsBot() then
		ply:SetActive( true )
	end
	--print( ply.ActivePlayer, ply:GetNActive() )
	CheckStart()
	if gamestarted then
		ply:SendLua( 'gamestarted = true' )
	end
end
/*
function GM:PlayerAuthed( ply, steamid, uniqueid )
	ply.Active = false
	ply.Leaver = "none"
	if prepring then
		ply:SetClassD()
	else
		ply:SetSpectator()
	end
end
*/
function GM:PlayerSpawn( ply )
	//ply:SetupHands()
	ply:SetTeam(1)
	ply:SetNoCollideWithTeammates(true)
	//ply:SetCustomCollisionCheck( true )
	if ply.freshspawn then
		ply:SetSpectator()
		ply.freshspawn = false
	end
	//ply:SetupHands()
end

function GM:PlayerSetHandsModel( ply, ent )
	local simplemodel = player_manager.TranslateToPlayerModelName( ply:GetModel() )
	local info = player_manager.TranslatePlayerHands( simplemodel )
	if ( info ) then
		if ply.handsmodel != nil then
			info.model = ply.handsmodel
		end
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end
end

function GM:DoPlayerDeath( ply, attacker, dmginfo )
	if (ply.noragdoll != true) then
		CreateRagdollPL(ply, attacker, dmginfo:GetDamageType())
	end
	ply:AddDeaths(1)
end


function GM:PlayerDeathThink( ply )
	if ply:GetNClass() == ROLES.ROLE_SCP076 and IsValid( SCP0761 ) then
		if ply.n076nextspawn and ply.n076nextspawn < CurTime() then
			--ply:SetSCP076()
			local scp = GetSCP( "SCP076" )
			if scp then
				scp:SetupPlayer( ply )
			end
		end
		return
	end
	if !ply:IsBot() and ply:GTeam() != TEAM_SPEC then
		ply:SetGTeam(TEAM_SPEC)
	end
	if ( ply:IsBot() || ply:KeyPressed( IN_ATTACK ) || ply:KeyPressed( IN_ATTACK2 ) || ply:KeyPressed( IN_JUMP ) || postround ) then
		ply:Spawn()
		ply:SetSpectator()
	end
end

function GM:PlayerNoClip( ply, desiredState )
	if ply:GTeam() == TEAM_SPEC and desiredState == true then return true end
end

function GM:PlayerDeath( victim, inflictor, attacker )
	net.Start( "Effect" )
		net.WriteBool( false )
	net.Send( victim )

	net.Start( "957Effect" )
		net.WriteBool( false )
	net.Send( victim )

	victim:SetModelScale( 1 )
	if attacker:IsPlayer() then
		print("[KILL] " .. attacker:Nick() .. " [" .. attacker:GetNClass() .. "] killed " .. victim:Nick() .. " [" .. victim:GetNClass() .. "]")
	end
	if victim:GetNClass() == ROLES.ROLE_SCP9571 then
		for k, v in pairs( player.GetAll() ) do
			if v:GetNClass() == ROLES.ROLE_SCP957 then
				v:TakeDamage( 500, attacker, inflictor)
			end
		end
	end
	if victim:GetNClass() == ROLES.ROLE_SCP076 and IsValid( SCP0761 ) and !postround then
		victim.n076nextspawn = CurTime() + 10
		return
	end
	victim:SetNClass(ROLES.ROLE_SPEC)
	if attacker != victim and postround == false and attacker:IsPlayer() then
		if attacker:IsPlayer() then
			if attacker:GTeam() == TEAM_GUARD then
				victim:PrintMessage(HUD_PRINTTALK, "You were killed by an MTF Guard: " .. attacker:Nick())
				if victim:GTeam() == TEAM_SCP then
					attacker:PrintMessage(HUD_PRINTTALK, "You've been awarded with 10 points for killing an SCP!")
					attacker:AddFrags(10)
				elseif victim:GTeam() == TEAM_CHAOS then
					attacker:PrintMessage(HUD_PRINTTALK, "You've been awarded with 5 points for killing a Chaos Insurgency member!")
					attacker:AddFrags(5)
				elseif victim:GTeam() == TEAM_CLASSD then
					attacker:PrintMessage(HUD_PRINTTALK, "You've been awarded with 2 points for killing a Class D Personell!")
					attacker:AddFrags(2)
				end
			elseif attacker:GTeam() == TEAM_CHAOS then
				victim:PrintMessage(HUD_PRINTTALK, "You were killed by a Chaos Insurgency Soldier: " .. attacker:Nick())
				if victim:GTeam() == TEAM_GUARD then 
					attacker:PrintMessage(HUD_PRINTTALK, "You've been awarded with 2 points for killing an MTF Guard!")
					attacker:AddFrags(2)
				elseif victim:GTeam() == TEAM_SCI then
					attacker:PrintMessage(HUD_PRINTTALK, "You've been awarded with 2 points for killing a Researcher!")
					attacker:AddFrags(2)
				elseif victim:GTeam() == TEAM_SCP then
					attacker:PrintMessage(HUD_PRINTTALK, "You've been awarded with 10 points for killing an SCP!")
					attacker:AddFrags(10)
				elseif victim:GTeam() == TEAM_CLASSD then
					attacker:PrintMessage(HUD_PRINTTALK, "Don't kill Class D Personell, you can capture them to get bonus points!")
					attacker:AddFrags(1)
				end
			elseif attacker:GTeam() == TEAM_SCP then
				victim:PrintMessage(HUD_PRINTTALK, "You were killed by an SCP: " .. attacker:Nick())
				attacker:PrintMessage(HUD_PRINTTALK, "You've been awarded with 2 points for killing " .. victim:Nick())
				attacker:AddFrags(2)
			elseif attacker:GTeam() == TEAM_CLASSD then
				victim:PrintMessage(HUD_PRINTTALK, "You were killed by a Class D: " .. attacker:Nick())
				if victim:GTeam() == TEAM_GUARD then 
					attacker:PrintMessage(HUD_PRINTTALK, "You've been awarded with 4 points for killing an MTF Guard!")
					attacker:AddFrags(4)
				elseif victim:GTeam() == TEAM_SCI then
					attacker:PrintMessage(HUD_PRINTTALK, "You've been awarded with 2 points for killing a Researcher!")
					attacker:AddFrags(2)
				elseif victim:GTeam() == TEAM_SCP then
					attacker:PrintMessage(HUD_PRINTTALK, "You've been awarded with 10 points for killing an SCP!")
					attacker:AddFrags(10)
				elseif victim:GTeam() == TEAM_CHAOS then
					attacker:PrintMessage(HUD_PRINTTALK, "You've been awarded with 2 points for killing a Chaos Insurgency member!")
					attacker:AddFrags(2)
				end
			elseif attacker:GTeam() == TEAM_SCI then
				victim:PrintMessage(HUD_PRINTTALK, "You were killed by a Researcher: " .. attacker:Nick())
				if victim:GTeam() == TEAM_SCP then
					attacker:PrintMessage(HUD_PRINTTALK, "You've been awarded with 10 points for killing an SCP!")
					attacker:AddFrags(10)
				elseif victim:GTeam() == TEAM_CHAOS then
					attacker:PrintMessage(HUD_PRINTTALK, "You've been awarded with 5 points for killing a Chaos Insurgency member!")
					attacker:AddFrags(5)
				elseif victim:GTeam() == TEAM_CLASSD then
					attacker:PrintMessage(HUD_PRINTTALK, "You've been awarded with 2 points for killing a Class D Personell!")
					attacker:AddFrags(2)
				end
			end
		end
	end
	roundstats.deaths = roundstats.deaths + 1
	local wasteam = victim:GTeam()
	victim:SetTeam(TEAM_SPEC)
	victim:SetGTeam(TEAM_SPEC)
	
	victim:DropAllWeapons()

	WinCheck()
	if !postround then
		if !IsValid( attacker ) or !attacker.GTeam then return end
		if attacker:GTeam() == wasteam then
			PunishVote( attacker, victim )
		elseif attacker:GTeam() == TEAM_GUARD then
			if wasteam == TEAM_SCI then
				PunishVote( attacker, victim )
			end
		elseif attacker:GTeam() == TEAM_SCI then
			if wasteam == TEAM_GUARD then
				PunishVote( attacker, victim )
			end
		elseif attacker:GTeam() == TEAM_CLASSD then
			if wasteam == TEAM_CHAOS then
				PunishVote( attacker, victim )
			end
		elseif attacker:GTeam() == TEAM_CHAOS then
			if wasteam == TEAM_CLASSD then
				PunishVote( attacker, victim )
			end
		end
	end
end

function GM:PlayerDisconnected( ply )
	 ply:SetTeam(TEAM_SPEC)
	 if #player.GetAll() < MINPLAYERS then
		BroadcastLua('gamestarted = false')
		gamestarted = false
	 end
	 WinCheck()
end

function HaveRadio(pl1, pl2)
	if pl1:HasWeapon("item_radio") then
		if pl2:HasWeapon("item_radio") then
			local r1 = pl1:GetWeapon("item_radio")
			local r2 = pl2:GetWeapon("item_radio")
			if !IsValid(r1) or !IsValid(r2) then return false end
			/*
			print(pl1:Nick() .. " - " .. pl2:Nick())
			print(r1.Enabled)
			print(r1.Channel)
			print(r2.Enabled)
			print(r2.Channel)
			*/
			if r1.Enabled == true then
				if r2.Enabled == true then
					if r1.Channel == r2.Channel then
						if r1.Channel > 4 then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

function GM:PlayerCanHearPlayersVoice( listener, talker )
	if talker:Alive() == false then return false end
	if listener:Alive() == false then return false end

	if !talker.GetNClass then
		player_manager.SetPlayerClass( talker, "class_breach" )
		player_manager.RunClass( talker, "SetupDataTables" )
	end

	if !listener.GetNClass then
		player_manager.SetPlayerClass( listener, "class_breach" )
		player_manager.RunClass( listener, "SetupDataTables" )
	end

	if talker:GetNClass() == ROLES.ROLE_SCP957 or listener:GetNClass() == ROLES.ROLE_SCP957 then
		if talker:GetNClass() == ROLES.ROLE_SCP9571 or listener:GetNClass() == ROLES.ROLE_SCP9571 then
			return true
		end
	end

	if talker:GTeam() == TEAM_SCP and talker:GetNClass() != ROLES.ROLE_SCP9571 then
		local omit = false

		if talker:GetNClass() == ROLES.ROLE_SCP939 then
			local wep = talker:GetWeapon("weapon_scp_939")
			if IsValid( wep ) then
				if wep.Channel == "ALL" then
					omit = true
				end
			end
		end

		if !omit and GetConVar( "br_allow_scptovoicechat" ):GetInt() == 0 then
			if listener:GTeam() != TEAM_SCP then
				return false
			end
		end
	end
	if talker:GTeam() == TEAM_SPEC then
		if listener:GTeam() == TEAM_SPEC then
			return true
		else
			return false
		end
	end
	if HaveRadio(listener, talker) == true then
		return true
	end
	if talker:GetPos():Distance(listener:GetPos()) < 750 then
		return true, true
	else
		return false
	end
end

function GM:PlayerCanSeePlayersChat( text, teamOnly, listener, talker )
	if activevote and ( text == "!forgive" or text == "!punish" ) then
		local votemsg = false
		if talker.voted == true or talker:SteamID64() == activesuspect then
			if !talker.timeout then talker.timeout = 0 end
			if talker.timeout < CurTime() then
				talker.timeout = CurTime() + 0.5
				net.Start( "ShowText" )
					net.WriteString( "vote_fail" )
				net.Send( talker )
			end
			return
		end
		if text == "!forgive" then
			if talker:SteamID64() == activevictim then
				voteforgive = voteforgive + 5
			elseif talker:GTeam() == TEAM_SPEC then
				specforgive = specforgive + 1
			else
				voteforgive = voteforgive + 1
			end
			talker.voted = true
			votemsg = true
			talker.timeout = CurTime() + 0.5
		elseif text == "!punish" then
			if talker:SteamID64() == activevictim then
				votepunish = votepunish + 5
			elseif talker:GTeam() == TEAM_SPEC then
				specpunish = specpunish + 1
			else
				votepunish = votepunish + 1
			end
			talker.voted = true
			votemsg = true
			talker.timeout = CurTime() + 0.5
		end
		if votemsg then
			if listener:IsSuperAdmin() then
				return true
			else
				return false
			end
		end
	end

	if !talker.GetNClass or !listener.GetNClass then
		player_manager.SetPlayerClass( ply, "class_breach" )
		player_manager.RunClass( ply, "SetupDataTables" )
	end

	if talker:GetNClass() == ROLES.ROLE_SCP957 or listener:GetNClass() == ROLES.ROLE_SCP957 then
		if talker:GetNClass() == ROLES.ROLE_SCP9571 or listener:GetNClass() == ROLES.ROLE_SCP9571 then
			return true
		end
	end

	if talker:GetNClass() == ROLES.ADMIN or listener:GetNClass() == ROLES.ADMIN then return true end
	if talker:Alive() == false then return false end
	if listener:Alive() == false then return false end
	if teamOnly then
		if talker:GetPos():Distance(listener:GetPos()) < 750 then
			return (listener:GTeam() == talker:GTeam())
		else
			return false
		end
	end
	if talker:GTeam() == TEAM_SPEC then
		if listener:GTeam() == TEAM_SPEC then
			return true
		else
			return false
		end
	end
	if HaveRadio(listener, talker) == true then
		return true
	end
	return (talker:GetPos():Distance(listener:GetPos()) < 750)
end

function GM:PlayerDeathSound()
	return true
end

hook.Add( "PlayerSay", "SCPPenaltyShow", function( ply, msg, teamonly )
	if msg == "!scp" then
		if !ply.nscpcmdcheck or ply.nscpcmdcheck < CurTime() then
			ply.nscpcmdcheck = CurTime() + 10

			local r = tonumber( ply:GetPData( "scp_penalty", 0 ) ) - 1
			r = math.max( r, 0 )

			if r == 0 then
				v:PrintTranslatedMessage( "scpready#50,200,50" )
			else
				v:PrintTranslatedMessage( "scpwait".."$"..r.."#200,50,50" )
			end
		end

		return ""
	end
end )

hook.Add( "SetupPlayerVisibility", "CCTVPVS", function( ply, viewentity )
	local wep = ply:GetActiveWeapon()
	if IsValid( wep ) and wep:GetClass() == "item_cameraview" then
		if wep.Enabled and IsValid( CCTV[wep.CAM].ent ) then
			AddOriginToPVS( CCTV[wep.CAM].pos )
		end
	end
end )

function GM:PlayerCanPickupWeapon( ply, wep )
	//if ply.lastwcheck == nil then ply.lastwcheck = 0 end
	//if ply.lastwcheck > CurTime() then return end
	//ply.lastwcheck = CurTime() + 0.5
	if wep.IDK != nil then
		for k,v in pairs(ply:GetWeapons()) do
			if wep.Slot == v.Slot then return false end
		end
	end
	if ply:GTeam() == TEAM_SCP and ply:GetNClass() != ROLES.ROLE_SCP9571 then
		if not wep.ISSCP then
			return false
		else
			if wep.ISSCP == true then
				return true
			else
				return false
			end
		end
	end
	if ply:GTeam() != TEAM_SPEC then
		if wep.teams then
			local canuse = false
			for k,v in pairs(wep.teams) do
				if v == ply:GTeam() then
					canuse = true
				end
			end
			if canuse == false and ply:GetNClass() != ROLES.ROLE_SCP9571 then
				return false
			end
		end
		for k,v in pairs(ply:GetWeapons()) do
			if v:GetClass() == wep:GetClass() then
				return false
			end
		end
		for k,v in pairs( ply:GetWeapons() ) do
			if ( string.starts( v:GetClass(), "cw_" ) and string.starts( wep:GetClass(), "cw_" )) then return false end
		end

		if table.Count( ply:GetWeapons() ) >= 8 then
			return false
		end

		ply.gettingammo = wep.SavedAmmo
		return true
	else
		if ply:GetNClass() == ROLES.ADMIN then
			if wep:GetClass() == "br_holster" then return true end
			if wep:GetClass() == "weapon_physgun" then return true end
			if wep:GetClass() == "gmod_tool" then return true end
			if wep:GetClass() == "br_entity_remover" then return true end
		end
		return false
	end
end

function GM:PlayerCanPickupItem( ply, item )
	return ply:GTeam() != TEAM_SPEC or ply:GetNClass() == ROLES.ADMIN
end

function GM:AllowPlayerPickup( ply, ent )
	return ply:GTeam() != TEAM_SPEC or ply:GetNClass() == ROLES.ADMIN
end
// usesounds = true,
function IsInTolerance( spos, dpos, tolerance )
	if spos == dpos then return true end

	if isnumber( tolerance ) then
		tolerance = { x = tolerance, y = tolerance, z = tolerance }
	end

	local allaxes = { "x", "y", "z" }
	for k, v in pairs( allaxes ) do
		if spos[v] != dpos[v] then
			if tolerance[v] then
				if math.abs( dpos[v] - spos[v] ) > tolerance[v] then
					return false
				end
			else
				return false
			end
		end
	end

	return true
end

function GM:PlayerUse( ply, ent )
	if ply:GTeam() == TEAM_SPEC and ply:GetNClass() != ROLES.ADMIN then return false end
	if ply:GetNClass() == ROLES.ADMIN then return true end
	if ply.lastuse == nil then ply.lastuse = 0 end
	if ply.lastuse > CurTime() then return false end
	for k, v in pairs( MAPBUTTONS ) do
		if v.pos == ent:GetPos() or v.tolerance then
			if v.tolerance and !IsInTolerance( v.pos, ent:GetPos(), v.tolerance ) then
				continue
			end
			if v.access then
				if OMEGADoors then
					return true
				end
				if v.levelOverride then
					return v.levelOverride( ply )
				end
				local wep = ply:GetActiveWeapon()
				if IsValid( wep ) and wep:GetClass() == "br_keycard" then
					local keycard = wep
					if IsValid( keycard ) then
						if bit.band( keycard.Access, v.access ) > 0 then
							if !v.nosound then
								ply:EmitSound( "KeycardUse1.ogg" )
							end
							ply.lastuse = CurTime() + 1
							ply:PrintMessage( HUD_PRINTCENTER, v.custom_access or "Access granted to "..v.name )
							if v.custom_access_granted then
								return v.custom_access_granted( ply, ent ) or false
							else
								return true
							end
						else
							if !v.nosound then
								ply:EmitSound( "KeycardUse2.ogg" )
							end
							ply.lastuse = CurTime() + 1
							ply:PrintMessage( HUD_PRINTCENTER, v.custom_deny or "You cannot operate this door with this keycard" )
							return false
						end
					end
				else
					ply.lastuse = CurTime() + 1
					ply:PrintMessage( HUD_PRINTCENTER, v.custom_nocard or "A keycard is required to operate this door" )
					return false
				end
			end
			if v.canactivate != nil then
				local canactivate = v.canactivate( ply, ent )
				if canactivate then
					if !v.nosound then
						ply:EmitSound( "KeycardUse1.ogg" )
					end
					ply.lastuse = CurTime() + 1
					if v.customaccessmsg then
						ply:PrintMessage( HUD_PRINTCENTER, v.customaccessmsg )
					else
						ply:PrintMessage( HUD_PRINTCENTER, "Access granted to " .. v["name"] )
					end
					return true
				else
					if !v.nosound then
						ply:EmitSound( "KeycardUse2.ogg" )
					end
					ply.lastuse = CurTime() + 1
					if v.customdenymsg then
						ply:PrintMessage( HUD_PRINTCENTER, v.customdenymsg )
					else
						ply:PrintMessage( HUD_PRINTCENTER, "Access denied" )
					end
					return false
				end
			end
		end
	end
	if ( GetConVar( "br_scp_cars" ):GetInt() == 0 ) then
		if ( ply:GTeam() == TEAM_SCP and ply:GetNClass() != ROLES.ROLE_SCP9571 ) then
			if ( ent:GetClass() == "prop_vehicle_jeep" ) then
				return false
			end
		end
	end
	if ply:GTeam() == TEAM_SCP and ply:GetNClass() != ROLES.ROLE_SCP9571 then
		if ent:GetClass() == "cw_ammo_40mm" then
			return false
		end
	end
	return true
end

function GM:CanPlayerSuicide( ply )
	return false
end

function string.starts( String, Start )
   return string.sub( String, 1, string.len( Start ) ) == Start
end



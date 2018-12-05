util.AddNetworkString("PlayerBlink")
util.AddNetworkString("DropWeapon")
util.AddNetworkString("DropCurWeapon")
--util.AddNetworkString("RequestGateA")
util.AddNetworkString("RequestEscorting")
util.AddNetworkString("PrepStart")
util.AddNetworkString("RoundStart")
util.AddNetworkString("PostStart")
util.AddNetworkString("RolesSelected")
util.AddNetworkString("SendRoundInfo")
util.AddNetworkString("Sound_Random")
util.AddNetworkString("Sound_Searching")
util.AddNetworkString("Sound_Classd")
util.AddNetworkString("Sound_Stop")
util.AddNetworkString("Sound_Lost")
util.AddNetworkString("UpdateRoundType")
util.AddNetworkString("ForcePlaySound")
util.AddNetworkString("OnEscaped")
util.AddNetworkString("SlowPlayerBlink")
util.AddNetworkString("DropCurrentVest")
util.AddNetworkString("RoundRestart")
util.AddNetworkString("SpectateMode")
util.AddNetworkString("UpdateTime")
--util.AddNetworkString("Update914B")
util.AddNetworkString("Effect")
util.AddNetworkString("NTFRequest")
util.AddNetworkString("ExplodeRequest")
util.AddNetworkString("ForcePlayerSpeed")
util.AddNetworkString("ClearData")
util.AddNetworkString("Restart")
util.AddNetworkString("AdminMode")
util.AddNetworkString("ShowText")
util.AddNetworkString("PlayerReady")
util.AddNetworkString("RecheckPremium")
util.AddNetworkString("CancelPunish")
util.AddNetworkString("689")
util.AddNetworkString( "UpdateKeycard" )
util.AddNetworkString( "SendSound" )
util.AddNetworkString( "957Effect" )
util.AddNetworkString( "SCPList" )
util.AddNetworkString( "TranslatedMessage" )
util.AddNetworkString( "CameraDetect" )

net.Receive( "DropWeapon", function( len, ply )
	local class = net.ReadString()
	if class then
		ply:ForceDropWeapon( class )
	end
end )

net.Receive( "CancelPunish", function( len, ply )
	if ply:IsSuperAdmin() then
		CancelVote()
	end
end )

net.Receive( "PlayerReady", function( len, ply )
	ply:SetActive( true )
	net.Start( "PlayerReady" )
		net.WriteTable( { sR, sL } )
	net.Send( ply )
	SendSCPList( ply )
end )

net.Receive( "RecheckPremium", function( len, ply )
	if ply:IsSuperAdmin() then
		for k, v in pairs( player.GetAll() ) do
			IsPremium( v, true )
		end
	end
end )

net.Receive( "SpectateMode", function( len, ply )
	/*
	if ply.ActivePlayer == true then
		if ply:Alive() and ply:Team() != TEAM_SPEC then
			ply:SetSpectator()
		end
		ply.SetActive( false )
		ply:PrintMessage(HUD_PRINTTALK, "Changed mode to spectator")
	elseif ply.ActivePlayer == false then
		ply.SetActive( true )
		ply:PrintMessage(HUD_PRINTTALK, "Changed mode to player")
	end
	CheckStart()
	*/
end)

net.Receive( "AdminMode", function( len, ply )
	if ply:IsSuperAdmin() then
		ply:ToggleAdminModePref()
	end
end)

net.Receive( "RoundRestart", function( len, ply )
	if ply:IsSuperAdmin() then
		RoundRestart()
	end
end)

net.Receive( "Restart", function( len, ply )
	if ply:IsSuperAdmin() then
		RestartGame()
	end
end)

net.Receive( "Sound_Random", function( len, ply )
	PlayerNTFSound("Random"..math.random(1,4)..".ogg", ply)
end)

net.Receive( "Sound_Searching", function( len, ply )
	PlayerNTFSound("Searching"..math.random(1,6)..".ogg", ply)
end)

net.Receive( "Sound_Classd", function( len, ply )
	PlayerNTFSound("ClassD"..math.random(1,4)..".ogg", ply)
end)

net.Receive( "Sound_Stop", function( len, ply )
	PlayerNTFSound("Stop"..math.random(2,6)..".ogg", ply)
end)

net.Receive( "Sound_Lost", function( len, ply )
	PlayerNTFSound("TargetLost"..math.random(1,3)..".ogg", ply)
end)

net.Receive( "DropCurrentVest", function( len, ply )
	if ply:GTeam() != TEAM_SPEC and ( ply:GTeam() != TEAM_SCP or ply:GetNClass() == ROLES.ROLE_SCP9571 ) and ply:Alive() then
		if ply.UsingArmor != nil then
			ply:UnUseArmor()
		end
	end
end)

net.Receive( "RequestEscorting", function( len, ply )
	if ply:GTeam() == TEAM_GUARD then
		CheckEscortMTF(ply)
	elseif ply:GTeam() == TEAM_CHAOS then
		CheckEscortChaos(ply)
	end
end)

net.Receive( "ClearData", function( len, ply )
	if not(ply:IsSuperAdmin()) then return end
	local com = net.ReadString()
	if com == "&ALL" then
		for k, v in pairs( player:GetAll() ) do
			clearData( v )
		end
	else
		for k, v in pairs( player:GetAll() ) do
			if v:GetName() == com then
				clearData( v )
				return
			end
		end
		if IsValidSteamID( com ) then
			clearDataID( com )
		end
	end
end)

function clearData( ply )
	ply:SetPData( "breach_exp", 0 )
	ply:SetNEXP( 0 )
	ply:SetPData( "breach_level", 0 )
	ply:SetNLevel( 0 )
end

function clearDataID( id64 )
	util.RemovePData( id64, "breach_exp" )
	util.RemovePData( id64, "breach_level" )
end

function IsValidSteamID( id )
	if tonumber( id ) then
		return true
	end
	return false
end

--net.Receive( "RequestGateA", function( len, ply )
--	RequestOpenGateA(ply)
--end)

net.Receive( "NTFRequest" , function( len, ply )
	if ply:IsSuperAdmin() then
		SpawnNTFS()
	end
end )

net.Receive( "ExplodeRequest", function( len, ply )
	if ply:GetNClass() == ROLES.ROLE_MTFNTF or ply:GetNClass() == ROLES.ROLE_CHAOS then
		explodeGateA( ply )
	end
end )

net.Receive( "DropCurWeapon", function( len, ply )
	local wep = ply:GetActiveWeapon()
	if ply:GTeam() == TEAM_SPEC then return end
	if IsValid(wep) and wep != nil and IsValid(ply) then
		local atype = wep:GetPrimaryAmmoType()
		if atype > 0 then
			wep.SavedAmmo = wep:Clip1()
		end
		
		if wep:GetClass() == nil then return end
		if wep.droppable != nil then
			if wep.droppable == false then return end
		end
		ply:DropWeapon( wep )
		ply:ConCommand( "lastinv" )
	end
end )

/*function dofloor(num, yes)
	if yes then
		return math.floor(num)
	end
	return num
end*/

/*function GetRoleTable(all)
	local classds = 0
	local mtfs = 0
	local researchers = 0
	local scps = 0
	if all < 8 then
		scps = 1
		all = all - 1
	elseif all > 7 and all < 16 then
		scps = 2
		all = all - 2
	elseif all > 15 then
		scps = 3
		all = all - 3
	end
	//mtfs = math.Round(all * 0.299)
	local mtfmul = 0.33
	if all > 12 then
		mtfmul = 0.3
	elseif all > 22 then
		mtfmul = 0.28
	end
	mtfs = math.Round(all * mtfmul)
	all = all - mtfs
	researchers = math.floor(all * 0.42)
	all = all - researchers
	classds = all
	//print(scps .. "," .. mtfs .. "," .. classds .. "," .. researchers .. "," .. chaosinsurgency)
	/*
	print("scps: " .. scps)
	print("mtfs: " .. mtfs)
	print("classds: " .. classds)
	print("researchers: " .. researchers)
	print("chaosinsurgency: " .. chaosinsurgency)
	*/
	/*return {scps, mtfs, classds, researchers}
end*/

function GetRoleTableCustom(all, scps, p_mtf, p_res)
	local classds = 0
	local mtfs = 0
	local researchers = 0
	all = all - scps
	mtfs = math.Round(all * p_mtf)
	all = all - mtfs
	researchers = math.floor(all * p_res)
	all = all - researchers
	classds = all
	return {scps, mtfs, classds, researchers}
end

cvars.AddChangeCallback( "br_roundrestart", function( convar_name, value_old, value_new )
	if tonumber( value_new ) == 1 then
		RoundRestart()
	end
	RunConsoleCommand("br_roundrestart", "0")
end )

/*function SetupPlayers(pltab)
	local allply = GetActivePlayers()
	
	// SCPS
	local spctab = table.Copy(SCPS)
	for i=1, pltab[1] do
		if #spctab < 1 then
			spctab = table.Copy(SCPS)
			//print("not enough scps, copying another table")
		end
		local pl = table.Random(allply)
		if IsValid(pl) == false then continue end
		local scp = table.Random(spctab)
		--scp["func"](pl)
		GetSCP( scp ):SetupPlayer( pl )
		print("assigning " .. pl:Nick() .. " to scps")
		table.RemoveByValue(spctab, scp)
		table.RemoveByValue(allply, pl)
	end
	
	// Class D Personell
	local dspawns = table.Copy(SPAWN_CLASSD)
	for i=1, pltab[3] do
		if #dspawns < 1 then
			dspawns = table.Copy(SPAWN_CLASSD)
		end
		if #dspawns > 0 then
			local pl = table.Random(allply)
			if IsValid(pl) == false then continue end
			local spawn = table.Random(dspawns)
			pl:SetupNormal()
			pl:SetClassD()
			pl:SetPos(spawn)
			print("assigning " .. pl:Nick() .. " to classds")
			table.RemoveByValue(dspawns, spawn)
			table.RemoveByValue(allply, pl)
		end
	end
	
	// Researchers
	local resspawns = table.Copy(SPAWN_SCIENT)
	for i=1, pltab[4] do
		if #resspawns < 1 then
			resspawns = table.Copy(SPAWN_SCIENT)
		end
		if #resspawns > 0 then
			local pl = table.Random(allply)
			if IsValid(pl) == false then continue end
			local spawn = table.Random(resspawns)
			pl:SetupNormal()
			pl:SetResearcher()
			pl:SetPos(spawn)
			print("assigning " .. pl:Nick() .. " to researchers")
			table.RemoveByValue(resspawns, spawn)
			table.RemoveByValue(allply, pl)
		end
	end
	
	// Security
	local security = ALLCLASSES["security"]["roles"]
	local securityspawns = table.Copy(SPAWN_GUARD)
	
	local i4inuse = false
	for i = 1, pltab[2] do
		if #securityspawns < 1 then
			securityspawns = table.Copy(SPAWN_GUARD)
		end
		if #securityspawns > 0 then
			local pl = table.remove( allply, math.random( #allply ) )
			if !IsValid( pl ) then continue end
			local spawn = table.remove( securityspawns, math.random( #allply ) )
			local thebestone
			for k, v in pairs( ALLCLASSES["security"]["roles"] ) do
				local useci = math.random( 1, 6 )
				local can = true
				if v.customcheck != nil then
					if !v.customcheck( self ) then
						can = false
					end
				end
				local using = 0
				for _, pl in pairs( player.GetAll() ) do
					if pl:GetNClass() == v.name then
						using = using + 1
					end
				end
				if using >= v.max then
					can = false
				end
				if v.importancelevel == 4 and ( i < GetConVar( "br_i4_min_mtf" ):GetInt() or i4inuse ) then
					can = false
				end
				if can then
					if pl:GetLevel() >= v.level then
						if thebestone != nil then
							if thebestone.sorting < v.sorting then
								thebestone = v
							end
						else
							thebestone = v
						end
					else
						can = false
					end
				end
			end
			if !thebestone then
				thebestone = ALLCLASSES["security"]["roles"][1]
			end
			if thebestone.name == ROLES.ROLE_MTFGUARD then
				if math.random( 1, 4 ) == 4 then
					for _, role in pairs( ALLCLASSES["security"]["roles"] ) do
						if role.name == ROLES.ROLE_CHAOSSPY then
							thebestone = role
							break
						end
					end
				end
			end
			if useci == 6 then
				local fakeci = math.random( 1, 3 ) == 1
				for _, role in pairs( ALLCLASSES["security"]["roles"] ) do
					local tofind = ROLES.ROLE_CHAOSSPY
					if fakeci then tofind = ROLES.ROLE_MTFGUARD end
					if role.name == tofind then
						thebestone = role
						break
					end
				end
			end
			if thebestone.importancelevel == 4 then
				i4inuse = true
			end
			pl:SetupNormal()
			pl:ApplyRoleStats( thebestone )
			pl:SetPos( spawn )
			print("assigning " .. pl:Nick() .. " to MTFs")
		end
	end
	
	net.Start("RolesSelected")
	net.Broadcast()
end*/

function SetupAdmins( players )
	for k, v in pairs( players ) do
		if v.admpref then
			if !v.AdminMode then
				v:ToggleAdminMode()
			end
			v:SetupAdmin()
		elseif v.AdminMode then
			v:ToggleAdminMode()
		end
	end
end

function GiveExp()
	for k, v in pairs( player.GetAll() ) do
		local exptogive = v:Frags() * 50
		v:SetFrags( 0 )
		if exptogive > 0 then
			v:AddExp( exptogive, true )
			v:PrintMessage( HUD_PRINTTALK, "You have recived "..exptogive.." experience for "..(exptogive / 50).." points" )
		end
	end
end

activevote = false
suspectname = ""
activesuspect = nil
activevictim = nil
votepunish = 0
voteforgive = 0
specpunish = 0
specforgive = 0

function PunishVote( ply, victim )
	if GetConVar( "br_allow_punish" ):GetInt() == 0 then return end
	if ply == victim then return end
	if activevote then
		EndPunishVote()
		timer.Destroy( "PunishEnd" )
	end
	net.Start( "ShowText" )
		net.WriteString( "text_punish" )
		net.WriteString( ply:GetName() )
	net.Broadcast()
	activevote = true
	votepunish = 0
	voteforgive = 0
	specpunish = 0
	specforgive = 0
	suspectname = ply:GetName()
	activesuspect = ply:SteamID64()
	activevictim = victim:SteamID64()
	timer.Create( "PunishEnd", GetConVar( "br_punishvote_time" ):GetInt(), 1, function()
		EndPunishVote()
	end )
end

function EndPunishVote()
	local specvotedforgive = math.Round( 3 * specforgive / ( specpunish + specforgive ) )
	if tostring( specvotedforgive ) != "nan" then
		voteforgive = voteforgive + specvotedforgive
		votepunish = votepunish + ( 3 - specvotedforgive )
	end
	print( "Player: "..suspectname, " Forgive: "..voteforgive, "Punish: "..votepunish )
	activevote = false
	for k,v in pairs( player.GetAll() ) do
		v.voted = false
	end
	local result = {
		punish = votepunish > voteforgive,
		punishvotes = votepunish,
		forgivevotes = voteforgive,
		punished = suspectname
	}
	net.Start( "ShowText" )
		net.WriteString( "text_punish_end" )
		net.WriteTable( result )
	net.Broadcast()
	if votepunish > voteforgive then
		for k,v in pairs( player.GetAll() ) do
			if v:SteamID64() == activesuspect then
				if v.warn then
					v:Kill()
				else
					v.warn = true
				end
				break
			end
		end
	end
	suspectname = ""
	activesuspect = nil
	activevictim = nil
end

function CancelVote()
	timer.Destroy( "PunishEnd" )
	net.Start( "ShowText" )
		net.WriteString( "text_punish_cancel" )
	net.Broadcast()
	activevote = false
	suspectname = ""
	activesuspect = nil
	activevictim = nil
	votepunish = 0
	voteforgive = 0
	specpunish = 0
	specforgive = 0
end
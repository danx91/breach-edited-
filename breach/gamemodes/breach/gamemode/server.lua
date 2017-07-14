util.AddNetworkString("PlayerBlink")
util.AddNetworkString("DropWeapon")
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
util.AddNetworkString("Update914B")
util.AddNetworkString("Effect")
util.AddNetworkString("NTFRequest")
util.AddNetworkString("ExplodeRequest")
util.AddNetworkString("ForcePlayerSpeed")
util.AddNetworkString("ClearData")
util.AddNetworkString("Restart")
util.AddNetworkString("AdminMode")

net.Receive( "SpectateMode", function( len, ply )
	/*
	if ply.ActivePlayer == true then
		if ply:Alive() and ply:Team() != TEAM_SPEC then
			ply:SetSpectator()
		end
		ply.ActivePlayer = false
		ply:PrintMessage(HUD_PRINTTALK, "Changed mode to spectator")
	elseif ply.ActivePlayer == false then
		ply.ActivePlayer = true
		ply:PrintMessage(HUD_PRINTTALK, "Changed mode to player")
	end
	CheckStart()
	*/
end)

net.Receive( "AdminMode", function( len, ply )
	if ply:IsSuperAdmin() then
		ply:ToogleAdminMode()
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
	if ply:GTeam() != TEAM_SPEC and ply:GTeam() != TEAM_SCP and ply:Alive() then
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
	end
end)

function clearData( ply )
	ply:SetPData( "breach_karma", GetConVar("br_karma_starting"):GetInt() or 0 )
	ply.Karma = GetConVar("br_karma_starting"):GetInt() or 0
	ply:SetNKarma( GetConVar("br_karma_starting"):GetInt() or 0 )
	ply:SetPData( "breach_exp", 0 )
	ply:SetNEXP( 0 )
	ply:SetPData( "breach_level", 0 )
	ply:SetNLevel( 0 )
end

--net.Receive( "RequestGateA", function( len, ply )
--	RequestOpenGateA(ply)
--end)

net.Receive( "NTFRequest" , function( len )
	if ply:IsSuperAdmin() then
		SpawnNTFS()
	end
end )

net.Receive( "ExplodeRequest", function( len, ply )
	explodeGateA( ply )
end )

net.Receive( "ForcePlayerSpeed", function( len, ply ) -- Honestly, this shouldnt even be a thing . . .
	local newSpeed = tonumber(net.ReadString())
	ply:SetRunSpeed( math.Clamp(newSpeed, ply:GetWalkSpeed(), 240) )
end )

net.Receive( "DropWeapon", function( len, ply )
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

function dofloor(num, yes)
	if yes then
		return math.floor(num)
	end
	return num
end

function GetRoleTable(all)
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
	return {scps, mtfs, classds, researchers}
end

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
	RoundRestart()
	RunConsoleCommand("br_roundrestart", "0")
end )

function SetupPlayers(pltab)
	local allply = GetActivePlayers()
	
	// SCPS
	local spctab = table.Copy(SPCS)
	for i=1, pltab[1] do
		if #spctab < 1 then
			spctab = table.Copy(SPCS)
			//print("not enough scps, copying another table")
		end
		local pl = table.Random(allply)
		if IsValid(pl) == false then return end
		local scp = table.Random(spctab)
		scp["func"](pl)
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
			if IsValid(pl) == false then return end
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
			if IsValid(pl) == false then return end
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
	local snum = pltab[2]
	local securityspawns = table.Copy(SPAWN_GUARD)
	
	local i4 = math.floor(snum / GetConVar("br_i4_min_mtf"):GetInt())
	
	local i4roles = {}
	local i4players = {}
	local i3roles = {}
	local i3players = {}
	local i2roles = {}
	local i2players = {}
	for k,v in pairs(security) do
		if v.importancelevel == 4 then
			table.ForceInsert(i4roles, v)
		elseif v.importancelevel == 3 then
			table.ForceInsert(i3roles, v)
		elseif v.importancelevel == 2 then
			table.ForceInsert(i2roles, v)
		end
	end
	
	for _,pl in pairs(allply) do
		for k,v in pairs(security) do
			if v.importancelevel > 1 then
				local can = true
				if v.customcheck != nil then
					if v.customcheck(pl) == false then
						can = false
					end
				end
				if can == true then
					if pl:GetLevel() >= v.level then
						if v.importancelevel == 2 then
							table.ForceInsert(i2players, pl)
						elseif v.importancelevel == 3 then
							table.ForceInsert(i3players, pl)
						else
							table.ForceInsert(i4players, pl)
						end
					end
				end
			end
		end
	end
	
	if i4 >= 1 then
		if #i4roles > 0 and #i4players > 0 then
			local pl = table.Random(i4players)
			local spawn = table.Random(securityspawns)
			pl:SetupNormal()
			pl:ApplyRoleStats(table.Random(i4roles))
			table.RemoveByValue(i4players, pl)
			table.RemoveByValue(i3players, pl)
			table.RemoveByValue(i2players, pl)
			pl:SetPos(spawn)
			print("assigning " .. pl:Nick() .. " to security i4")
			table.RemoveByValue(securityspawns, spawn)
			table.RemoveByValue(allply, pl)
		end
	end

	if #i3roles > 0 and #i3players > 0 then
		local pl = table.Random(i3players)
		local spawn = table.Random(securityspawns)
		pl:SetupNormal()
		pl:ApplyRoleStats(table.Random(i3roles))
		table.RemoveByValue(i4players, pl)
		table.RemoveByValue(i3players, pl)
		table.RemoveByValue(i2players, pl)
		pl:SetPos(spawn)
		print("assigning " .. pl:Nick() .. " to security i3")
		table.RemoveByValue(securityspawns, spawn)
		table.RemoveByValue(allply, pl)
	end
	
	if #i2roles > 0 and #i2players > 0 then
		local pl = table.Random(i2players)
		local spawn = table.Random(securityspawns)
		pl:SetupNormal()
		pl:ApplyRoleStats(table.Random(i2roles))
		pl:SetPos(spawn)
		table.RemoveByValue(i4players, pl)
		table.RemoveByValue(i3players, pl)
		table.RemoveByValue(i2players, pl)
		print("assigning " .. pl:Nick() .. " to security i2")
		table.RemoveByValue(securityspawns, spawn)
		table.RemoveByValue(allply, pl)
	end
	
	for k,v in pairs(allply) do
		if #securityspawns < 1 then
			securityspawns = table.Copy(SPAWN_GUARD2)
		end
		local spawn = table.Random(securityspawns)
		v:SetupNormal()
		v:SetSecurityI1()
		v:SetPos(spawn)
		print("assigning " .. v:Nick() .. " to security i1")
		table.RemoveByValue(securityspawns, spawn)
	end
	

	net.Start("RolesSelected")
	net.Broadcast()
end

function SetupAdmins( players )
	for k, v in pairs( players ) do
		if v:IsSuperAdmin() and v.ActivePlayer == false and v.AdminMode then
			v:SetupAdmin()
			--v:SetPos()
		end
	end
end
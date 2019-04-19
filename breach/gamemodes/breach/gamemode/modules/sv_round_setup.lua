function GetRoleTable( all )
	local scp = 0
	local mtf = 0
	local res = 0

	if all < 9 then
		scp = 1
	elseif all < 15 then
		scp = 2
	else
		scp = math.floor( ( all - 14 ) / 7 ) + 3
	end
	
	all = all - scp

	//if all < 14 then
		mtf = math.Round( all * 0.3 )
	//else
		//mtf = math.Round( all * 0.27 )
	//end

	all = all - mtf

	res = math.floor( all * 0.3 )
	all = all - res

	//print( "scp "..scp, "mtf "..mtf, "d"..all, "res"..res )
	return {scp, mtf, res, all}
end

local function PlayerLevelSorter(a, b)
	if a:GetLevel() > b:GetLevel() then return true end
end

function SetupPlayers( tab, multibreach )
	local players = GetActivePlayers()

	//Send info about penalties
	for k, v in pairs( players ) do
		local r = tonumber( v:GetPData( "scp_penalty", 0 ) )

		if r and r > 0 then
			v:SetPData( "scp_penalty", r - 1 )
		end
	end

	//Setup high priority players
	local scpply = {}
	for k, v in pairs( players ) do
		if tonumber( v:GetPData( "scp_penalty", 0 ) ) == 0 then
			table.insert( scpply, v )
			//print( v, "has NO penalty" )
		//else
			//print( v, "has penalty", v:GetPData( "scp_penalty", 0 ) )
		end
	end

	//Penalty values
	local p = GetConVar("br_scp_penalty"):GetInt() + 1
	local pp = GetConVar("br_premium_penalty"):GetInt() + 1

	//Select SCPs
	local SCP = table.Copy( SCPS )
	local rSCP = SCP[math.random( #SCP )]

	for i = 1, tab[1] do
		if #scpply == 0 then
			scpply = players
		end

		local scp = multibreach and GetSCP( rSCP ) or GetSCP( table.remove( SCP, math.random( #SCP ) ) )
		local ply = #scpply > 0 and table.remove( scpply, math.random( #scpply ) ) or table.Random( players )

		ply:SetPData( "scp_penalty", ply.Premium and pp or p )
		table.RemoveByValue( players, ply )

		scp:SetupPlayer( ply )
		print( "Assigning "..ply:Nick().." to role: "..scp.name.." [SCP]" )
	end

	//Select MTFs
	local mtfsinuse = {}
	local mtfspawns = table.Copy( SPAWN_GUARD )
	local mtfs = {}

	for i = 1, tab[2] do
		table.insert( mtfs, table.remove( players, math.random( #players ) ) )
	end

	table.sort( mtfs, PlayerLevelSorter )

	for i, v in ipairs( mtfs ) do
		local mtfroles = table.Copy( ALLCLASSES.security.roles )
		local selected

		repeat
			local role = table.remove( mtfroles, math.random( #mtfroles ) )
			mtfsinuse[role.name] = mtfsinuse[role.name] or 0

			if role.max == 0 or mtfsinuse[role.name] < role.max then
				if role.level <= v:GetLevel() then
					if !role.customcheck or role.customcheck( v ) then
						selected = role
						break
					end
				end
			end
		until #mtfroles == 0

		if !selected then
			ErrorNoHalt( "Something went wrong! Error code: 001" )
			selected = ALLCLASSES.security.roles[1]
		end

		mtfsinuse[selected.name] = mtfsinuse[selected.name] + 1

		if #mtfspawns == 0 then mtfspawns = table.Copy( SPAWN_GUARD ) end
		local spawn = table.remove( mtfspawns, math.random( #mtfspawns ) )

		v:SetupNormal()
		v:ApplyRoleStats( selected )
		v:SetPos( spawn )

		print( "Assigning "..v:Nick().." to role: "..selected.name.." [MTF]" )
	end

	//Select Researchers
	local resinuse = {}
	local resspawns = table.Copy( SPAWN_SCIENT )

	for i = 1, tab[3] do
		local ply = table.Random( players )

		local resroles = table.Copy( ALLCLASSES.researchers.roles )
		local selected

		repeat
			local role = table.remove( resroles, math.random( #resroles ) )
			resinuse[role.name] = resinuse[role.name] or 0

			if role.max == 0 or resinuse[role.name] < role.max then
				if role.level <= ply:GetLevel() then
					if !role.customcheck or role.customcheck( ply ) then
						selected = role
						break
					end
				end
			end
		until #resroles == 0

		if !selected then
			ErrorNoHalt( "Something went wrong! Error code: 002" )
			selected = ALLCLASSES.researchers.roles[1]
		end

		resinuse[selected.name] = resinuse[selected.name] + 1

		table.RemoveByValue( players, ply )

		if #resspawns == 0 then resspawns = table.Copy( SPAWN_SCIENT ) end
		local spawn = table.remove( resspawns, math.random( #resspawns ) )

		ply:SetupNormal()
		ply:ApplyRoleStats( selected )
		ply:SetPos( spawn )

		print( "Assigning "..ply:Nick().." to role: "..selected.name.." [RESEARCHERS]" )
	end

	//Select Class D
	local dinuse = {}
	local dspawns = table.Copy( SPAWN_CLASSD )

	for i = 1, tab[4] do
		local ply = table.Random( players )

		local droles = table.Copy( ALLCLASSES.classds.roles )
		local selected

		repeat
			local role = table.remove( droles, math.random( #droles ) )
			dinuse[role.name] = dinuse[role.name] or 0

			if role.max == 0 or dinuse[role.name] < role.max then
				if role.level <= ply:GetLevel() then
					if !role.customcheck or role.customcheck( ply ) then
						selected = role
						break
					end
				end
			end
		until #droles == 0

		if !selected then
			ErrorNoHalt( "Something went wrong! Error code: 003" )
			selected = ALLCLASSES.classds.roles[1]
		end

		dinuse[selected.name] = dinuse[selected.name] + 1

		table.RemoveByValue( players, ply )

		if #dspawns == 0 then dspawns = table.Copy( SPAWN_CLASSD ) end
		local spawn = table.remove( dspawns, math.random( #dspawns ) )

		ply:SetupNormal()
		ply:ApplyRoleStats( selected )
		ply:SetPos( spawn )

		print( "Assigning "..ply:Nick().." to role: "..selected.name.." [CLASS D]" )
	end

	//Send info to everyone
	net.Start("RolesSelected")
	net.Broadcast()
end

function SetupInfect( ply )
	if !SERVER then return end

	local roles = {}

	roles[1] = math.ceil( ply * 0.15 )
	ply = ply - roles[1]
	roles[2] = math.Round( ply * 0.333 )
	ply = ply - roles[2]
	roles[3] = ply

	local players = GetActivePlayers()
	local spawns = table.Copy( SPAWN_GUARD )
	local ply, spawn = nil, nil

	for i = 1, roles[1] do
		ply = table.remove( players, math.random( 1, #players ) )
		spawn = table.remove( spawns, math.random( 1, #spawns ) )

		ply:SetSCP0082( 750, 250, true )
		ply:SetPos( spawn )
	end

	spawns = table.Copy( SPAWN_CLASSD )

	for i = 1, roles[2] do
		if #spawns < 1 then
			spawns = table.Copy( SPAWN_CLASSD )
		end

		ply = table.remove( players, math.random( 1, #players ) )
		spawn = table.remove( spawns, math.random( 1, #spawns ) )

		ply:SetInfectMTF()
		ply:SetPos( spawn )
	end

	for i = 1, roles[3] do
		if #spawns < 1 then
			spawns = table.Copy( SPAWN_CLASSD )
		end

		ply = table.remove( players, math.random( 1, #players ) )
		spawn = table.remove( spawns, math.random( 1, #spawns ) )

		ply:SetInfectD()
		ply:SetPos( spawn )
	end

	net.Start("RolesSelected")
	net.Broadcast()
end
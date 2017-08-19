if !ulx or !ULib then 
	print( "ULX or ULib not found" ) 
	return
end

local class_names = {}
for _, group in pairs( ALLCLASSES ) do
	for k, class in pairs( group.roles ) do
		table.insert( class_names, class.name )
	end
end

local scp_names = {}
for _, scp in pairs( SPCS ) do
	table.insert( scp_names, scp.name )
end

function ulx.forcespawn( ply, plys, class, silent )
	if !class then return end
	local cl, gr
	for _, group in pairs( ALLCLASSES ) do
		gr = group.name
		for k, clas in pairs( group.roles ) do
			if clas.name == class or clas.name == ROLES["ROLE_"..class] then
				cl = clas
			end
			if cl then break end
		end
		if cl then break end
	end
	if cl and gr then
		local pos
		if gr == "Armed Site Support" then
			pos = table.Copy( SPAWN_OUTSIDE )
		elseif gr == "Armed Site Security" then
			pos = table.Copy( SPAWN_GUARD )
		elseif gr == "Unarmed Site Staff" then
			pos = table.Copy( SPAWN_SCIENT )
		elseif  gr == "Class D Personell" then
			pos = table.Copy( SPAWN_CLASSD )
		end
		for k, v in pairs( plys ) do
			if v:GetNActive() then
				v:SetupNormal()
				v:ApplyRoleStats( cl )
				if pos then
					v:SetPos( table.Random( pos ) )
				end
			else
				ULib.tsayError( plyc, "Player "..v:GetName().." is inactive! Forced spawn failed", true )
			end
		end
		if silent then
			ulx.fancyLogAdmin( ply, true, "#A force spawned #T as "..cl.name, plys )
		else
			ulx.fancyLogAdmin( ply, "#A force spawned #T as "..cl.name, plys )
		end
	end
end

local forcespawn = ulx.command( "Breach Admin", "ulx force_spawn", ulx.forcespawn, "!forcespawn" )
forcespawn:addParam{ type = ULib.cmds.PlayersArg }
forcespawn:addParam{ type = ULib.cmds.StringArg, hint = "class name", completes = class_names, ULib.cmds.takeRestOfLine }
forcespawn:addParam{ type = ULib.cmds.BoolArg, invisible = true }
forcespawn:setOpposite( "ulx silent force_spawn", { _, _, _, true }, "!sforcespawn" )
forcespawn:defaultAccess( ULib.ACCESS_SUPERADMIN )
forcespawn:help( "Sets player(s) to specific class and spawns him" )

function ulx.forcescp( plyc, plyt, scp, silent )
	if !scp then return end
	if !plyt:GetNActive() then
		ULib.tsayError( plyc, "Player "..plyt:GetName().." is inactive! Forced spawn failed", true )
		return
	end
	for k, v in pairs( SPCS ) do
		if v.name == scp then
			v.func( plyt )
			if silent then
				ulx.fancyLogAdmin( plyc, true, "#A force spawned #T as "..scp, plyt )
			else
				ulx.fancyLogAdmin( plyc, "#A force spawned #T as "..scp, plyt )
			end
			break
		end
	end
end

local forcescp = ulx.command( "Breach Admin", "ulx force_scp", ulx.forcescp, "!forcescp" )
forcescp:addParam{ type = ULib.cmds.PlayerArg }
forcescp:addParam{ type = ULib.cmds.StringArg, hint = "SCP name", completes = scp_names, ULib.cmds.takeRestOfLine }
forcescp:addParam{ type = ULib.cmds.BoolArg, invisible = true }
forcescp:setOpposite( "ulx silent force_scp", { _, _, _, true }, "!sforcescp" )
forcescp:defaultAccess( ULib.ACCESS_SUPERADMIN )
forcescp:help( "Sets player to specific SCP and spawns him" )

function ulx.recheckpremium( ply, silent )
	for k, v in pairs( player.GetAll() ) do
		IsPremium( v, true )
	end
	if silent then
		ulx.fancyLogAdmin( ply, true, "#A reloaded premium status of players" )
	else
		ulx.fancyLogAdmin( ply, "#A reloaded premium status of players" )
	end
end

local recheckpremium = ulx.command( "Breach Admin", "ulx recheck_premium", ulx.recheckpremium, "!recheckpremium" )
recheckpremium:defaultAccess( ULib.ACCESS_ADMIN )
recheckpremium:help( "Reloads player's premium status" )

function ulx.punishcancel( ply, silent )
	CancelVote()
	if silent then
		ulx.fancyLogAdmin( ply, true, "#A canceled last punish vote" )
	else
		ulx.fancyLogAdmin( ply, "#A canceled last punish vote" )
	end
end

local punishcancel = ulx.command( "Breach Admin", "ulx punish_cancel", ulx.punishcancel, "!punishcancel" )
punishcancel:addParam{ type = ULib.cmds.BoolArg, invisible = true }
punishcancel:setOpposite( "ulx silent recheck_premium", { _, true }, "!spunishcancel" )
punishcancel:defaultAccess( ULib.ACCESS_ADMIN )
punishcancel:help( "Cancels last punish vote" )

function ulx.clearstats( plyc, plyt, id, silent )
	if plyc == plyt and id != "" then
		if id == "&ALL" then
			ULib.tsayError( plyc, "To clear data of every online player use br_clear_stats instead!", true )
			return
		end
		if IsValidSteamID( id ) then
			clearDataID( id )
		end
		if silent then
			ulx.fancyLogAdmin( plyc, true, "#A cleared data of player with SteamID64: "..id )
		else
			ulx.fancyLogAdmin( plyc, "#A cleared data of player with SteamID64: "..id )
		end
		return
	end
	clearData( plyt )
	if silent then
		ulx.fancyLogAdmin( plyc, true, "#A cleared data of #T", plyt )
	else
		ulx.fancyLogAdmin( plyc, "#A cleared data of #T", plyt )
	end
end

local clearstats = ulx.command( "Breach Admin", "ulx clear_stats", ulx.clearstats, "!clearstats" )
clearstats:addParam{ type = ULib.cmds.PlayerArg }
clearstats:addParam{ type = ULib.cmds.StringArg, hint = "SteamID64", ULib.cmds.takeRestOfLine, ULib.cmds.optional }
clearstats:addParam{ type = ULib.cmds.BoolArg, invisible = true }
clearstats:setOpposite( "ulx silent clear_stats", { _, _, _, true }, "!sclearstats" )
clearstats:defaultAccess( ULib.ACCESS_SUPERADMIN )
clearstats:help( "Clears player data by name or SteamID64(to use SteamID64 put yourself as target)" )

function ulx.restartgame( ply, silent )
	RestartGame()
	if silent then
		ulx.fancyLogAdmin( plyc, true, "#A restarted game" )
	else
		ulx.fancyLogAdmin( plyc, "#A restarted game" )
	end
end

local restartgame = ulx.command( "Breach Admin", "ulx restart_game", ulx.restartgame, "!restartgame" )
restartgame:addParam{ type = ULib.cmds.BoolArg, invisible = true }
restartgame:setOpposite( "ulx silent restart_game", { _, true }, "!srestartgame" )
restartgame:defaultAccess( ULib.ACCESS_SUPERADMIN )
restartgame:help( "Restarts game" )

function ulx.adminmode( ply, silent )
	ply:ToggleAdminModePref()
	if ply.admpref then
		if ply.AdminMode then
			if silent then
				ulx.fancyLogAdmin( ply, true, "#A entered admin mode" )
			else
				ulx.fancyLogAdmin( ply, "#A entered admin mode" )
			end
		else
			if silent then
				ulx.fancyLogAdmin( ply, true, "#A will enter admin mode in next round" )
			else
				ulx.fancyLogAdmin( ply, "#A will enter admin mode in next round" )
			end
		end
	else
		if silent then
			ulx.fancyLogAdmin( ply, "#A will no longer be in admin mode" )
		else
			ulx.fancyLogAdmin( ply, "#A will no longer be in admin mode" )
		end
	end
end

local adminmode = ulx.command( "Breach Admin", "ulx admin_mode", ulx.adminmode, "!adminmode" )
adminmode:addParam{ type = ULib.cmds.BoolArg, invisible = true }
adminmode:setOpposite( "ulx silent admin_mode", { _, true }, "!sadminmode" )
adminmode:defaultAccess( ULib.ACCESS_ADMIN )
adminmode:help( "Toggles admin mode" )
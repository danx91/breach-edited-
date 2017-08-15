ROUNDS = {
	normal = {
		name = "Containment Breach",
		setup = function()
			MAPBUTTONS = table.Copy(BUTTONS)
			SetupPlayers( GetRoleTable( #GetActivePlayers() ) )
			disableNTF = false
		end,
		init = function()
			SpawnAllItems()
			timer.Create( "NTFEnterTime", GetNTFEnterTime(), 0, function()
				SpawnNTFS()
			end )
			timer.Create("MTFDebug", 2, 1, function()
				local fent = ents.FindInSphere(MTF_DEBUG, 750)
				for k, v in pairs( player.GetAll() ) do
					if v:GTeam() == TEAM_GUARD or v:GTeam() == TEAM_CHAOS then
						local found = false
						for k0, v0 in pairs(fent) do
							if v == v0 then
								found = true
								break
							end
						end
						if !found then
							v:SetPos(MTF_DEBUG)
						end
					end
				end
			end )	
		end,
		roundstart = function()
			OpenSCPDoors()
		end,
		postround = function() end,
		endcheck = function()
			if #GetActivePlayers() < 2 then return end	
			endround = false
			local ds = gteams.NumPlayers(TEAM_CLASSD)
			local mtfs = gteams.NumPlayers(TEAM_GUARD)
			local res = gteams.NumPlayers(TEAM_SCI)
			local scps = gteams.NumPlayers(TEAM_SCP)
			local chaos = gteams.NumPlayers(TEAM_CHAOS)
			local all = #GetAlivePlayers()		
			why = "idk man"
			if scps == all then
				endround = true
				why = "there are only scps"
			elseif mtfs == all then
				endround = true
				why = "there are only mtfs"
			elseif res == all then
				endround = true
				why = "there are only researchers"
			elseif ds == all then
				endround = true
				why = "there are only class ds"
			elseif chaos == all then
				endround = true
				why = "there are only chaos insurgency members"
			elseif (mtfs + res) == all then
				endround = true
				why = "there are only mtfs and researchers"
			elseif (chaos + ds) == all then
				endround = true
				why = "there are only chaos insurgency members and class ds"
			end
		end,
	},
/*	dm = {
		name = "MTF vs CI Deathmatch",
		setup = function()
			MAPBUTTONS = GetTableOverride( table.Copy(BUTTONS) ) + GetTableOverride( table.Copy(BUTTONS_DM) )
			SetupPlayers( GetRoleTableCustom( #GetActivePlayers(),  ) )
			
			disableNTF = false
		end,
		init = function()
			SpawnAllItems()
			DestroyGateA()
		end,
		roundstart = function()
			OpenSCPDoors()
		end,
		postround = function() end,
		cleanup = function() end,
	},*/
/*	omega = {
		name = "Omega Problem",
		setup = function()
			MAPBUTTONS = GetTableOverride( table.Copy(BUTTONS) ) + GetTableOverride( table.Copy(BUTTONS_OMEGA) )
			SetupPlayers( GetRoleTable( #GetActivePlayers() ) )
			disableNTF = false
		end,
		init = function()
			SpawnAllItems()
			timer.Create( "NTFEnterTime", GetNTFEnterTime(), 0, function()
				SpawnNTFS()
			end )
		end,
		roundstart = function()
			OpenSCPDoors()
		end,
		postround = function() end,
		cleanup = function() end,
	}, */
	infect = {
		name = "Infect",
		setup = function()
			MAPBUTTONS = table.Copy(BUTTONS)
			SetupInfect( #GetActivePlayers() )
			disableNTF = true
		end,
		init = function()
			SpawnAllItems()
		end,
		roundstart = function() end,
		postround = function() end,
		endcheck = function()
			if #GetActivePlayers() < 2 then return end
			local ds = gteams.NumPlayers(TEAM_CLASSD)
			local mtfs = gteams.NumPlayers(TEAM_GUARD)
			local scps = gteams.NumPlayers(TEAM_SCP)
			local all = #GetAlivePlayers()
			endround = false
			why = "idk"
			if ds == all then
				endround = true
				why = "there are only Class Ds"
			elseif mtfs == all then
				endround = true
				why = "there are only MTFs"
			elseif ds + mtfs == all then
				endround = true
				why = "there are only MTFs and Ds"
			elseif scps == all then
				endround = true
				why = "there are only SCPs"
			end		
		end,
	},
	multi = {
		name = "MultiBreach",
		setup = function()
			MAPBUTTONS = table.Copy(BUTTONS)
			SetupMultiBreach( GetRoleTable( #GetActivePlayers() ) )
			disableNTF = false
		end,
		init = function()
			SpawnAllItems()
			timer.Create( "NTFEnterTime", GetNTFEnterTime(), 0, function()
				SpawnNTFS()
			end )
			timer.Create("MTFDebug", 2, 1, function()
				local fent = ents.FindInSphere(MTF_DEBUG, 750)
				for k, v in pairs( player.GetAll() ) do
					if v:GTeam() == TEAM_GUARD or v:GTeam() == TEAM_CHAOS then
						local found = false
						for k0, v0 in pairs(fent) do
							if v == v0 then
								found = true
								break
							end
						end
						if !found then
							v:SetPos(MTF_DEBUG)
						end
					end
				end
			end )	
		end,
		roundstart = function()
			OpenSCPDoors()
		end,
		postround = function() end,
		endcheck = function()
			if #GetActivePlayers() < 2 then return end	
			endround = false
			local ds = gteams.NumPlayers(TEAM_CLASSD)
			local mtfs = gteams.NumPlayers(TEAM_GUARD)
			local res = gteams.NumPlayers(TEAM_SCI)
			local scps = gteams.NumPlayers(TEAM_SCP)
			local chaos = gteams.NumPlayers(TEAM_CHAOS)
			local all = #GetAlivePlayers()		
			why = "idk man"
			if scps == all then
				endround = true
				why = "there are only scps"
			elseif mtfs == all then
				endround = true
				why = "there are only mtfs"
			elseif res == all then
				endround = true
				why = "there are only researchers"
			elseif ds == all then
				endround = true
				why = "there are only class ds"
			elseif chaos == all then
				endround = true
				why = "there are only chaos insurgency members"
			elseif (mtfs + res) == all then
				endround = true
				why = "there are only mtfs and researchers"
			elseif (chaos + ds) == all then
				endround = true
				why = "there are only chaos insurgency members and class ds"
			end
		end,
	},
}
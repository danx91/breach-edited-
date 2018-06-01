/*
function SetupPlayers()
	local allplayers = player.GetAll()
	local plycount = PlayerCount()
	if plycount < 10 then
		local scpply = table.Random(allplayers)
		if scp == SCP_173 then
			scpply:SetSCP173()
			table.RemoveByValue(allplayers, scpply)
		elseif scp == SCP_106 then
			scpply:SetSCP106()
			table.RemoveByValue(allplayers, scpply)
		elseif scp == SCP_049 then
			scpply:SetSCP049()
			table.RemoveByValue(allplayers, scpply)
		end
		for i=1,math.Round(#allplayers / 3) do
			local rndplayer = table.Random(allplayers)
			table.RemoveByValue(allplayers, rndplayer)
			rndplayer:SetGuard()
		end
		for k,v in pairs(allplayers) do
			v:SetClassD()
		end
		for k,v in pairs(gteams.GetPlayers(TEAM_CLASSD)) do
			v:SetPos(table.Random(SPAWN_CLASSD))
		end
		for k,v in pairs(gteams.GetPlayers(TEAM_GUARD)) do
			v:SetPos(table.Random(SPAWN_GUARD))
		end
		return
	end
	if plycount > 10 or plycount == 10 then
		local scpply = table.Random(allplayers)
		table.RemoveByValue(allplayers, scpply)
		local scpply2 = table.Random(allplayers)
		table.RemoveByValue(allplayers, scpply2)
		// SCP 173
		if scp == SCP_173 then
			scpply:SetSCP173()
			local mtrnd = math.random(1,2)
			if mtrnd == 1 then
				scpply2:SetSCP106()
			elseif mtrnd == 2 then
				scpply2:SetSCP049()
			end
		// SCP 106
		elseif scp == SCP_106 then
			scpply:SetSCP106()
			local mtrnd = math.random(1,2)
			if mtrnd == 1 then
				scpply2:SetSCP173()
			elseif mtrnd == 2 then
				scpply2:SetSCP049()
			end
		// SCP 049
		elseif scp == SCP_049 then
			scpply:SetSCP049()
			local mtrnd = math.random(1,2)
			if mtrnd == 1 then
				scpply2:SetSCP106()
			elseif mtrnd == 2 then
				scpply2:SetSCP173()
			end
		end
		for i=1,math.Round(#allplayers / 4) do
			local rndplayer = table.Random(allplayers)
			table.RemoveByValue(allplayers, rndplayer)
			rndplayer:SetGuard()
		end
		for k,v in pairs(allplayers) do
			v:SetClassD()
		end
		for k,v in pairs(team.GetPlayers(TEAM_CLASSD)) do
			v:SetPos(table.Random(SPAWN_CLASSD))
		end
		for k,v in pairs(team.GetPlayers(TEAM_GUARD)) do
			v:SetPos(table.Random(SPAWN_GUARD))
		end
	end
end
*/
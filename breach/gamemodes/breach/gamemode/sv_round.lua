activeRound = nil
rounds = -1

function RestartGame()
	game.ConsoleCommand("changelevel "..game.GetMap().."\n")
end

function CleanUp()
	timer.Destroy("PreparingTime")
	timer.Destroy("RoundTime")
	timer.Destroy("PostTime")
	timer.Destroy("GateOpen")
	timer.Destroy("PlayerInfo")
	timer.Destroy("NTFEnterTime")
	timer.Destroy("966Debug")
	timer.Destroy("MTFDebug")
	timer.Destroy("GateExplode")
	if timer.Exists("CheckEscape") == false then
		timer.Create("CheckEscape", 1, 0, CheckEscape)
	end
	game.CleanUpMap()
	nextgateaopen = 0
	spawnedntfs = 0
	roundstats = {
		descaped = 0,
		rescaped = 0,
		sescaped = 0,
		dcaptured = 0,
		rescorted = 0,
		deaths = 0,
		teleported = 0,
		snapped = 0,
		zombies = 0,
		secretf = false
	}
	inUse = false
end

function CleanUpPlayers()
	for k,v in pairs(player.GetAll()) do
		v:SetModelScale( 1 )
		v:SetCrouchedWalkSpeed(0.6)
		v.mblur = false
		player_manager.SetPlayerClass( v, "class_breach" )
		player_manager.RunClass( v, "SetupDataTables" )
		v:Freeze(false)
		v.MaxUses = nil
		v.blinkedby173 = false
		v.usedeyedrops = false
		v.isescaping = false
		v:AddKarma(KarmaRound())
		v:UpdateNKarma()
	end
	net.Start("Effect")
		net.WriteBool( false )
	net.Broadcast()
end

function RoundTypeUpdate()
	local nextRoundName = GetConVar( "br_force_specialround" ):GetString()
	activeRound = nil
	if tonumber( nextRoundName ) then
		nextRoundName = tonumber( nextRoundName )
	end
	if ROUNDS[ nextRoundName ] then
		activeRound = ROUNDS[ nextRoundName ]
	end
	RunConsoleCommand( "br_force_specialround", "" )
	if !activeRound /*and #ROUNDS > 1*/ then
		local pct = math.Clamp( GetConVar( "br_specialround_pct" ):GetInt(), 0, 100 )
		print( pct )
		if math.random( 0, 100 ) < pct then
			repeat
				activeRound = table.Random( ROUNDS )
			until( activeRound != ROUNDS.normal )
		end
	end
	if !activeRound then
		activeRound = ROUNDS.normal
	end
end

function RoundRestart()
	print("round: starting")
	CleanUp()
	print("round: map cleaned")
	if GetConVar("br_firstround_debug"):GetInt() > 0 and rounds == -1 then
		rounds = 0
		RoundRestart()
		return
	end
	if GetConVar("br_rounds"):GetInt() > 0 then
		if rounds == GetConVar("br_rounds"):GetInt() then
			RestartGame()
		end
		rounds = rounds + 1
	else
		rounds = 0
	end	
	CleanUpPlayers()
	print("round: players cleaned")
	preparing = true
	postround = false
	activeRound = nil
	RoundTypeUpdate()
	activeRound:setup()
	SetupAdmins( player.GetAll() )
	print( "round: setup end" )	
	net.Start("UpdateRoundType")
		net.WriteString(activeRound.name)
	net.Broadcast()	
	activeRound:init()	
	print( "round: int end / preparation start" )	
	gamestarted = true
	BroadcastLua('gamestarted = true')
	print("round: gamestarted")
	timer.Create("966Debug", GetConVar("br_time_preparing"):GetInt() + 15, 1, function()
		local fent = ents.FindInSphere(SPAWN_966, 250)
		for k, v in pairs(fent) do
			if (v:IsPlayer()) then
				if (v:GetNClass() == ROLES.ROLE_SCP966) then
					v:SetPos(OUTSIDE_966)
					print("Do SCP 966 stuck?? Debugging...")
					break
				end
			end
		end
	end )
	net.Start("PrepStart")
		net.WriteInt(GetPrepTime(), 8)
	net.Broadcast()	
	timer.Create("PreparingTime", GetPrepTime(), 1, function()
		for k,v in pairs(player.GetAll()) do
			v:Freeze(false)
		end
		preparing = false
		postround = false		
		activeRound:roundstart()		
		net.Start("RoundStart")
			net.WriteInt(GetRoundTime(), 12)
		net.Broadcast()		
		print("round: started")
		timer.Create("RoundTime", GetRoundTime(), 1, function()
			postround = false
			postround = true		
			activeRound:postround()			
			print( "round: post" )			
			net.Start("SendRoundInfo")
				net.WriteTable(roundstats)
			net.Broadcast()			
			net.Start("PostStart")
				net.WriteInt(GetPostTime(), 6)
				net.WriteInt(1, 4)
			net.Broadcast()		
			timer.Create("PostTime", GetPostTime(), 1, function()
				RoundRestart()
			end)		
		end)
	end)
end

canescortds = true
canescortrs = true
function CheckEscape()
	for k,v in pairs(ents.FindInSphere(POS_GATEA, 250)) do
		if v:IsPlayer() == true then
			if v:Alive() == false then return end
			if v.isescaping == true then return end
			if v:GTeam() == TEAM_CLASSD or v:GTeam() == TEAM_SCI or v:GTeam() == TEAM_SCP then
				if v:GTeam() == TEAM_SCI then
					roundstats.rescaped = roundstats.rescaped + 1
					local rtime = timer.TimeLeft("RoundTime")
					local exptoget = 300
					if rtime != nil then
						exptoget = GetConVar("br_time_round"):GetInt() - (CurTime() - rtime)
						exptoget = exptoget * 1.8
						exptoget = math.Round(math.Clamp(exptoget, 300, 10000))
					end
					net.Start("OnEscaped")
						net.WriteInt(1,4)
					net.Send(v)
					v:AddFrags(5)
					v:AddExp(exptoget, true)
					v:GodEnable()
					v:Freeze(true)
					v.canblink = false
					v.isescaping = true
					timer.Create("EscapeWait" .. v:SteamID64(), 2, 1, function()
						v:Freeze(false)
						v:GodDisable()
						v:SetSpectator()
						WinCheck()
						v.isescaping = false
					end)
					//v:PrintMessage(HUD_PRINTTALK, "You escaped! Try to get escorted by MTF next time to get bonus points.")
				elseif v:GTeam() == TEAM_CLASSD then
					roundstats.descaped = roundstats.descaped + 1
					local rtime = timer.TimeLeft("RoundTime")
					local exptoget = 500
					if rtime != nil then
						exptoget = GetConVar("br_time_round"):GetInt() - (CurTime() - rtime)
						exptoget = exptoget * 2
						exptoget = math.Round(math.Clamp(exptoget, 500, 10000))
					end
					net.Start("OnEscaped")
						net.WriteInt(2,4)
					net.Send(v)
					v:AddFrags(5)
					v:AddExp(exptoget, true)
					v:GodEnable()
					v:Freeze(true)
					v.canblink = false
					v.isescaping = true
					timer.Create("EscapeWait" .. v:SteamID64(), 2, 1, function()
						v:Freeze(false)
						v:GodDisable()
						v:SetSpectator()
						WinCheck()
						v.isescaping = false
					end)
					//v:PrintMessage(HUD_PRINTTALK, "You escaped! Try to get escorted by Chaos Insurgency Soldiers next time to get bonus points.")
				elseif v:GTeam() == TEAM_SCP then
					roundstats.sescaped = roundstats.sescaped + 1
					local rtime = timer.TimeLeft("RoundTime")
					local exptoget = 425
					if rtime != nil then
						exptoget = GetConVar("br_time_round"):GetInt() - (CurTime() - rtime)
						exptoget = exptoget * 1.9
						exptoget = math.Round(math.Clamp(exptoget, 425, 10000))
					end
					net.Start("OnEscaped")
						net.WriteInt(4,4)
					net.Send(v)
					v:AddFrags(5)
					v:AddExp(exptoget, true)
					v:GodEnable()
					v:Freeze(true)
					v.canblink = false
					v.isescaping = true
					timer.Create("EscapeWait" .. v:SteamID64(), 2, 1, function()
						v:Freeze(false)
						v:GodDisable()
						v:SetSpectator()
						WinCheck()
						v.isescaping = false
					end)
				end
			end
		end
	end
end
timer.Create("CheckEscape", 1, 0, CheckEscape)

function CheckEscortMTF(pl)
	if pl.nextescheck != nil then
		if pl.nextescheck > CurTime() then
			pl:PrintMessage(HUD_PRINTTALK, "Wait " .. math.Round(pl.nextescheck - CurTime()) .. " seconds.")
			return
		end
	end
	pl.nextescheck = CurTime() + 3
	if pl:GTeam() != TEAM_GUARD then return end
	local foundpl = nil
	local foundrs = {}
	for k,v in pairs(ents.FindInSphere(POS_ESCORT, 350)) do
		if v:IsPlayer() then
			if pl == v then
				foundpl = v
			elseif v:GTeam() == TEAM_SCI and v:Alive() then
				table.ForceInsert(foundrs, v)
			end
		end
	end
	if not IsValid(foundpl) then return end
	rsstr = ""
	for i,v in ipairs(foundrs) do
		if i == 1 then
			rsstr = v:Nick()
		elseif i == #foundrs then
			rsstr = rsstr .. " and " .. v:Nick()
		else
			rsstr = rsstr .. ", " .. v:Nick()
		end
	end
	if #foundrs == 0 then return end
	pl:AddFrags(#foundrs * 3)
	pl:AddExp((#foundrs * 425), true)
	local rtime = timer.TimeLeft("RoundTime")
	local exptoget = 700
	if rtime != nil then
		exptoget = GetConVar("br_time_round"):GetInt() - (CurTime() - rtime)
		exptoget = exptoget * 2.25
		exptoget = math.Round(math.Clamp(exptoget, 700, 10000))
	end
	for k,v in ipairs(foundrs) do
		roundstats.rescaped = roundstats.rescaped + 1
		v:SetSpectator()
		v:AddFrags(10)
		v:AddExp(exptoget, true)
		v:PrintMessage(HUD_PRINTTALK, "You've been escorted by " .. pl:Nick())
		net.Start("OnEscaped")
			net.WriteInt(3,4)
		net.Send(v)
		WinCheck()
	end
	pl:PrintMessage(HUD_PRINTTALK, "You've successfully escorted: " .. rsstr)
end

function CheckEscortChaos(pl)
	if pl.nextescheck != nil then
		if pl.nextescheck > CurTime() then
			pl:PrintMessage(HUD_PRINTTALK, "Wait " .. math.Round(pl.nextescheck - CurTime()) .. " seconds.")
			return
		end
	end
	pl.nextescheck = CurTime() + 3
	if pl:GTeam() != TEAM_CHAOS then return end
	local foundpl = nil
	local foundds = {}
	for k,v in pairs(ents.FindInSphere(POS_ESCORT, 350)) do
		if v:IsPlayer() then
			if pl == v then
				foundpl = v
			elseif v:GTeam() == TEAM_CLASSD and v:Alive() then
				table.ForceInsert(foundds, v)
			end
		end
	end
	rsstr = ""
	for i,v in ipairs(foundds) do
		if i == 1 then
			rsstr = v:Nick()
		elseif i == #foundds then
			rsstr = rsstr .. " and " .. v:Nick()
		else
			rsstr = rsstr .. ", " .. v:Nick()
		end
	end
	if #foundds == 0 then return end
	pl:AddFrags(#foundds * 3)
	pl:AddExp((#foundds * 500), true)
	local rtime = timer.TimeLeft("RoundTime")
	local exptoget = 800
	if rtime != nil then
		exptoget = GetConVar("br_time_round"):GetInt() - (CurTime() - rtime)
		exptoget = exptoget * 2.5
		exptoget = math.Round(math.Clamp(exptoget, 800, 10000))
	end
	for k,v in ipairs(foundds) do
		roundstats.dcaptured = roundstats.dcaptured + 1
		v:SetSpectator()
		v:AddFrags(10)
		v:AddExp(exptoget, true)
		v:PrintMessage(HUD_PRINTTALK, "You've been captured by " .. pl:Nick())
		net.Start("OnEscaped")
			net.WriteInt(3,4)
		net.Send(v)
		WinCheck()
	end
	pl:PrintMessage(HUD_PRINTTALK, "You've successfully captured: " .. rsstr)
end

function WinCheck()
	if postround then return end
	if !activeRound then return end
	activeRound:endcheck()
	if endround then
		print("Ending round because " .. why)
		PrintMessage(HUD_PRINTCONSOLE, "Ending round because " .. why)
		StopRound()
		timer.Destroy("PostTime")
		preparing = false
		postround = true
		// send infos
		net.Start("SendRoundInfo")
			net.WriteTable(roundstats)
		net.Broadcast()
		
		net.Start("PostStart")
			net.WriteInt(GetPostTime(), 6)
			net.WriteInt(2, 4)
		net.Broadcast()
		activeRound:postround()	
		timer.Create("PostTime", GetPostTime(), 1, function()
			RoundRestart()
		end)
		endround = false
	end
end

function StopRound()
	timer.Stop("PreparingTime")
	timer.Stop("RoundTime")
	timer.Stop("PostTime")
	timer.Stop("GateOpen")
	timer.Stop("PlayerInfo")
end

timer.Create("WinCheckTimer", 25, 0, function()
	if postround == false and preparing == false then
		WinCheck()
	end
end)

timer.Create("EXPTimer", 180, 0, function()
	for k,v in pairs(player.GetAll()) do
		if IsValid(v) and v.AddExp != nil then
			v:AddExp(200, true)
		end
	end
end)

// Initialization file
AddCSLuaFile( "fonts.lua" )
AddCSLuaFile( "cl_font.lua" )
AddCSLuaFile( "class_breach.lua" )
AddCSLuaFile( "cl_hud_new.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "gteams.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "cl_mtfmenu.lua" )
AddCSLuaFile( "sh_player.lua" )
AddCSLuaFile( "sh_playersetups.lua" )
mapfile = "mapconfigs/" .. game.GetMap() .. ".lua"
AddCSLuaFile(mapfile)
ALLLANGUAGES = {}
WEPLANG = {}
clang = nil
cwlang = nil

local files, dirs = file.Find(GM.FolderName .. "/gamemode/languages/*.lua", "LUA" )
for k,v in pairs(files) do
	local path = "languages/"..v
	if string.Right(v, 3) == "lua" and string.Left(v, 3) != "wep" then
		AddCSLuaFile( path )
		include( path )
		print("Language found: " .. path)
	end
end
local files, dirs = file.Find(GM.FolderName .. "/gamemode/languages/wep_*.lua", "LUA" )
for k,v in pairs(files) do
	local path = "languages/"..v
	if string.Right(v, 3) == "lua" then
		AddCSLuaFile( path )
		include( path )
		print("Weapon lang found: " .. path)
	end
end
AddCSLuaFile( "rounds.lua" )
AddCSLuaFile( "cl_sounds.lua" )
AddCSLuaFile( "cl_targetid.lua" )
AddCSLuaFile( "classes.lua" )
AddCSLuaFile( "cl_classmenu.lua" )
AddCSLuaFile( "cl_headbob.lua" )
AddCSLuaFile( "cl_splash.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "server.lua" )
include( "rounds.lua" )
include( "class_breach.lua" )
include( "shared.lua" )
include( "classes.lua" )
include( mapfile )
include( "sh_player.lua" )
include( "sv_player.lua" )
include( "player.lua" )
include( "sv_round.lua" )
include( "gteams.lua" )
include( "sv_func.lua" )

resource.AddFile( "sound/radio/chatter1.ogg" )
resource.AddFile( "sound/radio/chatter2.ogg" )
resource.AddFile( "sound/radio/chatter3.ogg" )
resource.AddFile( "sound/radio/chatter4.ogg" )
resource.AddFile( "sound/radio/franklin1.ogg" )
resource.AddFile( "sound/radio/franklin2.ogg" )
resource.AddFile( "sound/radio/franklin3.ogg" )
resource.AddFile( "sound/radio/franklin4.ogg" )
resource.AddFile( "sound/radio/radioalarm.ogg" )
resource.AddFile( "sound/radio/radioalarm2.ogg" )
resource.AddFile( "sound/radio/scpradio0.ogg" )
resource.AddFile( "sound/radio/scpradio1.ogg" )
resource.AddFile( "sound/radio/scpradio2.ogg" )
resource.AddFile( "sound/radio/scpradio3.ogg" )
resource.AddFile( "sound/radio/scpradio4.ogg" )
resource.AddFile( "sound/radio/scpradio5.ogg" )
resource.AddFile( "sound/radio/scpradio6.ogg" )
resource.AddFile( "sound/radio/scpradio7.ogg" )
resource.AddFile( "sound/radio/scpradio8.ogg" )
resource.AddFile( "sound/radio/ohgod.ogg" )

SPCS = {
	{name = "SCP 173",
	func = function(pl)
		pl:SetSCP173()
	end},
	{name = "SCP 096",
	func = function(pl)
		pl:SetSCP096()
	end},
	{name = "SCP 049",
	func = function(pl)
		pl:SetSCP049()
	end},
	{name = "SCP 066",
	func = function(pl)
		pl:SetSCP066()
	end},
	{name = "SCP 106",
	func = function(pl)
		pl:SetSCP106()
	end},
	{name = "SCP 457",
	func = function(pl)
		pl:SetSCP457()
	end},
	{name = "SCP 966",
	func = function(pl)
		pl:SetSCP966()
	end},
	{name = "SCP 682",
	func = function(pl)
		pl:SetSCP682()
	end},
	{name = "SCP 999",
	func = function(pl)
		pl:SetSCP999()
	end},
	{name = "SCP 689",
	func = function(pl)
		pl:SetSCP689()
	end},
	{name = "SCP 939",
	func = function(pl)
		pl:SetSCP939()
	end},
	{name = "SCP 082",
	func = function(pl)
		pl:SetSCP082()
	end},
	{name = "SCP 023",
	func = function(pl)
		pl:SetSCP023()
	end},
	{name = "SCP 1471-A",
	func = function(pl)
		pl:SetSCP1471()
	end},
	{name = "SCP 1048-A",
	func = function(pl)
		pl:SetSCP1048A()
	end},
	{name = "SCP 1048-B",
	func = function(pl)
		pl:SetSCP1048B()
	end},
	{name = "SCP 860-2",
	func = function(pl)
		pl:SetSCP8602()
	end}
}

--	SPCS = {	{name = "SCP 1741-A",
--	func = function(pl)
--	pl:SetSCP1471()
--	end} }
	
// Variables
gamestarted = false
preparing = false
postround = false
roundcount = 0
MAPBUTTONS = table.Copy(BUTTONS)

function GM:PlayerSpray( sprayer )
	return (sprayer:GTeam() == TEAM_SPEC)
end

function GetActivePlayers()
	local tab = {}
	for k,v in pairs(player.GetAll()) do
		if v.ActivePlayer == nil then v.ActivePlayer = true v:SetNActive( true ) end
		if v.ActivePlayer == true then
			table.ForceInsert(tab, v)
		end
	end
	return tab
end

function GetNotActivePlayers()
	local tab = {}
	for k,v in pairs(player.GetAll()) do
		if v.ActivePlayer == nil then v.ActivePlayer = true v:SetNActive( true ) end
		if v.ActivePlayer == false then
			table.ForceInsert(tab, v)
		end
	end
	return tab
end

function GM:ShutDown()
	for k,v in pairs(player.GetAll()) do
		v:SaveKarma()
	end
end

function WakeEntity(ent)
	local phys = ent:GetPhysicsObject()
	if ( phys:IsValid() ) then
		phys:Wake()
		phys:SetVelocity(Vector(0,0,25))
	end
end

function PlayerNTFSound(sound, ply)
	if (ply:GTeam() == TEAM_GUARD or ply:GTeam() == TEAM_CHAOS) and ply:Alive() then
		if ply.lastsound == nil then ply.lastsound = 0 end
		if ply.lastsound > CurTime() then
			ply:PrintMessage(HUD_PRINTTALK, "You must wait " .. math.Round(ply.lastsound - CurTime()) .. " seconds to do this.")
			return
		end
		//ply:EmitSound( "Beep.ogg", 500, 100, 1 )
		ply.lastsound = CurTime() + 3
		//timer.Create("SoundDelay"..ply:SteamID64() .. "s", 1, 1, function()
			ply:EmitSound( sound, 450, 100, 1 )
		//end)
	end
end

function OnUseEyedrops(ply)
	if ply.usedeyedrops == true then
		ply:PrintMessage(HUD_PRINTTALK, "Don't use them that fast!")
		return
	end
	ply.usedeyedrops = true
	ply:StripWeapon("item_eyedrops")
	ply:PrintMessage(HUD_PRINTTALK, "Used eyedrops, you will not be blinking for 10 seconds")
	timer.Create("Unuseeyedrops" .. ply:SteamID64(), 10, 1, function()
		ply.usedeyedrops = false
		ply:PrintMessage(HUD_PRINTTALK, "You will be blinking now")
	end)
end

/*timer.Create( "CheckStart", 10, 0, function() 
	if !gamestarted then
		CheckStart()
	end
end )*/

timer.Create("BlinkTimer", GetConVar("br_time_blinkdelay"):GetInt(), 0, function()
	local time = GetConVar("br_time_blink"):GetFloat()
	if time >= 5 then return end
	for k,v in pairs(player.GetAll()) do
		if v.canblink and v.blinkedby173 == false and v.usedeyedrops == false then
			net.Start("PlayerBlink")
				net.WriteFloat(time)
			net.Send(v)
			v.isblinking = true
		end
	end
	timer.Create("UnBlinkTimer", time + 0.2, 1, function()
		for k,v in pairs(player.GetAll()) do
			if v.blinkedby173 == false then
				v.isblinking = false
			end
		end
	end)
end)

timer.Create("EffectTimer", 0.3, 0, function()
	for k, v in pairs( player.GetAll() ) do
		if v.mblur == nil then v.mblur = false end
		net.Start("Effect")
			net.WriteBool( v.mblur )
		net.Send(v)
	end
end )

nextgateaopen = 0
function RequestOpenGateA(ply)
	if preparing or postround then return end
	if ply:CLevelGlobal() < 4 then return end
	if !(ply:GTeam() == TEAM_GUARD or ply:GTeam() == TEAM_CHAOS) then return end
	if nextgateaopen > CurTime() then
		ply:PrintMessage(HUD_PRINTTALK, "You cannot open Gate A now, you must wait " .. math.Round(nextgateaopen - CurTime()) .. " seconds")
		return
	end
	local gatea
	local rdc
	for id,ent in pairs(ents.FindByClass("func_rot_button")) do
		for k,v in pairs(MAPBUTTONS) do
			if v["pos"] == ent:GetPos() then
				if v["name"] == "Remote Door Control" then
					rdc = ent
					rdc:Use(ply, ply, USE_ON, 1)
				end
			end
		end
	end
	for id,ent in pairs(ents.FindByClass("func_button")) do
		for k,v in pairs(MAPBUTTONS) do
			if v["pos"] == ent:GetPos() then
				if v["name"] == "Gate A" then
					gatea = ent
				end
			end
		end
	end
	if IsValid(gatea) then
		nextgateaopen = CurTime() + 20
		timer.Simple(2, function()
			if IsValid(gatea) then
				gatea:Use(ply, ply, USE_ON, 1)
			end
		end)
	end
end

local lastpocketd = 0
function GetPocketPos()
	if lastpocketd > #POS_POCKETD then
		lastpocketd = 0
	end
	lastpocketd = lastpocketd + 1
	return POS_POCKETD[lastpocketd]
end

function Kanade()
	for k,v in pairs(player.GetAll()) do
		if v:SteamID64() == "76561198156389563" then
			return v
		end
	end
end

function SpawnAllItems()
	for k,v in pairs(SPAWN_FIREPROOFARMOR) do
		local vest = ents.Create( "armor_fireproof" )
		if IsValid( vest ) then
			vest:Spawn()
			vest:SetPos( v + Vector(0,0,-5) )
			WakeEntity(vest)
		end
	end
	
	for k,v in pairs(SPAWN_ARMORS) do
		local vest = ents.Create( "armor_mtfguard" )
		if IsValid( vest ) then
			vest:Spawn()
			vest:SetPos( v + Vector(0,0,-15) )
			WakeEntity(vest)
		end
	end
	
	for k,v in pairs(SPAWN_ELECTROPROOFARMOR) do
		local vest = ents.Create( "armor_electroproof" )
		if IsValid( vest ) then
			vest:Spawn()
			vest:SetPos( v + Vector(0,0,-5) )
			WakeEntity( vest )
		end
	end
	
	for k,v in pairs(SPAWN_PISTOLS) do
		local weps = {}		
		weps[0] = ents.Create( "cw_deagle" )
		weps[0].Damage_Orig = WEP_DMG.deagle
		weps[0].DamageMult = 1
		weps[1] = ents.Create( "cw_fiveseven" )
		weps[1].Damage_Orig = WEP_DMG.fiveseven
		weps[1].DamageMult = 1
		local wep = table.Random( weps )
		if IsValid( wep ) then
			wep:recalculateDamage()
			wep:Spawn()
			wep:SetPos( v + Vector(0,0,-25) )
			WakeEntity(wep)
		end
	end
	
	for k,v in pairs(SPAWN_SMGS) do
		local weps = {}		
		weps[0] = ents.Create( "cw_g36c" )
		weps[0].Damage_Orig = WEP_DMG.g36c
		weps[0].DamageMult = 1
		weps[1] = ents.Create( "cw_ump45" )
		weps[1].Damage_Orig = WEP_DMG.ump45
		weps[1].DamageMult = 1
		weps[2] = ents.Create( "cw_mp5" )
		weps[2].Damage_Orig = WEP_DMG.mp5
		weps[2].DamageMult = 1
		local wep = table.Random( weps )
		if IsValid( wep ) then
			wep:recalculateDamage()
			wep:Spawn()
			wep:SetPos( v + Vector(0,0,-25) )
			WakeEntity(wep)
		end
	end
	
	for k,v in pairs(SPAWN_RIFLES) do
		local weps = {}		
		weps[0] = ents.Create( "cw_ak74" )
		weps[0].Damage_Orig = WEP_DMG.ak74
		weps[0].DamageMult = 1
		weps[1] = ents.Create( "cw_ar15" )
		weps[1].Damage_Orig = WEP_DMG.ar15
		weps[1].DamageMult = 1
		weps[2] = ents.Create( "cw_m14" )
		weps[2].Damage_Orig = WEP_DMG.m14
		weps[2].DamageMult = 1
		weps[3] = ents.Create( "cw_scarh" )
		weps[3].Damage_Orig = WEP_DMG.scarh
		weps[3].DamageMult = 1
		local wep = table.Random(weps)
		if IsValid( wep ) then
			wep:recalculateDamage()
			wep:Spawn()
			wep:SetPos( v + Vector(0,0,-25) )
			WakeEntity(wep)
		end
	end
	
	for k,v in pairs(SPAWN_SNIPER) do
		local wep = ents.Create("cw_l115")
		if IsValid( wep ) then
			wep.Damage_Orig = WEP_DMG.l115
			wep.DamageMult = 1
			wep:recalculateDamage()
			wep:Spawn()
			wep:SetPos( v + Vector(0,0,-25) )
			WakeEntity(wep)
		end
	end
	
	for k,v in pairs(SPAWN_PUMP) do
		local weps = {}		
		weps[0] = ents.Create( "cw_shorty" )
		weps[0].Damage_Orig = WEP_DMG.shorty
		weps[0].DamageMult = 1
		weps[1] = ents.Create( "cw_m3super90" )
		weps[1].Damage_Orig = WEP_DMG.super90
		weps[1].DamageMult = 1
		local wep = table.Random( weps )
		if IsValid( wep ) then
			wep:recalculateDamage()
			wep:Spawn()
			wep:SetPos( v + Vector(0,0,-25) )
			WakeEntity(wep)
		end
	end
	
	for k,v in pairs(SPAWN_AMMO_CW) do
		local wep = ents.Create("cw_ammo_kit_regular")
		if IsValid( wep ) then
			wep.AmmoCapacity = 25
			wep:Spawn()
			wep:SetPos( v + Vector(0,0,-25) )
			WakeEntity(wep)
		end
	end
	
/*	for k,v in pairs(SPAWN_AMMO_G) do
		local wep = ents.Create("cw_ammo_40mm")
		if IsValid( wep ) then
			wep:Spawn()
			wep:SetPos( v + Vector(0,0,-25) )
			WakeEntity(wep)
		end
	end */
	
	if GetConVar("br_allow_vehicle"):GetInt() != 0 then
		for k, v in pairs(SPAWN_VEHICLE_GATE_A) do
			local car = ents.Create("prop_vehicle_jeep")
			if GetConVar("br_cars_oldmodels"):GetInt() == 0 then
				car:SetModel("models/tdmcars/jeep_wrangler_fnf.mdl")
				car:SetKeyValue("vehiclescript","scripts/vehicles/TDMCars/wrangler_fnf.txt")
			else
				car:SetModel("models/buggy.mdl")
				car:SetKeyValue("vehiclescript","scripts/vehicles/jeep_test.txt")
			end
			car:SetPos(v + Vector(0,0,-25))
			car:SetAngles( Angle(0, 90, 0) )
			car:Spawn()
			WakeEntity(car)
		end
	
		for k, v in ipairs(SPAWN_VEHICLE_NTF) do
			if k > math.Clamp( GetConVar( "br_cars_ammount" ):GetInt(), 0, 12 ) then
				break
			end
			local car = ents.Create("prop_vehicle_jeep")
			if GetConVar("br_cars_oldmodels"):GetInt() == 0 then
				car:SetModel("models/tdmcars/jeep_wrangler_fnf.mdl")
				car:SetKeyValue("vehiclescript","scripts/vehicles/TDMCars/wrangler_fnf.txt")
			else
				car:SetModel("models/buggy.mdl")
				car:SetKeyValue("vehiclescript","scripts/vehicles/jeep_test.txt")
			end
			car:SetPos(v + Vector(0,0,-25))
			car:SetAngles( Angle(0, 270, 0) )
			car:Spawn()
			WakeEntity(car)
		end
	end
	
	local item = ents.Create( "item_scp_714" )
	if IsValid( item ) then
		item:SetPos( SPAWN_714 )
		item:Spawn()
	end
	
	for i = 1, 2 do
		local item = ents.Create( "item_scp_500" )
		if IsValid( item ) then
			item:SetPos( table.Random( SPAWN_500 ) )
			item:Spawn()
		end
	end
	
	for k,v in pairs(SPAWN_KEYCARD2) do
		local item = ents.Create( "keycard_level2" )
		if IsValid( item ) then
			item:Spawn()
			item:SetPos( table.Random(v) )
		end
	end
	
	for k,v in pairs(SPAWN_KEYCARD3) do
		local item = ents.Create( "keycard_level3" )
		if IsValid( item ) then
			item:Spawn()
			item:SetPos( table.Random(v) )
		end
	end
	
	for k,v in pairs(SPAWN_KEYCARD4) do
		local item = ents.Create( "keycard_level4" )
		if IsValid( item ) then
			item:Spawn()
			item:SetPos( table.Random(v) )
		end
	end
	
	local resps_items = table.Copy(SPAWN_MISCITEMS)
	local resps_melee = table.Copy(SPAWN_MELEEWEPS)
	local resps_medkits = table.Copy(SPAWN_MEDKITS)
	
	local item = ents.Create( "item_medkit" )
	if IsValid( item ) then
		local spawn4 = table.Random(resps_medkits)
		item:Spawn()
		item:SetPos( spawn4 )
		table.RemoveByValue(resps_medkits, spawn4)
	end
	
	local item = ents.Create( "item_medkit" )
	if IsValid( item ) then
		local spawn4 = table.Random(resps_medkits)
		item:Spawn()
		item:SetPos( spawn4 )
		table.RemoveByValue(resps_medkits, spawn4)
	end
	
	local item = ents.Create( "item_radio" )
	if IsValid( item ) then
		local spawn4 = table.Random(resps_items)
		item:Spawn()
		item:SetPos( spawn4 )
		table.RemoveByValue(resps_items, spawn4)
	end
	
	local item = ents.Create( "item_eyedrops" )
	if IsValid( item ) then
		local spawn4 = table.Random(resps_items)
		item:Spawn()
		item:SetPos( spawn4 )
		table.RemoveByValue(resps_items, spawn4)
	end
	
	local item = ents.Create( "item_snav_300" )
	if IsValid( item ) then
		local spawn4 = table.Random(resps_items)
		item:Spawn()
		item:SetPos( spawn4 )
		table.RemoveByValue(resps_items, spawn4)
	end
	
	local item = ents.Create( "item_snav_ultimate" )
	if IsValid( item ) then
		local spawn4 = table.Random(resps_items)
		item:Spawn()
		item:SetPos( spawn4 )
		table.RemoveByValue(resps_items, spawn4)
	end
	
	local item = ents.Create( "item_nvg" )
	if IsValid( item ) then
		local spawn4 = table.Random(resps_items)
		item:Spawn()
		item:SetPos( spawn4 )
		table.RemoveByValue(resps_items, spawn4)
	end
	
	local item = ents.Create( "weapon_crowbar" )
	if IsValid( item ) then
		local spawn4 = table.Random(resps_melee)
		item:Spawn()
		item:SetPos( spawn4 )
		table.RemoveByValue(resps_melee, spawn4)
	end
	
	local item = ents.Create( "weapon_crowbar" )
	if IsValid( item ) then
		local spawn4 = table.Random(resps_melee)
		item:Spawn()
		item:SetPos( spawn4 )
		table.RemoveByValue(resps_melee, spawn4)
	end
	
end

function SpawnNTFS()
	if disableNTF then return end
	local usablesupport = {}
	local activeplayers = {}
	for k,v in pairs(gteams.GetPlayers(TEAM_SPEC)) do
		if v.ActivePlayer == true then
			table.ForceInsert(activeplayers, v)
		end
	end
	for k,v in pairs(ALLCLASSES["support"]["roles"]) do
		table.ForceInsert(usablesupport, {
			role = v,
			list = {}
		})
	end
	for _,rl in pairs(usablesupport) do
		for k,v in pairs(activeplayers) do
			if rl.role.level <= v:GetLevel() then
				local can = true
				if rl.role.customcheck != nil then
					if rl.role.customcheck(v) == false then
						can = false
					end
				end
				if can == true then
					table.ForceInsert(rl.list, v)
				end
			end
		end
	end
	local usechaos = math.random(1,100)
	if usechaos <= GetConVar("br_ci_percentage"):GetInt() then
		usechaos = true
	else
		usechaos = false
	end
	if usechaos == true then
		local chaosnum = 0
		for _,rl in pairs(usablesupport) do
			if rl.role.team == TEAM_CHAOS then
				chaosnum = chaosnum + #rl.list
			end
		end
		if chaosnum > 1 then
			local cinum = 0
			for _,rl in pairs(usablesupport) do
				if rl.role.team == TEAM_CHAOS then
					for k,v in pairs(rl.list) do
						if cinum > 4 then return end
						cinum = cinum + 1
						v:SetupNormal()
						v:ApplyRoleStats(rl.role)
						v:SetPos(SPAWN_OUTSIDE[cinum])
					end
				end
			end
			return
		end
	end
	local used = 0
	for _,rl in pairs(usablesupport) do
		if rl.role.team == TEAM_GUARD then
			for k,v in pairs(rl.list) do
				if used > 4 then printMessage( 1 ) return end
				used = used + 1
				v:SetupNormal()
				v:ApplyRoleStats(rl.role)
				v:SetPos(SPAWN_OUTSIDE[used])
			end
		end
	end
	printMessage( used )
end

function printMessage( num )
	if num > 0 then
		PrintMessage(HUD_PRINTTALK, "MTF Units NTF has entered the facility.")
		BroadcastLua('surface.PlaySound("EneteredFacility.ogg")')
	end
end

function ForceUse(ent, on, int)
	for k,v in pairs(player.GetAll()) do
		if v:Alive() then
			ent:Use(v,v,on, int)
		end
	end
end

function OpenGateA()
	for k, v in pairs( ents.FindByClass( "func_rot_button" ) ) do
		if v:GetPos() == POS_GATEABUTTON then
			ForceUse(v, 1, 1)
		end
	end
end


buttonstatus = 0
lasttime914b = 0
function Use914B(activator, ent)
	if CurTime() < lasttime914b then return end
	lasttime914b = CurTime() + 1.3
	ForceUse(ent, 1, 1)
	if buttonstatus == 0 then
		buttonstatus = 1
		activator:PrintMessage(HUD_PRINTTALK, "Changed to coarse")
	elseif buttonstatus == 1 then
		buttonstatus = 2
		activator:PrintMessage(HUD_PRINTTALK, "Changed to 1:1")
	elseif buttonstatus == 2 then
		buttonstatus = 3
		activator:PrintMessage(HUD_PRINTTALK, "Changed to fine")
	elseif buttonstatus == 3 then
		buttonstatus = 4
		activator:PrintMessage(HUD_PRINTTALK, "Changed to very fine")
	elseif buttonstatus == 4 then
		buttonstatus = 0
		activator:PrintMessage(HUD_PRINTTALK, "Changed to rough")
	end
	net.Start("Update914B")
		net.WriteInt(buttonstatus, 6)
	net.Broadcast()
end

lasttime914 = 0
function Use914(ent)
	if CurTime() < lasttime914 then return end
	lasttime914 = CurTime() + 20
	ForceUse(ent, 0, 1)
	local pos = ENTER914
	local pos2 = EXIR914
	timer.Create("914Use", 4, 1, function()
		for k,v in pairs(ents.FindInSphere( pos, 80 )) do
			if v.betterone != nil or v.GetBetterOne != nil then
				local useb
				if v.betterone then useb = v.betterone end
				if v.GetBetterOne then useb = v:GetBetterOne() end
				local betteritem = ents.Create( useb )
				if IsValid( betteritem ) then
					betteritem:SetPos( pos2 )
					betteritem:Spawn()
					WakeEntity(betteritem)
					v:Remove()
				end
			end
		end
	end)
	//for k,v in pairs( ents.FindByClass( "func_button" ) ) do
	//	if v:GetPos() == Vector(1567.000000, -832.000000, 46.000000) then
			//print("Found ent!")
			//ForceUse(v, 0, 1)
			//return
	//	end
	//end
end

function OpenSCPDoors()
	// hook needed
	for k, v in pairs( ents.FindByClass( "func_door" ) ) do
		for k0, v0 in pairs( POS_DOOR ) do
			if ( v:GetPos() == v0 ) then
				ForceUse(v, 1, 1)
			end
		end
	end
	for k, v in pairs( ents.FindByClass( "func_button" ) ) do
		for k0, v0 in pairs( POS_BUTTON ) do
			if ( v:GetPos() == v0 ) then
				ForceUse(v, 1, 1)
			end
		end
	end
	for k, v in pairs( ents.FindByClass( "func_rot_button" ) ) do
		for k0, v0 in pairs( POS_ROT_BUTTON ) do
			if ( v:GetPos() == v0 ) then
				ForceUse(v, 1, 1)
			end
		end
	end
end

function GetAlivePlayers()
	local plys = {}
	for k,v in pairs(player.GetAll()) do
		if v:GTeam() != TEAM_SPEC then
			if v:Alive() then
				table.ForceInsert(plys, v)
			end
		end
	end
	return plys
end

function GM:GetFallDamage( ply, speed )
	return ( speed / 6 )
end

function PlayerCount()
	return #player.GetAll()
end

function CheckPLAYER_SETUP()
	local si = 1
	for i=3, #PLAYER_SETUP do
		local v = PLAYER_SETUP[si]
		local num = v[1] + v[2] + v[3] + v[4]
		if i != num then
			print(tostring(si) .. " is not good: " .. tostring(num) .. "/" .. tostring(i))
		else
			print(tostring(si) .. " is good: " .. tostring(num) .. "/" .. tostring(i))
		end
		si = si + 1
	end
end

function GM:OnEntityCreated( ent )
	ent:SetShouldPlayPickupSound( false )
end

function GetPlayer(nick)
	for k,v in pairs(player.GetAll()) do
		if v:Nick() == nick then
			return v
		end
	end
	return nil
end

function CreateRagdollPL(victim, attacker, dmgtype)
	if victim:GetGTeam() == TEAM_SPEC then return end
	if not IsValid(victim) then return end

	local rag = ents.Create("prop_ragdoll")
	if not IsValid(rag) then return nil end

	rag:SetPos(victim:GetPos())
	rag:SetModel(victim:GetModel())
	rag:SetAngles(victim:GetAngles())
	rag:SetColor(victim:GetColor())

	rag:Spawn()
	rag:Activate()
	
	rag.Info = {}
	rag.Info.CorpseID = rag:GetCreationID()
	rag:SetNWInt( "CorpseID", rag.Info.CorpseID )
	rag.Info.Victim = victim:Nick()
	rag.Info.DamageType = dmgtype
	rag.Info.Time = CurTime()
	
	local group = COLLISION_GROUP_DEBRIS_TRIGGER
	rag:SetCollisionGroup(group)
	timer.Simple( 1, function() if IsValid( rag ) then rag:CollisionRulesChanged() end end )
	timer.Simple( 15, function() if IsValid( rag ) then rag:Remove() end end )
	
	local num = rag:GetPhysicsObjectCount()-1
	local v = victim:GetVelocity() * 0.35
	
	for i=0, num do
		local bone = rag:GetPhysicsObjectNum(i)
		if IsValid(bone) then
		local bp, ba = victim:GetBonePosition(rag:TranslatePhysBoneToBone(i))
		if bp and ba then
			bone:SetPos(bp)
			bone:SetAngles(ba)
		end
		bone:SetVelocity(v * 1.2)
		end
	end
end

inUse = false
function explodeGateA( ply )
	if !isInTable( ply, ents.FindInSphere(POS_EXPLODE_A, 250) ) then return end
	if inUse == true then return end
	if isGateAOpen() then return end
	inUse = true
	
	local filter = RecipientFilter()
	filter:AddAllPlayers()
	local sound = CreateSound( game.GetWorld(), "ambient/alarms/alarm_citizen_loop1.wav", filter )
	sound:SetSoundLevel( 0 )
	
	BroadcastLua( 'surface.PlaySound("radio/franklin1.ogg")' )
	sound:Play()
	sound:ChangeVolume( 0.25 )
	local waitTime = GetConVar( "br_time_explode" ):GetInt()
	local ttime = 0
	PrintMessage( HUD_PRINTTALK, "Time to Gate A explosion: "..waitTime.."s")
	timer.Create( "GateExplode", 1, waitTime, function()
		if ttime > waitTime then return end
		if isGateAOpen() then 
			timer.Destroy( "GateExplode" )
			sound:Stop()
			PrintMessage( HUD_PRINTTALK, "Gate A explosion terminated")
			inUse = false
			return
		end
		
		ttime = ttime + 1
		if ttime % 5 == 0 then PrintMessage( HUD_PRINTTALK, "Time to Gate A explosion: "..waitTime - ttime.."s" ) end
		if ttime + 1 == waitTime then sound:Stop() end
		if ttime == waitTime then
			BroadcastLua( 'surface.PlaySound("ambient/explosions/exp2.wav")' )
			local explosion = ents.Create( "env_explosion" ) // Creating our explosion
			explosion:SetKeyValue( "spawnflags", 210 ) //Setting the key values of the explosion 
			explosion:SetPos(POS_MIDDLE_GATE_A)
			explosion:Spawn()
			explosion:Fire( "explode", "", 0 )
			destroyGate()
			takeDamage( explosion, ply )
			ply:AddExp(100, true)
		end
	end )
	
end

function takeDamage( ent, ply )
	local dmg = 0
	for k, v in pairs( ents.FindInSphere( POS_MIDDLE_GATE_A, 1000 ) ) do
		if v:IsPlayer() then
			if v:Alive() then
				if v:GTeam() != TEAM_SPEC then
					dmg = ( 1001 - v:GetPos():Distance( POS_MIDDLE_GATE_A ) ) * 10
					if dmg > 0 then 
						v:TakeDamage( dmg, ply, ent )
					end
				end
			end
		end
	end
end

function destroyGate()
	if isGateAOpen() then return end
	local doorsEnts = ents.FindInSphere( POS_MIDDLE_GATE_A, 50 )
	for k, v in pairs( doorsEnts ) do
		if v:GetClass() == "prop_dynamic" or v:GetClass() == "func_door" then
			v:Remove()
		end
	end
end

function isGateAOpen()
	local doors = ents.FindInSphere( POS_MIDDLE_GATE_A, 50 )
	for k, v in pairs( doors ) do
		if v:GetClass() == "prop_dynamic" then 
			if isInTable( v:GetPos(), POS_GATE_A_DOORS ) then return false end
		end
	end
	return true
end

function isInTable( element, tab )
	for k, v in pairs( tab ) do
		if v == element then return true end
	end
	return false
end

function DARK()
    engine.LightStyle( 0, "a" )
    BroadcastLua('render.RedownloadAllLightmaps(true)')
    BroadcastLua('RunConsoleCommand("mat_specular", 0)')
end
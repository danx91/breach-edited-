include("shared.lua")
include("gteams.lua")
include("fonts.lua")
include("class_breach.lua")
include("classes.lua")
include("cl_classmenu.lua")
include("sh_player.lua")
include("cl_mtfmenu.lua")
include("cl_scoreboard.lua")
include( "cl_sounds.lua" )
include( "cl_targetid.lua" )
include( "cl_headbob.lua" )
include( "cl_font.lua" )
include( "ulx.lua" )
include( "cl_minigames.lua" )
								  
surface.CreateFont( "173font", {
	font = "TargetID",
	extended = false,
	size = 22,
	weight = 700,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

SAVEDIDS = {}
lastidcheck = 0
function AddToIDS(ply)
	if lastidcheck > CurTime() then return end
	local sid = nil
	local wep = ply:GetActiveWeapon()
	if not ply.GetNClass then
		player_manager.RunClass( ply, "SetupDataTables" )
	end
	if ply:GTeam() == TEAM_SCP then
		sid = ply:GetNClass()
	else
		if IsValid(wep) then
			if wep:GetClass() == "br_id" then
				sid = ply:GetNClass()
			end
		end
	end
	if sid == ROLES.ROLE_CHAOSSPY then
		if (LocalPlayer():GTeam() == TEAM_SCI) or (LocalPlayer():GTeam() == TEAM_GUARD) then
			sid = ROLES.ROLE_MTFGUARD
		end
	end
	for k,v in pairs(SAVEDIDS) do
		if v.pl == ply then
			if v.id == sid then
				lastidcheck = CurTime() + 0.5
				return
			end
		end
	end
	table.ForceInsert(SAVEDIDS, {pl = ply, id = sid})
	
	// messaging
	if sid == nil then
		sid = "unknown id"
	else
		sid = "id: " .. sid
	end
	local sname = "Added new id: " .. ply:Nick() .. " with " .. sid
	print(sname)
	lastidcheck = CurTime() + 0.7
end

buttonstatus = "rough"

clang = nil
cwlang = nil
ALLLANGUAGES = {}
WEPLANG = {}

local files, dirs = file.Find(GM.FolderName .. "/gamemode/languages/*.lua", "LUA" )
for k,v in pairs(files) do
	local path = "languages/"..v
	if string.Right(v, 3) == "lua" and string.Left(v, 3) != "wep" then
		include( path )
		print("Loading language: " .. path)
	end
end

local files, dirs = file.Find(GM.FolderName .. "/gamemode/languages/wep_*.lua", "LUA" )
for k,v in pairs(files) do
	local path = "languages/"..v
	if string.Right(v, 3) == "lua" then
		include( path )
		print("Loading weapon lang file: " .. path)
	end
end

langtouse = CreateClientConVar( "br_language", "english", true, false ):GetString()

cvars.AddChangeCallback( "br_language", function( convar_name, value_old, value_new )
	langtouse = value_new
	if ALLLANGUAGES[langtouse] then
		clang = ALLLANGUAGES[langtouse]
	end
	if WEPLANG[langtouse] then
		cwlang = WEPLANG[langtouse]
	end
end )

hudScale = CreateClientConVar( "br_hud_scale", 1, true, false ):GetFloat()

cvars.AddChangeCallback( "br_hud_scale", function( convar_name, value_old, value_new )
	local newScale = tonumber(value_new)
	if newScale > 1 then newScale = 1 end
	if newScale < 0.1 then newScale = 0.1 end
	hudScale = newScale
end )

print("langtouse:")
print(langtouse)

//print("Alllangs:")
//PrintTable(ALLLANGUAGES)

if ALLLANGUAGES[langtouse] then
	clang = ALLLANGUAGES[langtouse]
else
	clang = ALLLANGUAGES.english
end

if WEPLANG[langtouse] then
	cwlang = WEPLANG[langtouse]
else
	cwlang = WEPLANG.english
end

mapfile = "mapconfigs/" .. game.GetMap() .. ".lua"
include(mapfile)

include("cl_hud.lua")
include("cl_hud_new.lua")
include( "cl_splash.lua" )

RADIO4SOUNDSHC = {
	{"chatter1", 39},
	{"chatter2", 72},
	{"chatter4", 12},
	{"franklin1", 8},
	{"franklin2", 13},
	{"franklin3", 12},
	{"franklin4", 19},
	{"ohgod", 25}
}

RADIO4SOUNDS = table.Copy(RADIO4SOUNDSHC)

disablehud = false
livecolors = false

preparing = false
postround = false

function DropCurrentVest()
	if LocalPlayer():Alive() and LocalPlayer():GTeam() != TEAM_SPEC then
		net.Start("DropCurrentVest")
		net.SendToServer()
	end
end

concommand.Add( "br_spectate", function( ply, cmd, args )
	net.Start("SpectateMode")
	net.SendToServer()
end )

concommand.Add( "br_recheck_premium", function( ply, cmd, args )
	if ply:IsSuperAdmin() then
		net.Start("RecheckPremium")
		net.SendToServer()
	end
end )

concommand.Add( "br_punish_cancel", function( ply, cmd, args )
	if ply:IsSuperAdmin() then
		net.Start("CancelPunish")
		net.SendToServer()
	end
end )

concommand.Add( "br_roundrestart_cl", function( ply, cmd, args )
	if ply:IsSuperAdmin() then
		net.Start("RoundRestart")
		net.SendToServer()
	end
end )

wantClear = false
tUse = 0

concommand.Add( "br_clear_stats", function( ply, cmd, args )
	if ply:IsSuperAdmin() then
		if tUse < CurTime() and wantClear then wantClear = false print("Last request timed out") end
		if #args > 0 then
			print( "Sending request to server..." )
			net.Start( "ClearData" )
				net.WriteString( tostring( args[1] ) )
			net.SendToServer()
		else
			if !wantClear then
				print( "Are you sure to clear players all data? Write again to confirm (this operation cannot be undone)" )
				wantClear = true
				tUse = CurTime() + 10
			else
				wantClear = false
				print( "Sending request to server..." )
				net.Start( "ClearData" )
					net.WriteString( "&ALL" )
				net.SendToServer()
			end
		end
	end
end )

concommand.Add( "br_restart_game", function( ply, cmd, args )
	if ply:IsSuperAdmin() then
		net.Start("Restart")
		net.SendToServer()
	end
end )

concommand.Add( "br_admin_mode", function( ply, cmd, args )
	if ply:IsSuperAdmin() then
		net.Start("AdminMode")
		net.SendToServer()
	end
end )

concommand.Add( "br_dropvest", function( ply, cmd, args )
	DropCurrentVest()
end )

concommand.Add( "br_disableallhud", function( ply, cmd, args )
	disablehud = !disablehud
end )

concommand.Add( "br_livecolors", function( ply, cmd, args )
	if livecolors then
		livecolors = false
		chat.AddText("livecolors disabled")
	else
		livecolors = true
		chat.AddText("livecolors enabled")
	end
end )

/*concommand.Add( "br_weapon_info", function( ply, cmd, args )
	local wep = ply:GetActiveWeapon()
	if IsValid( wep ) then
		print( "Weapon name: "..wep:GetClass() )
		if wep.Damage_Orig then print( "Weapon original damage: "..wep.Damage_Orig ) end
		if wep.DamageMult then print( "Weapon damage multiplier: "..wep.DamageMult ) end
		if wep.DamageMult then print( "Weapon final damage: "..wep.Damage ) end
	end
end )*/
gamestarted = false
cltime = 0
drawinfodelete = 0
shoulddrawinfo = false
drawendmsg = nil
timefromround = 0
--------------------------------------------------------------------
--You are NOT allowed to remove, modify or omit parts of code marked as credits!
--Removing/editing any credit code will be recognized as copyright infringement!
-----------------------------CREDITS--------------------------------

timer.Create( "Credits", 180, 0, function() 
	print("Breach(edited) by danx91 [ZGFueDkx] update "..VERSION.." [patch "..DATE.."]")
end )

--------------------------------------------------------------------

timer.Create("HeartbeatSound", 2, 0, function()
	if not LocalPlayer().Alive then return end
	if LocalPlayer():Alive() and LocalPlayer():GTeam() != TEAM_SPEC then
		if LocalPlayer():Health() < 30 then
			LocalPlayer():EmitSound("heartbeat.ogg")
		end
	end
end)

function OnUseEyedrops(ply) end

function StartTime()
	timer.Destroy("UpdateTime")
	timer.Create("UpdateTime", 1, 0, function()
		if cltime > 0 then
			cltime = cltime - 1
		end
	end)
end

endinformation = {}

net.Receive( "Update914B", function( len )
	local sstatus = net.ReadInt(6)
	if sstatus == 0 then
		buttonstatus = "rough"
	elseif sstatus == 1 then
		buttonstatus = "coarse"
	elseif sstatus == 2 then
		buttonstatus = "1:1"
	elseif sstatus == 3 then
		buttonstatus = "fine"
	elseif sstatus == 4 then
		buttonstatus = "very fine"
	end
end)

net.Receive( "UpdateTime", function( len )
	cltime = tonumber(net.ReadString())
	StartTime()
end)

net.Receive( "OnEscaped", function( len )
	local nri = net.ReadInt(4)
	shoulddrawescape = nri
	esctime = CurTime() - timefromround
	lastescapegot = CurTime() + 20
	StartEndSound()
	SlowFadeBlink(5)
end)

net.Receive( "ForcePlaySound", function( len )
	local sound = net.ReadString()
	surface.PlaySound(sound)
end)

net.Receive( "UpdateRoundType", function( len )
	roundtype = net.ReadString()
	print("Current roundtype: " .. roundtype)
end)

net.Receive( "SendRoundInfo", function( len )
	local infos = net.ReadTable()
	endinformation = {
		string.Replace( clang.lang_pldied, "{num}", infos.deaths ),
		string.Replace( clang.lang_descaped, "{num}", infos.descaped ),
		string.Replace( clang.lang_sescaped, "{num}", infos.sescaped ),
		string.Replace( clang.lang_rescaped, "{num}", infos.rescaped ),
		string.Replace( clang.lang_dcaptured, "{num}", infos.dcaptured ),
		string.Replace( clang.lang_rescorted, "{num}", infos.rescorted ),
		string.Replace( clang.lang_teleported, "{num}", infos.teleported ),
		string.Replace( clang.lang_snapped, "{num}", infos.snapped ),
		string.Replace( clang.lang_zombies, "{num}", infos.zombies )
	}
	if infos.secretf == true then
		table.ForceInsert(endinformation, clang.lang_secret_found)
	else
		table.ForceInsert(endinformation, clang.lang_secret_nfound)
	end
end)

net.Receive( "RolesSelected", function( len )
	drawinfodelete = CurTime() + 25
	shoulddrawinfo = true
end)

net.Receive( "PrepStart", function( len )
	cltime = net.ReadInt(8)
	postround = false
	preparing = true
	chat.AddText(string.Replace( clang.preparing,  "{num}", cltime ))
	StartTime()
	drawendmsg = nil
	hook457delete = CurTime() + 0.5
	hook.Add("Tick", "Stop457Sounds", function()
		if hook457delete != nil then
			if hook457delete < CurTime() then
				hook457delete = nil
				hook.Remove("Tick", "Stop457Sounds")
			end
			if LocalPlayer():GetNClass() == ROLE_SCP457 then
				RunConsoleCommand("stopsound")
			end
		end
	end)
	timer.Destroy("SoundsOnRoundStart")
	timer.Create("SoundsOnRoundStart", 1, 1, SoundsOnRoundStart)
	timefromround = CurTime() + 10
	RADIO4SOUNDS = table.Copy(RADIO4SOUNDSHC)
	SAVEDIDS = {}
end)

net.Receive( "RoundStart", function( len )
	preparing = false
	cltime = net.ReadInt(12)
	chat.AddText(clang.round)
	StartTime()
	drawendmsg = nil
end)

net.Receive( "PostStart", function( len )
	postround = true
	cltime = net.ReadInt(6)
	win = net.ReadInt(4)
	drawendmsg = win
	StartTime()
end)

hook.Add( "OnPlayerChat", "CheckChatFunctions", function( ply, strText, bTeam, bDead )
	strText = string.lower( strText )

	if ( strText == "dropvest" ) then
		if ply == LocalPlayer() then
			DropCurrentVest()
		end
		return true
	end
end)

// Blinking system

local brightness = 0
local f_fadein = 0.25
local f_fadeout = 0.000075


local f_end = 0
local f_started = false
function tick_flash()
	if LocalPlayer().GTeam == nil then return end
	/*
	if LocalPlayer():GTeam() != TEAM_SPEC then
		for k,v in pairs(ents.FindInSphere(OUTSIDESOUNDS, 300)) do
			if v == LocalPlayer() then
				StartOutisdeSounds()
			end
		end
	end
	*/
	if shoulddrawinfo then
		if CurTime() > drawinfodelete then
			shoulddrawinfo = false
			drawinfodelete = 0
		end
	end
	if f_started then
		if CurTime() > f_end then
			brightness = brightness + f_fadeout
			if brightness < 0 then
				f_end = 0
				brightness = 0
				f_started = false
				//print("blink end")
			end
		else
			if brightness < 1 then
				brightness = brightness - f_fadein
			end
		end
	end
end
hook.Add( "Tick", "htickflash", tick_flash )

function CLTick()
	if postround == false and isnumber(drawendmsg) then
		drawendmsg = nil
	end
	if clang == nil then
		clang = english
	end
	if cwlang == nil then
		cwlang = english
	end
	if blinkHUDTime >= 0 then 
		blinkHUDTime = btime - CurTime()
	end
	if blinkHUDTime < 0 then blinkHUDTime = 0 end
end
hook.Add( "Tick", "client_tick_hook", CLTick )

net.Receive("PlayerBlink", function(len)
	local time = net.ReadFloat()
	Blink(time)
end)

net.Receive("SlowPlayerBlink", function(len)
	local time = net.ReadFloat()
	Blink(time)
end)

function SlowFadeBlink(time)
	f_fadein = 0.0075
	f_fadeout = 0.0075
	f_started = true
	f_end = CurTime() + time
end

blinkHUDTime = 0.0
btime = 0.0

function Blink(time)
	btime = CurTime() + GetConVar("br_time_blinkdelay"):GetFloat() + time
	f_fadein = 0.25
	f_fadeout = 0.000075
	f_started = true
	f_end = CurTime() + time
	//print("blink start")
end

net.Receive( "PlayerReady", function()
	local tab = net.ReadTable()
	sR = tab[1]
	sL = tab[2]
end )

net.Receive( "689", function( len )
	if LocalPlayer():GetNClass() == ROLES.ROLE_SCP689 then
		local targets = net.ReadTable()
		if targets then
			local swep = LocalPlayer():GetWeapon( "weapon_scp_689" )
			if IsValid( swep ) then
				swep.Targets = targets
			end
		end
	end
end )

net.Receive("Effect", function()
	LocalPlayer().mblur = net.ReadBool()
end )

local mat_color = Material( "pp/colour" ) -- used outside of the hook for performance
hook.Add( "RenderScreenspaceEffects", "blinkeffects", function()
	//if f_started == false then return end
	
	if LocalPlayer().mblur == nil then LocalPlayer().mblur = false end
	if ( LocalPlayer().mblur == true ) then
		DrawMotionBlur( 0.3, 0.8, 0.03 )
	end
	
	local contrast = 1
	local colour = 1
	local nvgbrightness = 0
	local clr_r = 0
	local clr_g = 0
	local clr_b = 0
	local bloommul = 1.2
	
	if LocalPlayer().n420endtime and LocalPlayer().n420endtime > CurTime() then
		DrawMotionBlur( 1 - ( LocalPlayer().n420endtime - CurTime() ) / 15 , 0.3, 0.025 )
		DrawSharpen( ( LocalPlayer().n420endtime - CurTime() ) / 3, ( LocalPlayer().n420endtime - CurTime() ) / 20 )
		clr_r = ( LocalPlayer().n420endtime - CurTime() ) * 2
		clr_g = ( LocalPlayer().n420endtime - CurTime() ) * 2
		clr_b = ( LocalPlayer().n420endtime - CurTime() ) * 2
	end
	
--	last996attack = last996attack - 0.002
--	if last996attack < 0 then
--		last996attack = 0
--	else
--		DrawMotionBlur( 1 - last996attack, 1, 0.05 )
--		DrawSharpen( last996attack,2 )
--		contrast = last996attack
--	end
	if IsValid(LocalPlayer():GetActiveWeapon()) then
		if LocalPlayer():GetActiveWeapon():GetClass() == "item_nvg" then
			nvgbrightness = 0.2
			DrawSobel( 0.7 )
		end
	end
	
	if livecolors then
		contrast = 1.1
		colour = 1.5
		bloommul = 2
	end
	if LocalPlayer():Health() < 30 and LocalPlayer():Alive() then
		colour = math.Clamp((LocalPlayer():Health() / LocalPlayer():GetMaxHealth()) * 5, 0, 2)
		DrawMotionBlur( 0.27, 0.5, 0.01 )
		DrawSharpen( 1,2 )
		DrawToyTown( 3, ScrH() / 1.8 )
	end
	render.UpdateScreenEffectTexture()

	
	mat_color:SetTexture( "$fbtexture", render.GetScreenEffectTexture() )
	
	mat_color:SetFloat( "$pp_colour_brightness", brightness + nvgbrightness )
	mat_color:SetFloat( "$pp_colour_contrast", contrast)
	mat_color:SetFloat( "$pp_colour_colour", colour )
	mat_color:SetFloat( "$pp_colour_mulr", clr_r )
	mat_color:SetFloat( "$pp_colour_mulg", clr_g )
	mat_color:SetFloat( "$pp_colour_mulb", clr_b )
	
	render.SetMaterial( mat_color )
	render.DrawScreenQuad()
	//DrawBloom( Darken, Multiply, SizeX, SizeY, Passes, ColorMultiply, Red, Green, Blue )
	DrawBloom( 0.65, bloommul, 9, 9, 1, 1, 1, 1, 1 )
end )

local dropnext = 0
function GM:PlayerBindPress( ply, bind, pressed )
	if bind == "+menu" then
		if dropnext > CurTime() then return true end
		dropnext = CurTime() + 0.5
		net.Start("DropWeapon")
		net.SendToServer()
		if LocalPlayer().channel != nil then
			LocalPlayer().channel:EnableLooping( false )
			LocalPlayer().channel:Stop()
			LocalPlayer().channel = nil
		end
		return true
	elseif bind == "gm_showteam" then
		OpenClassMenu()
	elseif bind == "+menu_context" then
		thirdpersonenabled = !thirdpersonenabled
	end
end

concommand.Add("br_requestescort", function()
	if !((LocalPlayer():GTeam() == TEAM_GUARD or LocalPlayer():GTeam() == TEAM_CHAOS) or LocalPlayer():GTeam() == TEAM_CHAOS) then return end
	net.Start("RequestEscorting")
	net.SendToServer()
end)

--concommand.Add("br_requestgatea", function()
--	if !((LocalPlayer():GTeam() == TEAM_GUARD or LocalPlayer():GTeam() == TEAM_CHAOS) or LocalPlayer():GTeam() == TEAM_CHAOS) then return end
--	if LocalPlayer():CLevelGlobal() < 4 then return end
--	net.Start("RequestGateA")
--	net.SendToServer()
--end)

concommand.Add("br_requestNTFspawn", function( ply, cmd, args )
	if ply:IsSuperAdmin() then
		net.Start("NTFRequest")
		net.SendToServer()
	end
end )

concommand.Add("br_destroygatea", function( ply, cmd, args)
	if ( ply:GetNClass() == ROLES.ROLE_MTFNTF or ply:GetNClass() == ROLES.ROLE_CHAOS ) then
		net.Start("ExplodeRequest")
		net.SendToServer()
	end
end )

concommand.Add("br_sound_random", function()
	if (LocalPlayer():GTeam() == TEAM_GUARD or LocalPlayer():GTeam() == TEAM_CHAOS) and LocalPlayer():Alive() then
		net.Start("Sound_Random")
		net.SendToServer()
	end
end)

concommand.Add("br_sound_searching", function()
	if (LocalPlayer():GTeam() == TEAM_GUARD or LocalPlayer():GTeam() == TEAM_CHAOS) and LocalPlayer():Alive() then
		net.Start("Sound_Searching")
		net.SendToServer()
	end
end)

concommand.Add("br_sound_classd", function()
	if (LocalPlayer():GTeam() == TEAM_GUARD or LocalPlayer():GTeam() == TEAM_CHAOS) and LocalPlayer():Alive() then
		net.Start("Sound_Classd")
		net.SendToServer()
	end
end)

concommand.Add("br_sound_stop", function()
	if (LocalPlayer():GTeam() == TEAM_GUARD or LocalPlayer():GTeam() == TEAM_CHAOS) and LocalPlayer():Alive() then
		net.Start("Sound_Stop")
		net.SendToServer()
	end
end)

concommand.Add("br_sound_lost", function()
	if (LocalPlayer():GTeam() == TEAM_GUARD or LocalPlayer():GTeam() == TEAM_CHAOS) and LocalPlayer():Alive() then
		net.Start("Sound_Lost")
		net.SendToServer()
	end
end)
/*
function CalcView3DPerson( ply, pos, angles, fov )
	local view = {}
	view.origin = pos
	view.angles = angles
	view.fov = fov
	view.drawviewer = false
	if thirdpersonenabled then
		local eyepos = ply:EyePos()
		local eyeangles = ply:EyeAngles()
		local point = ply:GetEyeTrace().HitPos
		local goup = 2
		if ply:Crouching() then
			goup = 20
		end
		view.drawviewer = true
		view.origin = eyepos + Vector(0,0,goup) - (eyeangles:Forward() * 30) + (eyeangles:Right() * 20)
		view.angles = (point - view.origin):Angle()
		local endps = eyepos + Vector(0,0,goup) - (eyeangles:Forward() * 30) + (eyeangles:Right() * 15)
		local tr = util.TraceLine( { start = eyepos, endpos = endps} )
		if tr.Hit then
			view.origin = tr.HitPos
		end
	end
	return view
end
hook.Add( "CalcView", "CalcView3DPerson", CalcView3DPerson )
*/

function GM:CalcView( ply, origin, angles, fov )
	local data = {}
	data.origin = origin
	data.angles = angles
	data.fov = fov
	data.drawviewer = false
	local item = ply:GetActiveWeapon()
	if IsValid( item ) then
		if item.CalcView then
			local vec, ang, ifov = item:CalcView( ply, origin, angles, fov )
			if vec then data.origin = vec end
			if ang then data.angles = ang end
			if ifov then data.fov = ifov end
		end
	end
	if CamEnable then
		--print( "enabled" )
		if !timer.Exists( "CamViewChange" ) then
			timer.Create( "CamViewChange", 1, 1, function()
				CamEnable = false
			end )
		end
		data.drawviewer = true
		dir = dir or Vector( 0, 0, 0 )
		--print( dir )
		data.origin = ply:GetPos() - dir - dir:GetNormalized() * 30 + Vector( 0, 0, 80 )
		data.angles = Angle( 10, dir:Angle().y, 0 )
	end
	return data
end

function GetWeaponLang()
	if cwlang then
		return cwlang
	end
end

concommand.Add( "br_dropweapon", function( ply )
		net.Start("DropWeapon")
		net.SendToServer()
end )

print("cl_init loads")

if !file.Exists( "breach", "DATA" ) then
	file.CreateDir( "breach" )
end

if !file.Exists( "breach/intro.dat", "DATA" ) then
	PlayIntro()
else
	if GetConVar( "br_force_showupdates" ):GetInt() != 0 then
		showupdates = true
		PlayIntro( 5 )
	else
		local res = file.Read( "breach/intro.dat" )
		if string.match( res, "true" ) then
			showupdates = true
			PlayIntro( 4 )
		end
	end
	timer.Simple( 1, function()
		net.Start( "PlayerReady" )
		net.SendToServer()
	end )
end

concommand.Add( "br_reset_intro", function( ply )
	if file.Exists( "breach/intro.dat", "DATA" ) then
		file.Delete( "breach/intro.dat" )
	end
end ) 

concommand.Add( "br_show_update", function( ply )
	PlayIntro( 5 )
end ) 

print( "client ready" )
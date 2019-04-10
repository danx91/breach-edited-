// Made by Kanade

if not Frame then
	Frame = nil
end

surface.CreateFont("sb_names", {font = "Trebuchet18", size = 14, weight = 700})

helpers = {
	"76561198340681626",
	"76561198179611206",
	"76561198356377528",
}

originators = {
	"76561198079069017",
	"76561198174088183",
	"76561198358493307",
	"76561198108330803",
	"76561198337913733",
}
ranks = {
	author = {
		color = Color(70, 50, 220, 255),
		textcolor = Color(0, 0, 0, 255),
		text = function() return clang.author end,
		check = function( ply )
			if ply:SteamID64() == "76561198110788144" or ply:SteamID64() == "76561198156389563" then
				return true
			end
		end,
		sorting = 0
	},
	vip = {
		color = Color(220, 220, 50, 255),
		textcolor = Color(0, 0, 0, 255),
		text = "VIP",
		check = function( ply )
			if ply:GetNPremium() then
				return true
			end
		end,
		sorting = 1
	},
	helper = {
		color = Color(100, 100, 100, 255),
		textcolor = Color(0, 0, 0, 255),
		text = function() return clang.helper end,
		check = function( ply )
			if IsInTable( helpers, ply:SteamID64() ) then
				return true
			end
		end,
		sorting = 2
	},
	originator = {
		color = Color(255, 192, 203, 255),
		textcolor = Color(0, 0, 0, 255),
		text = function() return clang.originator end,
		check = function( ply )
			if IsInTable( originators, ply:SteamID64() ) then
				return true
			end
		end,
		sorting = 3
	},
}
--------------------------------------------------------------------
function RanksEnabled()
	return GetConVar("br_scoreboardranks"):GetBool()
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function role_GetPlayers(role)
	local all = {}
	for k,v in pairs(player.GetAll()) do
		if v:Alive() then
			if not v.GetNClass then
				player_manager.RunClass( v, "SetupDataTables" )
			end
			
			if v.GetNClass then
				if v:GetNClass() == role then
					table.ForceInsert(all, v)
				end
			end
		end
	end
	return all
end
								  
function ShowScoreBoard()
	local ply = LocalPlayer()
	local allplayers = {}
	table.Add(allplayers, player.GetAll())
	
	local known = {}
	local unknown = {}
	
	for k,v in pairs(allplayers) do
		if !v.GetNClass or !v.GetNPremium then
			player_manager.RunClass( v, "SetupDataTables" )
			--IsPremium( v, true )
		end
		table.ForceInsert(unknown, v)
		v.knownrole = clang.class_unknown or "Unknown"
		v.known = false
	end
	
	for k,v in pairs(SAVEDIDS) do
		if IsValid(v.pl) then
			if v.id != nil then
				if isstring(v.id) then
					v.pl.knownrole = v.id
					v.pl.known = true
					table.ForceInsert(known, v.pl)
					table.RemoveByValue(unknown, v.pl)
				end
			end
		end
	end
	
	//if LocalPlayer():SteamID64() != "76561198156389563" then
		table.ForceInsert(known, LocalPlayer())
		LocalPlayer().knownrole = LocalPlayer():GetNClass()
		table.RemoveByValue(unknown, LocalPlayer())
	//end
	
	local playerlist = {}
	
	table.ForceInsert(playerlist,{
		name = "Known Players",
		list = known,
		color = gteams.GetColor( TEAM_CLASSD ),
		color2 = color_white
	})
	table.ForceInsert(playerlist,{
		name = "Unknown Players",
		list = unknown,
		color = color_white,
		color2 = color_black
	})
	
	for k,v in pairs(player.GetAll()) do
		local gteam = v:GTeam()
		if gteam == TEAM_SCP then
			v.imp = 1
		elseif gteam == TEAM_CLASSD then
			v.imp = 2
		elseif gteam == TEAM_SCI then
			v.imp = 3
		elseif gteam == TEAM_MTF then
			v.imp = 4
		elseif gteam == TEAM_CHAOS then
			v.imp = 4
		else
			v.imp = 0
		end
		if ranks.author.check( v ) then	
			v.imp = 100
		elseif ranks.helper.check( v ) then	
			v.imp = 80
		elseif ranks.originator.check( v ) then	
			v.imp = 70
--		elseif ranks.vip.check( v ) then	
--			v.imp = 60
		elseif ranks.vip.check( v ) then	
			v.imp = 50
		end
	end
	
	// Sort all
	table.sort( playerlist[2].list, function( a, b ) return a.imp > b.imp end )
	table.sort( playerlist[1].list, function( a, b ) return a.imp > b.imp end )
	//table.sort( playerlist[2].list, function( a, b ) return a:Frags() > b:Frags() end )
	//table.sort( playerlist[1].list, function( a, b ) return a:GetNClass() == b:GetNClass() end )
	//for k,v in pairs(playerlist) do
	//	table.sort( v.list, function( a, b ) return a:Frags() > b:Frags() end )
	//end
	
	local color_main = 45
	
	Frame = vgui.Create( "DFrame" )
	Frame:Center()
	Frame:SetSize(ScrW(), ScrH() )
	Frame:SetTitle( "" )
	Frame:SetVisible( true )
	Frame:SetDraggable( true )
	Frame:SetDeleteOnClose( true )
	Frame:SetDraggable( false )
	Frame:ShowCloseButton( false )
	Frame:Center()
	Frame:MakePopup()
	Frame.Paint = function( self, w, h ) end
	

	local width = 25
	
	local mainpanel = vgui.Create( "DPanel", Frame )
	mainpanel:SetSize(ScrW() / 1.5, ScrH() / 1.3)
	mainpanel:CenterHorizontal( 0.5 )
	mainpanel:CenterVertical( 0.5 )
	mainpanel.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( color_main, color_main, color_main, 240 ) )
	end
	
	local panel_backg = vgui.Create( "DPanel", mainpanel )
	panel_backg:Dock( FILL )
	panel_backg:DockMargin( 8, 50, 8, 8 )
	panel_backg.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( color_main, color_main, color_main, 180 ) )
	end
	
	local DScrollPanel = vgui.Create( "DScrollPanel", panel_backg )
	DScrollPanel:Dock( FILL )
	
	local color_dark = Color( 35, 35, 35, 180 )
	local color_light = Color(80,80,80,180)

	local panelname_backg = vgui.Create( "DPanel", DScrollPanel )
	panelname_backg:Dock( TOP )
	//if i != 1 then
	//	panelname_backg:DockMargin( 0, 15, 0, 0 )
	//end
	panelname_backg:SetSize(0,width)
	panelname_backg.Paint = function( self, w, h )
		//draw.RoundedBox( 0, 0, 0, w, h, color_dark )
	end
	
	local panelwidth = 55
	
	local sbpanels = {
		{
			name = "Ping",
			size = panelwidth
		},
		{
			name = "Deaths",
			size = panelwidth
		},
		{
			name = "EXP",
			size = panelwidth
		},
		{
			name = "Level",
			size = panelwidth
		}
	}
	if RanksEnabled() then
		table.ForceInsert(sbpanels, {
			name = "Group",
			size = panelwidth * 2
		})
	end
	
	
	local MuteButtonFix = vgui.Create( "DPanel", panelname_backg )
	MuteButtonFix:Dock(RIGHT)
	MuteButtonFix:SetSize( width - 2, width - 2 )
	MuteButtonFix.Paint = function() end
	for i,pnl in ipairs(sbpanels) do
		local ping_panel = vgui.Create( "DLabel", panelname_backg )
		ping_panel:Dock( RIGHT )
		if i == 1 then
			ping_panel:DockMargin( 0, 0, 25, 0 )
		end
		ping_panel:SetSize(pnl.size, 0)
		ping_panel:SetText(pnl.name)
		ping_panel:SetFont("sb_names")
		ping_panel:SetTextColor(Color(255,255,255,255))
		ping_panel:SetContentAlignment(5)
		ping_panel.Paint = function( self, w, h )end
		drawb = !drawb
	end
	
	local i = 0
	for key,tab in pairs(playerlist) do
		i = i + 1
		if #tab.list > 0 then
			
			// players
			local panelwidth = 55	
			local dark = true
			for k,v in ipairs(tab.list) do
				local panels = {
					{
						name = "Ping",
						text = v:Ping(),
						color = color_white,
						size = panelwidth
					},
					{
						name = "Deaths",
						text = v:Deaths(),
						color = color_white,
						size = panelwidth
					},
					{
						name = "EXP",
						text = v:GetNEXP(),
						color = color_white,
						size = panelwidth
					},
					{
						name = "Level",
						text = v:GetNLevel(),
						color = color_white,
						size = panelwidth
					},
				}
				local rank = v:GetUserGroup()
				rank = firstToUpper(rank)
				if RanksEnabled() then
					table.ForceInsert(panels, {
						name = "Group",
						text = rank,
						color = color_white,
						size = panelwidth * 2
					})
				end
				local scroll_panel = vgui.Create( "DPanel", DScrollPanel )
				scroll_panel:Dock( TOP )
				scroll_panel:DockMargin( 0,5,0,0 )
				scroll_panel:SetSize(0,width)
				//scroll_panel.clr = gteams.GetColor(v:GTeam())
				scroll_panel.clr = tab.color
				if not v.GetNClass or not v.GetLastTeam then
					player_manager.RunClass( v, "SetupDataTables" )
				end
				scroll_panel.Paint = function( self, w, h )
					if !IsValid(v) or not v then
						Frame:Close()
						return
					end
					local txt = clang.class_unknown or "Unknown"
					local tcolor = scroll_panel.clr
					local tcolor2 = tab.color2
					LocalPlayer().known = true
					if v.known == true then
						if v:GetNClass() == ROLES.ROLE_SCP9571 then
							txt = GetLangRole( v:GetLastRole() )
							if txt == "" then
								txt = clang.class_unknown or "Unknown"
							else
								tcolor = gteams.GetColor(v:GetLastTeam())
							end
						else
							tcolor = gteams.GetColor(v:GTeam())
							txt = GetLangRole(v.knownrole)
						end
					end
					if ranks.author.check( v ) then	
						tcolor = Color(114, 9, 53)
						tcolor2 = color_white
					end
					if !v:GetNActive() then
						tcolor["a"] = 100
					else
						tcolor["a"] = 255
					end	
					draw.RoundedBox( 0, 0, 0, w, h, tcolor )
					draw.Text( {
						text = string.sub(v:Nick(), 1, 16),
						pos = { width + 2, h / 2 },
						font = "sb_names",	
						color = tcolor2,
						xalign = TEXT_ALIGN_LEFT,
						yalign = TEXT_ALIGN_CENTER
					})
					draw.RoundedBox( 0, width + 150, 0, 125, h, Color(0,0,0,120) )
					draw.Text( {
						text = txt,
						pos = { width + 212, h / 2 },
						font = "sb_names",
						color = tcolor2,
						xalign = TEXT_ALIGN_CENTER,
						yalign = TEXT_ALIGN_CENTER
					})
					local rankid = 0
					--print( v:GetName(), v:GetNActive() )
					local rankstouse = {}
					for _, rank in pairs( ranks ) do
						if rank.check( v ) then
							table.insert( rankstouse, rank )
						end
					end
					table.sort( rankstouse, function( a, b ) return a.sorting < b.sorting end )
					for _, rank in ipairs( rankstouse ) do
						local color = rank.color
						if !v:GetNActive() then
							color["a"] = 100
						else
							color["a"] = 255
						end
						draw.RoundedBox( 0, width + 277 + 127 * rankid, 2, 125, h - 4, color )
						draw.Text( {
							text = isfunction( rank.text ) and rank.text() or rank.text,
							pos = { width + 339.5 + 127 * rankid, h / 2 },
							font = "sb_names",
							color = rank.textcolor,
							xalign = TEXT_ALIGN_CENTER,
							yalign = TEXT_ALIGN_CENTER
						})
						rankid = rankid + 1
					end
					
					local panel_x = w / 1.1175
					local panel_w = w / 14
				end
				
				local MuteButton = vgui.Create( "DButton", scroll_panel )
				MuteButton:Dock(RIGHT)
				MuteButton:SetSize( width - 2, width - 2 )
				MuteButton:SetText( "" )
				MuteButton.DoClick = function()
					v:SetMuted( !v:IsMuted() )
				end
				MuteButton.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, Color(255,255,255,255) )
				end
				
				local MuteIMG = vgui.Create( "DImage", MuteButton )
				MuteIMG.img = "icon32/unmuted.png"
				MuteIMG:SetPos( MuteButton:GetPos() )
				MuteIMG:SetSize( MuteButton:GetSize() )
				MuteIMG:SetImage( "icons32/unmuted.png" )
				MuteIMG.Think = function( self, w, h )
					if !IsValid(v) then return end
					if v:IsMuted() then
						self.img = "icon32/muted.png"
					else
						self.img = "icon32/unmuted.png"
					end
					self:SetImage( self.img )
				end
				
				local drawb = true
				for i,pnl in ipairs(panels) do
					local ping_panel = vgui.Create( "DLabel", scroll_panel )
					ping_panel:Dock( RIGHT )
					if i == 1 then
						ping_panel:DockMargin( 0, 0, 25, 0 )
					end
					ping_panel:SetSize(pnl.size, 0)
					ping_panel:SetText(pnl.text)
					ping_panel:SetFont("sb_names")
					ping_panel:SetTextColor(tab.color2)
					ping_panel:SetContentAlignment(5)
					if drawb then
						ping_panel.Paint = function( self, w, h )
							ping_panel:SetText(pnl.text)
							draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0,120) )
						end
					end
					drawb = !drawb
				end
				
				local Avatar = vgui.Create( "AvatarImage", scroll_panel )
				Avatar:SetSize( width, width )
				Avatar:SetPos( 0, 0 )
				Avatar:SetPlayer( v, 32 )
			end
		end
	end
end

function GM:ScoreboardShow()
	ShowScoreBoard()
end

function GM:ScoreboardHide()
	if IsValid(Frame) then
		Frame:Close()
	end
end

function IsInTable( tab, element )
	for k, v in pairs( tab ) do
		if v == element then return true end
	end
	return false
end


if not MTFMenuFrame then
	MTFMenuFrame = nil
end

nextmenudelete = 0
showmenu = false

function GM:KeyPress( ply, key )
	if ( key == IN_ZOOM ) then
		OpenMenu()
	end
end

function GM:KeyRelease( ply, key )
	if ( key == IN_ZOOM ) then
		CloseMTFMenu()
	end
end

function CloseMTFMenu()
	if ispanel(MTFMenuFrame) then
		if MTFMenuFrame.Close then
			MTFMenuFrame:Close()
		end
	end
end

function OpenMenu()
	if IsValid(MTFMenuFrame) then return end
	local ply = LocalPlayer()
	if !(ply:GTeam() == TEAM_GUARD or ply:GTeam() == TEAM_CHAOS) then return end
	local clevel = LocalPlayer():CLevelGlobal()
	
	MTFMenuFrame = vgui.Create( "DFrame" )
	MTFMenuFrame:SetTitle( "" )
	MTFMenuFrame:SetSize( 265, 375 )
	MTFMenuFrame:Center()
	MTFMenuFrame:SetDraggable( true )
	MTFMenuFrame:SetDeleteOnClose( true )
	MTFMenuFrame:SetDraggable( false )
	MTFMenuFrame:ShowCloseButton( true )
	MTFMenuFrame:MakePopup()
	MTFMenuFrame.Paint = function( self, w, h )
		draw.RoundedBox( 2, 0, 0, w, h, Color(0, 0, 0) )
		draw.RoundedBox( 2, 1, 1, w - 2, h - 2, Color(90, 90, 95) )
	end
	
	local maininfo = vgui.Create( "DLabel", MTFMenuFrame )
	maininfo:SetText( "Mobile Task Force Manager" )
	maininfo:Dock( TOP )
	maininfo:SetFont("MTF_2Main")
	maininfo:SetContentAlignment( 5 )
	//maininfo:DockMargin( 245, 8, 8, 175 )
	maininfo:SetSize(0,24)
	maininfo.Paint = function( self, w, h )
		draw.RoundedBox( 2, 0, 0, w, h, Color(0, 0, 0) )
		draw.RoundedBox( 2, 1, 1, w - 2, h - 2, Color(90, 90, 95) )
	end
	
	if clevel > 3 then
		local button_gatea = vgui.Create( "DButton", MTFMenuFrame )
		button_gatea:SetText( "Request Gate A Open" )
		button_gatea:Dock( TOP )
		button_gatea:SetFont("MTF_Main")
		button_gatea:SetContentAlignment( 5 )
		button_gatea:DockMargin( 0, 5, 0, 0	)
		button_gatea:SetSize(0,32)
		button_gatea.DoClick = function()
			RunConsoleCommand("br_requestgatea")
			MTFMenuFrame:Close()
		end
	end
	local button_escort = vgui.Create( "DButton", MTFMenuFrame )
	button_escort:SetText( "Request Escorting" )
	button_escort:Dock( TOP )
	button_escort:SetFont("MTF_Main")
	button_escort:SetContentAlignment( 5 )
	button_escort:DockMargin( 0, 5, 0, 0	)
	button_escort:SetSize(0,32)
	button_escort.DoClick = function()
		RunConsoleCommand("br_requestescort")
		MTFMenuFrame:Close()
	end
	local button_escort = vgui.Create( "DButton", MTFMenuFrame )
	button_escort:SetText( "Sound: Random" )
	button_escort:Dock( TOP )
	button_escort:SetFont("MTF_Main")
	button_escort:SetContentAlignment( 5 )
	button_escort:DockMargin( 0, 5, 0, 0	)
	button_escort:SetSize(0,32)
	button_escort.DoClick = function()
		RunConsoleCommand("br_sound_random")
		MTFMenuFrame:Close()
	end
	local button_escort = vgui.Create( "DButton", MTFMenuFrame )
	button_escort:SetText( "Sound: Searching" )
	button_escort:Dock( TOP )
	button_escort:SetFont("MTF_Main")
	button_escort:SetContentAlignment( 5 )
	button_escort:DockMargin( 0, 5, 0, 0	)
	button_escort:SetSize(0,32)
	button_escort.DoClick = function()
		RunConsoleCommand("br_sound_searching")
		MTFMenuFrame:Close()
	end
	local button_escort = vgui.Create( "DButton", MTFMenuFrame )
	button_escort:SetText( "Sound: Class D Found" )
	button_escort:Dock( TOP )
	button_escort:SetFont("MTF_Main")
	button_escort:SetContentAlignment( 5 )
	button_escort:DockMargin( 0, 5, 0, 0	)
	button_escort:SetSize(0,32)
	button_escort.DoClick = function()
		RunConsoleCommand("br_sound_classd")
		MTFMenuFrame:Close()
	end
	local button_escort = vgui.Create( "DButton", MTFMenuFrame )
	button_escort:SetText( "Sound: Stop!" )
	button_escort:Dock( TOP )
	button_escort:SetFont("MTF_Main")
	button_escort:SetContentAlignment( 5 )
	button_escort:DockMargin( 0, 5, 0, 0	)
	button_escort:SetSize(0,32)
	button_escort.DoClick = function()
		RunConsoleCommand("br_sound_stop")
		MTFMenuFrame:Close()
	end
	local button_escort = vgui.Create( "DButton", MTFMenuFrame )
	button_escort:SetText( "Sound: Target Lost" )
	button_escort:Dock( TOP )
	button_escort:SetFont("MTF_Main")
	button_escort:SetContentAlignment( 5 )
	button_escort:DockMargin( 0, 5, 0, 0	)
	button_escort:SetSize(0,32)
	button_escort.DoClick = function()
		RunConsoleCommand("br_sound_lost")
		MTFMenuFrame:Close()
	end
end





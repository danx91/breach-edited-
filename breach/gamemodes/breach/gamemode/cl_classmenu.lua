CLASSMENU = nil
selectedclass = nil
selectedclr = nil

surface.CreateFont("MTF_2Main",   {font = "Trebuchet24",
									size = 20,
									weight = 750})
surface.CreateFont("MTF_Main",   {font = "Trebuchet24",
									size = ScreenScale(9),
									weight = 750})
surface.CreateFont("MTF_Secondary", {font = "Trebuchet24",
									size = ScreenScale(14),
									weight = 750,
									shadow = true})
surface.CreateFont("MTF_Third", {font = "Trebuchet24",
									size = ScreenScale(10),
									weight = 750,
									shadow = true})

function OpenClassMenu()
	if IsValid(CLASSMENU) then return end
	local ply = LocalPlayer()
	
	surface.CreateFont("MTF_2Main",   {font = "Trebuchet24",
										size = 35,
										weight = 750})
	surface.CreateFont("MTF_Main",   {font = "Trebuchet24",
										size = ScreenScale(9),
										weight = 750})
	surface.CreateFont("MTF_Secondary", {font = "Trebuchet24",
										size = ScreenScale(14),
										weight = 750,
										shadow = true})
	surface.CreateFont("MTF_Third", {font = "Trebuchet24",
										size = ScreenScale(10),
										weight = 750,
										shadow = true})
	
	local ourlevel = LocalPlayer():GetLevel()
	
	selectedclass = ALLCLASSES["support"]["roles"][1]
	selectedclr = ALLCLASSES["support"]["color"]
	
	if selectedclr == nil then selectedclr = Color(255,255,255) end
	
	local width = ScrW() / 1.5
	local height = ScrH() / 1.5
	
	CLASSMENU = vgui.Create( "DFrame" )
	CLASSMENU:SetTitle( "" )
	CLASSMENU:SetSize( width, height )
	CLASSMENU:Center()
	CLASSMENU:SetDraggable( true )
	CLASSMENU:SetDeleteOnClose( true )
	CLASSMENU:SetDraggable( false )
	CLASSMENU:ShowCloseButton( true )
	CLASSMENU:MakePopup()
	CLASSMENU.Paint = function( self, w, h )
		draw.RoundedBox( 2, 0, 0, w, h, Color(0, 0, 0) )
		draw.RoundedBox( 2, 1, 1, w - 2, h - 2, Color(90, 90, 95) )
	end
	
	local maininfo = vgui.Create( "DLabel", CLASSMENU )
	maininfo:SetText( "Class Manager" )
	maininfo:Dock( TOP )
	maininfo:SetFont("MTF_Main")
	maininfo:SetContentAlignment( 5 )
	//maininfo:DockMargin( 245, 8, 8, 175	)
	maininfo:SetSize(0,28)
	maininfo.Paint = function( self, w, h )
		draw.RoundedBox( 2, 0, 0, w, h, Color(0, 0, 0) )
		draw.RoundedBox( 2, 1, 1, w - 2, h - 2, Color(90, 90, 95) )
	end
	
	local panel_right = vgui.Create( "DPanel", CLASSMENU )
	panel_right:Dock( FILL )
	panel_right:DockMargin( width / 2 - 5, 0, 0, 0	)
	panel_right.Paint = function( self, w, h ) end
	
	
	local sclass_toppanel = vgui.Create( "DPanel", panel_right )
	sclass_toppanel:Dock( TOP )
	sclass_toppanel:SetSize(0, height / 2.5)
	sclass_toppanel.Paint = function( self, w, h ) end
	
	local smodel
	if selectedclass.showmodel == nil then
		smodel = table.Random(selectedclass.models)
	else
		smodel = selectedclass.showmodel
	end
	
	local class_modelpanel = vgui.Create( "DPanel", sclass_toppanel )
	class_modelpanel:Dock( LEFT )
	class_modelpanel:SetSize(width / 6)
	class_modelpanel.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(50,50,50) )
	end

	sclass_model = vgui.Create( "DModelPanel", class_modelpanel )
	sclass_model:Dock( FILL )
	sclass_model:SetFOV(50)
	sclass_model:SetModel( smodel )
	function sclass_model:LayoutEntity( entity )
		entity:SetAngles(Angle(0,18,0))
	end
	local ent = sclass_model:GetEntity()
	if selectedclass.pmcolor != nil then
		function ent:GetPlayerColor() return Vector ( selectedclass.pmcolor.r / 255, selectedclass.pmcolor.g / 255, selectedclass.pmcolor.b / 255 ) end
	end
	
	local sclass_name = vgui.Create( "DPanel", sclass_toppanel )
	sclass_name:Dock( TOP )
	sclass_name:SetSize(0, 50)
	sclass_name.Paint = function( self, w, h )
		draw.RoundedBox( 2, 0, 0, w, h, Color(0, 0, 0) )
		draw.RoundedBox( 2, 1, 1, w - 2, h - 2, selectedclr )
		draw.Text( {
			text = GetLangRole(selectedclass.name),
			font = "MTF_Secondary",
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			pos = { w / 2, h / 2 }
		} )
	end
	
	local sclass_name = vgui.Create( "DPanel", sclass_toppanel )
	sclass_name:Dock( FILL )
	sclass_name:SetSize(0, 50)
	sclass_name.Paint = function( self, w, h )
		draw.RoundedBox( 2, 0, 0, w, h, Color(0, 0, 0) )
		draw.RoundedBox( 2, 1, 1, w - 2, h - 2, Color(86, 88, 90) )
		local atso = w / 13
		local starpos = w / 16
		draw.Text( {
			text = "Health: " .. selectedclass.health,
			font = "MTF_Third",
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_CENTER,
			pos = { 12, starpos }
		} )
		draw.Text( {
			text = "Walk speed: " .. math.Round(240 * selectedclass.walkspeed),
			font = "MTF_Third",
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_CENTER,
			pos = { 12, starpos + (atso) }
		} )
		draw.Text( {
			text = "Run speed: " .. math.Round(240 * selectedclass.runspeed),
			font = "MTF_Third",
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_CENTER,
			pos = { 12, starpos + (atso * 2) }
		} )
		draw.Text( {
			text = "Jump Power: " .. math.Round(200 * selectedclass.jumppower),
			font = "MTF_Third",
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_CENTER,
			pos = { 12, starpos + (atso * 3) }
		} )
		local lvl = selectedclass.level
		local clr = Color(255,0,0)
		if ourlevel >= lvl then clr = Color(0,255,0) end
		if lvl == 6 then lvl = "Omni" end
		draw.Text( {
			text = "Clearance level: " .. lvl,
			font = "MTF_Third",
			color = clr,
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_CENTER,
			pos = { 12, h - starpos }
		} )
	end
	
	local sclass_downpanel = vgui.Create( "DPanel", panel_right )
	sclass_downpanel:Dock( FILL )
	sclass_downpanel:SetSize(0, height / 2.5)
	sclass_downpanel.Paint = function( self, w, h )
		local atso = w / 18
		local starpos = w / 12
		local numw = 0
		for k,v in pairs(selectedclass.showweapons) do
			draw.Text( {
				text = "- " .. v,
				font = "MTF_Third",
				xalign = TEXT_ALIGN_LEFT,
				yalign = TEXT_ALIGN_CENTER,
				pos = { 12, starpos + (numw * atso) }
			} )
			numw = numw + 1
		end
	end
	
	local maininfo = vgui.Create( "DLabel", sclass_downpanel )
	maininfo:SetText( "Equipment" )
	maininfo:Dock( TOP )
	maininfo:SetFont("MTF_Main")
	maininfo:SetContentAlignment( 5 )
	//maininfo:DockMargin( 245, 8, 8, 175	)
	maininfo:SetSize(0,28)
	maininfo.Paint = function( self, w, h )
		draw.RoundedBox( 2, 0, 0, w, h, Color(0, 0, 0) )
		draw.RoundedBox( 2, 1, 1, w - 2, h - 2, selectedclr	)
	end
	
	// LEFT PANELS
	
	local panel_left = vgui.Create( "DPanel", CLASSMENU )
	panel_left:Dock( FILL )
	panel_left:DockMargin( 0, 0, width / 2 - 5, 0	)
	panel_left.Paint = function( self, w, h ) end
	
	local scroller = vgui.Create( "DScrollPanel", panel_left )
	scroller:Dock( FILL )
	
	if ALLCLASSES == nil then return end
	
	for key,v in pairs(ALLCLASSES) do
		local name_security = vgui.Create( "DLabel", scroller )
		name_security:SetText( v.name )
		name_security:SetFont("MTF_Main")
		name_security:SetContentAlignment( 5 )
		name_security:Dock( TOP )
		name_security:SetSize(0,45)
		name_security:DockMargin( 0, 0, 0, 0 )
		name_security.Paint = function( self, w, h )
			draw.RoundedBox( 2, 0, 0, w, h, Color(0, 0, 0) )
			draw.RoundedBox( 2, 1, 1, w - 2, h - 2, v.color )
		end
		for i,cls in ipairs(v.roles) do
		
			local model
			if cls.showmodel == nil then
				model = table.Random(cls.models)
			else
				model = cls.showmodel
			end
		
			local class_panel = vgui.Create( "DButton", scroller )
			class_panel:SetText("")
			class_panel:SetMouseInputEnabled( true )
			class_panel.DoClick = function()
				selectedclass = cls
				selectedclr = v.color
				sclass_model:SetModel( model )
			end
			//class_panel:SetText( cls.name )
			//class_panel:SetFont("MTF_Main")
			class_panel:Dock( TOP )
			class_panel:SetSize(0,60)
			if i != 1 then
				class_panel:DockMargin( 0, 4, 0, 0 )
			end
			
			local level = "Clearance Level: "
			if cls.level == 6 then
				level = level .. "Omni"
			else
				level = level .. cls.level
			end
			
			//local enabled = true
			//if enabled == true then enabled = "Yes" else enabled = "No" end
			
			class_panel.Paint = function( self, w, h )
				if selectedclass == cls then
					draw.RoundedBox( 0, 0, 0, w, h, Color(v.color.r - 20, v.color.g - 20, v.color.b - 20) )
				else
					draw.RoundedBox( 0, 0, 0, w, h, Color(v.color.r - 50, v.color.g - 50, v.color.b - 50) )
				end
				draw.Text( {
					text = GetLangRole(cls.name),
					font = "MTF_Main",
					xalign = TEXT_ALIGN_LEFT,
					yalign = TEXT_ALIGN_CENTER,
					pos = { 70, h / 3.5 }
				} )
				draw.Text( {
					text = level,
					font = "MTF_Main",
					xalign = TEXT_ALIGN_LEFT,
					yalign = TEXT_ALIGN_CENTER,
					pos = { 70, h / 1.4 }
				} )
				/*
				draw.Text( {
					text = "Enabled: " .. enabled,
					font = "MTF_Main",
					xalign = TEXT_ALIGN_RIGHT,
					yalign = TEXT_ALIGN_CENTER,
					pos = { w - 15, h / 2 }
				} )
				*/
			end
			
			local class_modelpanel = vgui.Create( "DPanel", class_panel )
			class_modelpanel:Dock( LEFT )
			class_modelpanel.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color(v.color.r - 25, v.color.g - 25, v.color.b - 25) )
			end
			

			local class_model = vgui.Create( "DModelPanel", class_modelpanel )
			class_model:Dock( FILL )
			class_model:SetFOV(35)
			class_model:SetModel( model )
			function class_model:LayoutEntity( entity )
				entity:SetAngles(Angle(0,18,0))
			end
			local ent = class_model:GetEntity()
			if cls.pmcolor != nil then
				function ent:GetPlayerColor() return Vector ( cls.pmcolor.r / 255, cls.pmcolor.g / 255, cls.pmcolor.b / 255 ) end
			end
			if ent:LookupBone( "ValveBiped.Bip01_Head1" ) != nil then
				local eyepos = ent:GetBonePosition( ent:LookupBone( "ValveBiped.Bip01_Head1" ) )
				eyepos:Add( Vector( 0, 0, 2 ) )
				class_model:SetLookAt( eyepos )
				class_model:SetCamPos( eyepos-Vector( -24, 0, 0 ) )
				ent:SetEyeTarget( eyepos-Vector( -24, 0, 0 ) )
			end
		end
	end
	
	//button_escort:SetFont("MTF_Main")
	//button_escort:SetContentAlignment( 5 )
	//button_escort:DockMargin( 0, 5, 0, 0	)
	//button_escort:SetSize(0,32)
	//button_escort.DoClick = function()
	//	RunConsoleCommand("br_requestescort")
	//	CLASSMENU:Close()
	//end
	/*
	local button_escort = vgui.Create( "DButton", CLASSMENU )
	button_escort:SetText( "Sound: Random" )
	button_escort:Dock( TOP )
	button_escort:SetFont("MTF_Main")
	button_escort:SetContentAlignment( 5 )
	button_escort:DockMargin( 0, 5, 0, 0	)
	button_escort:SetSize(0,32)
	button_escort.DoClick = function()
		RunConsoleCommand("br_sound_random")
		CLASSMENU:Close()
	end
	*/
end

EQHUD = {
	c_dim = ScrH() * 0.13,
	c_offset = ScrH() * 0.02,
	width = 4,
	height = 2,
	enabled = false,
	weps = {}
}

WEPS_ICONS = {
	weapon_class = "weapon1",
	cw_ar15 = "txt"
}

local buttonnext = true
local buttonnextframe = true

local function QuickButton( x, y, w, h, lclick, rclick )
	local mouseL = input.IsMouseDown( MOUSE_LEFT )
	local mouseR = input.IsMouseDown( MOUSE_RIGHT )
	if mouseL or mouseR then
		if buttonnext then
			buttonnextframe = false
			local posx, posy = input.GetCursorPos()
			if posx > x and posx < x + w then
				if posy > y and posy < y + h then
					if lclick and mouseL then
						lclick()
					elseif rclick and mouseR then
						rclick()
					end
					return true
				end
			end
		end
	else
		buttonnextframe = true
	end
end

local function QuickHover( x, y, w, h, hover )
	local posx, posy = input.GetCursorPos()
	if posx > x and posx < x + w then
		if posy > y and posy < y + h then
			if hover then
				hover()
			end
			return true
		end
	end
end

function DrawEQ()
	if !EQHUD.enabled then return end
	if !vgui.CursorVisible() then
		gui.EnableScreenClicker( true )
	end

	buttonnext = buttonnextframe

	local w, h = ScrW(), ScrH()
	local wi, hi = EQHUD.width * ( EQHUD.c_dim + EQHUD.c_offset ) + EQHUD.c_offset, EQHUD.height * ( EQHUD.c_dim + EQHUD.c_offset ) + EQHUD.c_offset + 32
	local sx, sy = w * 0.5 - wi * 0.5, h * 0.5 - hi * 0.5

	surface.SetDrawColor( Color( 10, 10, 10, 240 ) )
	surface.DrawRect( sx, sy, wi, hi )

	local w, h = ScrW(), ScrH()

	for i = 0, EQHUD.width * EQHUD.height - 1 do
		local x, y = sx + ( i % EQHUD.width + 1 ) * ( EQHUD.c_offset + EQHUD.c_dim ) - EQHUD.c_dim, sy + ( math.floor( i / EQHUD.width ) + 1 ) * ( EQHUD.c_offset + EQHUD.c_dim ) - EQHUD.c_dim
		surface.SetDrawColor( Color( 150, 150, 150, 230 ) )
		surface.DrawRect( x, y, EQHUD.c_dim, EQHUD.c_dim )
		surface.SetDrawColor( Color( 0, 0, 0, 245 ) )
		surface.DrawRect( x + 2, y + 2, EQHUD.c_dim - 4, EQHUD.c_dim - 4 )
		draw.Text( {
			text = clang.eq_tip,
			pos = { sx + EQHUD.c_offset, sy + hi - 32 },
			font = "173font",
			color = Color( 200, 200, 200 ),
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_TOP,
		} )
		if IsValid( EQHUD.weps[i + 1] ) then
			--print( EQHUD.weps[i + 1].WepSelectIcon )
			if EQHUD.weps[i + 1].IconLetter then
				local letter = EQHUD.weps[i + 1].IconLetter
				local usefont = EQHUD.weps[i + 1].SelectFont
				local mx = Matrix()
				mx:Scale( Vector( 0.75, 0.75, 1 ) )
				mx:Translate( Vector( x * 0.3333333, y * 0.3333333 ) )
				cam.PushModelMatrix( mx )
					draw.SimpleText( letter, usefont, x + EQHUD.c_dim / 2 * 1.25, y + EQHUD.c_dim / 2, Color(255, 210, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				cam.PopModelMatrix()
			else
				local ico = EQHUD.weps[i + 1].SelectIcon or EQHUD.weps[i + 1].WepSelectIcon or 0
				surface.SetTexture( ico )
				surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
				surface.DrawTexturedRect( x + 2, y + EQHUD.c_dim / 4 + 2, EQHUD.c_dim - 4, EQHUD.c_dim / 2 - 4 )
			end
			QuickHover( x, y, EQHUD.c_dim, EQHUD.c_dim, function()
				local name = EQHUD.weps[i + 1].PrintName
				if !name or name == "" then
					name = EQHUD.weps[i + 1]:GetPrintName()
				end
				if !name or name == "" then
					name = EQHUD.weps[i + 1]:GetClass()
				end 
				DrawScreenTip( name, EQHUD.weps[i + 1] )
			end )
			QuickButton( x, y, EQHUD.c_dim, EQHUD.c_dim, function()
				LocalPlayer():SelectWeapon( EQHUD.weps[i + 1]:GetClass() )
			end, function()
				LocalPlayer():DropWeapon( EQHUD.weps[i + 1]:GetClass() )
				if EQHUD.weps[i + 1].droppable == nil or EQHUD.weps[i + 1].droppable then
					EQHUD.weps[i + 1] = nil
					timer.Simple( 0.5, function()
						EQHUD.weps = LocalPlayer():GetWeapons()
					end )
				end
			end )
		end
	end
end
hook.Add( "DrawOverlay", "DrawEQ", DrawEQ )

function ShowEQ()
	EQHUD.weps = LocalPlayer():GetWeapons()
	EQHUD.enabled = true
	gui.EnableScreenClicker( true )
end

function HideEQ()
	EQHUD.enabled = false
	gui.EnableScreenClicker( false )
end

function CanShowEQ()
	local t = LocalPlayer():GTeam()
	local adminmode = LocalPlayer():GetNClass() == ROLES.ADMIN
	local enabled = GetConVar( "br_new_eq" ):GetInt() == 1

	--return t != TEAM_SPEC and t != TEAM_SCP and enabled
	return ( t != TEAM_SPEC or  adminmode ) and enabled
end

function IsEQVisible()
	return EQHUD.enabled
end

local screen_tip = {
	text = "",
	pos = { 0, 0 },
	time = 0
}

function DrawScreenTip( txt, wep )
	screen_tip.text = txt
	screen_tip.pos = { input.GetCursorPos() }
	screen_tip.time = CurTime() + 0.1
	screen_tip.wep = wep
end

function PaintScreenTip()
	if screen_tip.time < CurTime() then return end

	local txt = screen_tip.text
	if !txt then return end

	surface.SetFont( "173font" )
	local w, h = surface.GetTextSize( txt )

	surface.SetDrawColor( Color( 75, 75, 75, 225 ) )
	surface.DrawRect( screen_tip.pos[1] + 8, screen_tip.pos[2], w + 16, h + 8 )

	draw.Text( {
		text = txt,
		pos = { screen_tip.pos[1] + 16, screen_tip.pos[2] + 4 },
		font = "173font",
		color = Color( 200, 200, 200 ),
		xalign = TEXT_ALIGN_LEFT,
		yalign = TEXT_ALIGN_TOP,
	})
	if screen_tip.wep then
		DrawInfoBox( w, h )
	end
end
hook.Add( "DrawOverlay", "DrawScreenTip", PaintScreenTip )

function DrawInfoBox( w, h )
	local lang = screen_tip.wep.Lang

	local author, contact, purpose, instructions

	if lang then
		author = lang.author
		contact = lang.contact
		purpose = lang.purpose
		instructions = lang.instructions
	else
		author = screen_tip.wep.Author
		contact = screen_tip.wep.Contact
		purpose = screen_tip.wep.Purpose
		instructions = screen_tip.wep.Instructions
	end

	if !author and !contact and !purpose and !instructions then return end

	local texts = { author, contact, purpose, instructions }

	for k, v in pairs( texts ) do
		if v == "" then
			texts[k] = nil
		end
	end

	local tops = { "Author:", "Contact:", "Purpose:", "Instructions:" }

	local verts = {
		{ x = screen_tip.pos[1] + w + 24, y = screen_tip.pos[2] },
		{ x = screen_tip.pos[1] + w + 72, y = screen_tip.pos[2] + h + 8 },
		{ x = screen_tip.pos[1] + w + 24, y = screen_tip.pos[2] + h + 8 },
	}

	local maxwidth = math.max( ScrW() * 0.2, 300 )

	draw.NoTexture()
	surface.SetDrawColor( Color( 75, 75, 75, 225 ) )
	surface.DrawPoly( verts )

	local height = 0
	for i, v in ipairs( texts ) do
		local txts = string.Split( v, "\n" )
		local prevh = height

		for _, t in ipairs( txts ) do
			surface.SetFont( "173font" )
			local w, h = surface.GetTextSize( t )

			local ppl = w / string.len( t )
			--local segs = math.ceil( w / maxwidth )
			--local maxi = math.ceil( string.len( t ) / segs )
			local max = math.ceil( maxwidth / ppl )
			local subtx = {}
			local curtx = t

			local stack = 0
			repeat
				if string.len( curtx ) > max then
					for k = max, 0, -1 do
						if k == 0 then
							table.insert( subtx, curtx )
							curtx = ""
						elseif string.sub( curtx, k, k ) == " " then
							table.insert( subtx, string.sub( curtx, 0, k ) )
							curtx = string.sub( curtx, k + 1, string.len( curtx ) )
							break
						end
					end
				else
					table.insert( subtx, curtx )
					curtx = ""
				end
				stack = stack + 1
				if stack > 1000 then
					error( "Stackoverflow!" )
				end
			until curtx == ""

			surface.SetDrawColor( Color( 75, 75, 75, 225 ) )
			surface.DrawRect( screen_tip.pos[1] + 8, screen_tip.pos[2] + h + 8 + height, maxwidth + 16, h * #subtx + h + 16 )

			for pos, tx in ipairs( subtx ) do	
				draw.Text( {
					text = tx,
					pos = { screen_tip.pos[1] + 16, screen_tip.pos[2] + h * ( pos + 1 ) + 8 + height },
					font = "173font",
					color = Color( 200, 200, 200 ),
					xalign = TEXT_ALIGN_LEFT,
					yalign = TEXT_ALIGN_TOP,
				})
			end	
			height = height + h * ( #subtx + 1 ) + 16
		end	
		draw.Text( {
			text = tops[i],
			pos = { screen_tip.pos[1] + 16, screen_tip.pos[2] + h + 8 + prevh },
			font = "173font",
			color = Color( 200, 150, 200 ),
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_TOP,
		})
	end
end
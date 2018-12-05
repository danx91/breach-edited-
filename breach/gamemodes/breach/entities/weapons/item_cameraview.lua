AddCSLuaFile()

if CLIENT then
	SWEP.WepSelectIcon 	= surface.GetTextureID("breach/wep_cameraview")
	SWEP.BounceWeaponIcon = false
end

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/props_junk/cardboard_box004a.mdl"
SWEP.WorldModel		= "models/props_junk/cardboard_box004a.mdl"
SWEP.PrintName		= "Camera View"
SWEP.Slot			= 1
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= false
SWEP.HoldType		= "normal"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false

SWEP.droppable				= true
SWEP.teams					= {2,3,5,6}

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			=  "none"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo			=  "none"
SWEP.Secondary.Automatic	=  false

SWEP.Enabled = false
SWEP.NextChange = 0
SWEP.CAM = 1
SWEP.CCTV = {}

function SWEP:Deploy()
	self.Owner:DrawViewModel( false )
end

function SWEP:DrawWorldModel()
	if !IsValid( self.Owner ) then
		self:DrawModel()
	end
end

SWEP.Lang = nil

function SWEP:Initialize()
	if CLIENT then
		self.Lang = GetWeaponLang().CV
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end

	self:SetHoldType( self.HoldType )
	self:SetSkin( 1 )
end

function SWEP:CalcView( ply, pos, ang, fov )
	if CCTV == nil then return end
	if CCTV[self.CAM] == nil then return end
	if !IsValid( self.CCTV[self.CAM] ) then return end

	local dw = false

	if self.Enabled then
		ang = CCTV[self.CAM].ang
		pos = CCTV[self.CAM].pos - Vector( 0, 0, 10 )
		fov = 90
		dw = true
	end

	return pos, ang, fov, dw
end

SWEP.snd = nil
SWEP.snden = false

function SWEP:Think()
	if #self.CCTV != #CCTV then
		for k, v in pairs( ents.FindByClass( "item_cctv" ) ) do
			//print( v, v:GetCam() )
			self.CCTV[v:GetCam()] = v
		end
	end

	if CLIENT then
		if !self.snd then
			sound.PlayFile( "sound/camera.ogg", "noplay", function( snd, err, e )
				if !snd then
					print( err, e )
				else
					self.snd = snd
				end
			end )
		else
			if self.Enabled and !self.snden then
				self.snd:Play()
				self.snd:EnableLooping( true )
				self.snden = true

				timer.Create("CameraCheck", 1, 0, function()
					if !IsValid( self.Owner ) then
						self.snd:Pause()
						self.Enabled = false
					end
				end )
			elseif !self.Enabled and self.snden then
				timer.Remove( "CameraCheck" )
				self.snd:Pause()
				self.snden = false
			end
		end
	end

	if self.CurScan + 0.2 < CurTime() then
		self.ScanEnd = 0
		self.CurScan = 0
	end
end

function SWEP:OnRemove()
	timer.Remove( "CameraCheck" )

	if IsValid( self.snd ) then
		self.snd:Stop()
		self.snd = nil
	end
end

function SWEP:Holster()
	timer.Remove( "CameraCheck" )
	self.Enabled = false

	if IsValid( self.snd ) then
		self.snd:Pause()
	end

	return true
end

function SWEP:OnDrop()
	self.Enabled = false
end

SWEP.ScanCD = 0
SWEP.CurScan = 0
SWEP.ScanEnd = 0

function SWEP:Reload()
	if !self.Enabled or !IsValid( self.CCTV[self.CAM] ) then return end
	if self.ScanCD > CurTime() then return end
	self.ScanCD = CurTime() + 0.1

	if self.ScanEnd == 0 then 
		self.ScanEnd = CurTime() + 3
		self.CurScan = CurTime()
	else
		self.CurScan = CurTime()

		if self.CurScan > self.ScanEnd then
			self.ScanEnd = 0
			self.CurScan = 0
			self.ScanCD = CurTime() + 10

			if SERVER then
				self:Scan()
			end
		end
	end
end

function SWEP:Scan()
	if !IsValid( self.CCTV[self.CAM] ) then return end

	local detected = {}

	local scps = gteams.GetPlayers( TEAM_SCP )
	print( #scps )
	for k, v in pairs( scps ) do
		local tr = util.TraceLine( {
			start = CCTV[self.CAM].pos - Vector( 0, 0, 10 ),
			endpos = v:GetPos() + v:OBBCenter(),
			mask = MASK_SHOT_HULL,
			filter = { v }
		} )

		if !tr.Hit then
			table.insert( detected, v )
		end
	end

	BroadcastDetection( self.Owner, detected )
end

function SWEP:PrimaryAttack()
	if !self.Enabled then return end
	if self.NextChange > CurTime() then return end

	self.CAM = self.CAM + 1

	if self.CAM > #CCTV then
		self.CAM = 1
	end

	//chat.AddText( self.Lang.changed.." ".. CCTV[self.CAM].name )
	self.NextChange = CurTime() + 0.1
end

function SWEP:SecondaryAttack()
	//if SERVER then return end
	if self.NextChange > CurTime() then return end

	self.Enabled = !self.Enabled
	self.NextChange = CurTime() + 0.5
end

function SWEP:DrawHUD()
	if self.Enabled then
		DisableHUDNextFrame()

		if !IsValid( self.CCTV[self.CAM] ) then
			surface.SetDrawColor( 0, 0, 0 )
			surface.DrawRect( 0, 0, ScrW(), ScrH() )

			draw.Text( {
				text = "NO SIGNAL",
				font = "HUDFontBig",
				pos = { ScrW() * 0.5, ScrH() * 0.5 },
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
			} )

			draw.Text( {
				text = "CAM "..self.CAM,
				font = "HUDFontBig",
				pos = { ScrW() * 0.5, 50 },
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
			} )

			draw.Text( {
				text = CCTV[self.CAM].name,
				font = "HUDFontBig",
				pos = { ScrW() * 0.5, 100 },
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
			} )

			return
		end

		if blinkHUDTime < 5 then
			surface.SetDrawColor( Color( 255, 255, 255, 255 ) )

			draw.Text( {
				text = "CAM "..self.CAM,
				font = "HUDFontBig",
				pos = { ScrW() * 0.5, 50 },
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
			} )

			draw.Text( {
				text = CCTV[self.CAM].name,
				font = "HUDFontBig",
				pos = { ScrW() * 0.5, 100 },
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
			} )

			for i = 1, 10 do
				local ry = math.random( ScrH() )
				local h = math.random( 1, 5 )
				local c = math.random( 100, 200 )
				local a = math.random( 0, 10 )

				surface.SetDrawColor( Color( c, c, c, a ) )
				surface.DrawRect( 0, ry, ScrW(), h )
			end
		end

		if self.ScanEnd != 0 then
			surface.SetDrawColor( Color( 255, 255, 255 ) )
			surface.DrawRing( ScrW() * 0.5, ScrH() * 0.5, 40, 5, 360 - 360 * (self.ScanEnd - CurTime()) / 3, 30 )

			draw.Text( {
				text = "SCANNING",
				font = "HUDFontBig",
				color = Color( 255, 255, 255, math.TimedSinWave( 0.8, 1, 255 ) ),
				pos = { ScrW() * 0.5, ScrH() * 0.5 + 55 },
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_TOP,
			} )
		end
	end
end
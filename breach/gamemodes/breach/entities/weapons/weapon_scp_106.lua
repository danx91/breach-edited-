AddCSLuaFile()

SWEP.Base 			= "weapon_scp_base"
SWEP.PrintName		= "SCP-106"

SWEP.ViewModel		= "models/vinrax/props/keycard.mdl"
SWEP.WorldModel		= "models/vinrax/props/keycard.mdl"

SWEP.HoldType		= "normal"

SWEP.Chase 			= "scp/106/chase.ogg"
SWEP.Place 			= "scp/106/place.ogg"
SWEP.Teleport 		= "scp/106/tp.ogg"
SWEP.Disappear 		= "scp/106/disappear.ogg"

SWEP.NextAttackW	= 0
SWEP.AttackDelay	= 1.5

if CLIENT then
	SWEP.WepSelectIcon 	= surface.GetTextureID("breach/wep_106")
end

function SWEP:OnRemove()
	if IsValid( self.Owner ) then
		self.Owner:SetCustomCollisionCheck( false )
	end
end

function SWEP:Deploy()
	if IsValid( self.Owner ) then
		self.Owner:SetCustomCollisionCheck( true )
	end
	self:HideModels()
end

function SWEP:Initialize()
	self:InitializeLanguage( "SCP_106" )

	self:SetHoldType(self.HoldType)

	self:PrecacheSnd( {
		{ name = "Place", snd = self.Place, level = 75 },
		{ name = "Disappear", snd = self.Disappear, level = 125 },
		{ name = "Teleport", snd = self.Teleport, level = 325 },
	} )
end

function SWEP:PrecacheSnd( tab )
	for k, v in pairs( tab ) do
		sound.Add( {
			name = v.name,
			channel = CHAN_STATIC,
			volume = 1.0,
			level = v.level or 75,
			pitch = 100,
			sound = v.snd
		} )
	end
end

SWEP.SoundPlayers = {}
SWEP.NThink = 0
function SWEP:Think()
	if self.NThink > CurTime() then return end
	self.NThink = CurTime() + 1
	if SERVER then
		for k, v in pairs( self.SoundPlayers ) do
			if v.ply:GTeam() == TEAM_SPEC or v.ply:GTeam() == TEAM_SCP or ( v.time and v.time < CurTime() ) or self.Owner:GetPos():DistToSqr( v.ply:GetPos() ) > 562500 then
				net.Start( "SendSound" )
					net.WriteInt( 0, 2 )
					net.WriteString( self.Chase )
				net.Send( v.ply )
				self.SoundPlayers[k] = nil
				--print( "Removing ", v.ply )
			end
		end
		local e = ents.FindInSphere( self.Owner:GetPos(), 750 )
		for k, v in pairs( e ) do
			if IsValid( v ) and  v:IsPlayer() then
				if  v:GTeam() != TEAM_SPEC and v:GTeam() != TEAM_SCP then
					if !self:IsInTable( self.SoundPlayers, v ) then
						net.Start( "SendSound" )
							net.WriteInt( 1, 2 )
							net.WriteString( self.Chase )
						net.Send( v )
						table.insert( self.SoundPlayers, { ply = v, time = CurTime() + 31 } )
						--print( "inserting ", v )
					end
				end
			end
		end
	end
end

function SWEP:PrimaryAttack()
	//if ( !self:CanPrimaryAttack() ) then return end
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if self.NextAttackW > CurTime() then return end
	self.NextAttackW = CurTime() + self.AttackDelay
	if SERVER then
		local ent = nil
		local tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 100 ),
			filter = self.Owner,
			mins = Vector( -10, -10, -10 ),
			maxs = Vector( 10, 10, 10 ),
			mask = MASK_SHOT_HULL
		} )
		ent = tr.Entity
		if IsValid(ent) then
			if ent:IsPlayer() then
				if ent:GTeam() == TEAM_SCP then return end
				if ent:GTeam() == TEAM_SPEC then return end
				if ent.Using714 then return end
				local pos = GetPocketPos()
				local ang = ent:GetAngles()
				ang.yaw = math.random( -180, 180 )
				if pos then
					roundstats.teleported = roundstats.teleported + 1
					//local health = math.Clamp( self.Owner:Health() + 100, self.Owner:Health(), self.Owner:GetMaxHealth() )
					//self.Owner:SetHealth( health )
					ent:TakeDamage( math.random( 25, 50 ), self.Owner, self.Owner )
					ent:SetPos(pos)
					ent:SetAngles( ang )
					self.Owner:AddExp(75, true)
				end
			else
				self:SCPDamageEvent( ent, 10 )
			end
		end
	end
end

SWEP.NextPlace = 0
SWEP.TPPoint = nil
function SWEP:SecondaryAttack()
	if SERVER then
		if self.NextPlace > CurTime() then
			self.Owner:PrintMessage( HUD_PRINTTALK, "You have to wait "..math.ceil( self.NextPlace - CurTime() ).." before next use!" )
			return
		end
		self.NextPlace = CurTime() + 15

		self.Owner:EmitSound( "Place" )
		self.TPPoint = self.Owner:GetPos()
		
		local tr = util.TraceLine( {
			start = self.Owner:GetPos(),
			endpos = self.Owner:GetPos() - Vector( 0, 0, 100 ),
			filter = self.Owner
		} )
		if tr.Hit then
			util.Decal( "Decal106", tr.HitPos - tr.HitNormal, tr.HitPos + tr.HitNormal )
		end
	end
end

SWEP.NextTP = 0
function SWEP:Reload()
	if !IsFirstTimePredicted() then return end

	if self.NextTP > CurTime() then return end
	self.NextTP = CurTime() + 90

	if SERVER then
		if self.TPPoint then
			self:TeleportSequence( self.TPPoint )
		end
	end
end

function SWEP:TeleportSequence( point )
	self.NextAttackW = CurTime() + 8
	self.NextPlace = CurTime() + 15

	local tr = util.TraceLine( {
		start = self.Owner:GetPos(),
		endpos = self.Owner:GetPos() - Vector( 0, 0, 100 ),
		filter = self.Owner
	} )
	if tr.Hit then
		util.Decal( "Decal106", tr.HitPos - tr.HitNormal, tr.HitPos + tr.HitNormal )
	end

	self.Owner:Freeze( true )

	if timer.Exists( "106TP_1"..self.Owner:SteamID64() ) then timer.Remove( "106TP_1"..self.Owner:SteamID64() ) end
	if timer.Exists( "106TP_2"..self.Owner:SteamID64() ) then timer.Remove( "106TP_2"..self.Owner:SteamID64() ) end

	local i = 40
	local ppos = self.Owner:GetPos()
	timer.Create( "106TP_1"..self.Owner:SteamID64(), 0.1, 40, function()
		if IsValid( self ) and IsValid( self.Owner ) then
			if i % 20 == 0 then
				self:SendSound( self.Disappear, 500 )
			end
			self.Owner:SetPos( ppos - Vector( 0, 0, 2 * ( 40 - i ) ) )
		end
		i = i - 1
	end )
	timer.Simple( 4.1, function()
		if IsValid( self ) and IsValid( self.Owner ) then
			self.Owner:SetPos( point - Vector( 0, 0, 80 ) )
		end
		local i = 40
		timer.Create( "106TP_2"..self.Owner:SteamID64(), 0.1, 41, function()
			if IsValid( self ) and IsValid( self.Owner ) then
				if i == 40 or i == 10 then
					self:SendSound( self.Teleport, 500 )
				end
				self.Owner:SetPos( point - Vector( 0, 0, 80 ) + Vector( 0, 0, 2 * ( 41 - i ) ) )
				i = i - 1
			end
		end )
		timer.Simple( 4.1, function()
			if IsValid( self ) and IsValid( self.Owner ) then
				self.Owner:SetPos( point )
				self.Owner:Freeze( false )
			end			
		end )
	end )
end

function SWEP:SendSound( sound, range )
	local e = ents.FindInSphere( self.Owner:GetPos(), range )
	for k, v in pairs( e ) do
		if IsValid( v ) and  v:IsPlayer() then
			net.Start( "SendSound" )
				net.WriteInt( 1, 2 )
				net.WriteString( sound )
			net.Send( v )
		end
	end
end

function SWEP:DrawHUD()
	if disablehud == true then return end
	
	local showtext = self.Lang.HUD.attackReady
	local showcolor = Color(0,255,0)
	
	if self.NextAttackW > CurTime() then
		showtext = self.Lang.HUD.attackCD.." ".. math.Round(self.NextAttackW - CurTime())
		showcolor = Color(255,0,0)
	end
	
	draw.Text( {
		text = showtext,
		pos = { ScrW() / 2, ScrH() - 60 },
		font = "173font",
		color = showcolor,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	})
	
	showtext = self.Lang.HUD.teleportReady
	showcolor = Color( 0, 255, 0 )

	if self.NextTP > CurTime() then
		showtext = self.Lang.HUD.teleportCD.." ".. math.Round( self.NextTP - CurTime() )
		showcolor = Color( 255, 0, 0 )
	end
	
	draw.Text( {
		text = showtext,
		pos = { ScrW() / 2, ScrH() - 30 },
		font = "173font",
		color = showcolor,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	})


	local x = ScrW() / 2.0
	local y = ScrH() / 2.0

	local scale = 0.3
	surface.SetDrawColor( 0, 255, 0, 255 )
	
	local gap = 5
	local length = gap + 20 * scale
	surface.DrawLine( x - length, y, x - gap, y )
	surface.DrawLine( x + length, y, x + gap, y )
	surface.DrawLine( x, y - length, x, y - gap )
	surface.DrawLine( x, y + length, x, y + gap )
end

function SWEP:IsInTable( tab, element )
	for k, v in pairs( tab ) do
		if v.ply == element then return true end
	end
	return false
end
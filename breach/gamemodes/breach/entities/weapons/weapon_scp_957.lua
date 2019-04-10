AddCSLuaFile()

SWEP.Base 			= "weapon_scp_base"
SWEP.PrintName		= "SCP-957"

SWEP.Primary.Delay 	= 8

SWEP.DrawCrosshair	= true
SWEP.HoldType 		= "normal"

function SWEP:SetupDataTables()
	self:NetworkVar( "Entity", 0, "SCPInstance" )
	self:NetworkVar( "Float", 0, "NextSummon" )
end

function SWEP:Initialize()
	self:InitializeLanguage( "SCP_957" )

	self:SetHoldType(self.HoldType)
end

function SWEP:Think()
	self:PlayerFreeze()
	if preparing or postround then return end
	if !self.NextSummon then
		self.NextSummon = CurTime() + 60
		self:SetNextSummon( CurTime() + 60 )
	end
	if SERVER and IsValid( self.Owner ) then
		if !self.Instance and self.NextSummon and self.NextSummon < CurTime() then
			local pos = self.Owner:GetPos()
			local bestdist
			local ply
			for k, v in pairs( player.GetAll() ) do
				local t = v:GTeam()
				if v != self.Owner and t != TEAM_SPEC and t != TEAM_SCP and !v.Using714 then
					local dist = pos:DistToSqr( v:GetPos() )
					if !bestdist or bestdist > dist then
						bestdist = dist
						ply = v
					end
				end
			end
			if ply then
				--ply:SetSCP9571()
				local scp = GetSCP( "SCP9571" )
				if scp then
					scp:SetupPlayer( ply )
				end
				self.Instance = ply
				self:SetSCPInstance( ply )
				WinCheck()
				return
			end
			self:SetNextSummon( CurTime() + 10 )
			self.NextSummon = CurTime() + 10
		end

		if self.Instance and !IsValid( self.Instance ) then
			self.NextSummon = CurTime() + 60
			self:SetNextSummon( CurTime() + 60 )
			self.Instance = nil			
		end

		if IsValid( self.Instance ) then
			if self.Instance:GTeam() != TEAM_SCP then
				self.NextSummon = CurTime() + 60
				self:SetNextSummon( CurTime() + 60 )
				self.Instance = nil
			end
		end
	end
	if CLIENT then
		self.Instance = self:GetSCPInstance()
		self.NextSummon = self:GetNextSummon()
	end
end

SWEP.NextPrimary = 0
function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if CurTime() < self.NextPrimary then return end
	self.NextPrimary = CurTime() + self.Primary.Delay

	if SERVER and IsValid( self.Owner ) then
		local fent = ents.FindInSphere( self.Owner:GetPos(), 1000 )
		local plys = {}
		for k, v in pairs( fent ) do
			if IsValid( v ) and v:IsPlayer() then
				if v:GTeam() != TEAM_SPEC and v:GTeam() != TEAM_SCP and !v.Using714 then
					table.insert( plys, v )
					v.scp173allow = true
					Timer( "957Timer_"..v:SteamID64(), 1, 5, function( s, n )
						if !IsValid( self ) or !IsValid( self.Owner ) or !IsValid( v ) or v:GTeam() == TEAM_SPEC or v:GTeam() == TEAM_SCP or v.Using714 then
							s:Destroy()
							net.Start( "957Effect" )
								net.WriteBool( false )
							net.Send( plys )
							v.scp173allow = false
							return
						end

						local shp = math.Clamp( self.Owner:Health() + n, 0, self.Owner:GetMaxHealth() )
						self.Owner:SetHealth( shp )
						if IsValid( self.Instance ) then
							local hp = math.Clamp( self.Instance:Health() + n, 0, self.Instance:GetMaxHealth() )
							self.Instance:SetHealth( hp )
						end

						v:TakeDamage( n * 2, self.Owner, self )
					end, function()
						v.scp173allow = false
					end )
				end
			end
		end
		if #plys > 0 then
			net.Start( "957Effect" )
				net.WriteBool( true )
			net.Send( plys )
		end
	end
end

SWEP.NSAttack = 0
function SWEP:SecondaryAttack()
	if CLIENT or preparing or postround then return end
	if self.NSAttack > CurTime() then return end
	self.NSAttack = CurTime() + 1
	
	local start = self.Owner:GetShootPos()
	local trace = util.TraceLine( {
		start = start,
		endpos = start + self.Owner:GetAimVector() * 100,
		filter = { self, self.Owner }
	} )

	if trace.Hit then
		local ent = trace.Entity
		self:SCPDamageEvent( ent, 10 )
	end
end

function SWEP:DrawHUD()
	if disablehud == true then return end
	
	local showtext2 = self.Lang.HUD.rattack
	local showcolor2 = Color(0,255,0)
	
	if self.NextPrimary > CurTime() then
		showtext2 = self.Lang.HUD.nattack.." "..math.Round(self.NextPrimary - CurTime()).."s"
		showcolor2 = Color(255,0,0)
	end

	if self.NextSummon and self.NextSummon > CurTime() or IsValid( self.Instance ) then
		local showtext = self.Lang.HUD.asummon
		local showcolor = Color( 0, 255, 0 )

		if self.NextSummon > CurTime() then
			showtext = self.Lang.HUD.nsummon.." ".. math.Round(self.NextSummon - CurTime()).."s"
			showcolor = Color(255,0,0)
		end

		draw.Text( {
			text = showtext,
			pos = { ScrW() / 2, ScrH() - 30 },
			font = "173font",
			color = showcolor,
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
		})
	end
	
	draw.Text( {
		text = showtext2,
		pos = { ScrW() / 2, ScrH() - 60 },
		font = "173font",
		color = showcolor2,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	})
end
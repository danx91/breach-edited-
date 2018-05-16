AddCSLuaFile()

SWEP.PrintName				= "SCP957"			

SWEP.ViewModelFOV 		= 56
SWEP.Spawnable 			= false
SWEP.AdminOnly 			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Delay        = 8
SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo		= "None"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Delay			= 5
SWEP.Secondary.Ammo		= "None"

SWEP.ISSCP 				= true
SWEP.droppable				= false
SWEP.CColor					= Color(0,255,0)
SWEP.teams					= {1}

SWEP.Slot					= 0
SWEP.SlotPos				= 4
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.ViewModel			= ""
SWEP.WorldModel			= ""
SWEP.HoldType 			= "normal"

SWEP.Lang = nil

function SWEP:SetupDataTables()
	self:NetworkVar( "Entity", 0, "SCPInstance" )
	self:NetworkVar( "Float", 0, "NextSummon" )
end

function SWEP:Initialize()
	if CLIENT then
		self.Lang = GetWeaponLang().SCP_957
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
	self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
	if self.Owner:IsValid() then
		self.Owner:DrawWorldModel( false )
		self.Owner:DrawViewModel( false )
	end
end

function SWEP:Holster()
	return true
end

function SWEP:Think()
	if preparing or postround then return end
	if !self.NextSummon then
		self.NextSummon = CurTime() + 60
		self:SetNextSummon( CurTime() + 60 )
	end
	if SERVER and IsValid( self.Owner ) then
		if !IsValid( self.Instance ) and self.NextSummon and self.NextSummon < CurTime() then
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
				ply:SetSCP9571()
				self.Instance = ply
				self:SetSCPInstance( ply )
				return
			end
			self:SetNextSummon( CurTime() + 10 )
			self.NextSummon = CurTime() + 10
		end

		if IsValid( self.Instance ) then
			if self.Instance:GTeam() != TEAM_SCP then
				self.Instance = nil
				self.NextSummon = CurTime() + 60
				self:SetNextSummon( CurTime() + 60 )
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

--SWEP.NextSecondary = 0
function SWEP:SecondaryAttack()
	/*if preparing or postround then return end
	if CurTime() < self.NextSecondary then return end
	self.NextSecondary = CurTime() + self.Secondary.Delay*/
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
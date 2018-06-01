AddCSLuaFile()

SWEP.Base 				= "weapon_scp_base"
SWEP.PrintName			= "SCP-860-2"

SWEP.Primary.Delay      = 1.5

SWEP.DrawCrosshair		= true
SWEP.HoldType 			= "normal"

function SWEP:Initialize()
	self:InitializeLanguage( "SCP_8602" )

	self:SetHoldType(self.HoldType)
end

SWEP.NextPrimary = 0

function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if self.NextPrimary > CurTime() then return end
	self.NextPrimary = CurTime() + self.Primary.Delay
	if !SERVER then return end
	local trace = util.TraceHull( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 50,
		filter = self.Owner,
		mask = MASK_SHOT,
		maxs = Vector( 10, 10, 10 ),
		mins = Vector( -10, -10, -10 )
	} )
	if trace.Hit then
		local trace2 = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 100,
			--filter = player:GetAll(),
			mask = MASK_SOLID_BRUSHONLY,
			maxs = Vector( 10, 10, 10 ),
			mins = Vector( -10, -10, -10 )
		} )
		if trace2.Hit and trace.Entity:IsPlayer() and !trace2.Entity:IsPlayer() then
			--if self.Owner:GetAimVector():Dot( Vector( 0, 0, -1 ) ) < 0.40 then --dont trigger charge when tr2 probably hit floor
			if math.abs( trace2.HitNormal.z ) < 0.5 then --z normal 0 is vertical, 1 or -1 is horizontal. If surface angle to floor is lower than 45 degrees, don't trigger special attack
				self:SpecialAttack( trace, trace2 )
			else
				self:NormalAttack( trace )
			end
		else
			self:NormalAttack( trace )
		end	
	end
end

SWEP.Angles = { Angle( -10, -5, 0 ), Angle( 10, 5, 0 ), Angle( -10, 5, 0 ), Angle( 10, -5, 0 ) }

function SWEP:NormalAttack( trace )
	local ent = trace.Entity
	if !IsValid( ent ) then return end
	if ent:IsPlayer() then
		if ent:GTeam() == TEAM_SPEC then return end
		if ent:GTeam() == TEAM_SCP then return end
		ent:TakeDamage( math.random( 20, 30 ), self.Owner, self.Owner )
		self.Owner:EmitSound( "npc/antlion/shell_impact3.wav" )
		self.Owner:ViewPunch( table.Random( self.Angles ) )
	else
		if ent:GetClass() == "func_breakable" then
			ent:TakeDamage( 100, self.Owner, self.Owner )
			self.Owner:ViewPunch( table.Random( self.Angles ) )
		end
	end
end

function SWEP:SpecialAttack( trace )
	local ent = trace.Entity
	if !IsValid( ent ) then return end
	if ent:IsPlayer() then
		if ent:GTeam() == TEAM_SPEC then return end
		if ent:GTeam() == TEAM_SCP then return end
		ent:TakeDamage( math.random( 50, 125 ), self.Owner, self.Owner )
		self.Owner:TakeDamage( math.random( 50, 100 ), self.Owner, self.Owner )
		self.Owner:EmitSound( "npc/antlion/shell_impact4.wav" )
		self.Owner:ViewPunch( Angle( -30, 0, 0 ) )
		ent:ViewPunch( Angle( -50, 0, 0 ) )

		self.Owner:SetVelocity( self.Owner:GetAimVector() * 1250 )
		ent:SetVelocity( self.Owner:GetAimVector() * 1250 )
	end
end

function SWEP:DrawHUD()
	if true then return end
	if disablehud == true then return end
	
	local showtext = self.Lang.HUD.attackReady
	local showcolor = Color(0,255,0)
	
	if self.NextAttackW > CurTime() then
		showtext = self.Lang.HUD.attackCD.." ".. math.Round(self.NextAttackW - CurTime())
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
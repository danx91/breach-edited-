AddCSLuaFile()

SWEP.Base 			= "weapon_scp_base"
SWEP.PrintName		= "SCP-1048-A"

SWEP.DrawCrosshair	= true
SWEP.HoldType 		= "melee"


function SWEP:Initialize()
	self:InitializeLanguage( "SCP_1048A" )

	self:SetHoldType( self.HoldType )

	sound.Add( {
		name = "attack",
		channel = CHAN_STATIC,
		volume = 1.0,
		level = 150,
		pitch = 100,
		sound = "scp/1048A/attack.ogg"	
	} )
end

SWEP.NextPrimary = 0

function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if self.NextPrimary > CurTime() then return end
	self.NextPrimary = CurTime() + 8
	if SERVER then
		self.Owner:EmitSound( "attack" )
		timer.Create( "Attack1048A", 0.4, 15, function()
			if !IsValid( self ) or !IsValid( self.Owner ) then
				timer.Destroy( "Attack1048A" )
				return
			end
			fent = ents.FindInSphere( self.Owner:GetPos(), 200 )
			for k, v in pairs( fent ) do
				if IsValid( v ) then
					if v:IsPlayer() then
						if v:GTeam() != TEAM_SPEC and v:GTeam() != TEAM_SCP then
							v:TakeDamage( 2, self.Owner, self.Owner )
						end
					else
						self:SCPDamageEvent( ent, 5 )
					end
				end
			end
		end )
	end
end

function SWEP:DrawHUD()
	if disablehud == true then return end
	
	local showtext = self.Lang.HUD.attackReady
	local showcolor = Color(0,255,0)
	
	if self.NextPrimary > CurTime() then
		showtext = self.Lang.HUD.attackCD.." ".. math.Round(self.NextPrimary - CurTime())
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
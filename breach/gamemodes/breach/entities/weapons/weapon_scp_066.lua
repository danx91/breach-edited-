AddCSLuaFile()

SWEP.Base 				= "weapon_scp_base"
SWEP.PrintName			= "SCP-066"			

SWEP.Primary.Delay0		= 3
SWEP.Primary.Delay1		= 30

SWEP.Primary.Eric		= "scp/066/eric.ogg"
SWEP.Primary.Beethoven	= "scp/066/beethoven.ogg"

SWEP.HoldType 			= "normal"

function SWEP:Initialize()
	self:InitializeLanguage( "SCP_066" )

	self:SetHoldType( self.HoldType )
	
	sound.Add( {
		name = "eric",
		channel = CHAN_STATIC,
		volume = 1.0,
		level = 300,
		pitch = 100,
		sound = self.Primary.Eric
	} )
	
	sound.Add( {
		name = "beethoven",
		channel = CHAN_STATIC,
		volume = 1.0,
		level = 511,
		pitch = 100,
		sound = self.Primary.Beethoven
	} )
	
end

SWEP.Eric = false
SWEP.NextPrimary = 0
SWEP.pop = false

function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if self.NextPrimary > CurTime() then return end
	if !self.Eric then
		self.NextPrimary = CurTime() + self.Primary.Delay0
		self.Eric = true
		if !SERVER then return end
		self.Owner:EmitSound( "eric" )
	else
		self.NextPrimary = CurTime() + self.Primary.Delay1
		self.Eric = false
		if !SERVER then return end
		self.Owner:EmitSound( "beethoven" )
		timer.Create( "DMGTimer", 1, self.Primary.Delay1 - 10, function()
			if !IsValid( self ) or !IsValid( self.Owner ) then
				timer.Destroy( "DMGTimer" )
				return
			end
			local fent = ents.FindInSphere( self.Owner:GetPos(), 400 )
			for k, v in pairs( fent ) do
				if IsValid( v ) then
					if v:IsPlayer() then
						if v:GTeam() != TEAM_SCP and  v:GTeam() != TEAM_SPEC then
							v:TakeDamage( 2, self.Owner, self.Owner )
						end
					end
				end
			end
		end )
	end
end

function SWEP:SecondaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
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
		if !IsValid(ent) then return end
		if ent:GetClass() == "func_breakable" then
			ent:TakeDamage( 100, self.Owner, self.Owner )
		end
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
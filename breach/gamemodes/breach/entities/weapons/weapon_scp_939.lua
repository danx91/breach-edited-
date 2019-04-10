AddCSLuaFile()

SWEP.Base 		= "weapon_scp_base"
SWEP.PrintName 	= "SCP-939"

SWEP.Primary.Delay        = 1
SWEP.Primary.Sound		= "scp/939/bite.ogg"

SWEP.DrawCrosshair		= true
SWEP.HoldType 			= "melee"

function SWEP:Initialize()
	self:InitializeLanguage( "SCP_939" )

	self:SetHoldType(self.HoldType)
end

/*function SWEP:Deploy()
	self:HideModels()
	if self.Owner:IsValid() then
		self.Owner:SetModelScale( 0.75 )
	end
end

function SWEP:OnRemove()
	self.Owner:SetModelScale( 1 )
end*/

SWEP.NextPrimary = 0
function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if self.NextPrimary > CurTime() then return end
	self.NextPrimary = CurTime() + self.Primary.Delay
	if !SERVER then return end
	local tr = util.TraceHull( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 100,
		maxs = Vector( 10, 10, 10 ),
		mins = Vector( -10, -10, -10 ),
		filter = self.Owner,
		mask = MASK_SHOT
	} )
	local ent = tr.Entity
	if IsValid( ent ) then
		if ent:IsPlayer() then
			if ent:GTeam() == TEAM_SPEC then return end
			if ent:GTeam() == TEAM_SCP then return end
			self.Owner:EmitSound( self.Primary.Sound )
			ent:TakeDamage( math.random( 20, 50 ), self.Owner, self.Owner )
			self.Owner:SetHealth( math.Clamp( self.Owner:Health() + math.random( 30, 50 ), 0, self.Owner:GetMaxHealth() ) )
		else
			self:SCPDamageEvent( ent, 10 )
		end	
	end
end

SWEP.Channel = "SCP"
SWEP.DBG = 0
function SWEP:SecondaryAttack()
	if preparing or postround then return end
	if self.DBG > CurTime() then return end
	self.DBG = CurTime() + 0.3
	self:nextChannel()
end

function SWEP:nextChannel()
	if self.Channel == "SCP" then
		self.Channel = "ALL"
	else
		self.Channel = "SCP"
	end
end

function SWEP:DrawHUD()
	if disablehud == true then return end
	
	local showtext = self.Lang.HUD.attackReady
	local showcolor = Color(0,255,0)
	
	if self.NextPrimary > CurTime() then
		showtext = self.Lang.HUD.attackCD.." "..math.Round(self.NextPrimary - CurTime())
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
		draw.Text( {
		text = self.Lang.HUD.channel.." "..self.Channel,
		pos = { ScrW() / 2, ScrH() - 60 },
		font = "173font",
		color = Color(0,255,0),
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	})
end
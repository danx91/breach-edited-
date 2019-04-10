AddCSLuaFile()

SWEP.Base 				= "weapon_scp_base"
SWEP.PrintName			= "SCP-1471-A"

SWEP.Primary.Automatic  = true
SWEP.Primary.Delay 		= 0.3

SWEP.Secondary.Delay 	= 7

SWEP.DrawCrosshair		= true
SWEP.HoldType 			= "normal"

--if (CLIENT) then
	--SWEP.WepSelectIcon	= surface.GetTextureID( "vgui/entities/weapon_scp096" )
	--SWEP.BounceWeaponIcon = false
	--killicon.Add( "kill_icon_scp096", "vgui/icons/kill_icon_scp096", Color( 255, 255, 255, 255 ) )
--end

SWEP.Lang = nil

function SWEP:Initialize()
	self:InitializeLanguage( "SCP_1471" )

	self:SetHoldType( self.HoldType )
end

function SWEP:Deploy()
	self:HideModels()

	if SERVER and !self.walkspeed and !self.runspeed then
		self.walkspeed = self.Owner:GetWalkSpeed()
		self.runspeed = self.Owner:GetRunSpeed()

		self.Owner:SetRunSpeed( self.walkspeed )
	end
end

SWEP.NextPrimary = 0
function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if self.NextPrimary > CurTime() then return end
	self.NextPrimary = CurTime() + self.Primary.Delay
	if !SERVER then return end
	local fents = ents.FindInSphere( self.Owner:GetPos(), 100 )
	for k, ent in pairs( fents ) do
		if IsValid( ent ) then
			if ent:IsPlayer() then
				if ent:GTeam() != TEAM_SPEC and ent:GTeam() != TEAM_SCP then
					//print( ent.scp1471stacks )
					ent:TakeDamage( ent.scp1471stacks or 1, self.Owner, self.Owner )
				end
			else
				self:SCPDamageEvent( ent, 5 )
			end	
		end
	end
end

SWEP.NextSecondary = 0
function SWEP:SecondaryAttack()
	if preparing or postround then return end
	if self.NextSecondary > CurTime() then return end
	local trace = self.Owner:GetEyeTrace()
	if !trace.Hit then return end
	local ent = trace.Entity
	if IsValid( ent ) then
		if ent:IsPlayer() and ent:GTeam() != TEAM_SCP and ent:GTeam() != TEAM_SPEC then
			if ent:GetAimVector():Dot( (ent:EyePos() - self.Owner:EyePos() ):GetNormalized() ) > -0.5 then
				self.NextSecondary = CurTime() + self.Secondary.Delay
				if !SERVER then return end

				self.Owner:SetWalkSpeed( self.runspeed )
				self.Owner:SetRunSpeed( self.runspeed )
				timer.Simple( 3, function()
					if IsValid( self ) and IsValid( self.Owner ) then
						self.Owner:SetWalkSpeed( self.walkspeed )
						self.Owner:SetRunSpeed( self.walkspeed )
					end
				end )

				local vec = self.Owner:GetPos() - ent:GetPos()
				local dir = vec:GetNormalized()

				ent:SendLua( "CamEnable = true" )
				ent:SendLua( "dir = Vector( "..dir.x..", "..dir.y..", "..dir.z.." )" )

				ent.scp1471stacks = ( ent.scp1471stacks or 1 ) + 1
				--self.Owner:SendLua( "CamEnable = true" )
				--self.Owner:SendLua( "dir = Vector( "..dir.x..", "..dir.y..", "..dir.z.." )" )
			end
		end
	end
end

function SWEP:DrawHUD()
	if disablehud == true then return end
	
	local showtext = self.Lang.HUD.attackReady
	local showcolor = Color(0,255,0)
	
	if self.NextSecondary > CurTime() then
		showtext = self.Lang.HUD.attackCD.." ".. math.Round(self.NextSecondary - CurTime())
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
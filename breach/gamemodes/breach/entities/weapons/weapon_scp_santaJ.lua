AddCSLuaFile()

SWEP.PrintName			= "SCP-SANTA-J"			

SWEP.ViewModelFOV 		= 56
SWEP.Spawnable 			= false
SWEP.AdminOnly 			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Delay        = 6
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo		= "None"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Delay			= 0.25
SWEP.Secondary.Ammo		= "None"

SWEP.ISSCP 				= true
SWEP.droppable				= false
SWEP.CColor					= Color(0,255,0)
SWEP.teams					= { 1 }

SWEP.Weight				= 3
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.Slot					= 0
SWEP.SlotPos				= 4
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.WorldModel			= ""
SWEP.IconLetter			= "w"
SWEP.HoldType 			= "normal"

SWEP.NextPrimary = 0
SWEP.NextSecondary = 0
SWEP.ActGift = false

SWEP.Lang = nil

function SWEP:Initialize()
	if CLIENT then
		self.Lang = GetWeaponLang().SCP_SantaJ
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

function SWEP:Remove()
end

function SWEP:Holster()
	return true
end

SWEP.Freeze = false

function SWEP:Think()
	if SERVER then
		if preparing and (self.Freeze == false) then
			self.Freeze = true
			self.Owner:SetJumpPower(0)
			self.Owner:SetCrouchedWalkSpeed(0)
			self.Owner:SetWalkSpeed(0)
			self.Owner:SetRunSpeed(0)
		end
		if preparing or postround then return end
		if self.Freeze == true then
			self.Freeze = false
			self.Owner:SetCrouchedWalkSpeed(0.6)
			self.Owner:SetJumpPower(200)
			self.Owner:SetWalkSpeed(160)
			self.Owner:SetRunSpeed(160)
		end
	end

	if self.EndTime and self.CTime and self.EndTime != 0 and self.CTime != 0 then
		if self.CTime < CurTime() - 0.1 then
			if SERVER then
				self:ThrowGift( 1.2 - ( self.EndTime - CurTime() ) / 2 )
			end
			self.EndTime = 0
			self.CTime = 0
			self.NextPrimary = CurTime() + self.Primary.Delay
		elseif self.EndTime - CurTime() < 0 then
			self.EndTime = 0
			self.CTime = 0
			self.NextPrimary = CurTime() + 1
		end
	end
	--self.NextPrimary = CurTime() + self.Primary.Delay
end

function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if self.NextPrimary > CurTime() then return end
	if !self.EndTime or self.EndTime == 0 then self.EndTime = CurTime() + 2 end
	if self.EndTime != 0 then
		self.CTime = CurTime()
	end
	--
end

function SWEP:SecondaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if self.NextSecondary > CurTime() then return end
	self.NextSecondary = CurTime() + self.Secondary.Delay
	self.ActGift = !self.ActGift
	--
end

function SWEP:Reload()
end

function SWEP:DrawHUD()
	if disablehud == true then return end

	local x = ScrW() / 2.0
	local y = ScrH() / 2.0

	if self.EndTime and self.EndTime != 0 then
		surface.SetDrawColor( Color( 200, 200, 200, 200 ) )
		surface.DrawRing( x, y, 50, 10, 360, 50, 1 - ( self.EndTime - CurTime() ) / 2 + 0.05, 0 )
	end

	local showtext = self.Lang.HUD.attackReady
	local showcolor = Color( 0, 255, 0 )
	
	if self.NextPrimary > CurTime() then
		showtext = self.Lang.HUD.attackCD.." ".. math.Round( self.NextPrimary - CurTime() )
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
	
	draw.Text( {
		text = self.Lang.HUD.gtype.." "..( self.ActGift and self.Lang.HUD.healing or self.Lang.HUD.explosive ),
		pos = { ScrW() / 2, ScrH() - 50 },
		font = "173font",
		color = Color( 0, 255, 0 ),
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	})

	local scale = 0.3
	surface.SetDrawColor( 0, 255, 0, 255 )
	
	local gap = 5
	local length = gap + 20 * scale
	surface.DrawLine( x - length, y, x - gap, y )
	surface.DrawLine( x + length, y, x + gap, y )
	surface.DrawLine( x, y - length, x, y - gap )
	surface.DrawLine( x, y + length, x, y + gap )
end

function SWEP:DrawWorldModel()
end

function SWEP:ThrowGift( power )
	local gift = ents.Create( "br_gift" )
	if IsValid( gift ) then
		gift:SetOwner( self.Owner )
		gift:SetGiftType( self.ActGift )
		gift:Spawn()
		gift:SetPos( self.Owner:GetShootPos() )
		gift:SetPhysVelocity( self.Owner:GetAimVector() * 750 * power )
	end
end
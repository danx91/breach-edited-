AddCSLuaFile()

SWEP.PrintName			= "SCP-066"			

SWEP.ViewModelFOV 		= 56
SWEP.Spawnable 			= false
SWEP.AdminOnly 			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Delay0		= 3
SWEP.Primary.Delay1		= 30
SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo		= "None"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Delay			= 5
SWEP.Secondary.Ammo		= "None"

SWEP.Primary.Eric				= "scp/066/eric.ogg"
SWEP.Primary.Beethoven		= "scp/066/beethoven.ogg"

SWEP.ISSCP 				= true
SWEP.droppable				= false
SWEP.CColor					= Color(0,255,0)
SWEP.teams					= {1}

SWEP.Weight				= 3
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.Slot					= 0
SWEP.SlotPos				= 4
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.ViewModel			= ""
SWEP.WorldModel			= ""
SWEP.IconLetter			= "w"
SWEP.HoldType 			= "normal"

SWEP.Lang = nil

function SWEP:Initialize()
	if CLIENT then
		self.Lang = GetWeaponLang().SCP_066
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
	self:SetHoldType(self.HoldType)
	
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

function SWEP:Deploy()
	if self.Owner:IsValid() then
		self.Owner:DrawWorldModel( false )
		self.Owner:DrawViewModel( false )
	end
end

function SWEP:Holster()
	return true
end

SWEP.Freeze = false

function SWEP:Think()
if !SERVER then return end
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

function SWEP:Reload()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	--
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
AddCSLuaFile()

if CLIENT then
	SWEP.WepSelectIcon 	= surface.GetTextureID("breach/wep_106")
	SWEP.BounceWeaponIcon = false
end

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/vinrax/props/keycard.mdl"
SWEP.WorldModel		= "models/vinrax/props/keycard.mdl"
SWEP.PrintName		= "SCP-106"
SWEP.Slot			= 0
SWEP.SlotPos		= 0
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= false
SWEP.HoldType		= "normal"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false

SWEP.AttackDelay			= 1
SWEP.ISSCP = true
SWEP.droppable				= false
SWEP.teams					= {1}
SWEP.Primary.Ammo			= "none"
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false

SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.NextAttackW			= 0

function SWEP:Deploy()
	self.Owner:DrawViewModel( false )
end

function SWEP:DrawWorldModel()
end
SWEP.Lang = nil

function SWEP:Initialize()
	if CLIENT then
		self.Lang = GetWeaponLang().SCP_106
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
	self:SetHoldType(self.HoldType)
end

function SWEP:Think()
end

function SWEP:Reload()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
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
				if pos then
					roundstats.teleported = roundstats.teleported + 1
					self.Owner:SetHealth(self.Owner:Health() + 100)
					ent:TakeDamage( 30, self.Owner, self.Owner )
					ent:SetPos(pos)
					self.Owner:AddExp(75, true)
				end
			else
				if ent:GetClass() == "func_breakable" then
					ent:TakeDamage( 100, self.Owner, self.Owner )
				end
			end
		end
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:CanPrimaryAttack()
	return true
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

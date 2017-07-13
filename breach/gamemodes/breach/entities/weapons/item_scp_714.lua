AddCSLuaFile()

SWEP.ViewModelFOV	= 60
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/mishka/models/scp714.mdl"
SWEP.WorldModel		= "models/mishka/models/scp714.mdl"
SWEP.PrintName		= "SCP-714"
SWEP.Slot			= 3
SWEP.SlotPos			= 1
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true
SWEP.HoldType		= "normal"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false

SWEP.droppable				= true
SWEP.teams					= {2,3,5,6}

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			=  "none"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo			=  "none"
SWEP.Secondary.Automatic	=  false

SWEP.InUse = false
SWEP.Durability = 100

function SWEP:Deploy()
	if not IsFirstTimePredicted() then return end
	self.Owner:DrawViewModel( false )
	self.InUse = true
	self.Owner.Using714 = true
end

function SWEP:Holster()
	if not IsFirstTimePredicted() then return end
	self.InUse = false
	self.Owner.Using714 = false
	return true
end

function SWEP:Equip()
	if not IsFirstTimePredicted() then return end
end

function SWEP:DrawWorldModel()
	if !IsValid(self.Owner) then
		self:DrawModel()
	end
end

SWEP.Lang = nil

function SWEP:Initialize()
	if CLIENT then
		self.Lang = GetWeaponLang().SCP_714
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
	self:SetHoldType(self.HoldType)
end

SWEP.LastTime = 0

function SWEP:Think()
	if not IsFirstTimePredicted() then return end
	if !self.InUse then return end
	if self.LastTime > CurTime() then return end
	self.LastTime = CurTime() + 1.2
	self.Durability = self.Durability - 1
	if SERVER then
		if self.Durability > 0 then
			if self.Owner:GetMaxHealth() > self.Owner:Health() then
				self.Owner:SetHealth( self.Owner:Health() + 1 )
			end
		end
		if self.Durability < 1 then self.Owner:StripWeapon( "item_scp_714" ) end
	end
end

function SWEP:OnRemove() 
	self.InUse = false
	for k, v in pairs( player.GetAll() ) do
		v.Using714 = false
	end
end

function SWEP:Reload()
end

function SWEP:OwnerChanged()
	self.InUse = false
	for k, v in pairs( player.GetAll() ) do
		v.Using714 = false
	end
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:CanPrimaryAttack()
end

function SWEP:DrawHUD()
	if disablehud == true then return end
	
	local cRed = (100 - self.Durability) / 100 * 255
	local cGreen = self.Durability / 100 * 255
	
	color = Color( cRed, cGreen, 0 )
	text = self.Lang.HUD.durability.." "..self.Durability.."%"
	disp = self.Lang.HUD.protect
	if self.Durability < 15 then
		disp = self.Lang.HUD.protend
	end
	
	draw.Text( {
		text = text,
		pos = { ScrW() / 2, ScrH() - 60 },
		font = "173font",
		color = color,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	} )
	
		draw.Text( {
		text = disp,
		pos = { ScrW() / 2, ScrH() - 30 },
		font = "173font",
		color = color,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	} )
	
end
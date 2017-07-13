AddCSLuaFile()

if CLIENT then
	SWEP.WepSelectIcon 	= surface.GetTextureID("breach/wep_eyedrops")
	SWEP.BounceWeaponIcon = false
end

SWEP.ViewModelFOV	= 60
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/mishka/models/eyedrops.mdl"
SWEP.WorldModel		= "models/mishka/models/eyedrops.mdl"
SWEP.PrintName		= "Eyedrops"
SWEP.Slot			= 1
SWEP.SlotPos		= 1
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

function SWEP:Deploy()
	self.Owner:DrawViewModel( false )
end
function SWEP:DrawWorldModel()
	if !IsValid(self.Owner) then
		self:DrawModel()
	end
end

SWEP.Lang = nil

function SWEP:Initialize()
	if CLIENT then
		self.Lang = GetWeaponLang().EYEDROPS
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
	self:SetHoldType(self.HoldType)
	self:SetSkin( 1 )
end
function SWEP:Think()
end
function SWEP:Reload()
end
function SWEP:PrimaryAttack()
	OnUseEyedrops(self.Owner)
end
function SWEP:SecondaryAttack()
end
function SWEP:CanPrimaryAttack()
end
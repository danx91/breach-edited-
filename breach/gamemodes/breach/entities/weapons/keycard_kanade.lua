
if CLIENT then
	SWEP.WepSelectIcon 	= surface.GetTextureID("breach/wep_keycardk")
	SWEP.BounceWeaponIcon = false
end

SWEP.Author			= "Kanade"
SWEP.Contact		= "Kanade"
SWEP.Purpose		= "Kanade"
SWEP.Instructions	= "Kanade"

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/breach/keycard.mdl"
SWEP.WorldModel		= "models/breach/keycard.mdl"
SWEP.PrintName		= "Kanade"
SWEP.Slot			= 1
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true
SWEP.HoldType		= "normal"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false

function SWEP:GetBetterOne()
	return "keycard_kanade"
end
SWEP.droppable				= true
SWEP.clevel					= 3
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
	self:SetColor(Color(183, 16, 86))
end
function SWEP:DrawWorldModel()
	if !IsValid(self.Owner) then
		self:DrawModel()
	end
end
function SWEP:Initialize()
	self:SetHoldType("normal")
	self:SetSkin(4)
	self:SetColor(Color(255,0,0))
end
function SWEP:Think()
end
function SWEP:Reload()
end
function SWEP:PrimaryAttack()
end
function SWEP:SecondaryAttack()
end
function SWEP:CanPrimaryAttack()
end
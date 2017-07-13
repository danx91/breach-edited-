AddCSLuaFile()

if CLIENT then
	SWEP.WepSelectIcon 	= surface.GetTextureID("breach/wep_keycard1")
	SWEP.BounceWeaponIcon = false
end

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/mishka/models/keycard.mdl"
SWEP.WorldModel		= "models/mishka/models/keycard.mdl"
SWEP.PrintName		= "Keycard Level 1"
SWEP.Slot			= 1
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true
SWEP.HoldType		= "normal"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false

SWEP.droppable				= true
SWEP.clevel					= 1
SWEP.teams					= {2,3,5,6}

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			=  "none"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo			=  "none"
SWEP.Secondary.Automatic	=  false

function SWEP:GetBetterOne()
	local r = math.random(1,100)
	if buttonstatus == 3 then
		if r < 50 then
			return "keycard_level2"
		else
			return "keycard_level1"
		end
	elseif buttonstatus == 4 then
		if r < 20 then
			return "keycard_level3"
		elseif r < 40 then
			return "keycard_level2"
		else
			return "keycard_level1"
		end
	end
	return "keycard_level1"
end
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
		self.Lang = GetWeaponLang().KEYCARD_1
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
	self:SetHoldType(self.HoldType)
	self:SetSkin(6)
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
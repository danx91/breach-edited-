AddCSLuaFile()

if CLIENT then
	SWEP.WepSelectIcon 	= surface.GetTextureID("breach/wep_cameraview")
	SWEP.BounceWeaponIcon = false
end

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/props_junk/cardboard_box004a.mdl"
SWEP.WorldModel		= "models/props_junk/cardboard_box004a.mdl"
SWEP.PrintName		= "Camera View"
SWEP.Slot			= 1
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= false
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

SWEP.Enabled = false
SWEP.NextChange = 0
SWEP.CAM = 1
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
		self.Lang = GetWeaponLang().CV
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
	self:SetHoldType(self.HoldType)
	self:SetSkin(1)
end
function SWEP:CalcView( ply, pos, ang, fov )
	if CAMERAS == nil then return end
	if !istable(CAMERAS) then return end
	if CAMERAS[self.CAM] == nil then return end
	if self.Enabled then
		ang = ang
		pos = CAMERAS[self.CAM].pos
		fov = 90
	end
	return pos, ang, fov
end
function SWEP:Think()
end
function SWEP:Reload()
end
function SWEP:PrimaryAttack()
	if SERVER then return end
	if self.NextChange > CurTime() then return end
	self.CAM = self.CAM + 1
	if self.CAM > #CAMERAS then
		self.CAM = 1
	end
	chat.AddText(self.Lang.changed.." ".. CAMERAS[self.CAM].name)
	self.NextChange = CurTime() + 0.25
end
function SWEP:SecondaryAttack()
	if SERVER then return end
	if self.NextChange > CurTime() then return end
	self.Enabled = !self.Enabled
	self.NextChange = CurTime() + 0.25
end
function SWEP:CanPrimaryAttack()
end



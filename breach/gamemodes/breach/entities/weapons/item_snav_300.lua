AddCSLuaFile()

if CLIENT then
	SWEP.WepSelectIcon 	= surface.GetTextureID("breach/wep_snav_300")
	SWEP.BounceWeaponIcon = false
end

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/mishka/models/snav.mdl"
SWEP.WorldModel		= "models/mishka/models/snav.mdl"
SWEP.PrintName		= "S-Nav 300"
SWEP.Slot			= 1
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= false
SWEP.HoldType		= "normal"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false

SWEP.betterone = "item_snav_ultimate"
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
		self.Lang = GetWeaponLang().SNAV
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
	self:SetHoldType(self.HoldType)
	self:SetSkin(1)
end
function SWEP:CalcView( ply, pos, ang, fov )
	if self.Enabled then
		ang = Vector(90,0,0)
		pos = pos + Vector(0,0,650)
		fov = 90
	end
	return pos, ang, fov
end
function SWEP:Think()
end
function SWEP:Reload()
end
function SWEP:PrimaryAttack()
end
function SWEP:OnRemove()
	if CLIENT then
		for k,v in pairs(player.GetAll()) do
			v:SetNoDraw( false )
		end
	end
end
function SWEP:Holster()
	if CLIENT then
		for k,v in pairs(player.GetAll()) do
			v:SetNoDraw( false )
		end
	end
	return true
end
function SWEP:SecondaryAttack()
	if SERVER then return end
	if self.NextChange > CurTime() then return end
	self.Enabled = !self.Enabled
	if self.Enabled then
		for k,v in pairs(player.GetAll()) do
			v:SetNoDraw( true )
		end
	else
		for k,v in pairs(player.GetAll()) do
			v:SetNoDraw( false )
		end
	end
	self.NextChange = CurTime() + 0.25
end
function SWEP:CanPrimaryAttack()
end



AddCSLuaFile()

SWEP.ViewModelFOV	= 60
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/scp500/scp500model.mdl"
SWEP.WorldModel		= "models/weapons/scp500/scp500model.mdl"
SWEP.PrintName		= "SCP-500"
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

function SWEP:Deploy()
	if not IsFirstTimePredicted() then return end
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
		self.Lang = GetWeaponLang().SCP_500
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
	self:SetHoldType(self.HoldType)
end

function SWEP:Think()
	if not IsFirstTimePredicted() then return end
end

function SWEP:OnUse()
	self.Owner:SetHealth( self.Owner:GetMaxHealth() )
	self.Owner:StripWeapon( self:GetClass() )
end

function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if !SERVER then return end
	if self.Owner:Health() > self.Owner:GetMaxHealth() * 0.75 then return end
	self:OnUse()
end

function SWEP:SecondaryAttack()
end

function SWEP:PlayerShouldDie()
	self.OnUse()
end
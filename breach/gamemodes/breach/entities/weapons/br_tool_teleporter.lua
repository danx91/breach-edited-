AddCSLuaFile()

SWEP.PrintName			= "Teleporter"			

SWEP.ViewModelFOV 		= 56
SWEP.Spawnable 			= false
SWEP.AdminOnly 			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Delay        = 0
SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo		= "None"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Delay			= 5
SWEP.Secondary.Ammo		= "None"

SWEP.droppable				= false

SWEP.Weight				= 3
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.Slot					= 0
SWEP.SlotPos				= 4
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.ViewModel			= ""
SWEP.WorldModel			= ""
SWEP.IconLetter			= "Teleporter"
SWEP.SelectFont			= "DermaLarge"
SWEP.HoldType 			= "normal"

--if (CLIENT) then
	--SWEP.WepSelectIcon	= surface.GetTextureID( "vgui/entities/weapon_scp096" )
	--SWEP.BounceWeaponIcon = false
	--killicon.Add( "kill_icon_scp096", "vgui/icons/kill_icon_scp096", Color( 255, 255, 255, 255 ) )
--end

function SWEP:Initialize()
	if CLIENT then
		self.Author		= "danx91"
	end
	self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
	if self.Owner:IsValid() then
		if SERVER then self.Owner:DrawWorldModel( false ) end
		self.Owner:DrawViewModel( false )
	end
end

function SWEP:Holster()
	return true
end

SWEP.cPlayer = 0
function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end

	self:Teleport( 1 )
end

function SWEP:SecondaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	
	self:Teleport( -1 )
end

function SWEP:Teleport( num )
	if SERVER then
		self.cPlayer = self.cPlayer + num

		if self.cPlayer > player.GetCount() then
			self.cPlayer = 1
		end

		if self.cPlayer < 1 then
			self.cPlayer = player.GetCount()
		end

		local target = player.GetAll()[self.cPlayer]

		if target == self.Owner then
			self.cPlayer = self.cPlayer + num

			if self.cPlayer > player.GetCount() then
				self.cPlayer = 1
			end

			if self.cPlayer < 1 then
				self.cPlayer = player.GetCount()
			end

			target = player.GetAll()[self.cPlayer]
		end

		if IsValid( target ) then
			local angs = target:GetAngles()
			local pos = target:GetPos() + angs:Forward() * -32 + Vector( 0, 0, 32 )

			angs:RotateAroundAxis( angs:Right(), -30 )

			self.Owner:SetEyeAngles( angs )
			self.Owner:SetPos( pos )
		end
	end
end

function SWEP:Reload()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	--
end

function SWEP:DrawHUD()
	/*local tr = self.Owner:GetEyeTrace()
	local pos = tr.HitPos:ToScreen()
	local spos = tr.StartPos:ToScreen()
	surface.SetDrawColor( Color( 25, 25, 200, 255 ) )
	surface.DrawLine( spos.x, spos.y, pos.x, pos.y )*/
end
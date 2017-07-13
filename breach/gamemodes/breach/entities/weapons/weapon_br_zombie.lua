AddCSLuaFile()

if CLIENT then
	SWEP.WepSelectIcon 	= surface.GetTextureID("breach/wep_zombie")
	SWEP.BounceWeaponIcon = false
end

SWEP.Author			= "Kanade"
SWEP.Contact		= "Look at this gamemode in workshop and search for creators"
SWEP.Purpose		= "Kill humens"
SWEP.Instructions	= "Click left to attack"
SWEP.Base			= "weapon_breach_basemelee"

SWEP.ViewModelFOV	= 75
SWEP.ViewModelFlip	= false
SWEP.HoldType		= "knife"
SWEP.ViewModel		= "models/weapons/v_zombiearms.mdl"
SWEP.WorldModel		= ""
SWEP.PrintName		= "Zombie"
SWEP.DrawCrosshair	= false
SWEP.Slot			= 0

SWEP.Spawnable			= false
SWEP.AdminOnly			= false
SWEP.ISSCP				= true

SWEP.droppable				= false
SWEP.Primary.Automatic		= false
SWEP.Primary.NextAttack		= 0.25
SWEP.Primary.AttackDelay	= 0.4
SWEP.Primary.Damage			= 26
SWEP.Primary.Force			= 3250
SWEP.Primary.AnimSpeed		= 2.8

SWEP.Secondary.Automatic	= true
SWEP.Secondary.NextAttack	= 0.7
SWEP.Secondary.AttackDelay	= 1.6
SWEP.Secondary.Damage		= 82
SWEP.Secondary.Force		= 6000
SWEP.Secondary.AnimSpeed	= 2.4

SWEP.Range					= 100

SWEP.UseHands				= false
SWEP.DrawCustomCrosshair	= true
SWEP.DeploySpeed			= 1
SWEP.AttackTeams			= {2,3,5,6} // Attack only humans
SWEP.AttackNPCs				= false

SWEP.ZombieWeapon			= true

SWEP.SoundMiss 			= "npc/zombie/claw_miss1.wav"
SWEP.SoundWallHit		= "npc/zombie/claw_strike1.wav"
SWEP.SoundFleshSmall	= "npc/zombie/claw_strike2.wav"
SWEP.SoundFleshLarge	= "npc/zombie/claw_strike3.wav"

function SWEP:SecondaryAttack()
	self:SetHoldType("knife")
	//if ( !self:CanSecondaryAttack() ) then return end
	//if not IsFirstTimePredicted() then return end
	if self:GetNextSecondaryFire() > CurTime() then return end
	self.Owner:GetViewModel():SetPlaybackRate( self.Secondary.AnimSpeed )
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self.Owner:DoAnimationEvent(ACT_GMOD_GESTURE_RANGE_ZOMBIE)
	timer.Create("AttackDelay" .. self.Owner:SteamID(), self.Secondary.NextAttack, 1, function()
		if IsValid(self) == false then return end
		self.AttackType = 2
		self:Stab(2, self.Range)
	end)
	self:SetNextPrimaryFire( CurTime() + self.Secondary.AttackDelay)
	self:SetNextSecondaryFire( CurTime() + self.Secondary.AttackDelay)
end

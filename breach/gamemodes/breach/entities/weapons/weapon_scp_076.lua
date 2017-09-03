SWEP.PrintName				= "SCP-076-2"
SWEP.Slot						= 0	
SWEP.SlotPos					= 25
SWEP.DrawAmmo				= false
SWEP.BounceWeaponIcon		= false
SWEP.DrawCrosshair			= false
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false
SWEP.HoldType 				= "melee"

SWEP.ViewModelFOV			= 60
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/scp076/v_katana.mdl"
SWEP.WorldModel				= "models/weapons/scp076/w_katana.mdl"
SWEP.Spawnable				= false
SWEP.AdminSpawnable			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo		= ""

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= ""

SWEP.ISSCP 				= true
SWEP.droppable				= false
SWEP.teams					= {1}

SWEP.NextPrimary = 0

SWEP.Lang = nil
SWEP.NextIdle = 0

function SWEP:Initialize()
	if CLIENT then
		self.Lang = GetWeaponLang().SCP_076
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
	self:SetHoldType( self.HoldType )
	self.NextIdle = CurTime() + self:SequenceDuration( ACT_VM_DRAW)
	self:SendWeaponAnim( ACT_VM_DRAW )
	self.NextPrimary = CurTime() + 1
	self:EmitSound( "weapons/knife/knife_deploy1.wav" )
end

SWEP.Freeze = false

function SWEP:Think()
	if !SERVER then return end
	if preparing and (self.Freeze == false) then
		self.Freeze = true
		self.Owner:SetJumpPower(0)
		self.Owner:SetCrouchedWalkSpeed(0)
		self.Owner:SetWalkSpeed(0)
		self.Owner:SetRunSpeed(0)
	end
	if preparing or postround then return end
	if self.Freeze == true then
		self.Freeze = false
		self.Owner:SetCrouchedWalkSpeed(0.6)
		self.Owner:SetJumpPower(210)
		self.Owner:SetWalkSpeed(250)
		self.Owner:SetRunSpeed(250)
	end
	if self.NextIdle > CurTime() then return end
	self.NextIdle = CurTime() + self:SequenceDuration( ACT_VM_IDLE )
	self:SendWeaponAnim( ACT_VM_IDLE )
end

function SWEP:PrimaryAttack()
	if postround then return end
	if self.NextPrimary > CurTime() then return end
	self.NextPrimary = CurTime() + 0.4
	self.NextIdle = CurTime() + self:SequenceDuration( ACT_VM_MISSCENTER )
	self:EmitSound( "Weapon_Knife.Slash" )
	self.Owner:LagCompensation( true )
	
	local pos = self.Owner:GetShootPos()
	local aim = self.Owner:GetAimVector()
	local dmg = math.random( 25, 50 )
	local dist = 75

	local damage = DamageInfo()
	damage:SetDamage( dmg )
	damage:SetDamageType( DMG_SLASH )
	damage:SetAttacker( self.Owner )
	damage:SetInflictor( self )
	damage:SetDamageForce( aim * 300 )

	local tr = util.TraceHull( {
		start = pos,
		endpos = pos + aim * dist,
		filter = self.Owner,
		mask = MASK_SHOT_HULL,
		mins = Vector( -10, -5, -5 ),
		maxs = Vector( 10, 5, 5 )
	} )
	if tr.Hit then
		local ent = tr.Entity
		if ent:IsPlayer() then
			self:EmitSound( "Weapon_Knife.Hit" )
			if SERVER then
				ent.RagVelocity = damage:GetDamageForce()
				ent:TakeDamageInfo( damage )
			end
		elseif ent:GetClass() != "worldspawn" then
			if SERVER then
				ent:TakeDamageInfo( damage )
			end
		else
			local look = self.Owner:GetEyeTrace()
			self:EmitSound( "weapons/rpg/shotdown.wav" )
			util.Decal("ManhackCut", look.HitPos + look.HitNormal, look.HitPos - look.HitNormal )
		end
	end
	
	self.Owner:LagCompensation( false )
	self:SendWeaponAnim( ACT_VM_MISSCENTER )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:SecondaryAttack()
	--
end
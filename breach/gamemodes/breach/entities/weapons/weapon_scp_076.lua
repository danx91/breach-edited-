AddCSLuaFile()

SWEP.Base 					= "weapon_scp_base"
SWEP.PrintName				= "SCP-076-2"

SWEP.ViewModel				= "models/weapons/scp076/v_katana.mdl"
SWEP.WorldModel				= "models/weapons/scp076/w_katana.mdl"

SWEP.HoldType 				= "melee"

SWEP.NextPrimary = 0
SWEP.NextIdle = 0

function SWEP:Initialize()
	self:InitializeLanguage( "SCP_076" )

	self:SetHoldType( self.HoldType )

	self.NextIdle = CurTime() + self:SequenceDuration( ACT_VM_DRAW)
	self:SendWeaponAnim( ACT_VM_DRAW )
	self.NextPrimary = CurTime() + 1
	self:EmitSound( "weapons/knife/knife_deploy1.wav" )
end

function SWEP:Deploy()
end

function SWEP:Think()
	self:PlayerFreeze()

	if self.NextIdle > CurTime() then return end
	self.NextIdle = CurTime() + self:SequenceDuration( ACT_VM_IDLE )
	self:SendWeaponAnim( ACT_VM_IDLE )
end

function SWEP:PrimaryAttack()
	if postround then return end
	if self.NextPrimary > CurTime() then return end
	self.NextPrimary = CurTime() + 1
	self.NextIdle = CurTime() + self:SequenceDuration( ACT_VM_MISSCENTER )
	self:EmitSound( "Weapon_Knife.Slash" )
	self.Owner:LagCompensation( true )
	
	local pos = self.Owner:GetShootPos()
	local aim = self.Owner:GetAimVector()
	local dmg = math.random( 25, 35 )
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
			if ent:GTeam() != TEAM_SPEC and ent:GTeam() != TEAM_SCP then
				self:EmitSound( "Weapon_Knife.Hit" )
				if SERVER and ent:GTeam() != TEAM_SCP then
					ent:TakeDamageInfo( damage )
				end
			end
		elseif !self:SCPDamageEvent( ent, 10 ) then
			local look = self.Owner:GetEyeTrace()
			self:EmitSound( "weapons/rpg/shotdown.wav" )
			util.Decal("ManhackCut", look.HitPos + look.HitNormal, look.HitPos - look.HitNormal )
		end
	end
	
	self.Owner:LagCompensation( false )
	self:SendWeaponAnim( ACT_VM_MISSCENTER )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end
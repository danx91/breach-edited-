AddCSLuaFile()

SWEP.Base 			= "weapon_scp_base"
SWEP.PrintName		= "SCP-1048-B"

SWEP.DrawCrosshair	= true
SWEP.ViewModel 		= "models/weapons/c_arms.mdl"
SWEP.HoldType 		= "fist"
SWEP.UseHands 		= true

function SWEP:Initialize()
	self:InitializeLanguage( "SCP_1048B" )

	self:SetHoldType(self.HoldType)

	sound.Add( {
		name = "miss",
		channel = CHAN_STATIC,
		volume = 1.0,
		level = 80,
		pitch = 100,
		sound = "weapons/slam/throw.wav"
	} )
	for i=1, 6 do
			sound.Add( {
			name = "attack"..i,
			channel = CHAN_STATIC,
			volume = 1.0,
			level = 80,
			pitch = 100,
			sound = "physics/body/body_medium_impact_hard"..i..".wav"
		} )
	end
end

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_draw" ) )

	self.Owner:DrawWorldModel( false )
end

SWEP.NextIdle = 0

function SWEP:Think()
	self:PlayerFreeze()

	if self.NextIdle < CurTime() then
		local vm = self.Owner:GetViewModel()
		self.NextIdle = CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate()
		vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_idle_0" .. math.random( 1, 2 ) ) )
	end
end

SWEP.NextPrimary = 0

function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if self.NextPrimary > CurTime() then return end
	self.NextPrimary = CurTime() + 1.25
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( table.Random( { "fists_left", "fists_right" } ) ) )
	self.NextIdle = CurTime() + 0.3
	local trace = util.TraceHull( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 50,
		filter = self.Owner,
		mask = MASK_SHOT,
		maxs = Vector( 10, 10, 10 ),
		mins = Vector( -10, -10, -10 ),
	} )
	local ent = trace.Entity
	if trace.Hit then
		self:EmitSound( "attack"..math.random( 1, 6 ) )
	else
		self:EmitSound( "miss" )
	end
	if SERVER then
		if IsValid( ent ) then
			if ent:IsPlayer() then
				if ent:GTeam() == TEAM_SPEC then return end
				if ent:GTeam() == TEAM_SCP then return end
				ent:TakeDamage( math.random( 20, 40 ), self.Owner, self )
			else
				if ent:GetClass() == "func_breakable" then
					ent:TakeDamage( 100, self.Owner, self )
				end
			end
		end
	end
end

function SWEP:SecondaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	self:PrimaryAttack()
end
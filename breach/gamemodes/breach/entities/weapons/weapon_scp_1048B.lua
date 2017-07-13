AddCSLuaFile()

SWEP.PrintName			= "SCP-1048-B"			

SWEP.ViewModelFOV 		= 54
SWEP.Spawnable 			= false
SWEP.AdminOnly 			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Delay        = 1
SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo		= "None"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Delay			= 5
SWEP.Secondary.Ammo		= "None"

SWEP.ISSCP 				= true
SWEP.droppable				= false
SWEP.CColor					= Color(0,255,0)
SWEP.teams					= {1}

SWEP.Weight				= 3
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.Slot					= 0
SWEP.SlotPos				= 4
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.ViewModel 		= Model( "models/weapons/c_arms.mdl" )
SWEP.WorldModel		= ""
SWEP.IconLetter			= "w"
SWEP.HoldType 			= "fist"
SWEP.UseHands = true

SWEP.Lang = nil

function SWEP:Initialize()
	if CLIENT then
		self.Lang = GetWeaponLang().SCP_1048B
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
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
end

function SWEP:Holster()
	return true
end

SWEP.Freeze = false
SWEP.NextIdle = 0

function SWEP:Think()
	if self.NextIdle < CurTime() then
		local vm = self.Owner:GetViewModel()
		self.NextIdle = CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate()
		vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_idle_0" .. math.random( 1, 2 ) ) )
	end
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
		self.Owner:SetJumpPower(200)
		self.Owner:SetWalkSpeed(180)
		self.Owner:SetRunSpeed(180)
	end
end

SWEP.NextPrimary = 0

function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if self.NextPrimary > CurTime() then return end
	self.NextPrimary = CurTime() + 1
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( table.Random( { "fists_left", "fists_right" } ) ) )
	self.NextIdle = CurTime() + 0.3
	local trace = util.TraceHull( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 50,
		filter = self.Owner,
		mask = MASK_SHOT,
		maxs = Vector( 10, 10, 8 ),
		mins = Vector( -10, -10, -8 ),
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

function SWEP:Reload()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	--
end

function SWEP:DrawHUD()
	if disablehud == true then return end
	--
end
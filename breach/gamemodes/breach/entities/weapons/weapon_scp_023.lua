AddCSLuaFile()

SWEP.Base 			= "weapon_scp_base"
SWEP.PrintName		= "SCP-023"
SWEP.DrawCrosshair	= true
SWEP.HoldType 		= "fist"

SWEP.Primary.Sound			= "scp/023/attack.mp3"
SWEP.Secondary.Automatic 	= true

function SWEP:Initialize()
	self:InitializeLanguage( "SCP_023" )
	self:SetHoldType( self.HoldType )
end

function SWEP:Deploy()
	self:HideModels()

	if SERVER and !self.basespeed then
		self.basespeed = self.Owner:GetWalkSpeed()
		self.runspeed = self.Owner:GetRunSpeed()
		self.Owner:SetRunSpeed( self.basespeed )
	end
end

SWEP.NextSpec = 0
function SWEP:Think()
	self:PlayerFreeze()
	if !SERVER then return end
	if self.Speed and self.NextSecondary < CurTime() then
		self.Owner:SetWalkSpeed(self.basespeed)
		self.Owner:SetRunSpeed(self.basespeed)
	end
	if self.NextSpec > CurTime() then return end
	self.NextSpec = CurTime() + 0.1
	for k, v in pairs( player.GetAll() ) do
		if v.scp023Ignited and v.scp023Ignited > 0 then
			v.scp023Ignited = v.scp023Ignited - 0.1
			if v.scp023Ignited < 0 then
				v.scp023Ignited = 0
			end
		end
	end
	local fent = ents.FindInSphere( self.Owner:GetPos(), 10 )
	if !fent or #fent < 1 then return end
	for k, v in pairs( fent ) do
		if IsValid( v ) and v:IsPlayer() and v:Alive() then
			if v:GTeam() != TEAM_SCP and v:GTeam() != TEAM_SPEC and !v.Using714 then
				if v.scp023Ignited == 0 or !v.scp023Ignited then
					local hp = self.Owner:Health() + math.random( 100, 200 )
					if hp > self.Owner:GetMaxHealth() then
						hp = self.Owner:GetMaxHealth()
					end
					self.Owner:SetHealth( hp )
					v.scp023Ignited = 15
					v:Ignite( 3 )
				end
			end
		end
	end
end

SWEP.NextPrimary = 0
function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if self.NextPrimary > CurTime() then return end
	self.NextPrimary = CurTime() + 1
	self:EmitSound( self.Primary.Sound )
	if !SERVER then return end
	local trace = util.TraceHull( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 40,
		filter = self.Owner,
		mask = MASK_SHOT,
		maxs = Vector( 5, 5, 5 ),
		mins = Vector( -5, -5, -5 ),
	} )
	local ent = trace.Entity
	if IsValid( ent ) then
		if ent:IsPlayer() then
			if ent:GTeam() == TEAM_SPEC then return end
			if ent:GTeam() == TEAM_SCP then return end
			ent:TakeDamage( math.random( 10, 20 ), self.Owner, self.Owner )
		else
			if ent:GetClass() == "func_breakable" then
				ent:TakeDamage( 100, self.Owner, self.Owner )
			end
		end
	end
end

SWEP.NextSecondary = 0
SWEP.Speed = false
function SWEP:SecondaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if self.NextSecondary > CurTime() then return end
	self.Speed = false
	if self.Owner:Health() < 250 then
		if CLIENT then
			self.Owner:PrintMessage( HUD_PRINTTALK, self.Lang.HUD.lowhealth )
		end
		self.NextSecondary = CurTime() + 1
	else
		self.Owner:SetHealth( self.Owner:Health() - 3 )
		self.NextSecondary = CurTime() + 0.15
		self.Speed = true
		if SERVER then
			self.Owner:SetWalkSpeed(self.runspeed)
			self.Owner:SetRunSpeed(self.runspeed)
		end
	end
end
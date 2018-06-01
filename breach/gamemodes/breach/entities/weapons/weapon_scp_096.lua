AddCSLuaFile()

SWEP.Base 				= "weapon_scp_base"
SWEP.PrintName			= "SCP096"			

SWEP.DrawCrosshair		= true
SWEP.ViewModel			= "models/weapons/v_arms_scp096.mdl"

SWEP.Primary.Sound 		= "weapons/scp96/attack1.wav"
SWEP.HoldType 			= "knife"

SWEP.NextAttackW		= 0

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID( "vgui/entities/weapon_scp096" )
end

function SWEP:Initialize()
	self:InitializeLanguage( "SCP_096" )

    self:SetHoldType( self.HoldType )
		
	sound.Add( { name = "096_1", channel = CHAN_STATIC, volume = 1.0, level = 80, pitch = { 95, 110 }, sound = "weapons/scp96/096_1.mp3" } )
	sound.Add( { name = "096_2", channel = CHAN_STATIC, volume = 1.0, level = 80, pitch = { 95, 110 }, sound = "weapons/scp96/096_2.mp3" } )
	sound.Add( { name = "096_3", channel = CHAN_STATIC, volume = 1.0, level = 80, pitch = { 95, 110 }, sound = "weapons/scp96/096_3.mp3" } )
	
	util.PrecacheSound("096_1")	
	util.PrecacheSound("096_2")	
	util.PrecacheSound("096_3")	
	util.PrecacheSound("weapons/scp96/attack1.wav")
	util.PrecacheSound("weapons/scp96/attack2.wav")
	util.PrecacheSound("weapons/scp96/attack3.wav")
	util.PrecacheSound("weapons/scp96/attack4.wav")
	util.PrecacheSound("weapons/scp96/096_idle1.wav")
	util.PrecacheSound("weapons/scp96/096_idle2.wav")
	util.PrecacheSound("weapons/scp96/096_idle3.wav")
end

function SWEP:IsLookingAt( ply )
	local yes = ply:GetAimVector():Dot( ( self.Owner:GetPos() - ply:GetPos() + Vector( 70 ) ):GetNormalized() )
	return yes > 0.39
end

SWEP.NextIdle = 0
function SWEP:Think()
	if self.NextIdle < CurTime() then
		self:SendWeaponAnim( ACT_VM_IDLE )
		self.NextIdle = CurTime() + self:SequenceDuration( ACT_VM_IDLE )
	end
	if postround then return end
	local watching = 0
	for k,v in pairs(player.GetAll()) do
		if IsValid(v) and v:GTeam() != TEAM_SPEC and v:Alive() and v != self.Owner and v.canblink then
			local tr_eyes = util.TraceLine( {
				start = v:EyePos() + v:EyeAngles():Forward() * 15,
				//start = v:LocalToWorld( v:OBBCenter() ),
				//start = v:GetPos() + (self.Owner:EyeAngles():Forward() * 5000),
				endpos = self.Owner:EyePos(),
				//filter = v
			} )
			local tr_center = util.TraceLine( {
				start = v:LocalToWorld( v:OBBCenter() ),
				endpos = self.Owner:LocalToWorld( self.Owner:OBBCenter() ),
				filter = v
			} )
			if tr_eyes.Entity == self.Owner or tr_center.Entity == self.Owner then
				//self.Owner:PrintMessage(HUD_PRINTTALK, tostring(tr_eyes.Entity) .. " : " .. tostring(tr_center.Entity) .. " : " .. tostring(tr_center.Entity))
				if self:IsLookingAt( v ) and v.isblinking == false then
					watching = watching + 1
					//if self:GetPos():Distance(v:GetPos()) > 100 then
						//self.Owner:PrintMessage(HUD_PRINTTALK, v:Nick() .. " is looking at you")
					//end 
				end
			end
		end
	end
	if self.basestats then
		if watching > 0 then
			self.Owner:SetRunSpeed( self.basestats.fast )
			self.Owner:SetWalkSpeed( self.basestats.fast )
		else
			self.Owner:SetRunSpeed( self.basestats.slow )
			self.Owner:SetWalkSpeed( self.basestats.slow )
		end
	end
end

function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if self.NextAttackW > CurTime() then return end
	self.NextAttackW = CurTime() + 1.25

	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.NextIdle = CurTime() + 0.7
	if SERVER then
		local trace = self.Owner:GetEyeTrace()
		local tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 125,
			filter = { self, self.Owner },
			mins = Vector( -15, -15, -15 ),
			maxs = Vector( 15, 15, 15 ),
			mask = MASK_SHOT_HULL
		} )

		local ent = tr.Entity
		if IsValid( ent ) then
			if ent:IsPlayer() then
				if ent:GTeam() == TEAM_SCP then return end
				if ent:GTeam() == TEAM_SPEC then return end
				ent:TakeDamage(math.random(60, 100), self.Owner, self.Owner)
			elseif ent:GetClass() == "func_breakable" then
				ent:TakeDamage( 100, self.Owner, self.Owner )
			end
		end
	end
end

function SWEP:Deploy()
	if self.Owner:IsValid() then
		if SERVER and !self.basestats then
			self.basestats = {
				slow = self.Owner:GetWalkSpeed(),
				fast = self.Owner:GetRunSpeed()
			}
		end

		self.Owner:SetRunSpeed( self.Owner:GetWalkSpeed() )

		self.Owner:DrawWorldModel( false )
		self.Weapon:EmitSound( "weapons/scp96/096_idle"..math.random(1,3)..".wav" )
		
		self:SendWeaponAnim( ACT_VM_DRAW )

		self.NextIdle = CurTime() + self:SequenceDuration( ACT_VM_DRAW )
	end
end

SWEP.NextSpecial = 0
function SWEP:SecondaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if self.NextSpecial > CurTime() then return end
	self.NextSpecial = CurTime() + 10

	self.Owner:StopSound("096_1")
	self.Owner:StopSound("096_2")
	self.Owner:StopSound("096_3")
	
    self.Owner:EmitSound( "096_"..math.random(1,3) )

end
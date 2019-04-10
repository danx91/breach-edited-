AddCSLuaFile()

SWEP.Base 			= "weapon_scp_base"
SWEP.PrintName		= "SCP-082"

SWEP.ViewModel		= "models/weapons/scp082/v_machete.mdl"
SWEP.WorldModel		= "models/weapons/scp082/w_fc2_machete.mdl"

SWEP.Primary.Sound	= Sound( "scp/082/woosh.mp3" )
SWEP.KnifeShink 	= Sound( "scp/082/hitwall.mp3" )
SWEP.KnifeSlash 	= Sound( "scp/082/slash.mp3" )
SWEP.KnifeStab 		= Sound( "scp/082/nastystab.mp3" )

SWEP.HoldType 		= "melee"
SWEP.NextPrimary	= 0
SWEP.NextIdle 		= 0

function SWEP:Initialize()
	self:InitializeLanguage( "SCP_082" )

	self:SetHoldType( self.HoldType )

	self:SendWeaponAnim( ACT_VM_DRAW )
	self.NextPrimary = CurTime() + 1.3
	self:EmitSound( "scp/082/knife_draw_x.mp3", 50, 100 )
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
	if preparing or postround then return end
	if self.NextPrimary > CurTime() then return end
	self.NextPrimary = CurTime() + 1.75
	vm = self.Owner:GetViewModel()
	self.NextIdle = CurTime() + vm:SequenceDuration( vm:LookupSequence( "stab" ) )
	self.Owner:ViewPunch( Angle( -10,0,0 ) )
	self:EmitSound( self.Primary.Sound )
	if SERVER then
		vm:SetSequence( vm:LookupSequence( "stab" ) )
		timer.Create( "hack-n-slash", 0.3, 1, function()
			if IsValid( self ) and IsValid( self.Owner ) then
				if self.Owner:Alive() then 
					self:HackNSlash() 
				end
			end
		end )		
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
	end
end

function SWEP:HackNSlash()
	self.Owner:LagCompensation( true )
	local slash = {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 65,
		filter = self.Owner,
		mins = Vector( -8, -10, 5 ),
		maxs = Vector( 8, 10, 5 ),
	}
	local slashtrace = util.TraceHull( slash )
	
	if self.Owner:GetActiveWeapon():GetClass() == self:GetClass() then
		self.Owner:ViewPunch( Angle( 15, 0, 0 ) )
		--if slashtrace.Hit then
			local target = slashtrace.Entity
			if IsValid( target ) then
				if target:IsPlayer() then
					if target:GTeam() == TEAM_SPEC then return end
					if target:GTeam() == TEAM_SCP then return end
					self:EmitSound( self.KnifeSlash )
					local dmg = math.random( 30, 60 )
					local paininfo = DamageInfo()
						paininfo:SetDamage( dmg )
						paininfo:SetDamageType( DMG_SLASH )
						paininfo:SetAttacker( self.Owner )
						paininfo:SetInflictor( self )
						paininfo:SetDamageForce( slashtrace.Normal * 3500 )
					target:TakeDamageInfo( paininfo )
					if target:Health() < 0 then
						local hp = self.Owner:Health()
						hp = hp + math.random( 150, 250 )
						if hp > self.Owner:GetMaxHealth() then hp = self.Owner:GetMaxHealth() end
						self.Owner:SetHealth( hp )
					end
					target:SendLua("LocalPlayer().Stamina = 10")
				else
					self:SCPDamageEvent( ent, 10 )
				end
			elseif slashtrace.Hit then
				self:EmitSound( self.KnifeShink )
				look = self.Owner:GetEyeTrace()
				util.Decal( "ManhackCut", look.HitPos + look.HitNormal * 5, look.HitPos - look.HitNormal * 5 )
			end
		--end
	end
	self.Owner:LagCompensation(false)
end
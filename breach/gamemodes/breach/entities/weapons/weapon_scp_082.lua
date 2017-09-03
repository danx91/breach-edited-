SWEP.PrintName				= "SCP-082"
SWEP.Slot					= 0	
SWEP.SlotPos					= 25
SWEP.DrawAmmo				= false
SWEP.BounceWeaponIcon	= false
SWEP.DrawCrosshair			= false
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom		= false
SWEP.HoldType 				= "melee"

SWEP.ViewModelFOV			= 60
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/scp082/v_machete.mdl"
SWEP.WorldModel			= "models/weapons/scp082/w_fc2_machete.mdl"
SWEP.Spawnable				= false
SWEP.AdminSpawnable		= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo			= ""

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo			= ""

SWEP.AttackDelay			= 5
SWEP.ISSCP 					= true
SWEP.droppable				= false
SWEP.teams					= {1}

SWEP.Primary.Sound	= Sound( "scp/082/woosh.mp3" )
SWEP.KnifeShink = Sound( "scp/082/hitwall.mp3" )
SWEP.KnifeSlash = Sound( "scp/082/slash.mp3" )
SWEP.KnifeStab = Sound( "scp/082/nastystab.mp3" )

SWEP.NextPrimary = 0

SWEP.Lang = nil

function SWEP:Initialize()
	if CLIENT then
		self.Lang = GetWeaponLang().SCP_082
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
	self:SetHoldType( self.HoldType )
	self:SendWeaponAnim( ACT_VM_DRAW )
	self.NextPrimary = CurTime() + 1.3
	self:EmitSound( "scp/082/knife_draw_x.mp3", 50, 100 )
	return true
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
		self.Owner:SetJumpPower(200)
		self.Owner:SetWalkSpeed(150)
		self.Owner:SetRunSpeed(150)
	end
end

function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if self.NextPrimary > CurTime() then return end
	self.NextPrimary = CurTime() + 1.5
	vm = self.Owner:GetViewModel()
	self:SendWeaponAnim( ACT_VM_IDLE )
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
					local dmg = math.random( 40, 75 )
					local paininfo = DamageInfo()
						paininfo:SetDamage( dmg )
						paininfo:SetDamageType( DMG_SLASH )
						paininfo:SetAttacker( self.Owner )
						paininfo:SetInflictor( self )
						paininfo:SetDamageForce( slashtrace.Normal * 3500 )
					target:TakeDamageInfo( paininfo )
					if target:Health() < 0 then
						print(target:Health(), dmg)
						local hp = self.Owner:Health()
						hp = hp + math.random( 150, 250 )
						if hp > self.Owner:GetMaxHealth() then hp = self.Owner:GetMaxHealth() end
						self.Owner:SetHealth( hp )
					end
					target:SendLua("LocalPlayer().Stamina = 10")
				elseif target:GetClass() == "func_breakable" then
					target:TakeDamage( 100, self.Owner, self )
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

function SWEP:SecondaryAttack()
end
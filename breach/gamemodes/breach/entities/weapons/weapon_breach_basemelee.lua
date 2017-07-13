AddCSLuaFile()

SWEP.Author			= "Kanade"
SWEP.Contact		= "Steam"
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 55
SWEP.ViewModelFlip	= false
SWEP.HoldType		= "knife"
SWEP.ViewModel		= "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel		= "models/weapons/w_knife_t.mdl"
SWEP.PrintName		= "Base Melee"
SWEP.DrawCrosshair	= false
SWEP.Slot			= 0
SWEP.Base			= "weapon_base"

SWEP.Spawnable			= false
SWEP.AdminOnly			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.NextAttack		= 0.2
SWEP.Primary.AttackDelay	= 0.6
SWEP.Primary.Damage			= 35
SWEP.Primary.Force			= 3250
SWEP.Primary.AnimSpeed		= 1

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.NextAttack	= 0.2
SWEP.Secondary.AttackDelay	= 0.85
SWEP.Secondary.Damage		= 70
SWEP.Secondary.Force		= 6000
SWEP.Secondary.AnimSpeed	= 1

SWEP.AttackType				= 1
SWEP.Range					= 75

SWEP.UseHands				= true
SWEP.DrawCustomCrosshair	= true
SWEP.DeploySpeed			= 1
SWEP.AttackTeams			= {}
SWEP.AttackNPCs				= true

SWEP.ZombieWeapon			= false

SWEP.SoundDeploy		=  "weapons/knife/knife_deploy1.wav"
SWEP.SoundMiss 			=  "weapons/knife/knife_slash1.wav"
SWEP.SoundWallHit		=  "weapons/knife/knife_hitwall1.wav"
SWEP.SoundFleshSmall	=  "weapons/knife/knife_hit1.wav"
SWEP.SoundFleshLarge	=  "weapons/knife/knife_stab.wav"

function SWEP:Deploy()
	self.NeedtoAttack = false
	timer.Destroy("AttackDelay" .. self.Owner:SteamID())
	if self.SoundDeploy != nil then
		self:EmitSound(self.SoundDeploy)
	end
	return true
end

function SWEP:SetDeploySpeed( speed )
	self.m_WeaponDeploySpeed = tonumber( speed )
end

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
	self:SetDeploySpeed(self.DeploySpeed)
end

function SWEP:OnAttackedPlayer(attacktype, ply)
	if attacktype == 1 then
		//self:StabDamage(ent, self.Primary.Damage )
		self:EmitSound(self.SoundFleshSmall)
	else
		//self:StabDamage(ent, self.Secondary.Damage )
		self:EmitSound(self.SoundFleshLarge)
	end
end

function CanAttackTypes(typ)
	local types = {"prop_physics", "prop_dynamic", "func_breakable"}
	if types[typ] != nil then
		return true
	else
		return false
	end
end

function SWEP:Stab(atype, range)
	local tracedata = {}

	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 95
	tracedata.filter = self.Owner
	tracedata.mins = Vector( -12 , -12 , -12 )
	tracedata.maxs = Vector( 12 , 12 , 12 )

	if ( self.Owner:IsPlayer() ) then
		self.Owner:LagCompensation( true )
	end

	local tr = util.TraceHull( tracedata )

	if ( self.Owner:IsPlayer() ) then
		self.Owner:LagCompensation( false )
	end
	
	//local tr = self.Owner:GetEyeTrace()
	local ent = tr.Entity
	//print(ent)
	//if !IsValid(tr.Entity) then ent = nil end
	if (not ent or !IsValid(ent)) and !ent:IsWorld() then
		self:EmitSound(self.SoundMiss)
	elseif ent:IsWorld() then
		self:EmitSound(self.SoundWallHit)
		self:DoImpactEffect(tr)
		//print("wlr")
	else
		local damagetodeal = self.Primary.Damage
		if atype == 2 then
			damagetodeal = self.Secondary.Damage
		end
		local cattack = true
		if ent:IsNPC() or ent:IsPlayer() then
			if ent:IsPlayer() then
				if table.HasValue(self.AttackTeams, ent:GTeam()) then
					cattack = true
					self:OnAttackedPlayer(atype, ent)
				else
					cattack = false
					self:EmitSound(self.SoundFleshSmall)
				end
			end
		else
			self:EmitSound(self.SoundWallHit)
			self:DoImpactEffect(tr)
			/*
			local force = 3000
			if atype == 1 then
				force = self.Primary.Force
			else
				force = self.Secondary.Force
			end
			if IsValid(ent:GetPhysicsObject()) then
				local phys = ent:GetPhysicsObject( )
				local pushvec = tr.Normal * force
				local pushpos = tr.HitPos
				
				phys:ApplyForceOffset( pushvec, pushpos )
			end
			*/
		end
		if ent:IsPlayer() and ( ent:GTeam() == TEAM_SPEC or ent:GTeam() == TEAM_SCP ) then return end
		if cattack	then
			local force = 3000
			if atype == 1 then
				force = self.Primary.Force
			else
				force = self.Secondary.Force
			end
			local dmg = DamageInfo()
			dmg:SetDamage(damagetodeal)
			dmg:SetAttacker(self.Owner)
			dmg:SetInflictor(self.Weapon or self)
			dmg:SetDamageForce(self.Owner:GetAimVector() * force)
			dmg:SetDamagePosition(self.Owner:GetPos())
			dmg:SetDamageType(DMG_CLUB)
			
			local spos = self.Owner:GetShootPos()
			local sdest = spos + (self.Owner:GetAimVector() * 70)
			local posdid = spos + (self.Owner:GetAimVector() * 3)
			posdid = tr.HitNormal
			ent:DispatchTraceAttack(dmg, tr, posdid)
		end
	end
end

function SWEP:StabDamage(entity, damage)
	local dmginfo = DamageInfo()
	dmginfo:SetDamage( damage )
	dmginfo:SetDamageType( DMG_SLASH )
	dmginfo:SetAttacker( self.Owner )
	dmginfo:SetInflictor( self )
	dmginfo:SetDamageForce( self.Owner:GetForward() )
	if SERVER then
		self.Owner:GetEyeTrace().Entity:TakeDamageInfo( dmginfo )
	end
end

local hits = 0
function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	//if not IsFirstTimePredicted() then return end
	timer.Destroy("AttackDelay" .. self.Owner:SteamID())
	self.Owner:GetViewModel():SetPlaybackRate( self.Primary.AnimSpeed )
	self:SendWeaponAnim(ACT_VM_HITCENTER)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:GetViewModel():SetPlaybackRate( self.Primary.AnimSpeed )
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	timer.Create("AttackDelay" .. self.Owner:SteamID(), self.Primary.NextAttack, 1, function()
		if IsValid(self) == false then return end
		self.AttackType = 1
		self:Stab(1, self.Range)
	end)
	self:SetNextPrimaryFire( CurTime() + self.Primary.AttackDelay)
	self:SetNextSecondaryFire( CurTime() + self.Primary.AttackDelay)
end

function SWEP:SecondaryAttack()
	//if ( !self:CanSecondaryAttack() ) then return end
	//if not IsFirstTimePredicted() then return end
	if self:GetNextSecondaryFire() > CurTime() then return end
	self.Owner:GetViewModel():SetPlaybackRate( self.Secondary.AnimSpeed )
	self:SendWeaponAnim(ACT_VM_HITCENTER)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:GetViewModel():SetPlaybackRate( self.Secondary.AnimSpeed )
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	timer.Create("AttackDelay" .. self.Owner:SteamID(), self.Secondary.NextAttack, 1, function()
		if IsValid(self) == false then return end
		self.AttackType = 2
		self:Stab(2, self.Range)
	end)
	self:SetNextPrimaryFire( CurTime() + self.Secondary.AttackDelay)
	self:SetNextSecondaryFire( CurTime() + self.Secondary.AttackDelay)
end

function SWEP:Reload()
end

function SWEP:Holster( wep )
	return true
end

function SWEP:Deploy()
	self:SetDeploySpeed(self.DeploySpeed)
	return true
end

function SWEP:ShootEffects()
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

end

function SWEP:CanPrimaryAttack()
	if self:GetNextPrimaryFire() > CurTime() then return false end
	self:SetNextPrimaryFire( CurTime() + self.Primary.NextAttack )
	return true

end

function SWEP:CanSecondaryAttack()
	if self:GetNextSecondaryFire() > CurTime() then return false end
	self:SetNextSecondaryFire( CurTime() + self.Secondary.NextAttack )
	return true

end

function SWEP:OnRemove()
	self:SetHoldType(self.HoldType)
end

function SWEP:OwnerChanged()
	
end

function SWEP:SetDeploySpeed( speed )
	self.m_WeaponDeploySpeed = tonumber( speed )
end

function SWEP:DoImpactEffect( tr, nDamageType )

	if ( tr.HitSky ) then return end

	local effectdata = EffectData()
	effectdata:SetOrigin( tr.HitPos + tr.HitNormal )
	effectdata:SetNormal( tr.HitNormal )
	util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal )

end


SWEP.PrintName			= "SCP096"			
SWEP.ViewModelFOV 		= 56
SWEP.Spawnable 			= false
SWEP.AdminOnly 			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Delay         = 1
SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo			= "None"

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Delay		= 5
SWEP.Secondary.Ammo		= "None"

SWEP.ISSCP 					= true
SWEP.droppable				= false
SWEP.CColor					= Color(0,255,0)
SWEP.teams					= {1}

SWEP.NextAttackW			= 0

SWEP.Weight					= 3
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom		= false
SWEP.Slot					= 0
SWEP.SlotPos					= 4
SWEP.DrawAmmo				= false
SWEP.DrawCrosshair			= true
SWEP.IdleAnim				= true
SWEP.ViewModel				= "models/weapons/v_arms_scp096.mdl"
SWEP.WorldModel			= ""
SWEP.IconLetter				= "w"
SWEP.Primary.Sound 		= ("weapons/scp96/attack1.wav") 
SWEP.HoldType 				= "knife"

if (CLIENT) then
	SWEP.WepSelectIcon	= surface.GetTextureID( "vgui/entities/weapon_scp096" )
	SWEP.BounceWeaponIcon = false
	killicon.Add( "kill_icon_scp096", "vgui/icons/kill_icon_scp096", Color( 255, 255, 255, 255 ) )
end

SWEP.Lang = nil

function SWEP:Initialize()
	if CLIENT then
		self.Lang = GetWeaponLang().SCP_096
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
    self:SetWeaponHoldType( self.HoldType )
		
	sound.Add( { name = "096_1", channel = CHAN_STATIC, volume = 1.0, level = 80, pitch = { 95, 110 }, sound = "weapons/scp96/096_1.mp3" } )
	sound.Add( { name = "096_2", channel = CHAN_STATIC, volume = 1.0, level = 80, pitch = { 95, 110 }, sound = "weapons/scp96/096_2.mp3" } )
	sound.Add( { name = "096_3", channel = CHAN_STATIC, volume = 1.0, level = 80, pitch = { 95, 110 }, sound = "weapons/scp96/096_3.mp3" } )
	
	util.PrecacheSound("096_1")	
	util.PrecacheSound("096_1")	
	util.PrecacheSound("096_1")	
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
	return (yes > 0.39)
end

function SWEP:Think()
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
	if watching > 0 then
		self.Owner:SetRunSpeed(500)
		self.Owner:SetWalkSpeed(500)
	else
		self.Owner:SetRunSpeed(125)
		self.Owner:SetWalkSpeed(125)
	end
end

function SWEP:Reload()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
end

function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if self.NextAttackW > CurTime() then return end
	self.NextAttackW = CurTime() + self.Primary.Delay
	if SERVER then
		local trace = self.Owner:GetEyeTrace();
		if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 75 then
			self.Owner:SetAnimation( PLAYER_ATTACK1 );
			self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
				
			local ent = nil
			local tr = util.TraceHull( {
				start = self.Owner:GetShootPos(),
				endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 100 ),
				filter = self.Owner,
				mins = Vector( -10, -10, -10 ),
				maxs = Vector( 10, 10, 10 ),
				mask = MASK_SHOT_HULL
			} )
			ent = tr.Entity
			if IsValid(ent) then
				if ent:IsPlayer() then
					if ent:GTeam() == TEAM_SCP then return end
					if ent:GTeam() == TEAM_SPEC then return end
					ent:TakeDamage(math.random(30, 60), self.Owner, self.Owner)
				else
					if ent:GetClass() == "func_breakable" then
						ent:TakeDamage( 100, self.Owner, self.Owner )
						self.Owner:EmitSound("Damage4.ogg")
					end
				end
			end
				--bullet = {}
				--bullet.Num    = 1
				--bullet.Src    = self.Owner:GetShootPos()
				--bullet.Dir    = self.Owner:GetAimVector()
				--bullet.Spread = Vector(0, 0, 0)
				--bullet.Tracer = 0
				--bullet.Force  = 25
				--bullet.Damage = 35
				--self.Owner:FireBullets(bullet) 		
		else
			self.Owner:SetAnimation( PLAYER_ATTACK1 );
			self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
			self.Weapon:EmitSound( "weapons/scp96/attack"..math.random(1,4)..".wav" )
		end
	end
end

function SWEP:Deploy()
	if self.Owner:IsValid() then
		self.Owner:DrawWorldModel( false )
		--self.Owner:SetViewOffset(Vector(0,0,90))
		self.Weapon:EmitSound( "weapons/scp96/096_idle"..math.random(1,3)..".wav" )
		
		self:SendWeaponAnim( ACT_VM_DRAW )
				self:SendWeaponAnim( ACT_VM_DRAW )
		timer.Simple( 0.9, function(wep)
			if !IsValid(self) or !IsValid(self.Owner) then return end
			if self.Owner:Alive() then
				self:SendWeaponAnim(ACT_VM_IDLE)
			end
		end )
	end
	return true;
end

function SWEP:Holster()
	if self.Owner:IsValid() then
		--self.Owner:SetViewOffset(Vector(0,0,60))
		self.Owner:SetWalkSpeed(1)
		self.Owner:SetRunSpeed(1)
		self.Owner:SetJumpPower(1)
	end
	return true;
end

SWEP.NextSpecial = 0
function SWEP:SecondaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if self.NextSpecial > CurTime() then return end
	self.NextSpecial = CurTime() + self.Secondary.Delay

	self.Owner:StopSound("096_1")
	self.Owner:StopSound("096_2")
	self.Owner:StopSound("096_3")
	
    self.Owner:EmitSound( "096_"..math.random(1,3) )

end
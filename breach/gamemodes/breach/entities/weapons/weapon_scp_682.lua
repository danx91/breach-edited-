AddCSLuaFile()

SWEP.Base 			= "weapon_scp_base"
SWEP.PrintName		= "SCP-682"

SWEP.HoldType			= "normal"

SWEP.Roar 				= "scp/682/roar.ogg"

SWEP.DrawCrosshair 			= true

--SWEP.SantasHatPositionOffset = Vector( 16, -5, 3.5 )
--SWEP.SantasHatAngleOffset = Angle( -10, 180, -20 )

function SWEP:Deploy()
	self:HideModels()

	if SERVER and !self.basespeed then
		self.basespeed = self.Owner:GetWalkSpeed()
		self.furyspeed = self.Owner:GetRunSpeed()
		self.Owner:SetRunSpeed( self.basespeed )
	end

	//self.Owner:SetModelScale( 0.75 )
end

function SWEP:Initialize()
	self:InitializeLanguage( "SCP_682" )

	self:SetHoldType(self.HoldType)
	/*if CLIENT then
		if !self.SantasHat then
			self.SantasHat = ClientsideModel( "models/cloud/kn_santahat.mdl" )
			self.SantasHat:SetModelScale( 1.8 )
			self.SantasHat:SetNoDraw( true )
		end
	end*/
end

function SWEP:OnRemove()
	//if IsValid( self.Owner ) then
		//self.Owner:SetModelScale( 1 )
	//end
	/*if CLIENT and IsValid( self.SantasHat ) then
		self.SantasHat:Remove()
	end*/
end

SWEP.NextAttackW	= 0
SWEP.AttackDelay	= 4
SWEP.OnFuryCD = 0.7
function SWEP:PrimaryAttack()
	if preparing then return end
	if not IsFirstTimePredicted() then return end
	if self.NextAttackW > CurTime() then return end
	if CLIENT then return end
	local ent = nil
	local tr = util.TraceHull({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 75),
		mins = Vector(-10, -10, -10),
		maxs = Vector(10, 10, 10),
		filter = self.Owner,
		mask = MASK_SHOT,
	})
	ent = tr.Entity
	if IsValid(ent) then
		if ent:IsPlayer() then
			if ( ent:GTeam() == TEAM_SPEC or ent:GTeam() == TEAM_SCP ) then return end
				local rdmdmg = math.random(50, 100)
				ent:TakeDamage(rdmdmg, self.Owner, self.Owner)
			--ent:Kill()
			--self.Owner:AddExp(15, true)
			if self.fury == true then
				self.NextAttackW = CurTime() + self.OnFuryCD
			else
				self.NextAttackW = CurTime() + self.AttackDelay
				self:EmitSound( self.Roar )
			end
		else
			self:SCPDamageEvent( ent, 10 )
		end
	end
end

SWEP.NextSpeial = 0
SWEP.SpecialDelay = 45
SWEP.fury = false
function SWEP:SecondaryAttack()
	if self.NextSpeial > CurTime() then
		if SERVER then
			self.Owner:PrintMessage(HUD_PRINTTALK, "Special ability is on cooldown!")
		end
		return
	end
	self.NextSpeial = CurTime() + self.SpecialDelay
	
	if SERVER then
		local hp = self:ApplyEffect()
		timer.Create( "682BuffEnd"..self.Owner:SteamID64(), 7, 1, function()
			self:RemoveEffect( hp, 0 )
		end )
	end
end

function SWEP:ApplyEffect()
	self.fury = true
	self.NextAttackW = CurTime() + 0.5
	self:EmitSound( self.Roar )
	self.Owner:SetWalkSpeed(self.furyspeed)
	self.Owner:SetRunSpeed(self.furyspeed)
	local hp = self.Owner:Health()
	self.Owner:SetHealth( 9999 )
	return hp
end

function SWEP:RemoveEffect( hp, regen )
	self.fury = false
	self.Owner:SetWalkSpeed(self.basespeed)
	self.Owner:SetRunSpeed(self.basespeed)
	hp = hp + regen
	if hp > self.Owner:GetMaxHealth() then hp = self.Owner:GetMaxHealth() end
	self.Owner:SetHealth( hp )
end

hook.Add("EntityTakeDamage", "AcidDamage", function(target, dmg)
	if !target or !target:IsPlayer() or !target:Alive() then return end
	if !IsValid( target:GetActiveWeapon() ) or target:GetActiveWeapon():GetClass() != "weapon_scp_682" then return end
	if dmg:GetDamageType() == DMG_ACID then
		if preparing then return true end
		dmg:ScaleDamage( 3 )
	end
end)

function SWEP:DrawHUD()
	if disablehud == true then return end
	
	local showtext = self.Lang.HUD.attackReady
	local showcolor = Color(0,255,0)
	
	if self.NextSpeial > CurTime() then
		showtext = self.Lang.HUD.attackCD.." ".. math.Round(self.NextSpeial - CurTime())
		showcolor = Color(255,0,0)
	end
	
	draw.Text( {
		text = showtext,
		pos = { ScrW() / 2, ScrH() - 30 },
		font = "173font",
		color = showcolor,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	})
end

function SWEP:DrawWorldModel()
	/*if !IsValid( self.SantasHat ) then return end
	local boneid = self.Owner:LookupBone( "Bip01_Head" )
	if not boneid then
		for i=0, self.Owner:GetBoneCount()-1 do
			print( i, self.Owner:GetBoneName( i ) )
		end
		return
	end

	local matrix = self.Owner:GetBoneMatrix( boneid )
	if not matrix then
		return
	end

	local newpos, newang = LocalToWorld( self.SantasHatPositionOffset, self.SantasHatAngleOffset, matrix:GetTranslation(), matrix:GetAngles() )

	self.SantasHat:SetPos( newpos )
	self.SantasHat:SetAngles( newang )
	self.SantasHat:SetupBones()
	self.SantasHat:DrawModel()*/
end
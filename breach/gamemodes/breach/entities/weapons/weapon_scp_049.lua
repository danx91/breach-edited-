AddCSLuaFile()

SWEP.Base 		= "weapon_scp_base"
SWEP.PrintName	= "SCP-049"
SWEP.HoldType	= "normal"

SWEP.AttackDelay			= 5
SWEP.NextAttackW			= 0

if CLIENT then
	SWEP.WepSelectIcon 	= surface.GetTextureID("breach/wep_049")
end

--SWEP.SantasHatPositionOffset = Vector( 1.5, 2.2, 1.1 )
--SWEP.SantasHatAngleOffset = Angle( -40, -90, -10 )

/*function SWEP:Remove()
	if CLIENT and IsValid( self.SantasHat ) then
		self.SantasHat:Remove()
	end
end*/

function SWEP:Initialize()
	self:InitializeLanguage( "SCP_049" )

	self:SetHoldType( self.HoldType )

	for i=0, 4 do
		sound.Add( {
			name = "attack"..i,
			channel = CHAN_STATIC,
			volume = 1.0,
			level = 130,
			pitch = 100,
			sound = "scp/049/attack"..i..".ogg"
		} )
	end
	/*if CLIENT then
		if !self.SantasHat then
			self.SantasHat = ClientsideModel( "models/cloud/kn_santahat.mdl" )
			self.SantasHat:SetModelScale( 1 )
			self.SantasHat:SetNoDraw( true )
		end
	end*/
end

function SWEP:PrimaryAttack()
	//if ( !self:CanPrimaryAttack() ) then return end
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if self.NextAttackW > CurTime() then return end
	self.NextAttackW = CurTime() + self.AttackDelay
	if SERVER then
		self.Owner:EmitSound( "attack"..math.random( 0, 4 ) )
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
				if ent.Using714 then return end
				local scp = GetSCP( "SCP0492" )
				if scp then
					scp:SetupPlayer( ent )
				end
				--ent:SetSCP0492()
				self.Owner:AddExp(200, true)
				roundstats.zombies = roundstats.zombies + 1
			else
				self:SCPDamageEvent( ent, 10 )
				--if ent:GetClass() == "func_breakable" then
					--ent:TakeDamage( 100, self.Owner, self.Owner )
				--end
			end
		end
	end
end

function SWEP:DrawHUD()
	if disablehud == true then return end
	
	local showtext = self.Lang.HUD.attackReady
	local showcolor = Color(0,255,0)
	
	if self.NextAttackW > CurTime() then
		showtext = self.Lang.HUD.attackCD.." ".. math.Round(self.NextAttackW - CurTime())
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
	
	local x = ScrW() / 2.0
	local y = ScrH() / 2.0

	local scale = 0.3
	surface.SetDrawColor( 0, 255, 0, 255 )
	
	local gap = 5
	local length = gap + 20 * scale
	surface.DrawLine( x - length, y, x - gap, y )
	surface.DrawLine( x + length, y, x + gap, y )
	surface.DrawLine( x, y - length, x, y - gap )
	surface.DrawLine( x, y + length, x, y + gap )
end

/*function SWEP:DrawWorldModel()
	if !IsValid( self.SantasHat ) then return end
	local boneid = self.Owner:LookupBone( "ValveBiped.Bip01_Head1" )
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
	self.SantasHat:DrawModel()
end*/
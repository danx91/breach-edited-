AddCSLuaFile()

if CLIENT then
	SWEP.WepSelectIcon 		= surface.GetTextureID("breach/wep_966")
	SWEP.BounceWeaponIcon 	= false
end

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/vinrax/props/keycard.mdl"
SWEP.WorldModel	= "models/vinrax/props/keycard.mdl"
SWEP.PrintName		= "SCP-966"
SWEP.Slot			= 0
SWEP.SlotPos			= 0
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true
SWEP.HoldType		= "normal"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false

SWEP.ISSCP 					= true
SWEP.droppable				= false
SWEP.teams					= {1}
SWEP.Primary.Ammo			= "none"
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic	= false

SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic		= false

function SWEP:Deploy()
	self.Owner:DrawViewModel( false )
end
function SWEP:DrawWorldModel()
end

SWEP.Lang = nil

function SWEP:Initialize()
	if CLIENT then
		self.Lang = GetWeaponLang().SCP_966
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
	self:SetHoldType(self.HoldType)
end

function SWEP:Reload()
end

SWEP.NextSpec 	= 0
SWEP.SpecDelay = 1
function SWEP:Think()
	if postround then return end
	if self.NextSpec > CurTime() then return end
	self.NextSpec = CurTime() + self.SpecDelay
	if SERVER then
		local ent = ents.FindInSphere( self.Owner:GetPos(), 200 )
		local gplayers = {}
	
		for k, v in pairs( player.GetAll() ) do
			if v:IsPlayer() then 
				if v.mblur == true then
					if !isAny(v, ent) then
						v.mblur = false
					end
				end
			end
		end
	
		for k, v in pairs( ent ) do
			if v:IsPlayer() then 
				if v.mblur == nil then v.mblur = false end	
				if !( v:GTeam() == TEAM_SCP or v:GTeam() == TEAM_SPEC or v.Using714 ) then
					table.ForceInsert(gplayers, v)
				end
			end
		end
		if ( #gplayers > 0 ) then
			for k, v in pairs( gplayers ) do
				if v:Alive() then
					v:TakeDamage(4, self.Owner, self.Owner)
					v.mblur = true
				end
			end
		end
	end
end

function isAny(ittf, allit)
	for k, v in pairs( allit ) do
		if (v == ittf) then return true end
	end
	return false
end

SWEP.AttackDelay			= 0.8
SWEP.NextAttackW			= 0
function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	if self.NextAttackW > CurTime() then return end
	self.NextAttackW = CurTime() + self.AttackDelay
	if SERVER then
		local ent = nil
		local hullsize = 20
		local tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 160 ),
			filter = self.Owner,
			mins = Vector( -hullsize, -hullsize, -hullsize ),
			maxs = Vector( hullsize, hullsize, hullsize ),
			mask = MASK_SHOT_HULL
		} )
		ent = tr.Entity
		if IsValid(ent) then
			--if ent:IsPlayer() then
				--if ent:GTeam() == TEAM_SPEC then return end
				--if ent:GTeam() == TEAM_SCP then return end
				--if ent:Alive() then
				--	ent:TakeDamage( 48, self.Owner, self.Owner )
				--	self.Owner:EmitSound("Damage4.ogg")
			--end
			--else
				if ent:GetClass() == "func_breakable" and !ent:IsPlayer() then
					ent:TakeDamage( 100, self.Owner, self.Owner )
					self.Owner:EmitSound("Damage4.ogg")
				end
			--end
		end
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:CanPrimaryAttack()
	return false
end
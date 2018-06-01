AddCSLuaFile()

SWEP.Base 		= "weapon_scp_base"
SWEP.PrintName	= "SCP-457"

SWEP.HoldType	= "normal"

if CLIENT then
	SWEP.WepSelectIcon 	= surface.GetTextureID("breach/wep_457")
end

function SWEP:Initialize()
	self:InitializeLanguage( "SCP_457" )

	self:SetHoldType(self.HoldType)
end

function SWEP:Think()
	if SERVER then
		self.Owner:Ignite(0.1,100)
		for k,v in pairs(ents.FindInSphere( self.Owner:GetPos(), 125 )) do
			if v:IsPlayer() then
				if v:GTeam() != TEAM_SCP and v:GTeam() != TEAM_SPEC then
					v:Ignite(2,250)
					if self.Owner.nextexp == nil then self.Owner.nextexp = 0 end
					if self.Owner.nextexp < CurTime() then
						self.Owner:SetHealth( math.Clamp( self.Owner:Health() + 20, 0, self.Owner:GetMaxHealth() ) )
						self.Owner:AddExp(5)
						self.Owner.nextexp = CurTime() + 1
					end
				end
			end
		end
	end
end

function SWEP:PrimaryAttack()
	//if ( !self:CanPrimaryAttack() ) then return end
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if SERVER then
		local ent = self.Owner:GetEyeTrace().Entity
		if(ent:GetPos():Distance(self.Owner:GetPos()) < 125) then
			if ent:IsPlayer() then
				if ent:GTeam() == TEAM_SCP then return end
				if ent:GTeam() == TEAM_SPEC then return end
				//ent:SetSCP0492()
				//roundstats.zombies = roundstats.zombies + 1
			else
				if ent:GetClass() == "func_breakable" then
					ent:TakeDamage( 1000, self.Owner, self.Owner )
				end
			end
		end
	end
end
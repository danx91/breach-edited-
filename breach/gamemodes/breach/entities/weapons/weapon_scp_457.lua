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

SWEP.LastDMG = 0
function SWEP:Think()
	if SERVER then
		if self.Owner:WaterLevel() > 0 then
			if self.LastDMG < CurTime() and self.Owner:Health() > 1 then
				self.LastDMG = CurTime() + 0.1
				self.Owner:SetHealth( math.max( 1, self.Owner:Health() - 20 ) )
			end
		else
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
end

function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if SERVER then
		local ent = self.Owner:GetEyeTrace().Entity
		if ent:GetPos():DistToSqr( self.Owner:GetPos() ) < 10000 then
			self:SCPDamageEvent( ent, 10 )
		end
	end
end
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "breach_baseammo"
ENT.AmmoID = 3
ENT.AmmoType = "AR2"
ENT.PName = "Rifle Ammo"
ENT.AmmoAmount = 120
ENT.MaxUses = 2
ENT.Model = Model("models/items/boxmrounds.mdl")

function ENT:Initialize()
	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_BBOX )
	self:SetColor(Color(0,0,255))
end

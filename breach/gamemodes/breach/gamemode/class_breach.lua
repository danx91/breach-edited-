DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

function PLAYER:SetupDataTables()
	
	self.Player:NetworkVar( "String", 0, "NClass" )
	self.Player:NetworkVar( "Int", 0, "NKarma" )
	self.Player:NetworkVar( "Int", 1, "NEXP" )
	self.Player:NetworkVar( "Int", 2, "NLevel" )
	self.Player:NetworkVar( "Int", 3, "NGTeam" )
	
	if SERVER then
		print("Setting up datatables for " .. self.Player:Nick())
		self.Player:SetNClass("Spectator")
		local num
		if SaveKarma() then
			num = tonumber(self.Player:GetPData( "breach_karma", StartingKarma() ))
		else
			num = SaveKarma()
		end
		self.Player:SetNEXP( tonumber(self.Player:GetPData( "breach_exp", 0 )) )
		self.Player:SetNLevel( tonumber(self.Player:GetPData( "breach_level", 0 )) )
		self.Player:SetNKarma( num )
		self.Player.Karma = num
		self.Player:SetNGTeam(1)
	end
end

player_manager.RegisterClass( "class_breach", PLAYER, "player_default" )

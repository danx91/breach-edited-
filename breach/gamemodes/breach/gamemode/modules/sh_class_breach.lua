DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

function PLAYER:SetupDataTables()
	
	self.Player:NetworkVar( "String", 0, "NClass" )
	self.Player:NetworkVar( "String", 1, "LastRole" )
	self.Player:NetworkVar( "Int", 0, "NEXP" )
	self.Player:NetworkVar( "Int", 1, "NLevel" )
	self.Player:NetworkVar( "Int", 2, "NGTeam" )
	self.Player:NetworkVar( "Int", 3, "LastTeam" )
	self.Player:NetworkVar( "Bool", 0, "NActive" )
	self.Player:NetworkVar( "Bool", 1, "NPremium" )
	
	if SERVER then
		print("Setting up datatables for " .. self.Player:Nick())
		self.Player:SetNClass("Spectator")
		self.Player:SetLastRole( "" )
		self.Player:SetLastTeam( 0 )
		CheckPlayerData( self.Player, "breach_exp" )
		CheckPlayerData( self.Player, "breach_level" )
		self.Player:SetNEXP( tonumber( self.Player:GetPData( "breach_exp", 0 ) ) )
		self.Player:SetNLevel( tonumber( self.Player:GetPData( "breach_level", 0 ) ) )
		self.Player:SetNGTeam(1)
		self.Player:SetNActive( self.Player.ActivePlayer or false )
		self.Player:SetNPremium( self.Player.Premium or false )
	end
end

function CheckPlayerData( player, name )
	local pd = player:GetPData( name, 0 )
	if pd == "nil" then
		print( "Damaged playerdata found..." )
		player:RemovePData( name )
		player:SetPData( name, 1 )
	end
end

player_manager.RegisterClass( "class_breach", PLAYER, "player_default" )
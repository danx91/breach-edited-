ROLES.ROLE_INFECTD = "Class D Presonnel"
ROLES.ROLE_INFECTMTF = "MTF"

function SetupInfect( ply )
	if !SERVER then return end
	local roles = { }
	roles[1] = math.ceil( ply * 0.166 )
	ply = ply - roles[1]
	roles[2] = math.Round( ply * 0.333 )
	ply = ply - roles[2]
	roles[3] = ply
	ply = 0
	local players = GetActivePlayers()
	local spawns = table.Copy( SPAWN_GUARD )
	local ply, spawn = nil, nil
	for i = 1, roles[1] do
		ply = table.remove( players, math.random( 1, #players ) )
		spawn = table.remove( spawns, math.random( 1, #spawns ) )
		ply:SetSCP0082( 750, 250, true )
		ply:SetPos( spawn )
	end
	spawns = table.Copy( SPAWN_CLASSD )
	ply, spawn = nil, nil
	for i = 1, roles[2] do
		ply = table.remove( players, math.random( 1, #players ) )
		spawn = table.remove( spawns, math.random( 1, #spawns ) )
		ply:SetInfectMTF()
		ply:SetPos( spawn )
	end
	ply, spawn = nil, nil
	for i = 1, roles[3] do
		ply = table.remove( players, math.random( 1, #players ) )
		spawn = table.remove( spawns, math.random( 1, #spawns ) )
		ply:SetInfectD()
		ply:SetPos( spawn )
	end
end
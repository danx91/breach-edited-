SCPObjects = {}
SCPNoSelectObjects = {}
TransmitSCPS = {}

SCP_VALID_ENTRIES = {
	base_speed = true,
	run_speed = true,
	max_speed = true,
	base_health = true,
	max_health = true,
	jump_power = true,
	crouch_speed = true,
	no_ragdoll = true,
	model_scale = true,
	hands_model = true,
	prep_freeze = true,
	no_spawn = true,
	no_model = true,
	no_swep = true,
	no_strip = true,
	no_select = true,
}

SCP_DYNAMIC_VARS = SCP_DYNAMIC_VARS or {}

local lua_override = false

function UpdateDynamicVars()
	print( "Updating SCPs dynamic vars" )
	if !file.Exists( "breach", "DATA" ) then
		file.CreateDir( "breach" )
	end
	if !file.Exists( "breach/scp.txt", "DATA" ) then
		util.WriteINI( "breach/scp.txt", {} )
	end

	if lua_override then
		print( "Dev mode is enabled! Overwritting INI values..." )
	else
		util.LoadINI( "breach/scp.txt", SCP_DYNAMIC_VARS )
	end
end
UpdateDynamicVars()

function SaveDynamicVars()
	util.WriteINI( "breach/scp.txt", SCP_DYNAMIC_VARS )
end

function SendSCPList( ply )
	net.Start( "SCPList" )
		net.WriteTable( SCPS )	
		net.WriteTable( TransmitSCPS )
	net.Send( ply )
end

function GetSCP( name )
	return SCPObjects[name] or SCPNoSelectObjects[name]
end

function RegisterSCP( name, model, weapon, static_stats, dynamic_stats, custom_callback, post_callback )
	--RegisterSCP( "name", "path_to_model", "SWEP_class_name", {entry = value} )
	if !name or !model or !weapon or !static_stats then return end

	dynamic_stats = dynamic_stats or {}

	if SCPObjects[name] then
		error( "SCP " .. name .. "is already registered!" )
	end

	local rolename = "ROLE_"..name
	if !ALLLANGUAGES["english"]["ROLES"][rolename] or !ALLLANGUAGES["english"]["starttexts"][rolename] then
		error( "No language entry for: "..rolename )
	end

	local spawn = _G["SPAWN_"..name]
	if !static_stats.no_spawn and !dynamic_stats.no_spawn then
		if !spawn or ( !isvector( spawn ) and !istable( spawn ) ) then
			error( "No spawn position entry for: ".."SPAWN_"..name )
		end
	end

	ROLES[rolename] = name

	local scp = ObjectSCP( name, model, weapon, spawn, static_stats, dynamic_stats )

	if custom_callback and isfunction( custom_callback ) then
		scp:SetCallback( custom_callback )
	end

	if post_callback and isfunction( post_callback ) then
		scp:SetCallback( post_callback, true )
	end

	if !scp.basestats.no_select then
		SCPObjects[name] = scp
		table.insert( SCPS, name )
	else
		SCPNoSelectObjects[name] = scp
		table.insert( TransmitSCPS, name )
	end

	print( name.." has been registered!" )
	return true
end


-----SCP class-----
ObjectSCP = {}
ObjectSCP.__index = ObjectSCP

/*ObjectSCP.name = ""
ObjectSCP.basestats = {}
ObjectSCP.callback = function() end
ObjectSCP.post = function() end
ObjectSCP.swep = ""
ObjectSCP.model = ""
ObjectSCP.spawnpos = nil*/

function ObjectSCP:Create( name, model, weapon, pos, static_stats, dynamic_stats )
	local scp = setmetatable( {}, ObjectSCP )
	scp.Create = function() end

	scp.name = name
	scp.model = model
	scp.swep = weapon
	scp.spawnpos = pos
	scp.basestats = {}

	scp.callback = function() end
	scp.post = function() end

	if !SCP_DYNAMIC_VARS[name] then
		SCP_DYNAMIC_VARS[name] = {}
	end

	local dv = SCP_DYNAMIC_VARS[name]

	for k, v in pairs( dynamic_stats ) do
		if SCP_VALID_ENTRIES[k] then
			local istab = istable( v )
			local var = istab and v.var or v

			if dv[k] then
				var = dv[k]
			else
				dv[k] = var
			end

			if istab then
				if v.min or v.max then
					if !isnumber( var ) then
						ErrorNoHalt( name.." entry: "..k..". Number expected, got "..type( var ) )
						continue
					end

					if v.min then
						var = math.max( v.min, var )
					end

					if v.max then
						var = math.min( v.max, var )
					end
				end
			end

			scp.basestats[k] = var
		else
			print( "Invalid dynamic stat entry '"..k.."' for "..name )
		end
	end

	for k, v in pairs( static_stats ) do
		if SCP_VALID_ENTRIES[k] then
			scp.basestats[k] = v
		else
			print( "Invalid static stat entry '"..k.."' for "..name )
		end
	end

	return scp
end

function ObjectSCP:SetCallback( cb, post )
	if post then
		self.post = cb
	else
		self.callback = cb
	end
end

function ObjectSCP:SetupPlayer( ply, ... )
	if self.callback then
		if self.callback( ply, self.basestats, ... ) then
			return
		end
	end

	ply:UnSpectate()
	ply:GodDisable()
	if !self.basestats.no_strip then
		ply:StripWeapons()
		ply:RemoveAllAmmo()
	end

	local pos = self.spawnpos
	if pos and !self.basestats.no_spawn then
		if istable( pos ) then
			pos = table.Random( pos )
		end
		ply:Spawn()
		ply:SetPos( pos )
	end

	ply:SetGTeam( TEAM_SCP )
	ply:SetNClass( ROLES["ROLE_"..self.name] )

	if !self.basestats.no_model then
		ply:SetModel( self.model )
	end

	ply:SetModelScale( self.basestats.model_scale or 1 )

	ply:SetHealth( self.basestats.base_health or 1500 )
	ply:SetMaxHealth( self.basestats.max_health or 1500 )
	ply:SetWalkSpeed( self.basestats.base_speed or 200 )
	ply:SetRunSpeed( self.basestats.run_speed or 200 )
	ply:SetMaxSpeed( self.basestats.max_speed or 200 )
	ply:SetCrouchedWalkSpeed( self.basestats.crouch_speed or 0.6 )
	ply:SetJumpPower( self.basestats.jump_power or 200 )

	if !self.basestats.no_swep then
		local wep = ply:Give( self.swep )
		ply:SelectWeapon( self.swep )

		if IsValid( wep ) then
			wep.ShouldFreezePlayer = self.basestats.prep_freeze == true
		end
	end

	ply:SetArmor( 0 )

	ply:Flashlight( false )
	ply:AllowFlashlight( false )
	ply:SetNoDraw( false )
	ply:SetNoTarget( true )

	ply.BaseStats = nil
	ply.UsingArmor = nil

	ply.Active = true
	ply.canblink = false
	ply.noragdoll = self.basestats.no_ragdoll == true

	ply.handsmodel = self.basestats.hands_model
	ply:SetupHands()

	net.Start( "RolesSelected" )
	net.Send( ply )

	if self.post then
		self.post( ply )
	end
end

setmetatable( ObjectSCP, { __call = ObjectSCP.Create } )
--------------------------------------------------------------------------------

timer.Simple( 0, function()
	hook.Run( "RegisterSCP" )
	SaveDynamicVars()
	--InitializeBreachULX()
	SetupForceSCP()
	for k, v in pairs( player.GetAll() ) do
		SendSCPList( v )
	end
end )
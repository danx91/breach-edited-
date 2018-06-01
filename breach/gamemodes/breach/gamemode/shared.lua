MODULES_PATH = GM.FolderName .. "/gamemode/modules"
LANGUAGES_PATH = GM.FolderName .. "/gamemode/languages"
MAP_CONFIG_PATH = GM.FolderName .. "/gamemode/mapconfigs"

ALLLANGUAGES = {}
WEPLANG = {}

print( "----------------Loading Languages----------------" )
local files = file.Find(LANGUAGES_PATH .. "/*.lua", "LUA" )
for k, f in pairs( files ) do
	if SERVER then
		AddCSLuaFile( LANGUAGES_PATH.."/"..f )
		include( LANGUAGES_PATH.."/"..f )
	else
		include( LANGUAGES_PATH.."/"..f )
		if string.sub( f, 1, 3 ) != "wep" then
			print("# Loading language: " .. f )
		end
	end
end

if SERVER then
	AddCSLuaFile( "modules/cl_module.lua" )
	AddCSLuaFile( "modules/sh_module.lua" )

	include( "modules/sv_module.lua" )
	include( "modules/sh_module.lua" )
else
	include( "modules/cl_module.lua" )
	include( "modules/sh_module.lua" )
end

print( "-----------------Loading Modules-----------------" )
local modules = file.Find( MODULES_PATH.."/*.lua", "LUA" )
local skipped = 0
for k, f in pairs( modules ) do
	if f == "sv_module.lua" or f == "sh_module.lua" or f == "cl_module.lua" then continue end

	if string.sub( f, 1, 1 ) == "_" then
		skipped = skipped + 1
		continue
	end

	if string.len( f ) > 3 then
		local ext = string.sub( f, 1, 3 )

		if ext == "cl_" then
			if SERVER then
				AddCSLuaFile( MODULES_PATH .. "/" .. f )
			else
				include( MODULES_PATH .. "/" .. f )
				print("# Loading module: " .. f )
			end
		elseif ext == "sv_" then
			if SERVER then
				include( MODULES_PATH .. "/" .. f )
				print("# Loading module: " .. f )
			end
		elseif ext == "sh_" then
			if SERVER then
				AddCSLuaFile( MODULES_PATH .. "/" .. f )
			end		
			include( MODULES_PATH .. "/" .. f )
			print("# Loading module: " .. f )
		end
	else
		skipped = skipped + 1
	end
end
print( "#" )
print( "# Skipped files: " .. skipped )

print( "---------------Loading Map Config----------------" )
if file.Exists( MAP_CONFIG_PATH .. "/" .. game.GetMap() .. ".lua", "LUA" ) then
	local relpath = "mapconfigs/" .. game.GetMap() .. ".lua"
	if SERVER then
		AddCSLuaFile( relpath )
	end
	include( relpath )
	print( "# Loading config for map " .. game.GetMap() )
	MAP_LOADED = true
else
	print( "----------------Loading Complete-----------------" )
	error( "Unsupported map " .. game.GetMap() .. "!" )
end

print( "----------------Loading Complete-----------------" )
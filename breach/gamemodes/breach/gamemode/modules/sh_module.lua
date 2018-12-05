// Shared file
GM.Name 	= "Breach"
GM.Author 	= "Kanade, edited by danx91"
GM.Email 	= ""
GM.Website 	= ""

VERSION = "0.3"
DATE = "01/06/2018"

function GM:Initialize()
	self.BaseClass.Initialize( self )
end

TEAM_SCP = 1
TEAM_GUARD = 2
TEAM_CLASSD = 3
TEAM_SPEC = 4
TEAM_SCI = 5
TEAM_CHAOS = 6

MINPLAYERS = 2

// Team setup
team.SetUp( 1, "Default", Color(255, 255, 0) )
/* Replaced with GTeams
team.SetUp( TEAM_SCP, "SCPs", Color(237, 28, 63) )
team.SetUp( TEAM_GUARD, "MTF Guards", Color(0, 100, 255) )
team.SetUp( TEAM_CLASSD, "Class Ds", Color(255, 130, 0) )
team.SetUp( TEAM_SPEC, "Spectators", Color(141, 186, 160) )
team.SetUp( TEAM_SCI, "Scientists", Color(66, 188, 244) )
team.SetUp( TEAM_CHAOS, "Chaos Insurgency", Color(0, 100, 255) )
*/

game.AddDecal( "Decal106", "decals/decal106" )

function GetLangRole(rl)
	if clang == nil then return rl end
	local rolef = nil
	for k,v in pairs(ROLES) do
		if rl == v then
			rolef = k
		end
	end
	if rolef != nil then
		return clang.ROLES[rolef]
	else
		return rl
	end
end

SCPS = {}

ROLES = {}
ROLES.ROLE_SCP0082 = "SCP0082"

ROLES.ADMIN = "ADMIN MODE"

// Researchers
ROLES.ROLE_RES = "Researcher"
ROLES.ROLE_MEDIC = "Medic"
ROLES.ROLE_NO3 = "Level 3 Researcher"

// Class D Personell
ROLES.ROLE_CLASSD = "Class D Personell"
ROLES.ROLE_VETERAN = "Veteran"
ROLES.ROLE_CIC = "CI Agent"

// Security
ROLES.ROLE_SECURITY = "Security Officer"
ROLES.ROLE_MTFGUARD = "MTF Guard"
ROLES.ROLE_MTFMEDIC = "MTF Medic"
ROLES.ROLE_MTFL = "MTF Lieutenant"
ROLES.ROLE_HAZMAT = "MTF SCU"
ROLES.ROLE_MTFNTF = "MTF Nine Tailed Fox"
ROLES.ROLE_CSECURITY = "Security Chief"
ROLES.ROLE_MTFCOM = "MTF Commander"
ROLES.ROLE_SD = "Site Director"
ROLES.ROLE_O5 = "O5 Council Member"

// Infect round
ROLES.ROLE_INFECTD = "Class D Presonnel"
ROLES.ROLE_INFECTMTF = "MTF"

// Chaos Insurgency
ROLES.ROLE_CHAOSSPY = "Chaos Insurgency Spy"
ROLES.ROLE_CHAOS = "Chaos Insurgency"
ROLES.ROLE_CHAOSCOM = "CI Commander"

// Other
ROLES.ROLE_SPEC = "Spectator"

--include( "sh_playersetups.lua" )

if !ConVarExists("br_roundrestart") then CreateConVar( "br_roundrestart", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Restart the round" ) end
if !ConVarExists("br_time_preparing") then CreateConVar( "br_time_preparing", "60", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Set preparing time" ) end
if !ConVarExists("br_time_round") then CreateConVar( "br_time_round", "780", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Set round time" ) end
if !ConVarExists("br_time_postround") then CreateConVar( "br_time_postround", "30", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Set postround time" ) end
if !ConVarExists("br_time_ntfenter") then CreateConVar( "br_time_ntfenter", "360", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time that NTF units will enter the facility" ) end
if !ConVarExists("br_time_blink") then CreateConVar( "br_time_blink", "0.25", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Blink timer" ) end
if !ConVarExists("br_time_blinkdelay") then CreateConVar( "br_time_blinkdelay", "5", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Delay between blinks" ) end
if !ConVarExists("br_spawnzombies") then CreateConVar( "br_spawnzombies", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Do you want zombies?" ) end
if !ConVarExists("br_scoreboardranks") then CreateConVar( "br_scoreboardranks", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "" ) end
if !ConVarExists("br_defaultlanguage") then CreateConVar( "br_defaultlanguage", "english", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "" ) end
if !ConVarExists("br_expscale") then CreateConVar( "br_expscale", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "" ) end
if !ConVarExists("br_scp_cars") then CreateConVar( "br_scp_cars", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Allow SCPs to drive cars?" ) end
if !ConVarExists("br_allow_vehicle") then CreateConVar( "br_allow_vehicle", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Allow vehicle spawn?" ) end
if !ConVarExists("br_dclass_keycards") then CreateConVar( "br_dclass_keycards", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Is D class supposed to have keycards? (D Class Weterans have keycard anyway)" ) end
if !ConVarExists("br_time_explode") then CreateConVar( "br_time_explode", "30", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time from call br_destroygatea to explode" ) end
if !ConVarExists("br_ci_percentage") then CreateConVar("br_ci_percentage", "25", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Percentage of CI spawn" ) end
if !ConVarExists("br_i4_min_mtf") then CreateConVar("br_i4_min_mtf", "4", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Percentage of CI spawn" ) end
if !ConVarExists("br_cars_oldmodels") then CreateConVar("br_cars_oldmodels", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Use old cars models?" ) end
if !ConVarExists("br_premium_url") then CreateConVar("br_premium_url", "", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Link to premium members list" ) end
if !ConVarExists("br_premium_mult") then CreateConVar("br_premium_mult", "1.25", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Premium members exp multiplier" ) end
if !ConVarExists("br_premium_display") then CreateConVar("br_premium_display", "Premium player %s has joined!", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Text shown to all players when premium member joins" ) end
if !ConVarExists("br_stamina_enable") then CreateConVar("br_stamina_enable", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Is stamina allowed?" ) end
if !ConVarExists("br_stamina_scale") then CreateConVar("br_stamina_scale", "1, 1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Stamina regen and use. ('x, y') where x is how many stamina you will receive, and y how many stamina you will lose" ) end
if !ConVarExists("br_rounds") then CreateConVar("br_rounds", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "How many round before map restart? 0 - dont restart" ) end
if !ConVarExists("br_min_players") then CreateConVar("br_min_players", "2", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Minimum players to start round" ) end
if !ConVarExists("br_firstround_debug") then CreateConVar("br_firstround_debug", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Skip first round" ) end
if !ConVarExists("br_force_specialround") then CreateConVar("br_force_specialround", "", {FCVAR_SERVER_CAN_EXECUTE}, "Available special rounds [ infect, multi ]" ) end
if !ConVarExists("br_specialround_pct") then CreateConVar("br_specialround_pct", "10", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Skip first round" ) end
if !ConVarExists("br_punishvote_time") then CreateConVar("br_punishvote_time", "30", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How much time players have to vote" ) end
if !ConVarExists("br_allow_punish") then CreateConVar("br_allow_punish", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Is punish system allowed?" ) end
if !ConVarExists("br_cars_ammount") then CreateConVar("br_cars_ammount", "12", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How many cars should spawn?" ) end
if !ConVarExists("br_dropvestondeath") then CreateConVar("br_dropvestondeath", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Do players drop vests on death?" ) end
if !ConVarExists("br_force_showupdates") then CreateConVar("br_force_showupdates", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Should players see update logs any time they join to server?" ) end
if !ConVarExists("br_allow_scptovoicechat") then CreateConVar("br_allow_scptovoicechat", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Can SCPs talk with humans?" ) end
if !ConVarExists("br_ulx_premiumgroup_name") then CreateConVar("br_ulx_premiumgroup_name", "", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Name of ULX premium group" ) end
if !ConVarExists("br_experimental_bulletdamage_system") then CreateConVar("br_experimental_bulletdamage_system", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Turn it off when you see any problems with bullets" ) end
if !ConVarExists("br_experimental_antiknockback_force") then CreateConVar("br_experimental_antiknockback_force", "5", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Turn it off when you see any problems with bullets" ) end
if !ConVarExists("br_allow_ineye_spectate") then CreateConVar("br_allow_ineye_spectate", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "" ) end
if !ConVarExists("br_allow_roaming_spectate") then CreateConVar("br_allow_roaming_spectate", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "" ) end
if !ConVarExists("br_scale_bullet_damage") then CreateConVar("br_scale_bullet_damage", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Bullet damage scale" ) end
if !ConVarExists("br_new_eq") then CreateConVar("br_new_eq", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Enables new EQ" ) end
if !ConVarExists("br_enable_warhead") then CreateConVar("br_enable_warhead", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE }, "Enables OMEGA Warhead" ) end
if !ConVarExists("br_scale_human_damage") then CreateConVar("br_scale_human_damage", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE }, "Scales damage dealt by humans" ) end
if !ConVarExists("br_scale_scp_damage") then CreateConVar("br_scale_scp_damage", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE }, "Scales damage dealt by SCP" ) end
if !ConVarExists("br_scp_penalty") then CreateConVar("br_scp_penalty", "3", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE }, "" ) end
if !ConVarExists("br_premium_penalty") then CreateConVar("br_premium_penalty", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE }, "" ) end


MINPLAYERS = GetConVar("br_min_players"):GetInt()

function GetPrepTime()
	return GetConVar("br_time_preparing"):GetInt()
end

function GetRoundTime()
	return GetConVar("br_time_round"):GetInt()
end

function GetPostTime()
	return GetConVar("br_time_postround"):GetInt()
end

function GetGateOpenTime()
	return GetConVar("br_time_gateopen"):GetInt()
end

function GetNTFEnterTime()
	return GetConVar("br_time_ntfenter"):GetInt()
end

function GM:EntityFireBullets( ent, data )
	if GetConVar( "br_experimental_bulletdamage_system" ):GetInt() != 0 then
		local damage = data.Damage
		data.Damage = 0
		data.Callback = function( ent, tr, info )
			if !SERVER then return end
			local vic = tr.Entity
			if IsValid( vic ) then
				if vic:IsPlayer() then
					info:SetDamage( damage )
					gamemode.Call( "ScalePlayerDamage", vic, nil, info )
					local scaleddamge = info:GetDamage()
					local force = info:GetDamageForce():GetNormalized()
					local antiforce = GetConVar( "br_experimental_antiknockback_force" ):GetInt() * -1
					info:SetDamage( 0 )
					info:SetDamageForce( Vector( 0 ) )
					vic:TakeDamage( scaleddamge, ent, ent )
					vic:SetVelocity( force * scaleddamge * antiforce )
				else
					vic:TakeDamage( info:GetDamage(), ent, ent )
				end
			end
		end
		return true
	end
end

function GM:PlayerFootstep( ply, pos, foot, sound, volume, rf )
	if not ply.GetNClass then
		player_manager.RunClass( ply, "SetupDataTables" )
	end
	if not ply.GetNClass then return end
	if ply:GetNClass() == ROLE_SCP173 then
		if ply.steps == nil then ply.steps = 0 end
		ply.steps = ply.steps + 1
		if ply.steps > 6 then
			ply.steps = 1
			if SERVER then
				ply:EmitSound( "173sound"..math.random(1,3)..".ogg", 300, 100, 1 )
			end
		end
		return true
	end
	return false
end

function GM:ShouldCollide( ent1, ent2 )
	/*local ply = ent1:IsPlayer() and ent1 or ent2:IsPlayer() and ent2
	local ent
	if ply then
		if ent1 == ply then
			ent = ent2
		else
			ent = ent1
		end
		if ply:GetNClass() == ROLES.ROLE_SCP106 then
			if ent.ignorecollide106 then
				return false
			end
		end
	end*/
	if ent1:IsPlayer() and ent1:GetNClass() == ROLES.ROLE_SCP106 or ent2:IsPlayer() and ent2:GetNClass() == ROLES.ROLE_SCP106 then
		if ent1.ignorecollide106 or ent2.ignorecollide106 then
			return false
		end
	end	
	return true
end

/*
function GM:PlayerShouldTakeDamage( ply, attacker ) 
	if attacker:IsVehicle() then
	
	end
	
end
*/

function GM:PlayerButtonDown( ply, button )
	if CLIENT and IsFirstTimePredicted() then
		local bind = _G[ "KEY_"..string.upper( input.LookupBinding( "+menu" ) ) ] or KEY_Q
		if button == bind then
			if CanShowEQ() then
				ShowEQ()
			end
		end
	end
end

function GM:PlayerButtonUp( ply, button )
	if CLIENT and IsFirstTimePredicted() then
		local bind = _G[ "KEY_"..string.upper( input.LookupBinding( "+menu" ) ) ] or KEY_Q
		if button == bind and IsEQVisible() then
			HideEQ()
		end
	end
end

function GM:EntityTakeDamage( target, dmginfo )
	if target:IsPlayer() and target:HasWeapon( "item_scp_500" ) then
		if target:Health() <= dmginfo:GetDamage() then
			target:GetWeapon( "item_scp_500" ):OnUse()
			target:PrintMessage( HUD_PRINTTALK, "Using SCP 500" )
		end
	end
	local at = dmginfo:GetAttacker()
	if at:IsVehicle() or ( at:IsPlayer() and at:InVehicle() ) then
		dmginfo:SetDamage( 0 )
	end
	if at:IsNPC() then
		if at:GetClass() == "npc_fastzombie" then
			dmginfo:ScaleDamage( 4 )
		end
	elseif target:IsPlayer() then
		if target:Alive() then
			local dmgtype = dmginfo:GetDamageType()
			if dmgtype == 268435464 or dmgtype == 8 then
				if target:GTeam() == TEAM_SCP then
					dmginfo:SetDamage( 0 )
					return true
				elseif target.UsingArmor == "armor_fireproof" then
					dmginfo:ScaleDamage(0.75)
				end
			end
			if (dmgtype == DMG_SHOCK or dmgtype == DMG_ENERGYBEAM) and target.UsingArmor == "armor_electroproof" then
				dmginfo:ScaleDamage(0.2)
			end
			if dmgtype == DMG_VEHICLE then
				dmginfo:SetDamage( 0 )
			end
		end
	end
	if at:IsPlayer() and target:IsPlayer() and at:GetNClass() == ROLES.ROLE_SCP9571 and target:GTeam() == TEAM_SCP then
		return true
	end
end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	/*
	if SERVER then
		local at = dmginfo:Getat()
		if ply:GTeam() == at:GTeam() then
			at:TakeDamage( 25, at, at )
		end
	end
	*/
	local at = dmginfo:GetAttacker()

	local mul = 1
	local armormul = 1

	if at:IsPlayer() then
		if at:GTeam() == TEAM_SCP then
			local scale = GetConVar( "br_scale_scp_damage" ):GetFloat()
			if scale == 0 then scale = 1 end
			scale = math.Clamp( scale, 0.1, 5 )
			dmginfo:ScaleDamage( scale )
		elseif at:GTeam() != TEAM_SPEC then
			local scale = GetConVar( "br_scale_human_damage" ):GetFloat()
			if scale == 0 then scale = 1 end
			scale = math.Clamp( scale, 0.1, 5 )
			dmginfo:ScaleDamage( scale )
		end

		if at.GetActiveWeapon then
			local wep = at:GetActiveWeapon()
			if IsValid(wep) then
				if wep:GetClass() == "weapon_crowbar" then
					dmginfo:ScaleDamage(0.3)
				elseif wep:GetClass() == "weapon_stunstick" then
					dmginfo:ScaleDamage(0.5)
				end
			end
		end

		if SERVER then
			local rdm = false
			if at != ply then
				if at:IsPlayer() then
					if dmginfo:IsDamageType( DMG_BULLET ) then
						if ply.UsingArmor != nil then
							if ply.UsingArmor != "armor_fireproof" and ply.UsingArmor != "armor_electroproof" then
								armormul = 0.75
							end
						end
					end
					if postround == false and at.GTeam and ply.GTeam then
						if at:GTeam() == TEAM_GUARD then
							if ply:GTeam() == TEAM_GUARD then 
								rdm = true
							elseif ply:GTeam() == TEAM_SCI then
								rdm = true
							end
						elseif at:GTeam() == TEAM_CHAOS then
							if ply:GTeam() == TEAM_CHAOS or ply:GTeam() == TEAM_CLASSD then
								rdm = trueGTeam
							end
						elseif at:GTeam() == TEAM_SCP then
							if ply:GTeam() == TEAM_SCP then
								rdm = true
							end
						elseif at:GTeam() == TEAM_CLASSD then
							if ply:GTeam() == TEAM_CLASSD or ply:GTeam() == TEAM_CHAOS then
								rdm = true
							end
						elseif at:GTeam() == TEAM_SCI then
							if ply:GTeam() == TEAM_GUARD or ply:GTeam() == TEAM_SCI then 
								rdm = true
							end
						end
					end
					if postround == false then
						if !rdm then
							at:AddExp( math.Round(dmginfo:GetDamage() / 2) )
						end
					end
				end
			end
		end
	end
	
	/*
	if SERVER then
		print("DMG to "..ply:GetName().."["..ply:GetClass().."]", "DMG: "..dmginfo:GetDamage(), "TYPE: "..dmginfo:GetDamageType())
	end
	*/
	
	if (hitgroup == HITGROUP_HEAD) then
		mul = 1.5
	end
	if (hitgroup == HITGROUP_LEFTARM or hitgroup == HITGROUP_RIGHTARM) then
		mul = 0.9
	end
	if (hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG) then
		mul = 0.9
	end
	if (hitgroup == HITGROUP_GEAR) then
		mul = 0
	end
	if (hutgroup == HITGROUP_STOMACH) then
		mul = 1
	end
	if SERVER then
		/*if at:IsPlayer() then -- GET THE FUCK OUT
			if at.GetNKarma then -- GET THE FUCK OUT
				mul = mul * (at:GetNKarma() / StartingKarma()) -- GET THE FUCK OUT
			end -- GET THE FUCK OUT
		end*/ -- GET THE FUCK OUT

		mul = mul * armormul
		dmginfo:ScaleDamage(mul)
		if ply:GTeam() == TEAM_SCP and OUTSIDE_BUFF( ply:GetPos() ) then
			dmginfo:ScaleDamage( 0.75 )
		end
		local scale = math.Clamp( GetConVar( "br_scale_bullet_damage" ):GetFloat(), 0.1, 2 )
		dmginfo:ScaleDamage( scale )

		if ply:GetNClass() == ROLES.ROLE_SCP957 then
			dmginfo:ScaleDamage( 0.1 )
		end

		if at:IsPlayer() then
			if at:GetNClass() == ROLES.ROLE_SCP9571 then
				dmginfo:ScaleDamage( 0.2 )
			end

			if at:GetNClass() == ROLES.ROLE_SCP9571 and ply:GTeam() == TEAM_SCP then
				return true
			end
		end
	end
end

function GM:Move( ply, mv )
	if ply:GTeam() == TEAM_SCP and OUTSIDE_BUFF( ply:GetPos() ) then
		local speed = 0.0025
		local ang = mv:GetMoveAngles()
		local vel = mv:GetVelocity()
		if vel.z == 0 then 
			vel = vel + ang:Forward() * mv:GetForwardSpeed() * speed
			vel = vel + ang:Right() * mv:GetSideSpeed() * speed
			vel.z = 0
		end

		mv:SetVelocity( vel )
	end
end
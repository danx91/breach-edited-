
local mply = FindMetaTable( "Player" )


function mply:ForceDropWeapon( class )
	if self:HasWeapon( class ) then
		local wep = self:GetWeapon( class )
		if IsValid( wep ) and IsValid( self ) then
			if self:GTeam() == TEAM_SPEC then return end
			local atype = wep:GetPrimaryAmmoType()
			if atype > 0 then
				wep.SavedAmmo = wep:Clip1()
			end	
			if wep:GetClass() == nil then return end
			if wep.droppable != nil and !wep.droppable then return end
			self:DropWeapon( wep )
			self:ConCommand( "lastinv" )
		end
	end
end

function mply:DropAllWeapons( strip )
	if GetConVar( "br_dropvestondeath" ):GetInt() != 0 then
		self:UnUseArmor()
	end
	if #self:GetWeapons() > 0 then
		local pos = self:GetPos()
		for k, v in pairs( self:GetWeapons() ) do
			local candrop = true
			if v.droppable != nil then
				if v.droppable == false then
					candrop = false
				end
			end
			if candrop then
				local class = v:GetClass()
				local wep = ents.Create( class )
				if IsValid( wep ) then
					wep:SetPos( pos )
					wep:Spawn()
					if class == "br_keycard" then
						local cardtype = v.KeycardType or v:GetNWString( "K_TYPE", "safe" )
						wep:SetKeycardType( cardtype )
					end
					local atype = v:GetPrimaryAmmoType()
					if atype > 0 then
						wep.SavedAmmo = v:Clip1()
					end
				end
			end
			if strip then
				v:Remove()
			end
		end
	end
end

// just for finding a bad spawns :p
function mply:FindClosest(tab, num)
	local allradiuses = {}
	for k,v in pairs(tab) do
		table.ForceInsert(allradiuses, {v:Distance(self:GetPos()), v})
	end
	table.sort( allradiuses, function( a, b ) return a[1] < b[1] end )
	local rtab = {}
	for i=1, num do
		if i <= #allradiuses then
			table.ForceInsert(rtab, allradiuses[i])
		end
	end
	return rtab
end

function mply:GiveRandomWep(tab)
	local mainwep = table.Random(tab)
	self:Give(mainwep)
	local getwep = self:GetWeapon(mainwep)
	if getwep.Primary == nil then
		print("ERROR: weapon: " .. mainwep)
		print(getwep)
		return
	end
	getwep:SetClip1(getwep.Primary.ClipSize)
	self:SelectWeapon(mainwep)
	self:GiveAmmo((getwep.Primary.ClipSize * 4), getwep.Primary.Ammo, false)
end

function mply:GiveNTFwep()
	self:GiveRandomWep({"cw_ump45", "cw_mp5"})
end

function mply:GiveMTFwep()
	self:GiveRandomWep({"cw_ar15", "cw_ump45", "cw_mp5"})
end

function mply:GiveCIwep()
	self:GiveRandomWep({"cw_ak74", "cw_scarh", "cw_g36c"})
end

function mply:DeleteItems()
	for k,v in pairs(ents.FindInSphere( self:GetPos(), 150 )) do
		if v:IsWeapon() then
			if !IsValid(v.Owner) then
				v:Remove()
			end
		end
	end
end

function mply:ApplyArmor(name)
	self.BaseStats = {
		wspeed = self:GetWalkSpeed(),
		rspeed = self:GetRunSpeed(),
		jpower = self:GetJumpPower(),
		 model = self:GetModel()
	}
	local stats = 0.9
	if name == "armor_ntf" then
		self:SetModel("models/player/pmc_4/pmc__07.mdl")
		stats = 0.8
	elseif name == "armor_mtfguard" then
		self:SetModel("models/scp/guard_noob.mdl")
		stats = 0.85
	elseif name == "armor_mtfcom" then
		self:SetModel("models/scp/captain.mdl")
		stats = 0.9
	elseif name == "armor_mtfl" then
		self:SetModel("models/scp/guard_left.mdl")
		stats = 0.85
	elseif name == "armor_mtfmedic" then
		self:SetModel("models/scp/guard_med.mdl")
		stats = 0.9
	elseif name == "armor_security" then
		self:SetModel("models/scp/guard_sci.mdl")
		stats = 0.92
	elseif name == "armor_fireproof" then
		self:SetModel("models/player/kerry/class_securety.mdl")
		stats = 0.9
	elseif name == "armor_chaosins" then
		self:SetModel("models/friskiukas/bf4/us_01.mdl")
		stats = 0.85
	elseif name == "armor_hazmat" then
		self:SetModel("models/scp/soldier_4.mdl")
		stats = 0.93
	elseif name == "armor_electroproof" then
		self:SetModel("models/scp/soldier_2.mdl")
		stats = 0.8
	elseif name == "armor_csecurity" then
		self:SetModel("models/scp/soldier_1.mdl")
		stats = 0.91
	end
	self:SetWalkSpeed(self.BaseStats.wspeed * stats)
	self:SetRunSpeed(self.BaseStats.rspeed * stats)
	self:SetJumpPower(self.BaseStats.jpower * stats)
	self.UsingArmor = name
end

function mply:UnUseArmor()
	if self.UsingArmor == nil then return end
	self:SetWalkSpeed(self.BaseStats.wspeed)
	self:SetRunSpeed(self.BaseStats.rspeed)
	self:SetJumpPower(self.BaseStats.jpower)
	self:SetModel(self.BaseStats.model)
	local item = ents.Create( self.UsingArmor )
	if IsValid( item ) then
		item:Spawn()
		item:SetPos( self:GetPos() )
		self:EmitSound( Sound("npc/combine_soldier/gear".. math.random(1, 6).. ".wav") )
	end
	self.UsingArmor = nil
end

function mply:SetSpectator()
	self:Flashlight( false )
	self:AllowFlashlight( false )
	self.handsmodel = nil
	self:Spectate( OBS_MODE_CHASE )
	self:StripWeapons()
	self:RemoveAllAmmo()
	self:SetGTeam(TEAM_SPEC)
	self:SetNoDraw(true)
	if self.SetNClass then
		self:SetNClass(ROLES.ROLE_SPEC)
	end
	self.Active = true
	print("adding " .. self:Nick() .. " to spectators")
	self.canblink = false
	self:SetNoTarget( true )
	self.BaseStats = nil
	self.UsingArmor = nil
	//self:Spectate(OBS_MODE_IN_EYE)
end

--[[-------------------------------------------------------------------------

								READ CAREFULLY!

Now to add SCP you have to call RegisterSCP() inside 'RegisterSCP' hook
Therefore if you only want to add SCPs, you don't have to reupload gamemode! Use hook instead and
place files in 'lua/autorun/server/'!


Basic infotmations about RegisterSCP():
	

	RegisterSCP( name, model, weapon, static_stats, dynamic_stats, callback, post_callback )


		name (String) - name of SCP, it will be used by most things. This function will automatically add
			every necessary variablesso you no longer have to care about ROLES table(function will
			create ROLES.ROLE_name = name). Funtion will look for valid language and spawnpos entries
			(for language: english.ROLES.ROLE_name and english.starttexts.ROLE_name, for
			spawnpos: SPAWN_name = Vector or Table of vectors). Function will throw error if something
			is wrong(See errors section below)


		model (String) - full path to model. If you put wrong path you will see error instead of model!


		weapon (String) - SWEP call name. If you put wrong name your scp will not receive weapon and you
			will see red error in console


		static_stats (Table) - this table contain important entries for your SCP. Things specified inside
			this table are more important than dynamic_stats, so it will overwrite them. These stats cannot
			be changed in 'scp.txt' file. This table cotains keys and values(key = "value"). List of valid keys is below.


		dynamic_stats (Table) - this table contains entries for your SCP that can be accessed and changed in
			'garrysmod/data/breach/scp.txt' file. So everybody can customize them. These stats will be overwritten
			by statc_stats. This table cotains keys and values(key = "value") or tables that contains value and
			clamping info(num values only!)(key = "value" or key = { var = num_value, max = max_value, min_minimum value }).
			List of valid keys is below. 

					Valid entreis for static_stats and dynamic_stats:
							base_speed - walk speed
							run_speed - run speed
							max_speed - maximum speed
							base_health - starting health
							max_health - maximum health
							jump_power - jump power
							crouch_speed - crouched walk speed
							no_ragdoll - if true, rgdoll will not appear
							model_scale - scale of model
							hands_model - model of hands
							prep_freeze - if true, SCP will not be able to move during preparing
							no_spawn - position will not be changed
							no_model - model will not be changed
							no_swep - SCP won't have SWEP
							no_strip - player EQ won't be stripped
							no_select - SCP won't appear in game


		callback (Function) - called on beginning of SetupPlayer return true to override default actions(post callback will not be called).
			function( ply, basestats, ... ) - 3 arguments are passed:
				ply - player
				basestats - result of static_stats and dynamic_stats
				... - (varargs) passsed from SetupPlayer
		

		post_callback (Function) - called on end of SetupPlayer. Only player is passed as argument:
			function( ply )
				ply - player


To get registered SCP:
		GetSCP( name ) - global function that returns SCP object
			arguments:
				name - name of SCP(same as used in RegisterSCP)

			return:
				ObjectSCP - (explained below)

	ObjectSCP:
		functions:
			SCPObject:SetCallback( callback, post ) - used internally by RegisterSCP. Sets callback, if post == true, sets post_callback

			ObjectSCP:SetupPlayer( ply, ... ) - use to set specified player as SCP.
					ply - player who become SCP
					... - varargs passed to callback if ObjectSCP has one

---------------------------------------------------------------------------]]

hook.Add( "RegisterSCP", "RegisterBaseSCPs", function()
	/*RegisterSCP( "SCPSantaJ", "models/player/christmas/santa.mdl", "weapon_scp_santaJ", {
		jump_power = 200,
		prep_freeze = true,
		no_ragdoll = true,
	}, {
		base_health = 2500,
		max_health = 2500,
		base_speed = 160,
		run_speed = 160,
		max_speed = 160,
	} )*/

	RegisterSCP( "SCP023", "models/Novux/023/Novux_SCP-023.mdl", "weapon_scp_023", {
		jump_power = 200,
		prep_freeze = true,
	}, {
		base_health = 2000,
		max_health = 2000,
		base_speed = 150,
		run_speed = 250,
		max_speed = 250,
	} )

	RegisterSCP( "SCP049", "models/vinrax/player/scp049_player.mdl", "weapon_scp_049", {
		jump_power = 200,
	}, {
		base_health = 1600,
		max_health = 1600,
		base_speed = 135,
		run_speed = 135,
		max_speed = 135,
	} )

	RegisterSCP( "SCP0492", "models/player/zombie_classic.mdl", "weapon_br_zombie", {
		jump_power = 200,
		no_spawn = true,
		no_select = true,
	}, {
		base_health = 750,
		max_health = 750,
		base_speed = 160,
		run_speed = 160,
		max_speed = 160,
	}, nil, function( ply )
		WinCheck()
	end )

	RegisterSCP( "SCP066", "models/player/mrsilver/scp_066pm/scp_066_pm.mdl", "weapon_scp_066", {
		jump_power = 200,
		no_ragdoll = true,
		prep_freeze = true,
	}, {
		base_health = 2250,
		max_health = 2250,
		base_speed = 160,
		run_speed = 160,
		max_speed = 160,
	} )

	RegisterSCP( "SCP076", "models/abel/abel.mdl", "weapon_scp_076", {
		jump_power = 200,
		prep_freeze = true,
	}, {
		base_health = 300,
		max_health = 300,
		base_speed = 220,
		run_speed = 220,
		max_speed = 220,
	}, nil, function( ply )
		SetupSCP0761( ply )
	end )

	RegisterSCP( "SCP082", "models/models/konnie/savini/savini.mdl", "weapon_scp_082", {
		jump_power = 200,
		prep_freeze = true,
	}, {
		base_health = 2300,
		max_health = 2800,
		base_speed = 160,
		run_speed = 160,
		max_speed = 160,
	}, nil, function( ply )
		ply:SetBodygroup( ply:FindBodygroupByName( "Mask" ), 1 )
	end )

	RegisterSCP( "SCP096", "models/scp096anim/player/scp096pm_raf.mdl", "weapon_scp_096", {
		jump_power = 200,
	}, {
		base_health = 1750,
		max_health = 1750,
		base_speed = 120,
		run_speed = 500,
		max_speed = 500,
	} )

	RegisterSCP( "SCP106", "models/scp/106/unity/unity_scp_106_player.mdl", "weapon_scp_106", {
		jump_power = 200,
	}, {
		base_health = 2000,
		max_health = 2000,
		base_speed = 170,
		run_speed = 170,
		max_speed = 170,
	} )

	RegisterSCP( "SCP173", "models/breach173.mdl", "weapon_scp_173", {
		jump_power = 200,
		no_ragdoll = true,
	}, {
		base_health = 3000,
		max_health = 3000,
		base_speed = 400,
		run_speed = 400,
		max_speed = 400,
	} )

	RegisterSCP( "SCP457", "models/player/corpse1.mdl", "weapon_scp_457", {
		jump_power = 200,
	}, {
		base_health = 2300,
		max_health = 2300,
		base_speed = 135,
		run_speed = 135,
		max_speed = 135,
	} )

	RegisterSCP( "SCP682", "models/scp_682/scp_682.mdl", "weapon_scp_682", {
		jump_power = 200,
		no_ragdoll = true,
	}, {
		base_health = 2000,
		max_health = 2000,
		base_speed = 120,
		run_speed = 275,
		max_speed = 275,
	} )

	RegisterSCP( "SCP689", "models/dwdarksouls/models/darkwraith.mdl", "weapon_scp_689", {
		jump_power = 200,
	}, {
		base_health = 1500,
		max_health = 1500,
		base_speed = 75,
		run_speed = 75,
		max_speed = 75,
	} )

	RegisterSCP( "SCP8602", "models/props/forest_monster/forest_monster2.mdl", "weapon_scp_8602", {
		jump_power = 200,
		prep_freeze = true,
	}, {
		base_health = 2250,
		max_health = 2250,
		base_speed = 190,
		run_speed = 190,
		max_speed = 190,
	} )

	RegisterSCP( "SCP939", "models/scp/939/unity/unity_scp_939.mdl", "weapon_scp_939", {
		jump_power = 200,
		prep_freeze = true,
	}, {
		base_health = 2000,
		max_health = 2000,
		base_speed = 190,
		run_speed = 190,
		max_speed = 190,
	} )

	RegisterSCP( "SCP957", "models/immigrant/outlast/walrider_pm.mdl", "weapon_scp_957", {
		jump_power = 200,
		prep_freeze = true,
	}, {
		base_health = 1500,
		max_health = 1500,
		base_speed = 175,
		run_speed = 175,
		max_speed = 175,
	} )

	RegisterSCP( "SCP9571", "", "", {
		no_spawn = true,
		no_select = true,
	}, {
		base_health = 1000,
		max_health = 1000,
	}, function( ply, basestats )
		if !ply.SetLastRole or !ply.SetLastTeam then
			player_manager.RunClass( ply, "SetupDataTables" )
		end

		ply:SetHealth( basestats.base_health or 1000 )
		ply:SetMaxHealth( basestats.max_health or 1000 )

		ply:SetLastRole( ply:GetNClass() )
		ply:SetLastTeam( ply:GTeam() )
		ply:SetGTeam( TEAM_SCP )
		ply:SetNClass( ROLES.ROLE_SCP9571 )
		ply.canblink = false

		net.Start( "RolesSelected" )
		net.Send( ply )

		return true
	end )

	RegisterSCP( "SCP966", "models/player/mishka/966_new.mdl", "weapon_scp_966", {
		jump_power = 200,
	}, {
		base_health = 800,
		max_health = 800,
		base_speed = 140,
		run_speed = 140,
		max_speed = 140,
	} )

	RegisterSCP( "SCP999", "models/scp/999/jq/scp_999_pmjq.mdl", "weapon_scp_999", {
		jump_power = 200,
	}, {
		base_health = 1000,
		max_health = 1000,
		base_speed = 150,
		run_speed = 150,
		max_speed = 150,
	} )

	RegisterSCP( "SCP1048A", "models/1048/tdyear/tdybrownearpm.mdl", "weapon_scp_1048A", {
		jump_power = 200,
		prep_freeze = true,
	}, {
		base_health = 1500,
		max_health = 1500,
		base_speed = 135,
		run_speed = 135,
		max_speed = 135,
	} )

	RegisterSCP( "SCP1048B", "models/player/teddy_bear/teddy_bear.mdl", "weapon_scp_1048B", {
		jump_power = 200,
		prep_freeze = true,
	}, {
		base_health = 2000,
		max_health = 2000,
		base_speed = 165,
		run_speed = 165,
		max_speed = 165,
	} )

	RegisterSCP( "SCP1471", "models/burd/scp1471/scp1471.mdl", "weapon_scp_1471", {
		jump_power = 200,
		prep_freeze = true,
	}, {
		base_health = 3000,
		max_health = 3000,
		base_speed = 160,
		run_speed = 325,
		max_speed = 160,
	} )
end )

function SetupSCP0761( ply )
	print( "setup" )
	if !IsValid( SCP0761 ) then
		cspawn076 = table.Random( SPAWN_SCP076 )
		SCP0761 = ents.Create( "item_scp_0761" )
		SCP0761:Spawn()
		SCP0761:SetPos( cspawn076 )
	end
	ply:SetPos( cspawn076 )
end

function mply:SetSCP0082( hp, speed, spawn )
	self:Flashlight( false )
	self.handsmodel = nil
	self:UnSpectate()
	self:GodDisable()
	if spawn then
		self:Spawn()
	end
	self:DropAllWeapons( true )
	self:SetModel("models/player/zombie_classic.mdl")
	self:SetGTeam(TEAM_SCP)
	self:SetHealth(hp)
	self:SetMaxHealth(hp)
	self:SetArmor(0)
	self:SetWalkSpeed(speed)
	self:SetRunSpeed(speed)
	self:SetMaxSpeed(speed)
	self:SetJumpPower(200)
	self:SetNoDraw(false)
	self:SetNClass(ROLES.ROLE_SCP0082)
	self.Active = true
	print("adding " .. self:Nick() .. " to zombies")
	self:SetupHands()
	if !spawn then
		WinCheck()
	end
	self.canblink = false
	self.noragdoll = false
	self:AllowFlashlight( false )
	self.WasTeam = TEAM_SCP
	self:SetNoTarget( true )
	net.Start("RolesSelected")
	net.Send(self)
	self:Give("weapon_br_zombie_infect")
	self:SelectWeapon("weapon_br_zombie_infect")
	self.BaseStats = nil
	self.UsingArmor = nil
	self:SetupHands()
end

function mply:SetInfectD()
	self:Flashlight( false )
	self.handsmodel = nil
	self:UnSpectate()
	self:GodDisable()
	self:Spawn()
	self:StripWeapons()
	self:RemoveAllAmmo()
	self:SetGTeam(TEAM_CLASSD)
	self:SetNClass(ROLES.ROLE_INFECTD)
	self:SetModel( table.Random( CLASSDMODELS ) )
	self:SetHealth(100)
	self:SetMaxHealth(100)
	self:SetArmor(0)
	self:SetWalkSpeed(130)
	self:SetRunSpeed(250)
	self:SetMaxSpeed(250)
	self:SetJumpPower(200)
	self:SetNoDraw(false)
	self:SetupHands()
	self.canblink = true
	self.noragdoll = false
	self:AllowFlashlight( true )
	self.WasTeam = TEAM_CLASSD
	self:SetNoTarget( false )
	self:Give("br_holster")
	self:Give("br_id")

	local card = self:Give( "br_keycard" )
	if card then
		card:SetKeycardType( "safe" )
	end
	self:SelectWeapon( "br_keycard" )

	self.BaseStats = nil
	self.UsingArmor = nil
end

function mply:SetInfectMTF()
	self:Flashlight( false )
	self.handsmodel = nil
	self:UnSpectate()
	self:GodDisable()
	self:Spawn()
	self:StripWeapons()
	self:RemoveAllAmmo()
	self:SetGTeam(TEAM_GUARD)
	self:SetNClass(ROLES.ROLE_INFECTMTF)
	self:SetModel( table.Random( SECURITYMODELS ) )
	self:SetHealth(150)
	self:SetMaxHealth(150)
	self:SetArmor(0)
	self:SetWalkSpeed(140)
	self:SetRunSpeed(260)
	self:SetMaxSpeed(260)
	self:SetJumpPower(215)
	self:SetNoDraw(false)
	self:SetupHands()
	self.canblink = true
	self.noragdoll = false
	self:AllowFlashlight( true )
	self.WasTeam = TEAM_GUARD
	self:SetNoTarget( false )
	self:Give("br_holster")
	self:Give("br_id")
	self:Give("cw_ar15")
	self:GiveAmmo( 60, "5.56x45MM" )

	local card = self:Give( "br_keycard" )
	if card then
		card:SetKeycardType( "euclid" )
	end
	self:SelectWeapon( "br_keycard" )

	self.BaseStats = nil
	self.UsingArmor = nil
	self:ApplyArmor("armor_mtfcom")
	if ( self:GetWeapons() != nil ) then
		for k, v in pairs( self:GetWeapons() ) do
			if ( v:GetClass() == "cw_deagle" ) then v.Damage_Orig = WEP_DMG.deagle v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_fiveseven" ) then v.Damage_Orig = WEP_DMG.fiveseven v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_ak74 " ) then v.Damage_Orig = WEP_DMG.ak74 v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_ar15" ) then v.Damage_Orig = WEP_DMG.ar15 v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_g36c" ) then v.Damage_Orig = WEP_DMG.g36c v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_ump45" ) then v.Damage_Orig = WEP_DMG.ump45 v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_mp5" ) then v.Damage_Orig = WEP_DMG.mp5 v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_m14" ) then v.Damage_Orig = WEP_DMG.m14 v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_scarh" ) then v.Damage_Orig = WEP_DMG.scarh v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_l115" ) then v.Damage_Orig = WEP_DMG.l115 v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_shorty" ) then v.Damage_Orig = WEP_DMG.shorty v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_m3super90" ) then v.Damage_Orig = WEP_DMG.super90 v.DamageMult = 1 v:recalculateDamage() end	
		end
	end
end

function mply:SetupNormal()
	self.BaseStats = nil
	self.UsingArmor = nil
	self.handsmodel = nil
	self:UnSpectate()
	self:Spawn()
	self:GodDisable()
	self:SetNoDraw(false)
	self:SetNoTarget(false)
	self:SetupHands()
	self:RemoveAllAmmo()
	self:StripWeapons()
	self.canblink = true
	self.noragdoll = false
	self.scp1471stacks = 1
end

function mply:SetupAdmin()
	self:Flashlight( false )
	self:AllowFlashlight( true )
	self.handsmodel = nil
	self:UnSpectate()
	//self:Spectate(6)
	self:StripWeapons()
	self:RemoveAllAmmo()
	self:SetGTeam(TEAM_SPEC)
	self:SetNoDraw(true)
	if self.SetNClass then
		self:SetNClass(ROLES.ADMIN)
	end
	self.canblink = false
	self:SetNoTarget( false )
	self.BaseStats = nil
	self.UsingArmor = nil
	self:GodEnable()
	self:SetupHands()
	self:SetWalkSpeed(400)
	self:SetRunSpeed(400)
	self:SetMaxSpeed(300)
	self:ConCommand( "noclip" )
	self:Give( "br_holster" )
	self:Give( "br_entity_remover" )
	self:Give( "weapon_physgun" )
end



function mply:ApplyRoleStats( role )
	self:SetNClass( role.name )
	self:SetGTeam( role.team )
	for k, v in pairs( role.weapons ) do
		self:Give( v )
	end
	if role.keycard and role.keycard != "" then
		local card = self:Give( "br_keycard" )
		if card then
			card:SetKeycardType( role.keycard )
		end
		self:SelectWeapon( "br_keycard" )
	end
	if ( self:GetWeapons() != nil ) then
		for k, v in pairs( self:GetWeapons() ) do
			if ( v:GetClass() == "cw_deagle" ) then v.Damage_Orig = WEP_DMG.deagle v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_fiveseven" ) then v.Damage_Orig = WEP_DMG.fiveseven v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_ak74 " ) then v.Damage_Orig = WEP_DMG.ak74 v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_ar15" ) then v.Damage_Orig = WEP_DMG.ar15 v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_g36c" ) then v.Damage_Orig = WEP_DMG.g36c v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_ump45" ) then v.Damage_Orig = WEP_DMG.ump45 v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_mp5" ) then v.Damage_Orig = WEP_DMG.mp5 v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_m14" ) then v.Damage_Orig = WEP_DMG.m14 v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_scarh" ) then v.Damage_Orig = WEP_DMG.scarh v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_l115" ) then v.Damage_Orig = WEP_DMG.l115 v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_shorty" ) then v.Damage_Orig = WEP_DMG.shorty v.DamageMult = 1 v:recalculateDamage() end
			if ( v:GetClass() == "cw_m3super90" ) then v.Damage_Orig = WEP_DMG.super90 v.DamageMult = 1 v:recalculateDamage() end	
		end
	end
	for k, v in pairs( role.ammo ) do
		for _, wep in pairs( self:GetWeapons() ) do
			if v[1] == wep:GetClass() then
				wep:SetClip1(v[2])
			end
		end
	end
	self:SetHealth(role.health)
	self:SetMaxHealth(role.health)
	self:SetWalkSpeed(100 * role.walkspeed)
	self:SetRunSpeed(210 * role.runspeed)
	self:SetJumpPower(190 * role.jumppower)
	self:SetModel( table.Random(role.models) )
	self:Flashlight( false )
	self:AllowFlashlight( role.flashlight )
	if role.vest != nil then
		self:ApplyArmor(role.vest)
	end
	if role.pmcolor != nil then
		self:SetPlayerColor(Vector(role.pmcolor.r / 255, role.pmcolor.g / 255, role.pmcolor.b / 255))
	end
	net.Start("RolesSelected")
	net.Send(self)
	self:SetupHands()
end

function mply:SetSecurityI1()
	local thebestone = nil
	local usechaos = false
	if math.random(1,6) == 6 then usechaos = true end
	for k,v in pairs(ALLCLASSES["security"]["roles"]) do
		if v.importancelevel == 1 then
			local skip = false
			if usechaos == true then
				if v.team == TEAM_GUARD then
					skip = true
				end
			else
				if v.team == TEAM_CHAOS then
					skip = true
				end
			end
			if skip == false then
				local can = true
				if v.customcheck != nil then
					if v.customcheck(self) == false then
						can = false
					end
				end
				local using = 0
				for _,pl in pairs(player.GetAll()) do
					if pl:GetNClass() == v.name then
						using = using + 1
					end
				end
				if using >= v.max then can = false end
				if can == true then
					if self:GetLevel() >= v.level then
						if thebestone != nil then
							if thebestone.sorting < v.sorting then
								thebestone = v
							end
						else
							thebestone = v
						end
					end
				end
			end
		end
	end
	if thebestone == nil then
		thebestone = ALLCLASSES["security"]["roles"][1]
	end
	self:SetupNormal()
	self:ApplyRoleStats(thebestone)
end

function mply:SetClassD()
	self:SetRoleBestFrom("classds")
end

function mply:SetResearcher()
	self:SetRoleBestFrom("researchers")
end

function mply:SetRoleBestFrom(role)
	local thebestone = nil
	for k,v in pairs(ALLCLASSES[role]["roles"]) do
		local can = true
		if v.customcheck != nil then
			if v.customcheck(self) == false then
				can = false
			end
		end
		local using = 0
		for _,pl in pairs(player.GetAll()) do
			if pl:GetNClass() == v.name then
				using = using + 1
			end
		end
		if using >= v.max then can = false end
		if can == true then
			if self:GetLevel() >= v.level then
				if thebestone != nil then
					if thebestone.level < v.level then
						thebestone = v
					end
				else
					thebestone = v
				end
			end
		end
	end
	if thebestone == nil then
		thebestone = ALLCLASSES[role]["roles"][1]
	end
	if thebestone == ALLCLASSES["classds"]["roles"][4] and #player.GetAll() < 4 then
		thebestone = ALLCLASSES["classds"]["roles"][3]
	end
	if ( GetConVar("br_dclass_keycards"):GetInt() != 0 ) then
		if thebestone == ALLCLASSES["classds"]["roles"][1] then thebestone = ALLCLASSES["classds"]["roles"][2] end
	else
		if thebestone == ALLCLASSES["classds"]["roles"][2] then thebestone = ALLCLASSES["classds"]["roles"][1] end
	end
	self:SetupNormal()
	self:ApplyRoleStats(thebestone)
end

function mply:IsActivePlayer()
	return self.Active
end

hook.Add( "KeyPress", "keypress_spectating", function( ply, key )
	if ply:GTeam() != TEAM_SPEC or ply:GetNClass() == ROLES.ADMIN then return end
	if ( key == IN_ATTACK ) then
		ply:SpectatePlayerLeft()
	elseif ( key == IN_ATTACK2 ) then
		ply:SpectatePlayerRight()
	elseif ( key == IN_RELOAD ) then
		ply:ChangeSpecMode()
	end
end )

function mply:SpectatePlayerRight()
	if !self:Alive() then return end
	if self:GetObserverMode() != OBS_MODE_IN_EYE and
	   self:GetObserverMode() != OBS_MODE_CHASE 
	then return end
	self:SetNoDraw(true)
	local allply = GetAlivePlayers()
	if #allply == 1 then return end
	if not self.SpecPly then
		self.SpecPly = 0
	end
	self.SpecPly = self.SpecPly - 1
	if self.SpecPly < 1 then
		self.SpecPly = #allply 
	end
	for k,v in pairs(allply) do
		if k == self.SpecPly then
			self:SpectateEntity( v )
		end
	end
end

function mply:SpectatePlayerLeft()
	if !self:Alive() then return end
	if self:GetObserverMode() != OBS_MODE_IN_EYE and
	   self:GetObserverMode() != OBS_MODE_CHASE 
	then return end
	self:SetNoDraw(true)
	local allply = GetAlivePlayers()
	if #allply == 1 then return end
	if not self.SpecPly then
		self.SpecPly = 0
	end
	self.SpecPly = self.SpecPly + 1
	if self.SpecPly > #allply then
		self.SpecPly = 1
	end
	for k,v in pairs(allply) do
		if k == self.SpecPly then
			self:SpectateEntity( v )
		end
	end
end

function mply:ChangeSpecMode()
	if !self:Alive() then return end
	if !(self:GTeam() == TEAM_SPEC) then return end
	self:SetNoDraw(true)
	local m = self:GetObserverMode()
	local allply = #GetAlivePlayers()
	if allply < 2 then
		self:Spectate(OBS_MODE_ROAMING)
		return
	end
	/*
	if m == OBS_MODE_CHASE then
		self:Spectate(OBS_MODE_IN_EYE)
	else
		self:Spectate(OBS_MODE_CHASE)
	end
	*/
	
	if m == OBS_MODE_IN_EYE then
		self:Spectate(OBS_MODE_CHASE)	
	elseif m == OBS_MODE_CHASE then
		if GetConVar( "br_allow_roaming_spectate" ):GetInt() == 1 then
			self:Spectate(OBS_MODE_ROAMING)
		elseif GetConVar( "br_allow_ineye_spectate" ):GetInt() == 1 then
			self:Spectate(OBS_MODE_IN_EYE)
			self:SpectatePlayerLeft()
		else
			self:SpectatePlayerLeft()
		end	
	elseif m == OBS_MODE_ROAMING then
		if GetConVar( "br_allow_ineye_spectate" ):GetInt() == 1 then
			self:Spectate(OBS_MODE_IN_EYE)
			self:SpectatePlayerLeft()
		else
			self:Spectate(OBS_MODE_CHASE)
			self:SpectatePlayerLeft()
		end
	else
		self:Spectate(OBS_MODE_ROAMING)
	end
end

function mply:SaveExp()
	self:SetPData( "breach_exp", self:GetExp() )
end

function mply:SaveLevel()
	self:SetPData( "breach_level", self:GetLevel() )
end

function mply:AddExp(amount, msg)
	amount = amount * GetConVar("br_expscale"):GetInt()
	if self.Premium == true then
		amount = amount * GetConVar("br_premium_mult"):GetFloat()
	end
	amount = math.Round(amount)
	if not self.GetNEXP then
		player_manager.RunClass( self, "SetupDataTables" )
	end
	if self.GetNEXP and self.SetNEXP then
		self:SetNEXP( self:GetNEXP() + amount )
		if msg != nil then
			self:PrintMessage(HUD_PRINTTALK, "LevelS: Earned " .. amount .. " Experience, your EXP now: " .. self:GetNEXP())
		else
			self:PrintMessage(HUD_PRINTCONSOLE, "LevelS: Earned " .. amount .. " Experience, your EXP now: " .. self:GetNEXP())
		end
		local xp = self:GetNEXP()
		local lvl = self:GetNLevel()
		if lvl == 0 then
			if xp >= 3000 then
				self:AddLevel(1)
				self:SetNEXP(xp - 3000)
				self:SaveLevel()
				PrintMessage(HUD_PRINTTALK, self:Nick() .. " reached level 1! Congratulations!")
			end
		elseif lvl == 1 then
			if xp >= 5000 then
				self:AddLevel(1)
				self:SetNEXP(xp - 5000)
				self:SaveLevel()
				PrintMessage(HUD_PRINTTALK, self:Nick() .. " reached level 2! Congratulations!")
			end
		elseif lvl == 2 then
			if xp >= 7500 then
				self:AddLevel(1)
				self:SetNEXP(xp - 7500)
				self:SaveLevel()
				PrintMessage(HUD_PRINTTALK, self:Nick() .. " reached level 3! Congratulations!")
			end
		elseif lvl == 3 then
			if xp >= 11000 then
				self:AddLevel(1)
				self:SetNEXP(xp - 11000)
				self:SaveLevel()
				PrintMessage(HUD_PRINTTALK, self:Nick() .. " reached level 4! Congratulations!")
			end
		elseif lvl == 4 then
			if xp >= 14000 then
				self:AddLevel(1)
				self:SetNEXP(xp - 14000)
				self:SaveLevel()
				PrintMessage(HUD_PRINTTALK, self:Nick() .. " reached level 5! Congratulations!")
			end
		elseif lvl == 5 then
			if xp >= 25000 then
				self:AddLevel(1)
				self:SetNEXP(xp - 25000)
				self:SaveLevel()
				PrintMessage(HUD_PRINTTALK, self:Nick() .. " reached level OMNI! Congratulations!")
			end
		elseif lvl == 6 then
			if xp >= 100000 then
				self:AddLevel(1)
				self:SetNEXP(xp - 100000)
				self:SaveLevel()
				PrintMessage(HUD_PRINTTALK, self:Nick() .. " is a now a Veteran! Congratulations!")
			end
		elseif lvl > 6 then
			if xp >= 100000 then
				self:AddLevel(1)
				self:SetNEXP(xp - 100000)
				self:SaveLevel()
				PrintMessage(HUD_PRINTTALK, self:Nick() .. " reached level "..lvl.."! Congratulations!")
			end
		end
		self:SetPData( "breach_exp", self:GetExp() )
	else
		if self.SetNEXP then
			self:SetNEXP( 0 )
		else
			ErrorNoHalt( "Cannot set the exp, SetNEXP invalid" )
		end
	end
end

function mply:AddLevel(amount)
	if not self.GetNLevel then
		player_manager.RunClass( self, "SetupDataTables" )
	end
	if self.GetNLevel and self.SetNLevel then
		self:SetNLevel( self:GetNLevel() + amount )
		self:SetPData( "breach_level", self:GetNLevel() )
	else
		if self.SetNLevel then
			self:SetNLevel( 0 )
		else
			ErrorNoHalt( "Cannot set the exp, SetNLevel invalid" )
		end
	end
end

function mply:SetRoleName(name)
	local rl = nil
	for k,v in pairs(ALLCLASSES) do
		for _,role in pairs(v.roles) do
			if role.name == name then
				rl = role
			end
		end
	end
	if rl != nil then
		self:ApplyRoleStats(rl)
	end
end

function mply:SetActive( active )
	self.ActivePlayer = active
	self:SetNActive( active )
	if !gamestarted then
		CheckStart()
	end
end

function mply:ToggleAdminModePref()
	if self.admpref == nil then self.admpref = false end
	if self.admpref then
		self.admpref = false
		if self.AdminMode then
			self:ToggleAdminMode()
			self:SetSpectator()
		end
	else
		self.admpref = true
		if self:GetNClass() == ROLES.ROLE_SPEC then
			self:ToggleAdminMode()
			self:SetupAdmin()
		end
	end
end

function mply:ToggleAdminMode()
	if self.AdminMode == nil then self.AdminMode = false end
	if self.AdminMode == true then
		self.AdminMode = false
		self:SetActive( true )
		self:DrawWorldModel( true ) 
	else
		self.AdminMode = true
		self:SetActive( false )
		self:DrawWorldModel( false ) 
	end
end
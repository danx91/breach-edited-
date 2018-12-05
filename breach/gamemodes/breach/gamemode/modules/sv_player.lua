
local mply = FindMetaTable( "Player" )

function mply:PrintTranslatedMessage( string )
	net.Start( "TranslatedMessage" )
		net.WriteString( string )
		//net.WriteBool( center or false )
	net.Send( self )
end

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
				local max_clip = wep:GetMaxClip1()
				local new_clip = math.min( v[2], max_clip )
				local reserve = v[2] - new_clip

				wep:SetClip1( new_clip )

				if reserve > 0 then
					self:GiveAmmo( reserve, wep:GetPrimaryAmmoType() )
				end

				break
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
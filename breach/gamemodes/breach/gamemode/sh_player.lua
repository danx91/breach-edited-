
local mply = FindMetaTable( "Player" )

function mply:CLevelGlobal()
	local biggest = 1
	for k,wep in pairs(self:GetWeapons()) do
		if IsValid(wep) then
			if wep.clevel then
				if wep.clevel > biggest then
					biggest =  wep.clevel
				end
			end
		end
	end
	return biggest
end 

function mply:CLevel()
	local wep = self:GetActiveWeapon()
	if IsValid(wep) then
		if wep.clevel then
			return wep.clevel
		end
	end
	return 1
end 

function mply:GetKarma()
	if not self.GetNKarma then
		player_manager.RunClass( self, "SetupDataTables" )
	end
	if not self.GetNKarma then
		return 999
	else
		return self:GetNKarma()
	end
end

function mply:GetExp()
	if not self.GetNEXP then
		player_manager.RunClass( self, "SetupDataTables" )
	end
	if self.GetNEXP and self.SetNEXP then
		return self:GetNEXP()
	else
		ErrorNoHalt( "Cannot get the exp, GetNEXP invalid" )
		return 0
	end
end

function mply:GetLevel()
	if not self.GetNLevel then
		player_manager.RunClass( self, "SetupDataTables" )
	end
	if self.GetNLevel and self.SetNLevel then
		return self:GetNLevel()
	else
		ErrorNoHalt( "Cannot get the exp, GetNLevel invalid" )
		return 0
	end
end

function Sprint( ply )
	if not ply.RunSpeed then ply.RunSpeed = 0 end
	if not ply.lTime then ply.lTime = 0 end
	if !ply.GetRunSpeed then return end
	if ply:GetRunSpeed() == ply:GetWalkSpeed() or GetConVar("br_stamina_enable"):GetInt() == 0 then
		ply.Stamina = 100
	else
		if !ply.Stamina then ply.Stamina = 100 end
		if ply.exhausted then
			if ply.Stamina >= 30 then
				ply.exhausted = false
				ply:SetRunSpeed( ply.RunSpeed ) --SetRunSpeed doesnt work clientside
			end
			if ply.lTime < CurTime() then
				ply.lTime = CurTime() + 0.1
				ply.Stamina = ply.Stamina + sR
			end
		else
			if ply.Stamina <= 0 then
				ply.Stamina = 0
				ply.exhausted = true
				ply.RunSpeed = ply:GetRunSpeed()
				ply:SetRunSpeed( ply:GetWalkSpeed() + 1 ) --again not effect on clientside
			end
			if ply.lTime < CurTime() then
				ply.lTime = CurTime() + 0.1
				if ply.sprintEnabled and !( ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetMoveType() == MOVETYPE_LADDER or ply:GetMoveType() == MOVETYPE_OBSERVER  or ply:InVehicle() ) then
					ply.Stamina = ply.Stamina - sL
				else
					ply.Stamina = ply.Stamina + sR
				end
			end
		end
		if ply.Stamina > 100 then ply.Stamina = 100 end
		if ply.Using714 and ply.Stamina > 30 then ply.Stamina = 30 end
	end
end

if CLIENT then
	function mply:DropWeapon( class )
		net.Start( "DropWeapon" )
			net.WriteString( class )
		net.SendToServer()
	end

	function mply:SelectWeapon( class )
		if ( !self:HasWeapon( class ) ) then return end
		self.DoWeaponSwitch = self:GetWeapon( class )
	end
	
	hook.Add( "CreateMove", "WeaponSwitch", function( cmd )
		if !IsValid( LocalPlayer().DoWeaponSwitch ) then return end

		cmd:SelectWeapon( LocalPlayer().DoWeaponSwitch )

		if LocalPlayer():GetActiveWeapon() == LocalPlayer().DoWeaponSwitch then
			LocalPlayer().DoWeaponSwitch = nil
		end
	end )
end

function OnTick()
	if CLIENT then
		Sprint( LocalPlayer() )
	elseif SERVER then
		for k, v in pairs( player.GetAll() ) do
			Sprint( v )
		end
	end
end

hook.Add( "Tick", "Stamina", OnTick )

local n = GetConVar("br_stamina_scale"):GetString()
sR = tonumber( string.sub( n, 1, string.find( n, "," ) - 1 ) )
sL = tonumber( string.sub( n, string.find( n, "," ), string.len( n ) ) ) or tonumber( string.sub( n, string.find( n, "," ) + 1, string.len( n ) ) )

hook.Add("KeyPress", "stm_on", function( ply, button )
	if button == IN_SPEED then ply.sprintEnabled = true end
end )

hook.Add("KeyRelease", "stm_off", function( ply, button )
	if button == IN_SPEED then ply.sprintEnabled = false end
end )
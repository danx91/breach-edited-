AddCSLuaFile()

SWEP.Base 			= "weapon_scp_base"
SWEP.PrintName		= "SCP-173"

SWEP.HoldType		= "normal"

SWEP.AttackDelay			= 0.25
SWEP.SpecialDelay			= 30
SWEP.NextAttackW			= 0

if CLIENT then
	SWEP.WepSelectIcon 	= surface.GetTextureID("breach/wep_173")
end
 
--SWEP.SantasHatPositionOffset = Vector( -3, 47, 1 )
--SWEP.SantasHatAngleOffset = Angle( -90, -20, -20 )

function SWEP:Initialize()
	self:InitializeLanguage( "SCP_173" )

	self:SetHoldType(self.HoldType)
	/*if CLIENT then
		if !self.SantasHat then
			self.SantasHat = ClientsideModel( "models/cloud/kn_santahat.mdl" )
			self.SantasHat:SetModelScale( 1.2 )
			self.SantasHat:SetNoDraw( true )
		end
	end*/
end

/*function SWEP:Remove()
	if CLIENT and IsValid( self.SantasHat ) then
		self.SantasHat:Remove()
	end
end*/

/*function SWEP:IsLookingAt( ply )
	local yes = ply:GetAimVector():Dot( ( self.Owner:GetPos() - ply:GetPos() + Vector( 70 ) ):GetNormalized() )
	return (yes > 0.39)
end*/
 
SWEP.Watching = 0
function SWEP:Think()
	if CLIENT then
		self.Watching = CurTime() + 0.1
	end

	if postround then return end

	local watching = false

	local ply = self.Owner
	local obb_bot, obb_top = ply:GetModelBounds()
	local obb_mid = ( obb_bot + obb_top ) / 2

	obb_bot.x = obb_mid.x
	obb_bot.y = obb_mid.y
	obb_bot.z = obb_bot.z + 10

	obb_top.x = obb_mid.x
	obb_top.y = obb_mid.y
	obb_top.z = obb_bot.z - 10

	local top, mid, bot = ply:LocalToWorld( obb_top ), ply:LocalToWorld( obb_mid ), ply:LocalToWorld( obb_bot )
	local mask = MASK_BLOCKLOS_AND_NPCS

	for k, v in pairs( player.GetAll() ) do
		if IsValid( v ) and v:GTeam() != TEAM_SPEC and v:GTeam() != TEAM_SCP and v:Alive() and v.canblink and !v.scp173allow and !v.isblinking then
			local eyepos = v:EyePos()
			local eyevec = v:EyeAngles():Forward()

			local mid_z = mid:Copy()
			mid_z.z = mid_z.z + 17.5

			local line = ( mid_z - eyepos ):GetNormalized()
			local angle = math.acos( eyevec:Dot( line ) )

			if angle <= 0.8 then
				local trace_top = util.TraceLine( {
					start = eyepos,
					endpos = top,
					filter = { ply, v },
					mask = mask
				} )

				local trace_mid = util.TraceLine( {
					start = eyepos,
					endpos = mid,
					filter = { ply, v },
					mask = mask
				} )

				local trace_bot = util.TraceLine( {
					start = eyepos,
					endpos = bot,
					filter = { ply, v },
					mask = mask
				} )

				if !trace_top.Hit and !trace_mid.Hit and !trace_bot.Hit then
					watching = true
					break
				end
			end
		end
	end

	if watching then
		ply:Freeze( true )
	else
		ply:Freeze( false )
	end
	/*local watching = 0
	for k,v in pairs(player.GetAll()) do
		if IsValid(v) and v:GTeam() != TEAM_SPEC and v:Alive() and v != self.Owner and v.canblink then
			local tr_eyes = util.TraceLine( {
				start = v:EyePos() - v:EyeAngles():Forward() * 5,
				//start = v:LocalToWorld( v:OBBCenter() ),
				//start = v:GetPos() + (self.Owner:EyeAngles():Forward() * 5000),
				endpos = self.Owner:EyePos() - self.Owner:EyeAngles():Forward() * 5,
				//filter = v
			} )

			/*local tr_center = util.TraceLine( {
				start = v:LocalToWorld( v:OBBCenter() ),
				endpos = self.Owner:LocalToWorld( self.Owner:OBBCenter() ),
				filter = v
			} )*/

			/*if tr_eyes.Entity == self.Owner then//tr_center.Entity == self.Owner then
				//self.Owner:PrintMessage(HUD_PRINTTALK, tostring(tr_eyes.Entity) .. " : " .. tostring(tr_center.Entity) .. " : " .. tostring(tr_center.Entity))
				if self:IsLookingAt( v ) and v.isblinking == false then
					if v.scp173allow and self.Owner:GetPos():DistToSqr( v:GetPos() ) > 62500 then
						continue
					end
					watching = watching + 1
					//if self:GetPos():Distance(v:GetPos()) > 100 then
						//self.Owner:PrintMessage(HUD_PRINTTALK, v:Nick() .. " is looking at you")
					//end 
				end
			end
		end
	end
	if watching > 0 then
		self.Owner:Freeze(true)
	else
		self.Owner:Freeze(false)
	end*/
end

function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end

	if self.NextAttackW > CurTime() then return end
	self.NextAttackW = CurTime() + self.AttackDelay

	if SERVER then
		//if self.Owner:IsFlagSet( FL_FROZEN ) then return end

		local ent = nil
		local tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 100 ),
			filter = self.Owner,
			mins = Vector( -10, -10, -10 ),
			maxs = Vector( 10, 10, 10 ),
			mask = MASK_SHOT_HULL
		} )
		ent = tr.Entity
		if IsValid(ent) then
			if ent:IsPlayer() then
				if ent:GTeam() == TEAM_SCP then return end
				if ent:GTeam() == TEAM_SPEC then return end
				ent:Kill()
				self.Owner:AddExp(175, true)
				roundstats.snapped = roundstats.snapped + 1
				ent:EmitSound( "snap.wav", 500, 100 )
			else
				if ent:GetClass() == "func_breakable" then
					ent:TakeDamage( 100, self.Owner, self.Owner )
				end
			end
		end
	end
end

SWEP.NextSpecial = 0
function SWEP:SecondaryAttack()
	local time = 5
	if self.NextSpecial > CurTime() then return end
	self.NextSpecial = CurTime() + self.SpecialDelay
	if CLIENT then
		surface.PlaySound("Horror2.ogg")
	end
	local findents = ents.FindInSphere( self.Owner:GetPos(), 600 )
	local foundplayers = {}
	for k,v in pairs(findents) do
		if v:IsPlayer() then
			if !(v:GTeam() == TEAM_SCP or v:GTeam() == TEAM_SPEC or v.Using714 ) then
				if v.usedeyedrops == false then
					table.ForceInsert(foundplayers, v)
				end
			end
		end
	end
	if #foundplayers > 0 then
		local fixednicks = "Blinded: "
		if CLIENT then return end
		local numi = 0
		for k,v in pairs(foundplayers) do
			numi = numi + 1
			
			if numi == 1 then
				fixednicks = fixednicks .. v:Nick()
			elseif numi == #foundplayers then
				fixednicks = fixednicks .. " and " .. v:Nick()
			else
				fixednicks = fixednicks .. ", " .. v:Nick()
			end
			v:SendLua( 'surface.PlaySound("Horror2.ogg")' )
			net.Start("PlayerBlink")
				net.WriteFloat(time)
			net.Send(v)
			v.isblinking = true
			v.blinkedby173 = true
		end
		self.Owner:PrintMessage(HUD_PRINTTALK, fixednicks)
		timer.Create("UnBlinkTimer173", time + 0.2, 1, function()
			for k,v in pairs(player.GetAll()) do
				if v.blinkedby173 then
					v.isblinking = false
					v.blinkedby173 = false
				end
			end
		end)
	end
end

function SWEP:DrawHUD()
	if disablehud == true then return end
	local showtext = ""
	local showtextlook = self.Lang.HUD.nlook
	local lookcolor = Color(0,255,0)
	local showcolor = Color(17, 145, 66)
	if self.NextSpecial > CurTime() then
		showtext = self.Lang.HUD.specCD.." "..math.Round(self.NextSpecial - CurTime())
		showcolor = Color(145, 17, 62)
	else
		showtext = self.Lang.HUD.specReady
	end
	if self.Watching < CurTime() then
		self.CColor = Color(255,0,0)
		showtextlook = self.Lang.HUD.slook
		lookcolor = Color(145, 17, 62)
	else
		self.CColor = Color(0,255,0)
	end
	
	draw.Text( {
		text = showtext,
		pos = { ScrW() / 2, ScrH() - 50 },
		font = "173font",
		color = showcolor,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	})
	
	draw.Text( { 
		text = showtextlook,
		pos = { ScrW() / 2, ScrH() - 25 },
		font = "173font",
		color = lookcolor,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	})
	
	local x = ScrW() / 2.0
	local y = ScrH() / 2.0

	local scale = 0.3
	surface.SetDrawColor( self.CColor.r, self.CColor.g, self.CColor.b, 255 )
	
	local gap = 5
	local length = gap + 20 * scale
	surface.DrawLine( x - length, y, x - gap, y )
	surface.DrawLine( x + length, y, x + gap, y )
	surface.DrawLine( x, y - length, x, y - gap )
	surface.DrawLine( x, y + length, x, y + gap )
end

/*function SWEP:DrawWorldModel()
	if !IsValid( self.SantasHat ) then return end
	local boneid = self.Owner:LookupBone( "joint1" )
	if not boneid then
		return
	end

	local matrix = self.Owner:GetBoneMatrix( boneid )
	if not matrix then
		return
	end

	local newpos, newang = LocalToWorld( self.SantasHatPositionOffset, self.SantasHatAngleOffset, matrix:GetTranslation(), matrix:GetAngles() )

	self.SantasHat:SetPos( newpos )
	self.SantasHat:SetAngles( newang )
	self.SantasHat:SetupBones()
	self.SantasHat:DrawModel()
end*/
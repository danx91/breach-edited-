AddCSLuaFile()

SWEP.PrintName		= "SCP-689"

SWEP.ViewModelFOV 		= 56
SWEP.Spawnable 			= false
SWEP.AdminOnly 			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Delay       	=  15
SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo			= "None"
SWEP.Sound					= "scp/689/689Attack.ogg"

SWEP.ISSCP 				= true
SWEP.droppable			= false
SWEP.CColor				= Color(0,255,0)
SWEP.teams				= {1}

SWEP.Weight				= 3
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom	= false
SWEP.Slot				= 0
SWEP.SlotPos				= 4
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair		= true
SWEP.ViewModel			= ""
SWEP.WorldModel		= ""
SWEP.IconLetter			= "w"
SWEP.HoldType 			= "normal"

SWEP.Targets = {}

function SWEP:SetupDataTables()
	self:NetworkVar( "Entity", 0, "NCurTarget" )
	self:SetNCurTarget( nil )
end

function SWEP:Deploy()
	if self.Owner:IsValid() then
		self.Owner:DrawWorldModel( false )
		self.Owner:DrawViewModel( false )
	end
end

SWEP.Lang = nil

function SWEP:Initialize()
	if CLIENT then
		self.Lang = GetWeaponLang().SCP_689
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
	self:SetHoldType(self.HoldType)
end

function SWEP:Holster()
	return true
end

SWEP.ntabupdate = 0

function SWEP:Think()
	if postround or preparing then return end
	if self.ntabupdate < CurTime() then
		self.ntabupdate = CurTime() + 1 --delay for performance
		if SERVER then
			net.Start( "689" )
				net.WriteTable( self.Targets )
			net.Send( self.Owner )
		end
	end
	if CLIENT then return end
	for k, v in pairs( self.Targets ) do
		if !IsValid( v ) or !v:Alive() or v:GTeam() == TEAM_SPEC or v:GTeam() == TEAM_SCP or v.Using714 then
			table.RemoveByValue(self.Targets, v)
		end
	end
	for k, v in pairs( player.GetAll() ) do
		if v != self.Owner and !table.HasValue( self.Targets, v ) and !v.Using714 then
			if v:IsPlayer() and v:GTeam() != TEAM_SPEC and v:GTeam() != TEAM_SCP then
				local treyes = util.TraceLine( {
					start = v:EyePos(),
					endpos = self.Owner:EyePos(),
					mask = MASK_SHOT_HULL,
					filter = { v, self.Owner }
				} )
				local trpos = util.TraceLine( {
					start = v:EyePos(),
					endpos = self.Owner:GetPos(),
					mask = MASK_SHOT_HULL,
					filter = { v, self.Owner }
				} )
				if !treyes.Hit or !trpos.Hit then
					local trnormal = !treyes.Hit and treyes.Normal or !trpos.Hit and trpos.Normal
					local eyenormal = v:EyeAngles():Forward()
					if eyenormal:Dot( trnormal ) > 0.70 then
						table.insert( self.Targets, v )
					end
				end
			end
		end
	end
end

SWEP.NextPrimary = 0

function SWEP:PrimaryAttack()
	if preparing or postround then return end
	//if not IsFirstTimePredicted() then return end
	if #self.Targets < 1 then return end
	if self.NextPrimary > CurTime() then return end
	self.NextPrimary = CurTime() + self.Primary.Delay
	if SERVER then
		local at = self:GetNCurTarget()
		if !table.HasValue( self.Targets, at ) then at = nil print( "689 tried to attack invalid entity!" ) end
		if !IsValid( at ) then
			at = table.Random(self.Targets)
			self:SetNCurTarget( at )
		end
		self.Owner:EmitSound(self.Sound)
		at:EmitSound(self.Sound)
		timer.Create("CheckTimer"..self.Owner:SteamID64(), 0.5, math.floor(self.Primary.Delay), function()
			if !( IsValid( self.Owner ) and self.Owner:Alive() and IsValid( at ) and at:Alive() and at:GTeam() != TEAM_SPEC ) or at.Using714 then
				timer.Destroy("CheckTimer")
				timer.Destroy("KillTimer")
			end
		end )
		timer.Create("KillTimer"..self.Owner:SteamID64(), math.floor(self.Primary.Delay / 2), 1, function()
			if IsValid(self.Owner) and self.Owner:Alive() and IsValid(at) and at:Alive() and at:GTeam() != TEAM_SPEC then
				local pos = at:GetPos()
				at:Kill()
				self.Owner:SetPos(pos)
				self.Owner:AddExp(125, true)
				table.RemoveByValue(self.Targets, at)
				self:SetNCurTarget( nil )
			end
		end )
	end
end

function SWEP:SecondaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if SERVER then
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
		if !IsValid(ent) then return end
		if ent:GetClass() == "func_breakable" then
			ent:TakeDamage( 100, self.Owner, self.Owner )
		end
	end
end

SWEP.LastReload = 0

function SWEP:Reload()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if self.NextPrimary > CurTime() then return end
	if self.LastReload > CurTime() then return end
	self.LastReload = CurTime() + 0.25
	local CurTarget = self:GetNCurTarget()
	if !IsValid( CurTarget ) then
		self:SetNCurTarget( self.Targets[1] )
		return
	end
	for i, v in ipairs( self.Targets ) do
		if v == CurTarget then
			if i == #self.Targets then self:SetNCurTarget( self.Targets[1] ) return end
			self:SetNCurTarget( self.Targets[i + 1] ) 
			return
		end
	end
end

function SWEP:DrawHUD()
	if disablehud == true then return end
	
	local showtext = self.Lang.HUD.attackReady
	local showcolor = Color(0,255,0)
	
	if self.NextPrimary > CurTime() then
		showtext = self.Lang.HUD.attackCD.." ".. math.Round(self.NextPrimary - CurTime())
		showcolor = Color(255,0,0)
	end
	
	draw.Text( {
		text = showtext,
		pos = { ScrW() / 2, ScrH() - 30 },
		font = "173font",
		color = showcolor,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	})
	if #self.Targets > 0 then
		draw.Text( {
			text = self.Lang.HUD.targets..":",
			pos = { ScrW() * 0.97, ScrH() / 3 - 35 },
			font = "173font",
			color = showcolor,
			xalign = TEXT_ALIGN_RIGHT,
			yalign = TEXT_ALIGN_CENTER,
		})
	end
	for i, v in ipairs( self.Targets ) do
		local add = v == self:GetNCurTarget() and "> " or ""
		draw.Text( {
			text = add..v:GetName(),
			pos = { ScrW() * 0.99, ScrH() / 3 + i * 25 },
			font = "173font",
			color = showcolor,
			xalign = TEXT_ALIGN_RIGHT,
			yalign = TEXT_ALIGN_CENTER,
		})
	end
end

function isInTable( element, tab )
	for k, v in pairs( tab ) do
		if v == element then return true end
	end
	return false
end
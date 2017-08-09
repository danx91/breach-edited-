AddCSLuaFile()

if CLIENT then
	SWEP.WepSelectIcon 	= surface.GetTextureID("breach/wep_snav_ult")
	SWEP.BounceWeaponIcon = false
end

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/mishka/models/snav.mdl"
SWEP.WorldModel		= "models/mishka/models/snav.mdl"
SWEP.PrintName		= "S-Nav Ultimate"
SWEP.Slot			= 1
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= false
SWEP.HoldType		= "normal"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false

SWEP.droppable				= true
SWEP.teams					= {2,3,5,6}

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			=  "none"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo			=  "none"
SWEP.Secondary.Automatic	=  false

SWEP.Enabled = false
SWEP.NextChange = 0
function SWEP:Deploy()
	self.Owner:DrawViewModel( false )
end
function SWEP:DrawWorldModel()
	if !IsValid(self.Owner) then
		self:DrawModel()
	end
end

SWEP.Lang = nil

function SWEP:Initialize()
	if CLIENT then
		self.Lang = GetWeaponLang().SNAV_ULT
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
	self:SetHoldType(self.HoldType)
end

function SWEP:CalcView( ply, pos, ang, fov )
	if self.Enabled then
		ang = Vector(90,0,0)
		pos = pos + Vector(0,0,900)
		fov = 90
	end
	return pos, ang, fov
end

SWEP.warnings = {}
SWEP.scps = {}
SWEP.toshow = {}
SWEP.ScanDelay = 0
function SWEP:Think()
	if CLIENT then
		if self.Enabled then
			for k,v in pairs(player.GetAll()) do
				v:SetNoDraw( true )
			end
		else
			for k,v in pairs(player.GetAll()) do
				v:SetNoDraw( false )
			end
		end
		if self.ScanDelay > CurTime() then return end
		self.ScanDelay = CurTime() + 1
		self.warnings = {}
		self.scps = {}
		self.toshow = {}
		local lp = LocalPlayer()
		for k,v in pairs(ents.FindInSphere( lp:GetPos(), 1000 )) do
			if v:IsPlayer() then
				if v == lp then continue end
				if v:GTeam() != TEAM_SPEC then
					if v:GTeam() == TEAM_GUARD then
						table.ForceInsert(self.warnings, self.Lang.mtfdetect)
						continue
					elseif v:GTeam() == TEAM_CHAOS then
						if lp:GTeam() == TEAM_CHAOS then
							table.ForceInsert(self.warnings, self.Lang.cidetect)
							continue
						else
							table.ForceInsert(self.warnings, self.Lang.mtfdetect)
							continue
						end
					elseif v:GTeam() == TEAM_SCI then
						table.ForceInsert(self.warnings, self.Lang.resdetect)
						continue
					elseif v:GTeam() == TEAM_CLASSD then
						table.ForceInsert(self.warnings, self.Lang.ddetect)
						continue
					elseif v:GTeam() == TEAM_SCP then
						if not v.GetNClass then
							player_manager.RunClass( v, "SetupDataTables" )
						end
						--table.ForceInsert(self.warnings, v:GetNClass().." "..self.Lang.detect)
						table.ForceInsert( self.scps, v )
					else
						table.ForceInsert(self.warnings, self.Lang.unkdetect)
					end
				end
			elseif v:IsWeapon() then
				local found = false
				local nowarn = false
				if IsValid(v.Owner) then
					found = true
				end
				/*if v.ISSCP != nil then
					if v.ISSCP == true then
						table.ForceInsert( self.scps, v )
						found = true
						nowarn = true
					end
				end*/
				if !found then
					table.ForceInsert(self.toshow, v)
					if !nowarn then
						table.ForceInsert( self.warnings, language.GetPhrase( v:GetPrintName() ).." "..self.Lang.detect )
					end
				end
			end
		end
	end
end
function SWEP:Reload()
end
function SWEP:PrimaryAttack()
end
function SWEP:OnRemove()
	if CLIENT then
		for k,v in pairs(player.GetAll()) do
			v:SetNoDraw( false )
		end
	end
end
function SWEP:Holster()
	if CLIENT then
		for k,v in pairs(player.GetAll()) do
			v:SetNoDraw( false )
		end
	end
	return true
end
function SWEP:SecondaryAttack()
	if SERVER then return end
	if self.NextChange > CurTime() then return end
	self.Enabled = !self.Enabled
	self.NextChange = CurTime() + 0.25
end
function SWEP:CanPrimaryAttack()
end

function SWEP:DrawHUD()
	if self.Enabled then
		local w, h = ScrW(), ScrH()
		--surface.DrawCircle( w * 0.5, h * 0.5, 3, Color( 0, 255, 0, 255 ) )
		/*
		if BUTTONS != nil then
			for k,v in pairs(BUTTONS) do
				DrawInfo(v.pos, v.name, Color(0,255,50))
			end
			for k,v in pairs(SPAWN_KEYCARD2) do
				DrawInfo(v, "Keycard2", Color(255,255,0))
			end
			for k,v in pairs(SPAWN_KEYCARD3) do
				DrawInfo(v, "Keycard3", Color(255,120,0))
			end
			for k,v in pairs(SPAWN_KEYCARD4) do
				DrawInfo(v, "Keycard4", Color(255,0,0))
			end
			for k,v in pairs(SPAWN_ITEMS) do
				DrawInfo(v, "Item", Color(255,255,255))
			end
		end
		*/
		for k,v in pairs(self.toshow) do
			if IsValid(v) then
				if v:GetPos():Distance(LocalPlayer():GetPos()) < 400 then
					local pos = v:GetPos():ToScreen()
					local npos = v:GetPos()
					npos.x = npos.x - 25
					DrawInfo(npos, v:GetPrintName(), Color(255,255,255))
					surface.DrawCircle( pos.x, pos.y, 3, Color( 0, 255, 0, 255 ) )
				end
			end
		end
		if #self.warnings > 0 then
			draw.Text( {
				text = self.Lang.items,
				pos = { ScrW() * 0.8, ScrH() * 0.4 - 25 },
				font = "173font",
				color = Color(150,0,150),
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
			})
		end
		for i,v in ipairs(self.warnings) do
			draw.Text( {
				text = v,
				pos = { ScrW() * 0.9, ScrH() * 0.4 + i * 25 },
				font = "173font",
				color = Color(200,0,100),
				xalign = TEXT_ALIGN_RIGHT,
				yalign = TEXT_ALIGN_CENTER,
			})
		end
		if #self.scps > 0 then
			draw.Text( {
				text = "SCP:",
				pos = { ScrW() * 0.5, ScrH() * 0.045 },
				font = "173font",
				color = Color(255,0,0),
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
			})
		end
		for i, v in ipairs( self.scps ) do
			if IsValid( v ) then
				draw.Text( {
					text = v:GetNClass(),
					pos = { ScrW() * 0.5, ScrH() * 0.05 + i * 25 },
					font = "173font",
					color = Color(255,0,0),
					xalign = TEXT_ALIGN_CENTER,
					yalign = TEXT_ALIGN_CENTER,
				})
				--surface.DrawRect( v:GetPos():ToScreen().x - 10, v:GetPos():ToScreen().y - 10, 20, 20 )
				--local dist = self.Owner:GetPos():Distance( v:GetPos() )
				local dist = distance( self.Owner:GetPos():ToScreen(), v:GetPos():ToScreen() )
				local r = math.ceil( dist / 100 ) * 100
				for i = 0, 3 do
					surface.DrawCircle( w * 0.5, h * 0.5, r - i, Color( 255, 255, 255, 255 ) )
				end
			end
		end
	end
end

function distance( coords1, coords2 )
	local dx, dy = coords1.x - coords2.x, coords1.y - coords2.y
	local dist = math.sqrt( math.pow( dx, 2 ) + math.pow( dy, 2 ), 2 )
	return dist
end
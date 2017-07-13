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
						table.ForceInsert(self.warnings, v:GetNClass().." "..self.Lang.detect)
					else
						table.ForceInsert(self.warnings, self.Lang.unkdetect)
					end
				end
			elseif v:IsWeapon() then
				local found = false
				if IsValid(v.Owner) then
					found = true
				end
				if v.ISSCP != nil then
					if v.ISSCP == true then
						found = true
					end
				end
				if !found then
					table.ForceInsert(self.toshow, v)
					table.ForceInsert(self.warnings, language.GetPhrase( v:GetPrintName() ).." "..self.Lang.detect)
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
				if v:GetPos():Distance(LocalPlayer():GetPos()) < 425 then
					DrawInfo(v:GetPos(), v:GetPrintName(), Color(255,255,255))
				end
			end
		end
		for i,v in ipairs(self.warnings) do
			draw.Text( {
				text = v,
				pos = { ScrW() / 2, ScrH() / 2 - ((i * -25) - 125) },
				font = "173font",
				color = Color(255,0,0),
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
			})
		end
	end
end




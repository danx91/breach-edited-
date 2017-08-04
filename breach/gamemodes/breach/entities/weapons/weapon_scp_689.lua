AddCSLuaFile()

SWEP.PrintName		= "SCP-689"

SWEP.ViewModelFOV 		= 56
SWEP.Spawnable 			= false
SWEP.AdminOnly 			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Delay       	=  16
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

function SWEP:Think()
	if postround or preparing then return end
	for k, v in pairs(self.Targets) do
		if !v:Alive() or v:GTeam() == TEAM_SPEC or v:GTeam() == TEAM_SCP or v.Using714 then table.RemoveByValue(self.Targets, v) end
	end
//	table.sort(self.Targets)
	for k,v in pairs(player.GetAll()) do
		if IsValid(v) and v:GTeam() != TEAM_SPEC and v:Alive() and v != self.Owner and !v.Using714 and v.canblink then
			if !isInTable( v, self.Targets ) then 
				local tr_eyes = util.TraceLine( {
					start = v:EyePos() + v:EyeAngles():Forward() * 15,
					endpos = self.Owner:EyePos()
				} )
				local tr_center = util.TraceLine( {
					start = v:LocalToWorld( v:OBBCenter() ),
					endpos = self.Owner:LocalToWorld( self.Owner:OBBCenter() ),
					filter = v
				} )
				if tr_eyes.Entity == self.Owner or tr_center.Entity == self.Owner then
					if self:IsLookingAt( v ) == false then
						table.ForceInsert(self.Targets, v)
					end
				end
			end
		end
	end
end

function SWEP:IsLookingAt( ply )
	local yes = ply:GetAimVector():Dot( ( self.Owner:GetPos() - ply:GetPos() + Vector( 70 ) ):GetNormalized() )
	return (yes > 0.39)
end

SWEP.NextPrimary = 0
SWEP.CurTarget = nil

function SWEP:PrimaryAttack()
	if preparing or postround then return end
	//if not IsFirstTimePredicted() then return end
	if self.NextPrimary > CurTime() then return end
	self.NextPrimary = CurTime() + self.Primary.Delay
	if SERVER then
		if #self.Targets < 1 then return end
		self.CurTarget = table.Random(self.Targets)
		self.Owner:EmitSound(self.Sound)
		self.CurTarget:EmitSound(self.Sound)
		timer.Create("CheckTimer", 0.5, math.floor(self.Primary.Delay), function()
			if !(IsValid(self.Owner) and self.Owner:Alive() and IsValid(self.CurTarget) and self.CurTarget:Alive()) or self.CurTarget.Using714 then
				timer.Destroy("CheckTimer")
				timer.Destroy("KillTimer")
			end
		end )
		timer.Create("KillTimer", math.floor(self.Primary.Delay / 2), 1, function()
			if IsValid(self.Owner) and self.Owner:Alive() and IsValid(self.CurTarget) and self.CurTarget:Alive() then
				local pos = self.CurTarget:GetPos()
				self.CurTarget:Kill()
				self.Owner:SetPos(pos)
				self.Owner:AddExp(125, true)
				table.RemoveByValue(self.Targets, self.CurTarget)
				self.CurTarget = nil
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
end

function isInTable( element, tab )
	for k, v in pairs( tab ) do
		if v == element then return true end
	end
	return false
end
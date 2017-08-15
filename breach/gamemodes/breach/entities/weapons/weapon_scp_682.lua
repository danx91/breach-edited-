AddCSLuaFile()

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/vinrax/props/keycard.mdl"
SWEP.WorldModel		= "models/vinrax/props/keycard.mdl"

SWEP.PrintName		= "SCP-682"
SWEP.Slot				= 0
SWEP.SlotPos			= 0
SWEP.HoldType			= "normal"
SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true

SWEP.Primary.Ammo		= "none"
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic	= false

SWEP.Roar 				= "scp/682/roar.ogg"

SWEP.Secondary.Ammo		= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false

SWEP.DrawCrosshair 			= true

SWEP.ISSCP 		= true
SWEP.Teams			= { 1 }
SWEP.droppable		= false

function SWEP:Deploy()
	self.Owner:DrawViewModel( false )
	self.Owner:SetModelScale( 0.75 )
end

function SWEP:DrawWorldModel()
end

SWEP.Lang = nil

function SWEP:Initialize()
	if CLIENT then
		self.Lang = GetWeaponLang().SCP_682
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

function SWEP:OnRemove()
	self.Owner:SetModelScale( 1 )
end

function SWEP:HUDShouldDraw( element )
	local hide = {
		CHudAmmo = true,
		CHudSecondaryAmmo = true,
	}
	if hide[element] then return false end
	return true
end

SWEP.NextAttackW	= 0
SWEP.AttackDelay	= 4
SWEP.OnFuryCD = 0.7
function SWEP:PrimaryAttack()
	if preparing then return end
	if not IsFirstTimePredicted() then return end
	if self.NextAttackW > CurTime() then return end
	if CLIENT then return end
	local ent = nil
	local tr = util.TraceHull({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 75),
		mins = Vector(-10, -10, -10),
		maxs = Vector(10, 10, 10),
		filter = self.Owner,
		mask = MASK_SHOT,
	})
	ent = tr.Entity
	if IsValid(ent) then
		if ent:IsPlayer() then
			if ( ent:GTeam() == TEAM_SPEC or ent:GTeam() == TEAM_SCP ) then return end
				local rdmdmg = math.random(50, 100)
				ent:TakeDamage(rdmdmg, self.Owner, self.Owner)
			--ent:Kill()
			--self.Owner:AddExp(15, true)
			if self.fury == true then
				self.NextAttackW = CurTime() + self.OnFuryCD
			else
				self.NextAttackW = CurTime() + self.AttackDelay
				self:EmitSound( self.Roar )
			end
		else
			if ent:GetClass() == "func_breakable" then
				ent:TakeDamage( 100, self.Owner, self.Owner )
				self.NextAttackW = CurTime() + self.AttackDelay
			end
		end
	end
end

SWEP.NextSpeial = 0
SWEP.SpecialDelay = 45
SWEP.fury = false
function SWEP:SecondaryAttack()
	if self.NextSpeial > CurTime() then
		if SERVER then
			self.Owner:PrintMessage(HUD_PRINTTALK, "Special ability is on cooldown!")
		end
		return
	end
	self.NextSpeial = CurTime() + self.SpecialDelay
	
	local function applyEffect()
		self.fury = true
		self.NextAttackW = CurTime() + 0.5
		self:EmitSound( self.Roar )
		self.Owner:SetWalkSpeed(300)
		self.Owner:SetRunSpeed(300)
		self.Owner:SetMaxSpeed(300)
		self.Owner:SetJumpPower(300)
		local hp = self.Owner:Health()
		self.Owner:SetHealth( 9999 )
		return hp
	end
	
	local function removeEffect( hp, regen )
		self.fury = false
		self.Owner:SetWalkSpeed(115)
		self.Owner:SetRunSpeed(115)
		self.Owner:SetMaxSpeed(115)
		self.Owner:SetJumpPower(200)
		hp = hp + regen
		if hp > self.Owner:GetMaxHealth() then hp = self.Owner:GetMaxHealth() end
		self.Owner:SetHealth( hp )
	end
	
	local hp = applyEffect()
	timer.Create( "SCP_PLAYER_WILL_LOSE_BUFF", 7.5, 1, function()
		removeEffect( hp, 0 )
	end )
end

hook.Add("EntityTakeDamage", "AcidDamage", function(target, dmg)
	if not target:IsPlayer() then return end
	if not target:Alive() then return end
	if !IsValid( target:GetActiveWeapon() ) or target:GetActiveWeapon():GetClass() != "weapon_scp_682" then return end
	if dmg:GetDamageType() == DMG_ACID then
		if preparing then return true end
		dmg:ScaleDamage( 2.5 )
	end
end)

function SWEP:DrawHUD()
	if disablehud == true then return end
	
	local showtext = self.Lang.HUD.attackReady
	local showcolor = Color(0,255,0)
	
	if self.NextSpeial > CurTime() then
		showtext = self.Lang.HUD.attackCD.." ".. math.Round(self.NextSpeial - CurTime())
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
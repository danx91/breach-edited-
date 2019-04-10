AddCSLuaFile()

SWEP.Base 				= "weapon_scp_base"
SWEP.PrintName			= "SCP999"			

SWEP.Primary.Delay 		= 2
SWEP.Secondary.Delay 	= 5

SWEP.DrawCrosshair		= true
SWEP.HoldType 			= "normal"

function SWEP:Initialize()
	self:InitializeLanguage( "SCP_999" )

	self:SetHoldType(self.HoldType)
end

SWEP.NextPrimary = 0
function SWEP:PrimaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if CurTime() < self.NextPrimary then return end
	self.NextPrimary = CurTime() + self.Primary.Delay
	if SERVER then
		local tr = util.TraceHull({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 150,
			maxs = Vector(10, 10, 10),
			mins = Vector(-10, -10, -10),
			filter = self.Owner,
			mask = MASK_SHOT
		})
		local ent = tr.Entity
		if !IsValid(ent) then return end
		if ent:IsPlayer() then
			if ent:GTeam() != TEAM_SPEC then
				if ent:Health() == ent:GetMaxHealth() then return end
				local hp = ent:Health() + math.random(5, 10)
				if hp > ent:GetMaxHealth() then hp = ent:GetMaxHealth() end
				self.Owner:AddExp(20, false)
				ent:SetHealth(hp)
			end
		else
			self:SCPDamageEvent( ent, 10 )
		end
	end
end

SWEP.NextSecondary = 0
function SWEP:SecondaryAttack()
	if preparing or postround then return end
	if not IsFirstTimePredicted() then return end
	if CurTime() < self.NextSecondary then return end
	self.NextSecondary = CurTime() + self.Secondary.Delay
	if SERVER then
		local fent = ents.FindInSphere(self.Owner:GetPos(), 300)
		local hp = 0
		local totalheal = 0
		for k, v in pairs(fent) do
			if v:IsPlayer() then
				if v:GTeam() != TEAM_SPEC and v != self.Owner then
					hp = v:Health() + math.random(5, 15)
					if hp > v:GetMaxHealth() then hp = v:GetMaxHealth() end
					totalheal = totalheal + (hp - v:Health())
					v:SetHealth(hp)
					hp = 0
				end
			end
		end
		if totalheal > 0 then self.Owner:AddExp(totalheal, false) end
	end
end

function SWEP:DrawHUD()
	if disablehud == true then return end
	
	local showtext = self.Lang.HUD.ghealReady
	local showtext2 = self.Lang.HUD.healReady
	local showcolor = Color(0,255,0)
	local showcolor2 = Color(0,255,0)
	
	if self.NextSecondary > CurTime() then
		showtext = self.Lang.HUD.ghealCD.." ".. math.Round(self.NextSecondary - CurTime()).."s"
		showcolor = Color(255,0,0)
	end
	
	if self.NextPrimary > CurTime() then
		showtext2 = self.Lang.HUD.healCD.." "..math.Round(self.NextPrimary - CurTime()).."s"
		showcolor2 = Color(255,0,0)
	end
	
	draw.Text( {
		text = showtext,
		pos = { ScrW() / 2, ScrH() - 30 },
		font = "173font",
		color = showcolor,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	})
	
	draw.Text( {
		text = showtext2,
		pos = { ScrW() / 2, ScrH() - 60 },
		font = "173font",
		color = showcolor2,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	})
end
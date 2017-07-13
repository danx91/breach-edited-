if CLIENT then
	SWEP.WepSelectIcon 	= surface.GetTextureID("breach/wep_id")
	SWEP.BounceWeaponIcon = false
end

SWEP.PrintName = "ID tag"

SWEP.Category = "Passport" 
 
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Base = "weapon_base"

SWEP.UseHands = true

SWEP.ViewModelFOV = 54
SWEP.ViewModel = "models/weapons/kerry/passport_g.mdl"
SWEP.WorldModel = "models/weapons/kerry/w_garrys_pass.mdl"

SWEP.droppable		= false
SWEP.teams			= {2,3,5,6}

SWEP.Slot			= 0
SWEP.SlotPos		= 1

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
 
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "pistol"



SWEP.Lang = nil

function SWEP:Initialize()
	if CLIENT then
		self.Lang = GetWeaponLang().ID
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
	self:SetHoldType(self.HoldType)
	if CLIENT then	
		self.Passport = table.FullCopy( self.Passport )
		self:CreateModels( self.Passport )
	end
	self:SetupValue()
end

function validString( str )
	if string.len( str ) > 20 then
		return string.sub( str, 1, 20 )
	end
	return str
end

if CLIENT then
function SWEP:ViewModelDrawn()
	local vm = self.Owner:GetViewModel()
	if !IsValid(vm) then return end
		local bone = vm:LookupBone("PBase")
		if (!bone) then return end
		pos, ang = Vector(0,0,0), Angle(0,0,0)
		local m = vm:GetBoneMatrix(bone)
		if (m) then
			pos, ang = m:GetTranslation(), m:GetAngles()
		else
			return
		end
			ang:RotateAroundAxis(ang:Forward(),0)
			ang:RotateAroundAxis(ang:Right(), -130)
			ang:RotateAroundAxis(ang:Up(), 93)
			cam.Start3D2D(pos+ang:Right()*3+ang:Forward()*-1.80+ang:Up()*1.0, ang, 0.02)
			        draw.SimpleText(self.Lang.name, "PassHud2", 40, -50, Color(0,0,0,255))
					draw.SimpleText(self.Owner:Name() or "Unknown", "PassHud", 40, -40, Color(0,0,0,255))
					draw.SimpleText(self.Lang.city, "PassHud2", 40, 15, Color(0,0,0,255))
					draw.SimpleText(validString( GetHostName() ), "PassHud3", 40, 30, Color(0,0,0,255))
					draw.SimpleText("<G<<<<<<<<<<<"..self.Owner:SteamID().."<<<<", "PassHud2", -60, 60, Color(0,0,0,200))
					draw.SimpleText("<G<<<2281337<<<<777<<<<06<<<<<<<<<<", "PassHud2", -60, 75, Color(0,0,0,200))
					surface.SetDrawColor(255,255,255,250)
					surface.SetMaterial(self.mat_ply)
					surface.DrawTexturedRect( -40, -42, 80, 80 )
				cam.End3D2D()
end
end


if CLIENT then	
	SWEP.Passport = {
		["pass"] = { type = "Model", model = "models/weapons/kerry/w_garrys_pass.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6, 3.5, -0.6), angle = Angle(0, 90, 120), size = Vector(0.699, 0.699, 0.699), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["info_pass"] = { type = "Quad", bone = "ValveBiped.Bip01_R_Hand", rel = "pass", pos = Vector(0, 0, 0), angle = Angle(0, 0, 0), size = 0.5}
	}
	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()		
		if (!self.wRenderOrder) then
			self.wRenderOrder = {}
			for k, v in pairs( self.Passport) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end
		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.Passport[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.Passport, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.Passport, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end								
			elseif (v.type == "Quad") then
				if LocalPlayer():GetPos():Distance(self:GetPos()) >= 200 then return end				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * 0.08
				ang:RotateAroundAxis(ang:Up(), 180)
				
				cam.Start3D2D(drawpos, ang, 0.02)
				    draw.SimpleText(self.Lang.name, "PassHud2", 40, -50, Color(0,0,0,255))
					draw.SimpleText(self.Owner:Name() or "Unknown", "PassHud", 40, -40, Color(0,0,0,255))
					draw.SimpleText(self.Lang.city, "PassHud2", 40, 15, Color(0,0,0,255))
					draw.SimpleText(validString( GetHostName() ), "PassHud3", 40, 30, Color(0,0,0,255))
					draw.SimpleText("<G<<<<<<<<<<<"..self.Owner:SteamID().."<<<<", "PassHud2", -60, 60, Color(0,0,0,200))
					draw.SimpleText("<G<<<2281337<<<<777<<<<06<<<<<<<<<<", "PassHud2", -60, 75, Color(0,0,0,200))
					surface.SetDrawColor(255,255,255,250)
					surface.SetMaterial(self.mat_ply)
					surface.DrawTexturedRect( -40, -42, 80, 80 )
				cam.End3D2D()
			end
			
		end
		
	end
	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)
			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
		
		end
		
		return pos, ang
	end
	function SWEP:CreateModels( tab )
		if (!tab) then return end
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end				
			end
		end		
	end
	
	function table.FullCopy( tab )
		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:SetupValue()
	if not IsValid(self.Owner) then return end
	if not self.Owner:IsBot() then end
	if self.Owner:GTeam() == TEAM_GUARD then
		self.mat_ply = Material("breach/mtf.png")
	elseif self.Owner:GTeam() == TEAM_CHAOS then
		if self.Owner:GetNClass() == ROLES.ROLE_CHAOSSPY then
			self.mat_ply = Material("breach/mtf.png")
		else
			self.mat_ply = Material("breach/ci.png")
		end
	else
		self.mat_ply = Material("spawnicons/" .. string.gsub(self.Owner:GetModel(), ".mdl", ".png"))
	end
end


function SWEP:Holster()
	self:SetupValue()
	return true
end
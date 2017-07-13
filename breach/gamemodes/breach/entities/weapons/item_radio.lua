AddCSLuaFile()

if CLIENT then
	SWEP.WepSelectIcon 	= surface.GetTextureID("breach/wep_radio")
	SWEP.BounceWeaponIcon = false
end

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/mishka/models/radio.mdl"
SWEP.WorldModel		= "models/mishka/models/radio.mdl"
SWEP.PrintName		= "Radio"
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

SWEP.Channel = 1
SWEP.Enabled = false
SWEP.NextChange = 0
SWEP.IsPlayingFor = nil
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
		self.Lang = GetWeaponLang().RADIO
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
	self:SetHoldType(self.HoldType)
	self:SetSkin(1)
end

function SWEP:PlaySound(name, volume, looping)
	if CLIENT then
		//print("Starting playing a sound " .. name .. " with volume: " .. tostring(volume) .. " and looping is: " .. tostring(looping))
		sound.PlayFile( name, "mono noblock", function( station, errorID, errorName )
			if ( IsValid( station ) ) then
				station:SetPos( LocalPlayer():GetPos() )
				station:SetVolume( volume )
				if looping then
					station:EnableLooping( looping )
					station:SetTime( 360 )
				end
				station:Play()
				LocalPlayer().channel = station
			else
				print("station not found")
				print(errorName)
			end
		end )
	end
end

function SWEP:RemoveSounds()
	if CLIENT then
		if LocalPlayer().channel != nil then
			LocalPlayer().channel:EnableLooping( false )
			LocalPlayer().channel:Stop()
			LocalPlayer().channel = nil
		end
	end
end

function SWEP:StopSounds()
	if CLIENT then
		if LocalPlayer().channel != nil then
			//LocalPlayer().channel:EnableLooping( false )
			LocalPlayer().channel:SetVolume(0)
			//LocalPlayer().channel = nil
		end
	end
end

SWEP.LastSound = 0
function SWEP:CheckSounds()
	if CLIENT then
		local r = "sound/radio/"
		if self.Channel == 1 then
			self:PlaySound(r .. "radioalarm.ogg", 1, true)
			self.IsLooping = true
		elseif self.Channel == 2 then
			self:PlaySound(r .. "radioalarm2.ogg", 1, false)
			self.NextSoundCheck = CurTime() + 12
			self.IsLooping = false
		elseif self.Channel == 3 then
			self.LastSound = self.LastSound + 1
			if self.LastSound == 0 then
				self.NextSoundCheck = CurTime() + 24
			elseif self.LastSound == 1 then
				self.NextSoundCheck = CurTime() + 15
			elseif self.LastSound == 2 then
				self.NextSoundCheck = CurTime() + 21
			elseif self.LastSound == 3 then
				self.NextSoundCheck = CurTime() + 25
			elseif self.LastSound == 4 then
				self.NextSoundCheck = CurTime() + 28
			elseif self.LastSound == 5 then
				self.NextSoundCheck = CurTime() + 35
			elseif self.LastSound == 6 then
				self.NextSoundCheck = CurTime() + 46
			elseif self.LastSound == 7 then
				self.NextSoundCheck = CurTime() + 20
			elseif self.LastSound == 8 then
				self.NextSoundCheck = CurTime() + 24
			elseif self.LastSound == 9 then
				self.LastSound = 0
				self.NextSoundCheck = CurTime() + 24
			end
			local sound = "scpradio" .. self.LastSound
			self:PlaySound(r .. sound .. ".ogg", 1, false)
			self.IsLooping = false
		elseif self.Channel == 4 then
			if #RADIO4SOUNDS > 0 then
				if math.random(1,4) == 4 then
					local rndtbl = table.Random(RADIO4SOUNDS)
					//print("playing " .. rndtbl[1])
					self:PlaySound(r .. rndtbl[1] .. ".ogg", 1, false)
					self.NextSoundCheck = CurTime() + rndtbl[2] + 5
					self.IsLooping = false
					table.RemoveByValue(RADIO4SOUNDS, rndtbl)
				else
					//print("waiting 5 secs")
					self.NextSoundCheck = CurTime() + 5
					self.IsLooping = false
				end
			else
				self.IsLooping = true
			end
		end
	end
end

SWEP.IsLooping = false
SWEP.NextSoundCheck = 0
function SWEP:Think()
	if SERVER then return end
	if self.Enabled then
		if self.IsLooping == false then
			if self.NextSoundCheck < CurTime() then
				self:CheckSounds()
			end
		end
	end
end
function SWEP:Reload()
end
function SWEP:PrimaryAttack()
	if self.NextChange > CurTime() then return end
	self.Channel = self.Channel + 1
	if self.Channel > 10 then
		self.Channel = 1
	end
	self.IsLooping = false
	self:RemoveSounds()
	if self.Enabled then
		self:CheckSounds()
	end
	self.NextChange = CurTime() + 0.1
end
function SWEP:OnRemove()
	if CLIENT then
		self.IsLooping = false
		self:StopSounds()
		self.Enabled = false
	end
end
function SWEP:Holster()
	//if CLIENT then
	//	self.IsLooping = false
	//	self:StopSounds()
	//	self.Enabled = false
	//end
	return true
end
function SWEP:SecondaryAttack()
	if self.NextChange > CurTime() then return end
	self.Enabled = !self.Enabled
	self.NextChange = CurTime() + 0.1
	if CLIENT then
		if self.Enabled then
			//self:CheckSounds()
			if IsValid(LocalPlayer().channel) then
				LocalPlayer().channel:SetVolume(1)
			end
		else
			self:StopSounds()
		end
	end
	//self.Owner.RadioEnabled = self.Enabled
	//print(self.NextChange)
	//print(self.Owner:Nick() .. " " .. tostring(self.Enabled))
end
function SWEP:CanPrimaryAttack()
end

local ourMat = Material( "breach/RadioHUD.png" )
function SWEP:DrawHUD()
	if disablehud == true then return end
	local rw = ScrW() / 7.6
	local rh = (rw * 2) * 1.1
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( ourMat	)
	surface.DrawTexturedRect( ScrW() - rw, ScrH() - rh, rw, rh )
	local showtext = ""
	local showcolor = Color(17, 145, 66)
	
	if self.Enabled then
		showtext = self.Lang.channel.." "..self.Channel
		showcolor = Color(0, 255, 0)
	else
		showtext = self.Lang.disabled
		showcolor = Color(255, 0, 0)
	end
	showcolor = color_white
	//local rx = ScrW() - rw
	//local ry = ScrH() - rh
	local rx = ScrW() / 2
	local ry = ScrH() / 2 + 50
	draw.Text( {
		text = showtext,
		//pos = { rx + 52, ry * 1.79 },
		pos = { rx + 2, ry + 2},
		font = "RadioFont",
		color = color_black,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	})
	draw.Text( {
		text = showtext,
		//pos = { rx + 52, ry * 1.79 },
		pos = { rx, ry },
		font = "RadioFont",
		color = showcolor,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	})
end




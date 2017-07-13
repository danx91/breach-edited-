local HBAP = 0
local HBAY = 0
local HBAR = 0
local HBPX = 0
local HBPY = 0
local HBPZ = 0
local HBEnabled = true

function HeadBob(pl, pos, ang, fov)
	if HBEnabled == false then return end
	local view = {}
	view.pos = pos
	view.ang = ang
	view.fov = fov
	
	local speedmul = (pl:GetVelocity():Length() / 100) / 3
	//print(speedmul)
	//chat.AddText(tostring(speedmul))
	
	if pl:IsOnGround() && HBEnabled  then
		
		if pl:KeyDown(IN_FORWARD) || pl:KeyDown(IN_BACK) || pl:KeyDown(IN_MOVELEFT) || pl:KeyDown(IN_MOVERIGHT) then
			HBPZ = HBPZ + (10 / 1) * FrameTime()
		end
	
		if pl:KeyDown(IN_FORWARD) then
			if HBAP < 1.5 then
				HBAP = HBAP + 0.05 * speedmul
			end
		else
			if HBAP > 0 then
				HBAP = HBAP - 0.05 * speedmul
			end
		end
		
		if pl:KeyDown(IN_BACK) then
			if HBAP > -1.5 then
				HBAP = HBAP - 0.05 * speedmul
			end
		else
			if HBAP < 0 then
				HBAP = HBAP + 0.05 * speedmul
			end
		end
		
		if pl:KeyDown(IN_MOVELEFT) then
			if HBAR > -1.5 then
				HBAR = HBAR - 0.07 * speedmul
			end
		else
			if HBAR < 0 then
				HBAR = HBAR + 0.07 * speedmul
			end
		end
		
		if pl:KeyDown(IN_MOVERIGHT) then
			if HBAR < 1.5 then
				HBAR = HBAR + 0.07 * speedmul
			end
		else
			if HBAR > 0 then
				HBAR = HBAR - 0.07 * speedmul
			end
		end
	end
	
	//if !pl:GetActiveWeapon():GetNWBool("Ironsights") then
		pl.OLDANG = view.ang
		pl.OLDPOS = view.pos
		view.ang.pitch = view.ang.pitch + HBAP * speedmul
		view.ang.roll = view.ang.roll + HBAR * 0.8 * speedmul
		view.pos.z = view.pos.z - math.cos(HBPZ * 0.7)
	//end
	
	return GAMEMODE:CalcView(pl, view.pos, view.ang, view.fov)
end
hook.Add("CalcView", "HeadBobbing", HeadBob)

function ToggleHB(ply)
	if HBEnabled == false then
		print("Head Bobbing enabled")
		HBEnabled = true
	else
		print("Head Bobbing disabled")
		HBEnabled = false
	end
end
concommand.Add("br_headbobbing",ToggleHB)




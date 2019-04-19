local CW_WEP_DMG = {
	cw_fiveseven = 20,
	cw_deagle = 35,
	cw_mp5 = 13,
	cw_ump45 = 16,
	cw_g36c = 20,
	cw_scarh = 22.5,
	cw_m14 = 25,
	cw_ar15 = 10,
	cw_ak74 = 14,
	cw_l115 = 90,
	cw_shorty = 6,
	cw_m3super90 = 4,
}

local handlers = {}

function registerDMGHandler( handler )
	table.insert( handlers, handler )
end

function applyDMGMods()
	for i, v in ipairs( handlers ) do
		v()
	end
end

registerDMGHandler( function()
	for k, v in pairs( CW_WEP_DMG ) do
		local wep_tab = weapons.GetStored( k )
		wep_tab.Damage = v
	end
end )

timer.Simple( 0, function()
	applyDMGMods()
end )
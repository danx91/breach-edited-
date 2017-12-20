WEP_DMG = {
	fiveseven = 9,
	deagle = 17,
	mp5 = 6,
	ump45 = 7,
	g36c = 8,
	scarh = 9,
	m14 = 10,
	ar15 = 7,
	ak74 = 8,
	l115 = 90,
	shorty = 4,
	super90 = 3.5,
}

function GetTableOverride( tab )
	local metatable = {
		__add = function( left, right )
			return AddTables( left, right )
		end
	}
	setmetatable( tab, metatable )
	return tab
end

/*function AddTables( tab1, tab2 )
	local returnTable = tab1
	for k, v in pairs( tab2 ) do
		returnTable[k] = v
	end
	return returnTable
end*/
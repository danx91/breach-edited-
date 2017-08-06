WEP_DMG = {
	fiveseven = 9,
	deagle = 20,
	mp5 = 6,
	ump45 = 7,
	g36c = 9,
	scarh = 10,
	m14 = 12,
	ar15 = 9,
	ak74 = 10,
	l115 = 125,
	shorty = 4.5,
	super90 = 4,
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

function AddTables( tab1, tab2 )
	local returnTable = tab1
	for k, v in pairs( tab2 ) do
		returnTable[k] = v
	end
	return returnTable
end
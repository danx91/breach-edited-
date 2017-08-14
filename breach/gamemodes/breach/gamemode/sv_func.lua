WEP_DMG = {
	fiveseven = 10,
	deagle = 18,
	mp5 = 7,
	ump45 = 8,
	g36c = 9,
	scarh = 10,
	m14 = 12,
	ar15 = 8,
	ak74 = 9,
	l115 = 100,
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
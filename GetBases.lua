local Link = 'https://raw.githubusercontent.com/Zanikes/Ayarum/master/'
local function GetFile(FileName)
	return loadstring('return ' .. game:HttpGet(Link .. FileName .. '.txt', true))()
end

local BaseList = {
	['America Town Base'] = GetFile('AmericaTown'),
	['America Base Revamp'] = GetFile('AmericaTownRevamp'),
	['Bunker Base'] = GetFile('BunkerBase'),
	['Cage'] = GetFile('Cage'),
	['Dave\'s House'] = GetFile('DavesHouse'),
	['Kin Tower'] = GetFile('KinTower'),
	['Large Cage'] = GetFile('LargeCage'),
	['MA Firestation'] = GetFile('MAFireStation'),
	['MA Extra'] = GetFile('MAExtra'),
	['Radio Tower'] = GetFile('RadioTower'),
	['TA Base'] = GetFile('TABase'),
	['Tower'] = GetFile('Tower'),
	['Weapons'] = GetFile('Weapons')
}

return BaseList
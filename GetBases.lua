local Link = 'https://ayarum.000webhostapp.com/Bases/'
local function GetFile(FileName)
	return loadstring('return ' .. game:HttpGet(Link .. FileName .. '.txt', true))()
end

local BaseList = {
	['Bunker Base'] = GetFile('BunkerBase'),
	['America Base'] = GetFile('AmericaTown'),
	['Tower'] = GetFile('Tower'),
	['Weapons'] = GetFile('Weapons'),
	['Kin Tower'] = GetFile('KinTower'),
	['Dave\'s House'] = GetFile('DavesHouse'),
	['Cage'] = GetFile('Cage'),
	['Large Cage'] = GetFile('LargeCage'),
	['Forever Part'] = GetFile('ForeverPart'),
	['Radio Tower'] = GetFile('RadioTower'),
	['MA Firestation'] = GetFile('MAFireStation'),
	['MA Extra'] = GetFile('MAExtra'),
	['Giant Cock & Balls'] = GetFile('pp'),
	['Amogus'] = GetFile('sussywussy'),
	['America Base v.2'] = GetFile('AmericaTown2'),
	['TA Base'] = GetFile('TABase')
}

return BaseList
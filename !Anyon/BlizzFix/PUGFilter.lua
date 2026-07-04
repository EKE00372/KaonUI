local filter = C_LFGList.GetDefaultLanguageSearchFilter() or {}
local filters = {"zhCN", "zhTW", "enUS", "esES", "ruRU", "koKR", "frFR", "deDE", "esMX", "ptBR", }

for i = 1, #filters do
	if not filter[filters[i]] then
		table.insert(filter, filters[i])
	end
end
	
C_LFGList.GetAvailableLanguageSearchFilter = function()
	return filter
end
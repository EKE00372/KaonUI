local _, ns = ...
local F = ns[2]

local separated = setmetatable({}, {__mode = "k"})

local function OnTooltipCleared(tooltip)
	separated[tooltip] = false
end

-- 分類與 ID 共用附加區；隨原生清行重設，append 或再次 Show 不重複分隔。
function F.AddTooltipSeparator(tooltip)
	if separated[tooltip] then return end
	if separated[tooltip] == nil then
		tooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
	end
	separated[tooltip] = true
	local count = tooltip:NumLines()
	if not issecretvalue(count) and count > 0 then
		tooltip:AddLine(" ")
	end
end

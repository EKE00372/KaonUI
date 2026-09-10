local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("BetterRaid", "BetterRaid")
local Ambiguate = Ambiguate
local type = type

local function IsCompactGroupUnit(unit)
	return unit == "player" or (type(unit) == "string" and (unit:match("^party%d+$") or unit:match("^raid%d+$")))
end

-------------------
-- 移除伺服器後綴 --
-------------------

local function RemoveRealmName(frame)
	-- 防止污染
	if frame:IsForbidden() or not frame.name then return end
	-- 只處理隊伍和團隊框架
	if not IsCompactGroupUnit(frame.unit) then return end
	-- 標記給後續的暴雪更新流程使用
	frame.hideRealmName = true
	-- 跳過沒名字的框體
	if not frame.name:IsShown() then return end
	-- 處理當前已經寫進 FontString 的文字
	local name = frame.name:GetText()
	local shortName = name and Ambiguate(name, "short")
	if shortName and shortName ~= name then
		frame.name:SetText(shortName)
	end
end

-----------------
-- 移除隊伍標題 --
-----------------

local function HideGroupTitle(frame)
	frame.title:Hide()
end

function M:OnEnable()
	hooksecurefunc("CompactUnitFrame_UpdateName", RemoveRealmName)
	-- 團隊的小隊標題
	hooksecurefunc("CompactRaidGroup_InitializeForGroup", HideGroupTitle)
	-- 團隊風格的小隊框體
	HideGroupTitle(CompactPartyFrame)
end

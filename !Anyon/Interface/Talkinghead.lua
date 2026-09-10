local _, ns = ...
local F = ns[2]
local M = F.RegisterModule("TalkingHead", "TalkingHead")

-- 12.1 的對話頭像由 FrameXML 預先建立；登入時縮小，顯示與語音仍交給暴雪。
function M:OnEnable()
	TalkingHeadFrame:SetScale(0.6)
end

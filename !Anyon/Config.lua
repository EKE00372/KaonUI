local _, ns = ...
local C, G = ns[1], ns[3]
local MediaFolder = G.MediaFolder

-- 這裡只放固定的字型、尺寸和位置；GUI 開關與預設值在 Init.lua。

-----------
-- Fonts --
-----------

	G.Font = STANDARD_TEXT_FONT
	G.CTCFont = MediaFolder.."Myriad Pro Semibold Condensed.ttf"
	G.FontSize = 14
	G.FontFlag = "OUTLINE"

-----------
-- Auras --
-----------

	C.Auras = {
		BuffSize = 32,
		BuffsPerRow = 16,
		DebuffSize = 36,
		DebuffsPerRow = 12,
		BuffPos = {"TOPRIGHT", UIParent, "TOPRIGHT", -10, -10},
		Margin = 6,
		CountFontSize = 14,
		TimerFontSize = 14,
	}

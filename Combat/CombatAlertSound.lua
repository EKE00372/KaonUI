local addon, ns = ...
local C, F, G, L = unpack(ns)
local modf, GetTime = math.modf, GetTime
local UnitIsDeadOrGhost, UnitHealth, UnitHealthMax = UnitIsDeadOrGhost, UnitHealth, UnitHealthMax
local UnitPowerType, UnitPower, UnitPowerMax = UnitPowerType, UnitPower, UnitPowerMax
local IsInInstance = IsInInstance

-- [[ 團隊確認警示音 ]] --

do
	local rcAlert = CreateFrame("Frame")
	rcAlert:RegisterEvent("READY_CHECK")
	rcAlert:SetScript("OnEvent", function()
		PlaySound(8960, "Master")
	end)
end

-- [[ 低血量警報 ]] --

do
	local lastHP = 0
	local lowHP = CreateFrame("Frame")
	lowHP:RegisterUnitEvent("UNIT_HEALTH", "player")
	lowHP:SetScript("OnEvent", function()
		-- 死了不報
		if UnitIsDeadOrGhost("player") then return end
		-- 警報閾值
		local maxHealth = UnitHealthMax("player")
		if not maxHealth or maxHealth == 0 then return end
		local lowHealth = (UnitHealth("player") / maxHealth) < 0.3
		-- 頻率限制
		local now = modf(GetTime())
		if now - lastHP < 1 then return end
		-- 警報聲
		if lowHealth then
			PlaySoundFile(G.HealthWarning, "Master")
			lastHP = now
		end
	end)
end

-- [[ 低法力警報 ]] --

do
	local lastMP = 0
	local lowMP = CreateFrame("Frame")
	lowMP:RegisterUnitEvent("UNIT_POWER_UPDATE", "player", 0)
	lowMP:SetScript("OnEvent", function()
		-- 死了不報
		if UnitIsDeadOrGhost("player") then return end
		-- 非法力不報
		if UnitPowerType("player") ~= "MANA" then return end
		-- 警報閾值
		local maxMana = UnitPowerMax("player", 0)
        if not maxMana or maxMana == 0 then return end
		local lowMana = (UnitPower("player", 0) / maxMana) < 0.3
		-- 頻率限制
		local now = modf(GetTime())
		if now - lastMP < 20 then return end
		-- 警報聲
		if lowMana then
			PlaySoundFile(G.ManaWarning, "Master")
			lastMP = now
		end
	end)
end

-- [[ 暫離狀態戰鬥警報 ]] --

do
	local afkAggro = CreateFrame("Frame")
	afkAggro:RegisterEvent("PLAYER_REGEN_DISABLED")
	afkAggro:RegisterEvent("PLAYER_REGEN_ENABLED")	
	afkAggro:SetScript("OnEvent", function(self, event, ...)
		-- 只在野外生效
		local _, instanceType = IsInInstance()
		if instanceType ~= "none" then return end
		-- 只在暫離狀態啟用
		if not IsChatAFK() then return end
		-- 警報聲
		if event == "PLAYER_REGEN_DISABLED" then	-- 進入戰鬥
			--PlaySound(8475, "Master")
			PlaySoundFile(544715, "Master")
		elseif event == "PLAYER_REGEN_ENABLED" then	-- 離開戰鬥
			StopMusic()
		end
	end)
end
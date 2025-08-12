scpRunner = {
    --[[Constants]]
    name ="scpRunner", --addon name
    updateTickRate = 10, --milliseconds 

    --[[Variables]]
    currentTime = 0,
    startTime = 0,
    endTime = 0,

    currentSplit = 0,
    currentSplitStartTime = 0,
    currentSplitEndTime = 0,
    wasDamageDone = false,

    --[[Tables]]--
    currentRunSplits = {
        {name = "trash1", time = 0, fightTime = 0, timeloss = 0},
        {name = "trash2", time = 0, fightTime = 0, timeloss = 0},
        {name = "trash3", time = 0, fightTime = 0, timeloss = 0},
        {name = "trash4", time = 0, fightTime = 0, timeloss = 0},
        {name = "trash5", time = 0, fightTime = 0, timeloss = 0},
        {name = "trash6", time = 0, fightTime = 0, timeloss = 0},
        {name = "boss1", time = 0, fightTime = 0, timeloss = 0},
        {name = "trash7", time = 0, fightTime = 0, timeloss = 0},
        {name = "boss2", time = 0, fightTime = 0, timeloss = 0},
        {name = "trash8", time = 0, fightTime = 0, timeloss = 0},
        {name = "trash9", time = 0, fightTime = 0, timeloss = 0},
        {name = "trash10", time = 0, fightTime = 0, timeloss = 0},
        {name = "trash11", time = 0, fightTime = 0, timeloss = 0},
        {name = "boss3", time = 0, fightTime = 0, timeloss = 0},
        {name = "trash12", time = 0, fightTime = 0, timeloss = 0},
        {name = "trash13", time = 0, fightTime = 0, timeloss = 0},
        {name = "trash14", time = 0, fightTime = 0, timeloss = 0},
        {name = "trash15", time = 0, fightTime = 0, timeloss = 0},
        {name = "boss4", time = 0, fightTime = 0, timeloss = 0},
        {name = "boss5", time = 0, fightTime = 0, timeloss = 0},
    },

    defaults = {
        splits ={ 
            {name = "trash1", time = 0, fightTime = 0},
            {name = "trash2", time = 0, fightTime = 0},
            {name = "trash3", time = 0, fightTime = 0},
            {name = "trash4", time = 0, fightTime = 0},
            {name = "trash5", time = 0, fightTime = 0},
            {name = "trash6", time = 0, fightTime = 0},
            {name = "boss1", time = 0, fightTime = 0},
            {name = "trash7", time = 0, fightTime = 0},
            {name = "boss2", time = 0, fightTime = 0},
            {name = "trash8", time = 0, fightTime = 0},
            {name = "trash9", time = 0, fightTime = 0},
            {name = "trash10", time = 0, fightTime = 0},
            {name = "trash11", time = 0, fightTime = 0},
            {name = "boss3", time = 0, fightTime = 0},
            {name = "trash12", time = 0, fightTime = 0},
            {name = "trash13", time = 0, fightTime = 0},
            {name = "trash14", time = 0, fightTime = 0},
            {name = "trash15", time = 0, fightTime = 0},
            {name = "boss4", time = 0, fightTime = 0},
            {name = "boss5", time = 0, fightTime = 0},
                },
        stats = {
            {name = "Trifectas", count = "0"},
                }
            },

    zaanHp = {
        [1683986] = true,
        [5131995] = true,
        [5901794] = true,
    },
}

--[[Player Activated, checks whether zone is Scalecaller Peak]]
function scpRunner:OnPlayerActivated()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    --[debug
    d("OnPlayerActivated Fired")
    if (zoneId == 1010 and self.currentTime == 0) then--If zone is scp, and current time ISN'T 0, it means function fired due to zone rechange (2nd boss door) or respawn (at wayshrine)
        --[[Start listening for]]
        --[Dungeon Start and Finish/Failed Checkers]
        EVENT_MANAGER:RegisterForEvent("scprStartTimer", EVENT_PLAYER_COMBAT_STATE, function() scpRunner:OnStartDungeon() end)
        EVENT_MANAGER:RegisterForEvent("scprEndDungeon", EVENT_UNIT_DEATH_STATE_CHANGED, function() scpRunner:OnZaanDeath() end)
        EVENT_MANAGER:AddFilterForEvent("scprEndDungeon", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "boss1")
        EVENT_MANAGER:RegisterForEvent("scprPlayerDied", EVENT_UNIT_DEATH_STATE_CHANGED, function() scpRunner:OnPlayerDied() end)
        EVENT_MANAGER:AddFilterForEvent("scprPlayerDied", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        --[Splits Manager]
        EVENT_MANAGER:RegisterForEvent("scprCreateSplits", EVENT_PLAYER_COMBAT_STATE, function() scpRunner:CreateSplitOnCombatEnd() end)
        EVENT_MANAGER:RegisterForEvent("scprDamageDoneCheck", EVENT_COMBAT_EVENT, function() scpRunner:OnDamageDone() end)
        EVENT_MANAGER:AddFilterForEvent("scprDamageDoneCheck", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    end
end
--[load addon and savedvariables, starts OnPlayerActivated]
local function OnAddOnLoaded(event, addonName)
    if addonName ~= scpRunner.name then return end
    EVENT_MANAGER:UnregisterForEvent(scpRunner.name, EVENT_ADD_ON_LOADED)

    scpRunner.SavedVars = ZO_SavedVars:NewAccountWide("scpRunnerSavedVariables", 1, nil, scpRunner.defaults, "$InstallationWide")
	
	EVENT_MANAGER:RegisterForEvent(scpRunner.playerActive, EVENT_PLAYER_ACTIVATED, function() scpRunner:OnPlayerActivated() end)
    scpRunner:LoadUI()
end
EVENT_MANAGER:RegisterForEvent(scpRunner.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

--------------------------------
--[[scpRunner Timer and Splits]]
--------------------------------

--[Start Dungeon/Timer]
function scpRunner:OnStartDungeon(_, inCombat)
    if inCombat == true and self.currentTime == 0 then
        scpRunner:Timer()
        self.startTime = GetGameTimeMilliseconds()
        EVENT_MANAGER:UnregisterForEvent("scprStartTimer", EVENT_PLAYER_COMBAT_STATE)
    end
end

function scpRunner:Timer()
    EVENT_MANAGER:RegisterForUpdate("scprTimer", self.updateTickRate, 
        function()
            self.currentTime = (GetGameTimeMilliseconds() - self.startTime) / 1000
            self.UI.HUDTimer:SetText(string.format("%02d:%05.2f", self.currentTime/60, self.currentTime%60)) --first value divides by 60 to get minutes, other gets the remainder to get seconds/milliseconds.
        end)
end

--[End Run Checkers & Function]
function scpRunner:OnZaanDeath(_,unitTag,_)
    local _, maxHp, _ = GetUnitPower(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH) --UnitPower in this case for flags_health just means currenthp, maxhp, and effectivehp. weird name
    if self.zaanHp[maxHp] then --Each time an enemy dies, it checks the exact hp amount zaan has on normal, veteran, and HM, if any of these match it must be zaan that died.
        self.endTime = GetGameTimeMilliseconds()
        scpRunner:EndRun(1)
        d("Zaan Died")
    end
end

function scpRunner:onPlayerDied(_,_,isDead)
    if isDead then
        scpRunner:EndRun(0)
        d("Player Died")
    end
end

function scpRunner:EndRun(Trifecta) --1 or 0, 1 means I killed zaan, aka trifecta no death, 0 means run ended from dying aka no trifecta.
    if Trifecta == 1 then 
        d("tri get")
    end
    --[Wipe data, but this should not be in this function yet. I need to make the spllits display first.]--
    self.currentTime = 0
    self.startTime = 0
    self.endTime = 0

    self.currentSplit = 0
    self.currentSplitStartTime = 0
    self.currentSplitEndTime = 0
end

function scpRunner:CompareandDisplayData()
    if self.currentTime ~= 0 then
        d("Comparing Times, run had been started and ended")
        for i = 1, #self.currentRunSplits do --i = 1 (start number), until #table entry count, so 20 splits here.
            local BestSplitTime = self.SavedVars[i].time
            self.currentRunSplits[i].timeloss = (self.currentRunSplits[i].time - BestSplitTime)
        end
    
        --rest of the stuff for displaying/comparing the data in the new UI
    end
end

--[Splits Manager]

--[this function exists to check whether the split was a non-combat one, if it wasnt, true or false can disregard it since wasDamageDone has to be true while a split is being registered]
function scpRunner:OnDamageDone(_,result,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_)
    if result == (ACTION_RESULT_DAMAGE or ACTION_RESULT_CRITICAL_DAMAGE or ACTION_RESULT_DOT_TICK or ACTION_RESULT_DOT_TICK_CRITICAL) then
        self.wasDamageDone = true
    end
end

function scpRunner:CreateSplitOnCombatEnd(_, inCombat)
    local bestSplit = self.SavedVars[self.currentSplit].time

    if inCombat == true then
        self.currentSplitStartTime = GetGameTimeMilliseconds()
    end

    if (inCombat == false and self.wasDamageDone == true) then 

        self.currentSplitEndTime = GetGameTimeMilliseconds()
        local splitTime = self.currentTime
        local splitFightTime = ((self.currentSplitEndTime - self.currentSplitStartTime) / 1000)
        
        if not (self.currentSplit == 19 and splitFightTime <= 10) then
            --[this function is in the UI file]
            self:ShowSplitsAnimation(self.UI.HUDSplitsIcon)
            self.ShowSplitsAnimation(self.UI.HUDSplitsTime)

            if bestSplit == 0 then
                self.UI.SplitsTime:SetText((string.format("|ce6f024%02d:%05.2f", splitTime/60, splitTime%60))) 
            elseif splitTime <= bestSplit then
                self.UI.SplitsTime:SetText((string.format("|c55e813-%02d:%05.2f", (bestSplit - splitTime)/60, (bestSplit - splitTime)%60)))
            elseif splitTime >= bestSplit then
                local timeLoss = splitTime - bestSplit
                --[this function is in the UI file]
                local color = self:SplitsColors(timeLoss)
                self.UI.SplitsTime:SetText((string.format("|c%s+%02d:%05.2f", color, (splitTime - bestSplit)/60, (splitTime - bestSplit)%60)))
            end
        
        self.currentRunSplits[self.CurrentSplit].time = splitTime
        self.currentRunSplits[self.CurrentSplit].fightTime = splitFightTime
        
        self.wasDamageDone = false
        self.currentSplit = self.currentSplit + 1
        end
    end
end

-------------------
--[[End Screen UI]]
-------------------


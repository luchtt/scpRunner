--[Visual functions/definitions for the UI to de-clutter the main file and make it more readable]
ScpRunner.UI = {
    HUDTimerIcon = scprHudTimer:GetNamedChild("Icon"),
    HUDTimer = scprHudTimer:GetNamedChild("Timer"),
    HUDSplitsIcon = scprHudTimer:GetNamedChild("SplitIcon"),
    HUDSplitsTime = scprHudTimer:GetNamedChild("SplitTime"),

    TopBG = scprStatsUI:GetNamedChild("TopBG"),
    BottomBG = scprStatsUI:GetNamedChild("BottomBG"),
    TopDivider = scprStatsUI:GetNamedChild("TopDivider"),
    TopTopDivider = scprStatsUI:GetNamedChild("TopTopDivider"),
    TopTopBG = scprStatsUI:GetNamedChild("loadscreenBG"),
    TopSubDivider = scprStatsUI:GetNamedChild("TopSubDivider"),
    BottomSubDivider = scprStatsUI:GetNamedChild("BottomSubDivider"),
    BottomDivier = scprStatsUI:GetNamedChild("BottomDivider"),

    DungeonIcon = scprStatsUI:GetNamedChild("DungeonIcon"),
    DungeonName = scprStatsUI:GetNamedChild("DungeonName"),

    TallyIcon = scprStatsUI:GetNamedChild("TimeTallyIcon"),
    TallyLabel = scprStatsUI:GetNamedChild("TimeTally"),

    SplitsLabel = scprStatsUI:GetNamedChild("SplitsLabel"),
    SplitsIcon = scprStatsUI:GetNamedChild("SplitsIcon"),
    SplitsTopDivider = scprStatsUI:GetNamedChild("SplitsTopDivider"),
    SplitsBottomDivider = scprStatsUI:GetNamedChild("SplitsBottomDivider"),

    TrifectasLabel = scprStatsUI:GetNamedChild("TrifectasLabel"),
    TrifectasIcon = scprStatsUI:GetNamedChild("TrifectasIcon"),
    TrifectasTopDivider = scprStatsUI:GetNamedChild("TrifectasTopDivider"),
    TrifectasBottomDivider = scprStatsUI:GetNamedChild("TrifectasBottomDivider"),
}

------------------------------
--[[Timer and Splits Visuals]]
------------------------------

function ScpRunner:SplitsColors()
    local steepCurve = ZO_GenerateCubicBezierEase(.01,.5,.75,.33) --Bezier curve generate

    local normalizedTimeLoss = steepCurve(math.min(math.max(timeLoss / 10, 0), 1)) --Normalizes it to a numer between 1 and 0 so it can be used in a bezier curve, and also limits it to 10 (10 being always 1 in this case)
    local red = math.floor(255 * normalizedTimeLoss) --Red RGB value, this is gonna be 0 if its a perfect split, and as we approach 10 second split time, it will approach 255.
    local green = math.floor(math.max(255 - (255 * normalizedTimeLoss))) --Same as red but reversed, closest to 0 its gonna be 255, and closer to 10 it will approach 0.
    return string.format("%02X%02X%02X", red, green, 0) --Hexadecimal rgb converter.
end

function ScpRunner:ShowSplitsAnimation(control, startx, starty, endx, endy, endx2, endy2)
    local endCurve = ZO_GenerateCubicBezierEase(.6,.3,.3,1)
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)

    local move1 = timeline:InsertAnimation(ANIMATION_TRANSLATE, control, 0)
    move1:SetTranslateOffsets(startx, starty, endx, endy) --start offsetx, startoffsety, endoffsets, endoffsets.
    move1:SetDuration(400)
    move1:SetEasingFunction(endCurve)

    local makeVisible = timeline:InsertAnimation(ANIMATION_ALPHA, control, 0)
    makeVisible:SetAlphaValues(0, 1)
    makeVisible:SetDuration(200)
    makeVisible:SetEasingFunction(endCurve)

    local move2 = timeline:InsertAnimation(ANIMATION_TRANSLATE, control, 5000)
    move2:SetTranslateOffsets(endx, endy, endx2, endy2) --start offsetx, startoffsety, endoffsets, endoffsets.
    move2:SetDuration(800)
    move2:SetEasingFunction(endCurve)

    local makeInvisible = timeline:InsertAnimation(ANIMATION_ALPHA, control, 5000)
    makeInvisible:SetAlphaValues(1, 0)
    makeInvisible:SetDuration(550)
    makeInvisible:SetEasingFunction(endCurve)
    timeline:PlayFromStart()
end

-------------------
--[[End Screen UI]]
-------------------

function ScpRunner:InitializeStatsScreen()
    self.Scene = ZO_Scene:New("ScpRunnerStatsScene", SCENE_MANAGER)
    self.fragment = ZO_FadeSceneFragment:New(scprStatsUI)

    self.Scene:AddFragment(self.fragment)
    self.Scene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
    self.Scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    SCENE_MANAGER:Show("ScpRunnerStatsScene")
    self.Scene:RegisterCallback("StateChange", 
        function(oldState, newState) 
            ScpRunner:OnSceneStateChanged(oldState, newState) 
        end)
end

function ScpRunner:OnSceneStateChanged(oldState, newState)
    d("scenestatechanged")
    if (newState == SCENE_SHOWN and self.wasStatsScreenOpened == false) then
        --[Dungeon Icon/Name]
        self:StatsScreenOpenAnimation(self.UI.DungeonIcon, 400, 0, 360, -490, 1, 0)
        self:StatsScreenOpenAnimation(self.UI.DungeonName, 500, 0, 500, -490, 1, 0)
        --[Tally Icon/Time]
        self:StatsScreenOpenAnimation(self.UI.TallyIcon, 500, 0, 420, -412, 1, 0)
        self:StatsScreenOpenAnimation(self.UI.TallyLabel, 500, 0, 500, -420, 1, 0)
        --[Splits Header/Icon]
        self:StatsScreenOpenAnimation(self.UI.SplitsLabel, 500, 0, 170, -333, 1, 0)
        self:StatsScreenOpenAnimation(self.UI.SplitsIcon, 500, 0, 115, -326, 1, 0)
        self:StatsScreenOpenAnimation(self.UI.SplitsTopDivider, 500, 0, 170, -360, 1, 0)
        self:StatsScreenOpenAnimation(self.UI.SplitsBottomDivider, 500, 0, 170, -295, 1, 0)
        --[Trifecta Count/Icon]
        self:StatsScreenOpenAnimation(self.UI.TrifectasLabel, 500, 0, 830, -333, 1, 0)
        self:StatsScreenOpenAnimation(self.UI.TrifectasIcon, 500, 0, 745, -326, 1, 0)
        self:StatsScreenOpenAnimation(self.UI.TrifectasTopDivider, 500, 0, 830, -360, 1, 0)
        self:StatsScreenOpenAnimation(self.UI.TrifectasBottomDivider, 500, 0, 830, -295, 1, 0)

        self:StatsScreenOpenAnimation(self.UI.TopBG, 500, 0, 500, -450, 0.7, 0)
        self:StatsScreenOpenAnimation(self.UI.BottomBG, 500, 0, 500, 450, 0.7, 0)
        self:StatsScreenOpenAnimation(self.UI.TopDivider, 500, 0, 500, -450, 1, 0)
        self:StatsScreenOpenAnimation(self.UI.TopTopDivider, 500, 0, 500, -525, 1, 0)
        self:StatsScreenOpenAnimation(self.UI.TopTopBG, 500, 0, 500, -490, .7, 0)
        self:StatsScreenOpenAnimation(self.UI.TopSubDivider, 500, 0, 500, -375, 1, 0)
        self:StatsScreenOpenAnimation(self.UI.BottomSubDivider, 500, 0, 500, 375, 1, 0)
        self:StatsScreenOpenAnimation(self.UI.BottomDivider, 500, 0, 500, 450, 1, 0)
        scprStatsUI:SetHidden(false)

        self.wasStatsScreenOpened = true
    elseif (newState == SCENE_HIDDEN) then
        d("scene hidden waow")
        scprStatsUI:SetHidden(true)
        scprStatsUI:SetAlpha(0)
    end
end

function ScpRunner:StatsScreenOpenAnimation(control, startx, starty, x, y, endAlpha, startTime)
    local Curve = ZO_GenerateCubicBezierEase(1,.08,.69,.63)
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    timeline:SetHandler("OnStop", function() self:TimeTallyer() end)
    timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)

    local move = timeline:InsertAnimation(ANIMATION_TRANSLATE, control, startTime)
    move:SetTranslateOffsets(startx, starty, x, y) --start offsetx, startoffsety, endoffsets, endoffsets.
    move:SetDuration(600)
    move:SetEasingFunction(Curve)

    local makeVisible = timeline:InsertAnimation(ANIMATION_ALPHA, control, startTime)
    makeVisible:SetAlphaValues(0, endAlpha)
    makeVisible:SetDuration(600)
    makeVisible:SetEasingFunction(Curve)
    timeline:PlayFromStart()
end


SLASH_COMMANDS["/createscene1"] = function() 
    ScpRunner:InitializeStatsScreen()
    end
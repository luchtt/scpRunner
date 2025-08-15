--[Visual functions/definitions for the UI to de-clutter the main file and make it more readable]
ScpRunner.UI = {
    HUDTimerIcon = scprHudTimer:GetNamedChild("Icon"),
    HUDTimer = scprHudTimer:GetNamedChild("Timer"),
    HUDSplitsIcon = scprHudTimer:GetNamedChild("SplitIcon"),
    HUDSplitsTime = scprHudTimer:GetNamedChild("SplitTime"),
}

ScpRunner.FrameAnimationStartAndEndPositions = {
    --[Control, startX, startY, endX, endY, endAlpha, startTime]
    {scprStatsUIFrameTopTopDivider, 500, 0, 500, -525, 1, 0},
    {scprStatsUIFrameTopBG, 500, 0, 500, -450, 0.7, 0},
    {scprStatsUIFrameBottomBG, 500, 0, 500, 450, 0.7, 0},
    {scprStatsUIFrameloadscreenBG, 500, 0, 500, -490, .7, 0},
    {scprStatsUIFrameTopDivider, 500, 0, 500, -450, 1, 0},
    {scprStatsUIFrameBottomDivider, 500, 0, 500, 450, 1, 0},
    --[Dungeon Icon/Name]
    {scprStatsUIDungeonIcon, 400, 0, 360, -490, 1, 0},
    {scprStatsUIDungeonName, 500, 0, 500, -490, 1, 0},
    --[Tally Icon/Time]
    {scprStatsUITimeTallyDivider, 500, 0, 500, -375, 1, 0},
    {scprStatsUITimeTallyIcon, 500, 0, 420, -412, 1, 0},
    {scprStatsUITimeTallyLabel, 500, 0, 500, -420, 1, 0},
    --[Splits Header/Icon]
    {scprStatsUISplitsLabel, 500, 0, 170, -333, 1, 0},
    {scprStatsUISplitsIcon, 500, 0, 115, -326, 1, 0},
    {scprStatsUISplitsTopDivider, 500, 0, 170, -360, 1, 0},
    {scprStatsUISplitsBottomDivider, 500, 0, 170, -295, 1, 0},
    --[Trifecta Count/Icon]
    {scprStatsUITrifectasLabel, 500, 0, 830, -333, 1, 0},
    {scprStatsUITrifectasIcon, 500, 0, 745, -326, 1, 0},
    {scprStatsUITrifectasTopDivider, 500, 0, 830, -360, 1, 0},
    {scprStatsUITrifectasBottomDivider, 500, 0, 830, -295, 1, 0},
    --[Difficulty Switcher]
    {scprStatsUIDifficultyChangerChangeDiffButton,500 ,0, 500, 337, 1, 0},
    {scprStatsUIDifficultyChangerNormalDiffActive,500 ,0, 450, 337, 1, 0},
    {scprStatsUIDifficultyChangerNormalDiffInactive,500 ,0, 450, 337, 1, 0},
    {scprStatsUIDifficultyChangerVeteranDiffActive,500 ,0, 550, 337, 1, 0},
    {scprStatsUIDifficultyChangerVeteranDiffInactive,500 ,0, 550, 337, 1, 0},
    {scprStatsUIDifficultyChangerTopDivider, 500, 0, 500, 300, 1, 0},
    {scprStatsUIDifficultyChangerBottomDivider, 500, 0, 500, 375, 1, 0},
}

------------------------------
--[[Timer and Splits Visuals]]
------------------------------

function ScpRunner:SplitsColors(timeLoss)
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
    self.Scene:RegisterCallback("StateChange", function(oldState, newState) ScpRunner:OnSceneStateChanged(oldState, newState) end)
end

function ScpRunner:OnSceneStateChanged(oldState, newState)
    d("scenestatechanged")
    
    if (newState == SCENE_SHOWN and self.wasStatsScreenOpened == false) then

        self.wasStatsScreenOpened = true
    elseif (newState == SCENE_HIDDEN) then
        d("scene hidden waow")
    end
end

function ScpRunner:CreateStatsScreenOpenAnimation()
    d("createanimation fired")
    local Curve = ZO_GenerateCubicBezierEase(1,.08,.69,.63)
    self.statsScreenTimeline = ANIMATION_MANAGER:CreateTimeline()
    self.statsScreenTimeline:SetHandler("OnStop", function() self:TimeTallyer() end)
    self.statsScreenTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
    for _, controlData in ipairs(self.FrameAnimationStartAndEndPositions) do
        d("for loop fired")
        --[1=Control, 2=startx, 3=starty, 4=x, 5=y, 6=endAlpha, 7=startTime]
        local move = self.statsScreenTimeline:InsertAnimation(ANIMATION_TRANSLATE, controlData[1], 0)
        move:SetTranslateOffsets(controlData[2], controlData[3], controlData[4], controlData[5]) --start offsetx, startoffsety, endoffsets, endoffsets.
        move:SetDuration(600)
        move:SetEasingFunction(Curve)

        local makeVisible = self.statsScreenTimeline:InsertAnimation(ANIMATION_ALPHA, controlData[1], 0)
        makeVisible:SetAlphaValues(0, controlData[6])
        makeVisible:SetDuration(600)
        makeVisible:SetEasingFunction(Curve)
    end
end

---------------
--[Splits List]

--[Creates the Scroll List from the control inside scpStatsUI:Splits]
function ScpRunner:CreateSplitsList()
    ZO_ScrollList_AddDataType(scprStatsUISplitsList, 1, "scprSplitsTemplates", 88, function(...) self:FormatSplitsListItems(...) end)
end


--[Sets up the UI properties and functionality of each split entry as a preset]
function ScpRunner:FormatSplitsListItems(control, data)
        local Name = control:GetNamedChild("SplitsName")
        local Time = control:GetNamedChild("SplitsTime")
        local FightTime = control:GetNamedChild("SplitsFightTime")
        local TimeLoss = control:GetNamedChild("SplitsTimeLoss")
        local Overwrite = control:GetNamedChild("SplitsOverwriteBest")
        local Background = control:GetNamedChild("BG")

        --[Sets the text to the correct values]
        Name:SetText(data.name)
        Time:SetText(string.format("%02d:%05.2f", data.time/60, data.time%60))
        FightTime:SetText(string.format("%02d:%05.2f", data.fightTime/60, data.fightTime%60))
        --[Same function as in scprunner:createsplit, just adapted a bit for displaying in the ui]
        if data.newtime == true then
            TimeLoss:SetText((string.format("|ce6f024%01.2f", data.time)))
        elseif data.timeloss <= 0 then
            TimeLoss:SetText((string.format("|c55e813%01.2f", data.timeloss)))
        elseif data.timeloss >= 0 then
            TimeLoss:SetText(string.format("|cff0000+%01.2f", data.timeloss))
            Overwrite:SetEnabled(false)
            Overwrite:SetMouseEnabled(false)
        end
        
        --[If not means this hasn't even been set as a variable yet. If it has been, that means this control already exists. Since it's independent of split values it doesnt need to be re-created.]
        if not control.AnimationHandler then 
        --[bg animation for hovering over a split]
            control.fadeTimeline = ANIMATION_MANAGER:CreateTimeline()
            local fade = control.fadeTimeline:InsertAnimation(ANIMATION_ALPHA, Background)
            fade:SetAlphaValues(0, 0.5)
            fade:SetDuration(150)

            control:SetHandler("OnMouseEnter", function() control.fadeTimeline:PlayFromStart() end)
            Overwrite:SetHandler("OnMouseEnter", function() control.fadeTimeline:PlayFromStart() end)
            control:SetHandler("OnMouseExit",function() control.fadeTimeline:PlayFromEnd() end)
            Overwrite:SetHandler("OnMouseExit",function() control.fadeTimeline:PlayFromEnd() end)
            control.AnimationHandler = true
        end
        
        --[Save split if it beats PB. aka click the book and quill button]
        Overwrite:SetHandler("OnMouseDown", function() 
            ScpRunner:SaveOverBestSplit(data.name, data.time) 
            Overwrite:SetEnabled(false)
            Overwrite:SetMouseEnabled(false)
            end)
end

--[Splits data is fed into the list]
function ScpRunner:PopulateSplitsList()

    local InputSplitsData = ZO_ScrollList_GetDataList(scprStatsUISplitsList)

    ZO_ScrollList_Clear(scprStatsUISplitsList)
     for _, entry in ipairs(self.currentRunSplits) do
        --[Only let through splits that were actually done/in the progress of done]
        if entry.time ~= 0 then
        local newEntry = ZO_ScrollList_CreateDataEntry(1, entry)

        table.insert(InputSplitsData, newEntry)
        end
     end
     ZO_ScrollList_Commit(scprStatsUISplitsList)
end

--[Create Splits Entry MouseOver Animation]
function ScpRunner:CreateMouseOverSplitsAnimation(control)
        self.MouseOverSplitsAnimation = ANIMATION_MANAGER:CreateTimeline()
        local makeVisible = self.MouseOverSplitsAnimation:InsertAnimation(ANIMATION_ALPHA, control, 0)
        makeVisible:SetAlphaValues(0, 0.33)
        makeVisible:SetDuration(300)
        makeVisible:SetEasingFunction(ZO_EaseInCubic)
        if reverse == true then
            self.MouseOverSplitsAnimation:PlayFromEnd()
        else
            self.MouseOverSplitsAnimation:PlayFromStart()
        end
end

--[debug]
SLASH_COMMANDS["/createscene1"] = function() 
    SCENE_MANAGER:Show("ScpRunnerStatsScene")
    ScpRunner.statsScreenTimeline:PlayFromStart()
    ScpRunner:PopulateSplitsList()
    scprStatsUISplitsListScrollBar:SetHidden(true)
    end
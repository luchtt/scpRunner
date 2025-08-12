--[Visual functions/definitions for the UI to de-clutter the main file and make it more readable]
function scpRunner:LoadUI()
    scpRunner.UI = {
        HUDTimerIcon = scprTimer:GetNamedChild("Icon"),
        HUDTimer = scprTimer:GetNamedChild("Timer"),
        HUDSplitsIcon = scprTimer:GetNamedChild("SplitIcon"),
        HUDSplitsTime = scprTimer:GetNamedChild("SplitTime"),

        TopBG = scprUI:GetNamedChild("TopBG"),
        BottomBG = scprUI:GetNamedChild("BottomBG"),
        TopDivider = scprUI:GetNamedChild("TopDivider"),
        TopTopDivider = scprUI:GetNamedChild("TopTopDivider"),
        TopTopBG = scprUI:GetNamedChild("loadscreenBG"),
        TopSubDivider = scprUI:GetNamedChild("TopSubDivider"),
        BottomSubDivider = scprUI:GetNamedChild("BottomSubDivider"),
        BottomDivier = scprUI:GetNamedChild("BottomDivider"),

        DungeonIcon = scprUI:GetNamedChild("DungeonIcon"),
        DungeonName = scprUI:GetNamedChild("DungeonName"),

        TallyIcon = scprUI:GetNamedChild("TimeTallyIcon"),
        TallyLabel = scprUI:GetNamedChild("TimeTally"),

        SplitsLabel = scprUI:GetNamedChild("SplitsLabel"),
        SplitsIcon = scprUI:GetNamedChild("SplitsIcon"),
        SplitsTopDivider = scprUI:GetNamedChild("SplitsTopDivider"),
        SplitsBottomDivider = scprUI:GetNamedChild("SplitsBottomDivider"),

        TrifectasLabel = scprUI:GetNamedChild("TrifectasLabel"),
        TrifectasIcon = scprUI:GetNamedChild("TrifectasIcon"),
        TrifectasTopDivider = scprUI:GetNamedChild("TrifectasTopDivider"),
        TrifectasBottomDivider = scprUI:GetNamedChild("TrifectasBottomDivider"),
    }
end

----------------------
--[[Timer and Splits]]
----------------------
function scpRunner:SplitsColors()
    local steepCurve = ZO_GenerateCubicBezierEase(.01,.5,.75,.33) --Bezier curve generate

    local normalizedTimeLoss = steepCurve(math.min(math.max(timeLoss / 10, 0), 1)) --Normalizes it to a numer between 1 and 0 so it can be used in a bezier curve, and also limits it to 10 (10 being always 1 in this case)
    local red = math.floor(255 * normalizedTimeLoss) --Red RGB value, this is gonna be 0 if its a perfect split, and as we approach 10 second split time, it will approach 255.
    local green = math.floor(math.max(255 - (255 * normalizedTimeLoss))) --Same as red but reversed, closest to 0 its gonna be 255, and closer to 10 it will approach 0.
    return string.format("%02X%02X%02X", red, green, 0) --Hexadecimal rgb converter.
end

function scpRunner:ShowSplitsAnimation(control, startx, starty, endx, endy, endx2, endy2)
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


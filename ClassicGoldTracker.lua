local optionsShown = false
local PLAYER_MONEY_START = 0
local PLAYER_MONEY_CURRENT = 0
local CURRENT_DATE = date("%d%m%y")
local CURRENT_PAGE = 1
local SavesSorted = {}
local content
local SavesSortedSize, SavesSortedSizeFinal

function CGT_OnLoad(self)
    SetPortraitToTexture(self.portrait, "Interface\\ICONS\\INV_Misc_Book_12")
    History_Title:SetText("Gold History")
    MakeMovable(self)

    GoldStat:RegisterEvent("PLAYER_ENTERING_WORLD")
    GoldStat:RegisterEvent("PLAYER_MONEY")
    GoldStat:RegisterEvent("VARIABLES_LOADED")

    GoldStat:SetScript(
        "OnEvent",
        function(self, event, ...)
            if (event == "VARIABLES_LOADED") then
                if SAVES == nil then
                    -- No Saves for this character found
                    SAVES = {}
                end
            end

            if (event == "PLAYER_ENTERING_WORLD") or (event == "PLAYER_MONEY") then
                updateMoneyOnScreen(event)
            end
        end
    )
end

function updateMoneyOnScreen(event)
    print("updateMoneyOnScreen")
    local copper = GetMoney()

    if SAVES == nil then
        PLAYER_MONEY_START = copper
    else
        if (SAVES[CURRENT_DATE] == nil) then
            PLAYER_MONEY_START = copper
        else
            PLAYER_MONEY_START = SAVES[CURRENT_DATE]
        end
    end

    SAVES[CURRENT_DATE] = PLAYER_MONEY_START

    PLAYER_MONEY_CURRENT = PLAYER_MONEY_START

    local tmpMoney = GetMoney()

    local overallDiff = tmpMoney - PLAYER_MONEY_START

    local overallDiffString = ""
    if overallDiff > 0 then
        overallDiffString = "+" .. GetCoinTextureString(overallDiff)
    else
        overallDiffString = "-" .. GetCoinTextureString(math.abs(overallDiff))
    end
    if overallDiff == 0 then
        overallDiffString = "" .. GetCoinTextureString(math.abs(overallDiff))
    end

    liveGold:SetText(overallDiffString)

    if (event == "PLAYER_ENTERING_WORLD") then
        local output = "Your Money: " .. GetCoinTextureString(PLAYER_MONEY_CURRENT) .. " (" .. overallDiffString .. ")"
    end
end

function MakeMovable(frame)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
end

function showOptions()
    content:Hide()
    content:SetParent(nil)
    content:UnregisterAllEvents()
    content:SetID(0)
    content:ClearAllPoints()
    optionsShown = true
    History_Title:SetText("Options")
    History:Hide()
    previousButton:Hide()
    nextButton:Hide()
    saveButton:Show()
end

function showHistory()
    History_Title:SetText("Gold History")
    History:Show()
    optionsShown = false
    previousButton:Show()
    nextButton:Show()
    saveButton:Hide()
end

function closeMainFrame()
    content:Hide()
    content:SetParent(nil)
    content:UnregisterAllEvents()
    content:SetID(0)
    content:ClearAllPoints()
    History_Title:SetText("Gold History")
    Main:Hide()
    showHistory()
end

function loadHistory()
    SavesSorted = {}

    for k in pairs(SAVES) do
        table.insert(SavesSorted, k)
    end
    table.sort(SavesSorted)

    dateSort(SavesSorted)

    SavesSortedSizeFinal = table.getn(SavesSorted)
    SavesSortedSize = table.getn(SavesSorted)

    TOTAL_PAGE_SIZE = 0
    repeat
        TOTAL_PAGE_SIZE = TOTAL_PAGE_SIZE + 1
        SavesSortedSize = SavesSortedSize - 15
    until (SavesSortedSize <= 0)

    if (CURRENT_PAGE > 1) then
        previousButton:Enable()
    else
        previousButton:Disable()
    end

    History_Pagination:SetText(CURRENT_PAGE .. "/" .. TOTAL_PAGE_SIZE)
    showPage(CURRENT_PAGE)
end

function nextPage()
    if (CURRENT_PAGE + 1 <= TOTAL_PAGE_SIZE) then
        content:Hide()
        content:SetParent(nil)
        content:UnregisterAllEvents()
        content:SetID(0)
        content:ClearAllPoints()
        CURRENT_PAGE = CURRENT_PAGE + 1
        History_Pagination:SetText(CURRENT_PAGE .. "/" .. TOTAL_PAGE_SIZE)

        showPage(CURRENT_PAGE)
    end
end

function previousPage()
    if (CURRENT_PAGE - 1 >= 1) then
        content:Hide()
        content:SetParent(nil)
        content:UnregisterAllEvents()
        content:SetID(0)
        content:ClearAllPoints()
        CURRENT_PAGE = CURRENT_PAGE - 1
        History_Pagination:SetText(CURRENT_PAGE .. "/" .. TOTAL_PAGE_SIZE)

        showPage(CURRENT_PAGE)
    end
end

function showPage(number)
    if (CURRENT_PAGE > 1) then
        previousButton:Enable()
    else
        previousButton:Disable()
    end

    if (CURRENT_PAGE + 1 <= TOTAL_PAGE_SIZE) then
        nextButton:Enable()
    else
        nextButton:Disable()
    end

    content = CreateFrame("Frame", nil, History)
    content:SetSize(128, 128)
    local texture = content:CreateTexture()
    texture:SetAllPoints()

    CURRENT_PAGE = number
    local offset = -5

    local END = ((15 - (CURRENT_PAGE * 15)) * -1) + 15
    if (((15 - (CURRENT_PAGE * 15)) * -1) + 16 >= table.getn(SavesSorted)) then
        END = table.getn(SavesSorted)
    end

    local dateHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dateHeader:SetPoint("TOPLEFT", History, 7, -5)
    dateHeader:SetText("Date")

    local PercentHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    PercentHeader:SetPoint("TOP", History, -5, -5)
    PercentHeader:SetText("Change %")

    local GoldHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    GoldHeader:SetPoint("TOPRIGHT", History, -15, -5)
    GoldHeader:SetText("Gold Amount")

    --print("END is " .. END .. "(" .. table.getn(SavesSorted) .. ")")
    for k = ((15 - (CURRENT_PAGE * 15)) * -1) + 1, END, 1 do
        offset = offset - 20
        local dateString = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        dateString:SetPoint("TOPLEFT", History, 0, offset)

        local day = string.sub(SavesSorted[k], 0, 2)
        local month = string.sub(SavesSorted[k], 3, 4)
        local year = string.sub(SavesSorted[k], 5, 6)
        if (CURRENT_DATE == day .. month .. year) then
            dateString:SetText("Today")
        else
            dateString:SetText(day .. "." .. month .. "." .. year)
        end
        dateString:SetTextColor(1, 1, 1, 1)

        local money = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        money:SetPoint("TOPRIGHT", History, -10, offset)
        money:SetFont("Fonts\\FRIZQT__.TTF", 10)

        money:SetText(GetCoinTextureString(SAVES[SavesSorted[k]]))

        if (k < SavesSortedSizeFinal) then
            local diffInPercent = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            diffInPercent:SetPoint("TOP", History, -10, offset)
            diffInPercent:SetFont("Fonts\\FRIZQT__.TTF", 10)

            local diff = SAVES[SavesSorted[k]] - SAVES[SavesSorted[k + 1]]
            local isNegative = false
            if (diff < 0) then
                isNegative = true
                diff = diff * -1
            end

            local diffPercent = diff / SAVES[SavesSorted[k + 1]] * 100

            if (isNegative) then
                if (diffPercent <= 25) then
                    diffInPercent:SetTextColor(1, 1, 0, 1)
                else
                    diffInPercent:SetTextColor(1, 0, 0, 1)
                end

                diffInPercent:SetText("-" .. math.floor(diffPercent) .. "%")
            else
                diffInPercent:SetText("+" .. math.floor(diffPercent) .. "%")

                if (diffPercent <= 25) then
                    diffInPercent:SetTextColor(0, 1, 0, 0.5)
                else
                    diffInPercent:SetTextColor(0, 1, 0, 1)
                end
            end
        else
            local diffInPercent = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            diffInPercent:SetPoint("TOP", History, -10, offset)
            diffInPercent:SetFont("Fonts\\FRIZQT__.TTF", 10)
            diffInPercent:SetText("--")
        end
    end
end

function dateSort(dateTable)
    local i = 1
    local changed = false

    table.foreach(
        dateTable,
        function(k, v)
            local day = string.sub(dateTable[k], 0, 2)
            local month = string.sub(dateTable[k], 3, 4)
            local year = string.sub(dateTable[k], 5, 6)

            if (i < table.getn(dateTable)) then
                local nextDay = string.sub(dateTable[k + 1], 0, 2)
                local nextMonth = string.sub(dateTable[k + 1], 3, 4)
                local nextYear = string.sub(dateTable[k + 1], 5, 6)

                if (day < nextDay and month <= nextMonth or month < nextMonth) then
                    changed = true

                    local temp = dateTable[k]
                    dateTable[k] = dateTable[i + 1]
                    dateTable[i + 1] = temp
                end
            end

            i = i + 1
        end
    )

    if (changed) then
        dateSort(dateTable)
    end
end

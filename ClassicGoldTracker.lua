local frame = CreateFrame("FRAME", "SimpleGoldTrackerFrame")
local PLAYER_MONEY_START = 0
local PLAYER_MONEY_CURRENT = 0
local CURRENT_DATE = date("%d%m%y")
local AceGUI = LibStub("AceGUI-3.0")
local historyIsOpen = false

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_MONEY")
frame:RegisterEvent("VARIABLES_LOADED")

local f = CreateFrame("Frame", "ProfitCraftablesFrame", UIParent) --Create a frame
f:SetFrameStrata("BACKGROUND") --Set its strata
f:SetHeight(50) --Give it height
f:SetWidth(200) --and width

f:SetBackdropColor(0, 0, 0, 0.3) --Set the background colour to black
f:SetPoint("CENTER") --Put it in the centre of the parent frame (UIParent)
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)

f.text = f:CreateFontString(nil, "ARTWORK") --Create a FontString to display text
f.text:SetFont("Fonts\\FRIZQT__.TTF", 12) --Set the font and size
f.text:SetTextColor(1, 1, 1) --Set the text colour
f.text:SetAllPoints() --Put it in the centre of the frame

local b = CreateFrame("Button", "MyButton", f, nil)
b:SetNormalTexture("Interface\\MINIMAP\\TRACKING\\None")

b:SetSize(20, 20) -- width, height
b:SetPoint("RIGHT", 15, 0)

local HistoryFrame = CreateFrame("frame", "HistoryFrameFrame", UIParent)

HistoryFrame:SetBackdrop(
    {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = 1,
        tileSize = 32,
        edgeSize = 32,
        insets = {left = 11, right = 12, top = 12, bottom = 11}
    }
)
HistoryFrame:SetWidth(500)
HistoryFrame:SetHeight(400)
HistoryFrame:SetPoint("CENTER", UIParent)
HistoryFrame:EnableMouse(true)
HistoryFrame:EnableMouseWheel(true)
HistoryFrame:SetFrameStrata("FULLSCREEN_DIALOG")
HistoryFrame:SetMovable(true)
HistoryFrame:RegisterForDrag("LeftButton")
HistoryFrame:SetScript("OnDragStart", frame.StartMoving)
HistoryFrame:SetScript("OnDragStop", frame.StopMovingOrSizing)
HistoryFrameFrame:Hide()

HistoryFrame.text = HistoryFrame:CreateFontString(nil, "ARTWORK") --Create a FontString to display text
HistoryFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 14) --Set the font and size
HistoryFrame:SetBackdropColor(0, 0, 0, 0.9)
HistoryFrame.text:SetTextColor(1, 1, 1) --Set the text colour
HistoryFrame.text:SetPoint("CENTER", 0, 170) --Put it in the centre of the frame
HistoryFrame.text:SetText("Classic Gold Tracker - History")

local CloseButton = CreateFrame("button", "HistoryFrameButton", HistoryFrame, "UIPanelButtonTemplate")
CloseButton:SetHeight(25)
CloseButton:SetWidth(25)
CloseButton:SetPoint("TOPRIGHT", 0, 0)
CloseButton:SetText("x")
CloseButton:SetScript(
    "OnClick",
    function(self)
        self:GetParent():Hide()
    end
)

b:SetScript(
    "OnClick",
    function()
        if (historyIsOpen == false) then
            historyIsOpen = true
            HistoryFrameFrame:Show()
            local offset = -40

            local SavesSorted = {}

            for k in pairs(SAVES) do
                table.insert(SavesSorted, k)
            end
            table.sort(SavesSorted)

            dateSort(SavesSorted)

            table.foreach(
                SavesSorted,
                function(k, v)
                    offset = offset - 20

                    local dateString = HistoryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    dateString:SetPoint("TOPLEFT", 30, offset)
                    dateString:SetText("Hello World!")

                    local day = string.sub(SavesSorted[k], 0, 2)
                    local month = string.sub(SavesSorted[k], 3, 4)
                    local year = string.sub(SavesSorted[k], 5, 6)
                    dateString:SetText(day .. "." .. month .. "." .. year)
                    dateString:SetFont("Fonts\\FRIZQT__.TTF", 10)

                    local money = AceGUI:Create("Label")
                    money:SetText()
                    money:SetFont("Fonts\\FRIZQT__.TTF", 12)

                    local money = HistoryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    money:SetPoint("TOPRIGHT", -30, offset)
                    money:SetFont("Fonts\\FRIZQT__.TTF", 10)

                    money:SetText(GetCoinTextureString(SAVES[SavesSorted[k]]))
                end
            )
        else
            historyIsOpen = false
            HistoryFrameFrame:Hide()
        end
    end
)

frame:SetScript(
    "OnEvent",
    function(self, event, arg1, ...)
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

                if (day >= nextDay and month == nextMonth or month > nextMonth) then
                    changed = true
                    --print(day .. ">= " .. nextDay .. " and " .. month .. " > " .. nextMonth)
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
function updateMoneyOnScreen(event)
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
        overallDiffString = "Total Today: +" .. GetCoinTextureString(overallDiff)
    else
        overallDiffString = "Total Today: -" .. GetCoinTextureString(math.abs(overallDiff))
    end
    if overallDiff == 0 then
        overallDiffString = "Total Today: " .. GetCoinTextureString(math.abs(overallDiff))
    end

    f.text:SetText(overallDiffString)

    if (event == "PLAYER_ENTERING_WORLD") then
        local output = "Your Money: " .. GetCoinTextureString(PLAYER_MONEY_CURRENT) .. " " .. overallDiffString
        print(output)
    end
end

local frame = CreateFrame("FRAME", "SimpleGoldTrackerFrame")
local PLAYER_MONEY_START = 0
local PLAYER_MONEY_CURRENT = 0
local CURRENT_DATE = date("%d%m%y")

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

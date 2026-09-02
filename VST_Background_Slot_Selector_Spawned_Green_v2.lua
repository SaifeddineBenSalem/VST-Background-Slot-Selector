script_name("VST Background Slot Selector")
script_author("Saifeddine Ben Salem")

require "lib.moonloader"
local sampev = require "lib.samp.events"
local ffi = require "ffi"

-- =========================================================
-- SA-MP INPUT STRUCTURES
-- =========================================================

ffi.cdef[[
    typedef struct stInputBox
    {
        void* pUnknown;

        uint8_t bIsChatboxOpen;
        uint8_t bIsMouseInChatbox;
        uint8_t bMouseClickRelated;
        uint8_t unk;

        uint32_t dwPosChatInput[2];

        uint8_t unk2[263];

        int iCursorPosition;

        uint8_t unk3;

        int iMarkedTextStartPos;

        uint8_t unk4[20];

        int iMouseLeftButton;

    } stInputBox;

    typedef struct stInputInfo
    {
        void* pD3DDevice;
        void* pDXUTDialog;
        stInputBox* pDXUTEditBox;

    } stInputInfo;
]]

-- =========================================================
-- VARIABLES
-- =========================================================

local carSlots = {}

-- Tracks the vehicles that are currently spawned.
-- Key = vehicle slot/index
-- Value = true when spawned
local spawnedSlots = {}

local pendingSlot = nil

local requestingVST = false

local suppressNextVSTDialog = false

-- =========================================================
-- FONT
-- =========================================================

local font =
    renderCreateFont(
        "Arial",
        11,
        5
    )

-- =========================================================
-- DISPLAY SETTINGS
-- =========================================================

local LINE_HEIGHT = 21

local MAX_VISIBLE = 12

-- Horizontal offset from the real chat input.
local LIST_X_OFFSET = 0

-- Vertical offset from the bottom of the chat input.
local LIST_Y_OFFSET = 30

-- Approximate height of the SA-MP chat input.
local CHAT_INPUT_HEIGHT = 28

-- =========================================================
-- UTILS
-- =========================================================

local function trim(s)

    if not s then
        return ""
    end

    return s:gsub(
        "^%s*(.-)%s*$",
        "%1"
    )
end

local function stripColors(s)

    if not s then
        return ""
    end

    return s:gsub(
        "{%x%x%x%x%x%x}",
        ""
    )
end

local function getLines(text)

    local lines = {}

    if not text then
        return lines
    end

    text =
        text:gsub(
            "\r",
            ""
        )

    for line in
        (text .. "\n"):gmatch("(.-)\n")
    do

        line =
            trim(line)

        if line ~= "" then

            table.insert(
                lines,
                line
            )
        end
    end

    return lines
end

-- =========================================================
-- CHECK /VST INPUT
-- =========================================================

local function isVSTInput(text)

    if not text then
        return false
    end

    return text:lower():match(
        "^/vst%s*.*$"
    ) ~= nil
end

-- =========================================================
-- GET TEXT AFTER /VST
-- =========================================================

local function getSearchText(text)

    if not text then
        return ""
    end

    local search =
        text:match(
            "^/vst%s*(.*)$"
        )

    if not search then
        return ""
    end

    return trim(search):lower()
end

-- =========================================================
-- FILTER VEHICLES
-- =========================================================

local function getMatches(input)

    local search =
        getSearchText(input)

    local result = {}

    for i, vehicle in ipairs(carSlots) do

        local clean =
            stripColors(vehicle)

        -- Nothing typed after /vst:
        -- show every vehicle.

        if search == "" then

            table.insert(
                result,
                {
                    index = i,
                    text = clean
                }
            )

        -- Something typed after /vst:
        -- filter matching vehicle names.

        elseif clean:lower():find(
            search,
            1,
            true
        ) then

            table.insert(
                result,
                {
                    index = i,
                    text = clean
                }
            )
        end
    end

    return result
end

-- =========================================================
-- GET REAL SA-MP CHAT INPUT POSITION
-- =========================================================

local function getRealChatInputPosition()

    local ok, inputPtr =
        pcall(
            sampGetInputInfoPtr
        )

    if not ok or
       not inputPtr then

        return nil, nil
    end

    local input =
        ffi.cast(
            "stInputInfo*",
            inputPtr
        )[0]

    if input.pDXUTEditBox == nil then
        return nil, nil
    end

    local edit =
        input.pDXUTEditBox[0]

    -- Chat box isn't actually open.

    if edit.bIsChatboxOpen == 0 then
        return nil, nil
    end

    local x =
        tonumber(
            edit.dwPosChatInput[0]
        )

    local y =
        tonumber(
            edit.dwPosChatInput[1]
        )

    return x, y
end

-- =========================================================
-- DRAW VEHICLE SUGGESTIONS
-- =========================================================

local function drawVehicleSuggestions(input)

    if #carSlots == 0 then
        return
    end

    local matches =
        getMatches(input)

    if #matches == 0 then
        return
    end

    -- Get the actual chat input position.

    local x, y =
        getRealChatInputPosition()

    if not x or not y then
        return
    end

    -- =====================================================
    -- CALCULATE LIST POSITION
    -- =====================================================

    local drawX =
        x + LIST_X_OFFSET

    local drawY =
        y +
        CHAT_INPUT_HEIGHT +
        LIST_Y_OFFSET

    -- =====================================================
    -- LIMIT NUMBER OF RESULTS
    -- =====================================================

    local visible =
        math.min(
            #matches,
            MAX_VISIBLE
        )

    -- =====================================================
    -- DRAW TEXT ONLY
    -- =====================================================

    for i = 1, visible do

        local vehicle =
            matches[i]

        local rowY =
            drawY +
            ((i - 1) * LINE_HEIGHT)

        local display =
            string.format(
                "%d  %s",
                vehicle.index,
                vehicle.text
            )

        -- =================================================
        -- COLOR
        -- =================================================
        --
        -- DEFAULT:
        -- White
        --
        -- CURRENTLY SPAWNED:
        -- Green
        --
        -- STORED/HIDDEN:
        -- White
        -- =================================================

        local textColor =
            0xFFFFFFFF

        if spawnedSlots[vehicle.index] then
            textColor =
                0xFF00FF00
        end

        renderFontDrawText(
            font,
            display,
            drawX + 6,
            rowY + 1,
            textColor
        )
    end
end

-- =========================================================
-- VEHICLE STATE HELPERS
-- =========================================================

local function setVehicleSpawned(slot, isSpawned)

    slot = tonumber(slot)

    if not slot then
        return
    end

    if isSpawned then

        spawnedSlots[slot] = true

    else

        -- IMPORTANT:
        -- Completely remove the slot from the table.
        -- This makes the line WHITE again.

        spawnedSlots[slot] = nil
    end
end

-- =========================================================
-- TOGGLE VEHICLE STATE
-- =========================================================
--
-- This is the important fix.
--
-- Previously:
--
--     spawnedSlots[pendingSlot] = true
--
-- That meant once a vehicle became green,
-- nothing ever removed it.
--
-- Now:
--
--     WHITE -> GREEN
--     GREEN -> WHITE
--
-- So when a vehicle is hidden/stored again,
-- its line doesn't stay green forever.
-- =========================================================

local function toggleVehicleState(slot)

    slot = tonumber(slot)

    if not slot then
        return
    end

    if spawnedSlots[slot] then

        -- Vehicle was previously spawned.
        -- It has now been stored/hidden.

        setVehicleSpawned(
            slot,
            false
        )

    else

        -- Vehicle was stored.
        -- It has now been spawned.

        setVehicleSpawned(
            slot,
            true
        )
    end
end

-- =========================================================
-- MAIN
-- =========================================================

function main()

    repeat
        wait(0)
    until isSampAvailable()

    -- =====================================================
    -- ONLY SCRIPT MESSAGE IN SA-MP CHAT
    -- =====================================================

    sampAddChatMessage(
        "{00FF00}[VST] {FFFFFF}Background selector loaded. Created by Saifeddine Ben Salem.",
        -1
    )

    while true do

        wait(0)

        -- =================================================
        -- CHAT INPUT OPEN
        -- =================================================

        if sampIsChatInputActive() then

            local input =
                sampGetChatInputText()

            -- =================================================
            -- PLAYER IS TYPING /VST
            -- =================================================

            if isVSTInput(input) then

                -- =========================================
                -- LOAD VST VEHICLES AUTOMATICALLY
                -- =========================================

                if #carSlots == 0 and
                   not requestingVST then

                    requestingVST = true

                    suppressNextVSTDialog = true

                    sampSendChat(
                        "/vst"
                    )
                end

                -- =========================================
                -- DISPLAY SUGGESTIONS
                -- =========================================

                drawVehicleSuggestions(
                    input
                )
            end
        end
    end
end

-- =========================================================
-- /VST [NUMBER]
-- =========================================================
--
-- Examples:
--
-- /vst 1
-- /vst 2
-- /vst 6
--
-- The original command is intercepted and the script
-- selects the corresponding row in the server dialog.
-- =========================================================

function sampev.onSendCommand(command)

    local slot =
        command:lower():match(
            "^/vst%s+(%d+)%s*$"
        )

    if slot then

        slot =
            tonumber(slot)

        if slot < 1 then
            return false
        end

        pendingSlot =
            slot

        -- Ask the server for its actual VST dialog.

        sampSendChat(
            "/vst"
        )

        -- Don't send the original /vst [number].

        return false
    end

    -- =====================================================
    -- EVERYTHING ELSE IS UNTOUCHED
    -- =====================================================

    return true
end

-- =========================================================
-- VST DIALOG HANDLER
-- =========================================================

function sampev.onShowDialog(
    id,
    style,
    title,
    button1,
    button2,
    text
)

    local titleLower =
        tostring(title):lower()

    -- =====================================================
    -- IGNORE NON-VST DIALOGS
    -- =====================================================

    if not titleLower:find(
        "vehicle storage",
        1,
        true
    ) then

        return true
    end

    -- =====================================================
    -- PARSE SERVER VEHICLE LIST
    -- =====================================================

    local lines =
        getLines(text)

    -- =====================================================
    -- CACHE VEHICLES
    -- =====================================================

    if #lines > 0 then

        carSlots = {}

        for i = 1, #lines do

            carSlots[i] =
                lines[i]
        end
    end

    -- =====================================================
    -- AUTOMATIC BACKGROUND REQUEST
    -- =====================================================
    --
    -- This dialog was opened by the script itself only
    -- to obtain the vehicle list.
    --
    -- Don't show it to the player.
    -- =====================================================

    if suppressNextVSTDialog then

        suppressNextVSTDialog = false

        requestingVST = false

        return false
    end

    -- =====================================================
    -- /VST [NUMBER]
    -- =====================================================
    --
    -- Select row automatically.
    -- =====================================================

    if pendingSlot ~= nil then

        -- No vehicles.

        if #lines == 0 then

            pendingSlot = nil

            return false
        end

        -- =================================================
        -- INVALID SLOT
        -- =================================================

        if pendingSlot > #lines then

            pendingSlot = nil

            return false
        end

        -- =================================================
        -- SA-MP DIALOG ROWS ARE ZERO-BASED
        -- =================================================

        local row =
            pendingSlot - 1

        -- =================================================
        -- SELECT VEHICLE
        -- =================================================

        sampSendDialogResponse(
            id,
            1,
            row,
            ""
        )

        -- =================================================
        -- FIXED STATE HANDLING
        -- =================================================
        --
        -- Previously the script always did:
        --
        --     spawnedSlots[pendingSlot] = true
        --
        -- Therefore a green line could NEVER return
        -- to white.
        --
        -- Now the state is toggled:
        --
        --     stored  -> spawned -> GREEN
        --     spawned -> stored  -> WHITE
        --
        -- =================================================

        toggleVehicleState(
            pendingSlot
        )

        pendingSlot = nil

        -- Keep the selection completely in background.

        return false
    end

    -- =====================================================
    -- NORMAL /VST
    -- =====================================================
    --
    -- If the player manually types:
    --
    -- /vst
    --
    -- the ORIGINAL SERVER VST MENU appears normally.
    -- =====================================================

    return true
end
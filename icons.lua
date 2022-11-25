local ADDONNAME, ns = ...

local L = LibStub("AceLocale-3.0"):GetLocale(ADDONNAME)

local C_QuestLog = C_QuestLog
local C_Timer = C_Timer
local math = math

local Pins = LibStub("HereBeDragons-Pins-2.0")

local PINS_REF = ADDONNAME .. "Pins"
local ICON_FALLBACK do
    local ICON_PATH = "Interface/AddOns/" .. ADDONNAME .. "/icons/minimap_icon.blp"
    ICON_FALLBACK = GetFileIDFromPath(ICON_PATH) or ICON_PATH
end

-- luacheck: ignore 11[1-3]/LunarlightPodHelperDB
LunarlightPodHelperDB = LunarlightPodHelperDB or { ts = 0 }


local treasureStates = {}
local tickerHandle = nil

local posPaar2XY = setmetatable({}, {__index = function(t, posPaar)
    local v = {
        math.floor(posPaar / 10000) / 10000,
        (posPaar % 10000) / 10000,
    }
    t[posPaar] = v
    return v
end})


local function setup_state(treasure)
    local data = ns.TREASURE_DATA[treasure]

    if data then
        local mapID = ns.TREASURE_MAP[treasure] or C_Map.GetBestMapForUnit("player") or nil
        local state =  {
            activeSet = nil,
            mapID = mapID,
            iconID = ns.TREASURE_ICON[treasure] or ICON_FALLBACK,
            distance = ns.MAP_DISTANCE[mapID or 0] or nil,
            positions = {},
        }
        treasureStates[treasure] = state

        local activeSet = nil

        local isQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted
        for questID, positions in pairs(data) do
            if not isQuestFlaggedCompleted(questID) then
                local quest_pos = {}
                state.positions[questID] = quest_pos

                for posPaar, setID in pairs(positions) do
                    if activeSet == nil then
                        activeSet = setID
                    elseif activeSet ~= setID then
                        activeSet = false
                    end

                    quest_pos[posPaar] = setID
                end
            end
        end

        if not next(state.positions) then
            return false -- no positions to display
        end

        if activeSet then
            state.activeSet = activeSet
        end

        return true
    end
end

local add_pin, remove_pin, remove_all_pins do
    local framePool = CreateFramePool("Frame")
    local activePins = {}

    function add_pin(mapID, posPaar, iconID)
        if activePins[mapID .. posPaar] then return end

        local icon, new = framePool:Acquire()
        if new then
            icon:SetSize(8, 8)
            -- "ARTWORK" "OVERLAY"
            local texture = icon:CreateTexture(nil, "ARTWORK")
            texture:SetAllPoints()

            icon.texture = texture
        end
        icon.texture:SetTexture(iconID)
        activePins[mapID .. posPaar] = icon

        local x, y = unpack(posPaar2XY[posPaar])
        Pins:AddMinimapIconMap(PINS_REF, icon, mapID, x, y, false, true)
    end

    function remove_pin(mapID, posPaar)
        local icon = activePins[mapID .. posPaar]
        if not icon then return end

        activePins[mapID .. posPaar] = nil
        Pins:RemoveMinimapIcon(PINS_REF, icon)
        framePool:Release(icon)
    end

    function remove_all_pins()
        wipe(activePins)
        Pins:RemoveAllMinimapIcons(PINS_REF)
        framePool:ReleaseAll()
    end
end

local check_quests do
    local DEFAULT_MAX_DISTANCE = 5 / 10000

    function check_quests()
        local isQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted
        local unregister = true

        local playerPosition = nil
        local ppX, ppY
        for _, state in pairs(treasureStates) do
            if state.active then
                local mapID = state.mapID or C_Map.GetBestMapForUnit("player")
                unregister = false

                if not state.activeSet and not playerPosition then
                    playerPosition = C_Map.GetPlayerMapPosition(mapID, "player")
                    ppX, ppY = playerPosition:GetXY()
                end

                local maxDistance = state.distance or DEFAULT_MAX_DISTANCE

                for questID, data in pairs(state.positions) do
                    if isQuestFlaggedCompleted(questID) then
                        if not state.activeSet then
                            local sets = {}

                            for posPaar, setID in pairs(data) do
                                local posX, posY = unpack(posPaar2XY[posPaar])
                                local x = ppX - posX
                                local y = ppY - posY

                                local distance = (x * x + y * y)^0.5
                                if distance <= maxDistance then
                                    sets[setID] = distance
                                end
                            end

                            -- clear unused sets
                            local count = 0
                            for _ in pairs(sets) do
                                count = count + 1
                            end
                            if count == 1 then
                                local id = next(sets)
                                state.activeSet = id or true
                            end
                            if count > 0 then
                                for _, _data in pairs(state.positions) do
                                    for posPaar, setID in pairs(_data) do
                                        if not sets[setID] then
                                            remove_pin(mapID, posPaar)
                                            _data[posPaar] = nil
                                        end
                                    end
                                end
                            else
                                --@debug@
                                DEFAULT_CHAT_FRAME:AddMessage(
                                    string.format("%s: Unknown treasure position:", ADDONNAME)
                                )
                                DEFAULT_CHAT_FRAME:AddMessage(
                                    string.format("    Quest: %d, [%d%d] = SET.?", questID, ppX*10000, ppY*10000)
                                )
                                --@end-debug@
                                DEFAULT_CHAT_FRAME:AddMessage(
                                    string.format(L.NO_POSITION_FOUND_S, ADDONNAME)
                                )
                            end
                        end

                        for posPaar in pairs(data) do
                            remove_pin(mapID, posPaar)
                        end
                        state.positions[questID] = nil
                    end
                end

                if not next(state.positions) then
                    -- no active quests deactivate state
                    -- ticker will be disabled on next tick when no other states are active
                    state.active = false
                end
            end
        end

        if unregister and tickerHandle then
            tickerHandle:Cancel()
            tickerHandle = nil
            remove_all_pins() -- remove orphaned pins, should not happen but you never know..
        end
    end
end

local function enable_tracking(treasure)
    if not treasureStates[treasure] then
        if not setup_state(treasure) then return end
    end

    local state = treasureStates[treasure]
    state.active = true

    local mapID = state.mapID or 0
    local iconID = state.iconID
    for _, data in pairs(state.positions) do
        for posPaar in pairs(data) do
            add_pin(mapID, posPaar, iconID)
        end
    end

    if not tickerHandle then
        tickerHandle = C_Timer.NewTicker(0.25, check_quests)
    end
end

local function disable_tracking(treasure)
    local state = treasureStates[treasure]

    if state then
        -- ticker will auto cancel with no active states
        state.active = false
        local mapID = state.mapID or 0

        for posPaar in pairs(state.positions) do
            remove_pin(mapID, posPaar)
        end
    end
end

ns.OnCallback.ENTERED_TREASURE_ZONE = function(event, treasure)
    enable_tracking(treasure)
end

ns.OnCallback.LEAVED_TREASURE_ZONE = function(event, treasure)
    disable_tracking(treasure)
end

ns.OnEvent.ADDON_LOADED = function(event, arg1)
    if arg1 ~= ADDONNAME then return end

    local ts = GetServerTime() - 60 * 15 -- 15 minutes in the past
    if LunarlightPodHelperDB.ts >= ts then
        local dbTreasureState = LunarlightPodHelperDB.treasureStates

        if dbTreasureState then
            for pod, state in pairs(dbTreasureState) do
                treasureStates[pod] = state
            end
        end
    end
    LunarlightPodHelperDB.podStates = nil -- NOTE: remove me on a later release
    LunarlightPodHelperDB.treasureStates = treasureStates

    return true
end

ns.OnEvent.PLAYER_LOGOUT = function(event)
    LunarlightPodHelperDB.ts = GetServerTime()

    -- clear finished/empty states
    for treasure, state in pairs(treasureStates) do
        if not next(state.positions) then
            treasureStates[treasure] = nil
        end
    end
    LunarlightPodHelperDB.treasureStates = treasureStates
end


local ADDONNAME, ns = ...


local C_QuestLog = C_QuestLog

local Pins = LibStub("HereBeDragons-Pins-2.0")

local ARDENWEALD_UIMAPID = ns.ARDENWEALD_UIMAPID
local PINS_REF = ADDONNAME .. "Pins"
local ICON do
    local ICON_PATH = "Interface/AddOns/" .. ADDONNAME .. "/icons/minimap_icon.blp"
    ICON = GetFileIDFromPath(ICON_PATH) or ICON_PATH
end

-- luacheck: ignore 11[1-3]/LunarlightPodHelperDB
LunarlightPodHelperDB = LunarlightPodHelperDB or { ts = 0 }


local podStates = {}
local tickerHandle = nil

local posPaar2XY = setmetatable({}, {__index = function(t, posPaar)
    local v = {
        floor(posPaar / 10000) / 10000,
        (posPaar % 10000) / 10000,
    }
    t[posPaar] = v
    return v
end})


local function setup_state(pod)
    local data = ns.POD_DATA[pod]

    if data then
        local state =  {
            activeSet = nil,
            positions = {},
        }
        podStates[pod] = state

        local activeSet = nil

        for questID, positions in pairs(data) do
            if not C_QuestLog.IsQuestFlaggedCompleted(questID) then
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

    function add_pin(posPaar)
        if activePins[posPaar] then return end

        local icon, new = framePool:Acquire()
        if new then
            icon:SetSize(8, 8)
            -- "ARTWORK" "OVERLAY"
            local texture = icon:CreateTexture(nil, "ARTWORK")
            texture:SetAllPoints()
            texture:SetTexture(ICON)

            icon.texture = texture
        end
        activePins[posPaar] = icon

        local x, y = unpack(posPaar2XY[posPaar])
        Pins:AddMinimapIconMap(PINS_REF, icon, ARDENWEALD_UIMAPID, x, y, false, true)
    end

    function remove_pin(posPaar)
        local icon = activePins[posPaar]
        if not icon then return end

        activePins[posPaar] = nil
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
    local NEAR_DISTANCE = 4.1 / 10000

    function check_quests()
        local unregister = true

        local playerPosition = nil
        local ppX, ppY
        for _, state in pairs(podStates) do
            if state.active then
                unregister = false

                if not state.activeSet and not playerPosition then
                    playerPosition = C_Map.GetPlayerMapPosition(ARDENWEALD_UIMAPID, "player")
                    ppX, ppY = playerPosition:GetXY()
                end

                for questID, data in pairs(state.positions) do
                    if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                        if not state.activeSet then
                            local sets = {}

                            for posPaar, setID in pairs(data) do
                                local posX, posY = unpack(posPaar2XY[posPaar])
                                local x = ppX - posX
                                local y = ppY - posY

                                local distance = (x * x + y * y)^0.5
                                if distance <= NEAR_DISTANCE then
                                    sets[setID] = distance
                                end
                            end

                            -- clear unused sets
                            local count = 0
                            for _ in pairs(sets) do
                                count = count + 1
                            end
                            if count == 1 then
                                state.activeSet = next(sets)
                            end
                            if count > 0 then
                                for _, _data in pairs(state.positions) do
                                    for posPaar, setID in pairs(_data) do
                                        if not sets[setID] then
                                            remove_pin(posPaar)
                                            _data[posPaar] = nil
                                        end
                                    end
                                end
                            else
                                DEFAULT_CHAT_FRAME:AddMessage(string.format("%s: Unknown Lunarpod position:", ADDONNAME))
                                DEFAULT_CHAT_FRAME:AddMessage(
                                    string.format("    Quest: %d, [%d%d] = SET.?", questID, ppX*10000, ppY*10000)
                                )
                            end
                        end

                        for posPaar in pairs(data) do
                            remove_pin(posPaar)
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

local function enable_tracking(pod)
    if not podStates[pod] then
        if not setup_state(pod) then return end
    end

    local state = podStates[pod]
    state.active = true

    for _, data in pairs(state.positions) do
        for posPaar in pairs(data) do
            add_pin(posPaar)
        end
    end

    if not tickerHandle then
        tickerHandle = C_Timer.NewTicker(0.25, check_quests)
    end
end

local function disable_tracking(pod)
    local state = podStates[pod]

    if state then
        -- ticker will auto cancel with no active states
        state.active = false

        for posPaar in pairs(state.positions) do
            remove_pin(posPaar)
        end
    end
end

ns.OnCallback.ENTERED_LUNARPOD_ZONE = function(event, pod)
    enable_tracking(pod)
end

ns.OnCallback.LEAVED_LUNARPOD_ZONE = function(event, pod)
    disable_tracking(pod)
end

ns.OnEvent.ADDON_LOADED = function(event, arg1)
    if arg1 ~= ADDONNAME then return end

    local ts = GetServerTime() - 60 * 15 -- 15 minutes in the past
    if LunarlightPodHelperDB.ts >= ts then
        local dbPodState = LunarlightPodHelperDB.podStates

        if dbPodState then
            for pod, state in pairs(dbPodState) do
                podStates[pod] = state
            end
        end

        LunarlightPodHelperDB.podStates = nil
    end

    return true
end

ns.OnEvent.PLAYER_LOGOUT = function(event)
    LunarlightPodHelperDB.ts = GetServerTime()

    -- clear finished/empty states
    for pod, state in pairs(podStates) do
        if not next(state.positions) then
            podStates[pod] = nil
        end
    end
    LunarlightPodHelperDB.podStates = podStates
end


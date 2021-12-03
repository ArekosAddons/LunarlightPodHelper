local ADDONNAME, ns = ...


local cancel_VIGNETTE_MINIMAP_UPDATED = false
local VIGNETTE_MINIMAP_UPDATED do
    local treasuresInRage = {}

    local inside = function(treasure)
        if not treasuresInRage[treasure] then
            treasuresInRage[treasure] = true
            ns.OnCallback.ENTERED_TREASURE_ZONE(treasure)
        end
    end
    local outside = function(treasure)
        if treasuresInRage[treasure] then
            treasuresInRage[treasure] = false
            ns.OnCallback.LEAVED_TREASURE_ZONE(treasure)
        end
    end

    VIGNETTE_MINIMAP_UPDATED = function(event, vignetteGUID, _, vignetteInfo)
        if cancel_VIGNETTE_MINIMAP_UPDATED then
            cancel_VIGNETTE_MINIMAP_UPDATED = false
            return true
        end
        vignetteInfo = vignetteInfo or C_VignetteInfo.GetVignetteInfo(vignetteGUID)

        if vignetteInfo and vignetteInfo.objectGUID then
            local _, _, _, _, _, objectID = string.split("-", vignetteInfo.objectGUID)

            local treasure = ns.ACTIVE_TREASURES[objectID]
            if treasure then
                if vignetteInfo.onMinimap then
                    inside(treasure)
                else
                    outside(treasure)
                end
            else
                treasure = ns.FINISHED_TREASURES[objectID]
                if treasure then
                    outside(treasure)
                end
            end
        end
    end
end


local in_MOI do
    local MOI = {
        [0] = false,
        [ns.ARDENWEALD_UIMAPID] = true,
    }
    local cache = {}

    in_MOI  = function()
        local currentMapID = C_Map.GetBestMapForUnit("player") or 0
        do
            local result = MOI[currentMapID]
            if result ~= nil then
                return result
            end

            result = cache[currentMapID]
            if result ~= nil then
                return result
            end
        end

        local mapID = currentMapID
        while true do
            local info = C_Map.GetMapInfo(mapID)
            if info and info.parentMapID ~= 0 then
                mapID = info.parentMapID
                if MOI[mapID] then
                    cache[currentMapID] = true
                    return true
                end
            else
                cache[currentMapID] = false
                return false
            end
        end
    end
end

ns.OnEvent.ZONE_CHANGED_NEW_AREA = function(event)
    if in_MOI() then
        cancel_VIGNETTE_MINIMAP_UPDATED = false
        ns.OnEvent.VIGNETTE_MINIMAP_UPDATED = VIGNETTE_MINIMAP_UPDATED
        -- if already registered, will simple overwrite it self

        -- call VIGNETTE_MINIMAP_UPDATED for already existing vignettes
        for _, vignetteGUID in pairs(C_VignetteInfo.GetVignettes()) do
            local vignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
            if vignetteInfo then
                VIGNETTE_MINIMAP_UPDATED("VIGNETTE_MINIMAP_UPDATED", vignetteGUID, vignetteInfo.onMinimap, vignetteInfo)
            end
        end
    else
        cancel_VIGNETTE_MINIMAP_UPDATED = true
    end
end

do-- Logging/Entering world
    local trigger_event = function()
        ns.OnEvent("ZONE_CHANGED_NEW_AREA")
    end

    if IsLoggedIn() then
        C_Timer.After(0, trigger_event)
    else
        ns.OnEvent.PLAYER_LOGIN = function(event)
            C_Timer.After(0, trigger_event)
            return true
        end
    end
end

local ADDONNAME, ns = ...


local ARDENWEALD_UIMAPID = ns.ARDENWEALD_UIMAPID


local cancel_VIGNETTE_MINIMAP_UPDATED = false
local VIGNETTE_MINIMAP_UPDATED do
    local podsInRage = {}

    local inside = function(pod)
        if not podsInRage[pod] then
            podsInRage[pod] = true
            ns.OnCallback.ENTERED_LUNARPOD_ZONE(pod)
        end
    end
    local outside = function(pod)
        if podsInRage[pod] then
            podsInRage[pod] = false
            ns.OnCallback.LEAVED_LUNARPOD_ZONE(pod)
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

            local pod = ns.ACTIVE_PODS[objectID]
            if pod then
                if vignetteInfo.onMinimap then
                    inside(pod)
                else
                    outside(pod)
                end
            else
                pod = ns.FINISHED_PODS[objectID]
                if pod then
                    outside(pod)
                end
            end
        end
    end
end


local in_ardenweald do
    local cache = {}

    in_ardenweald  = function()
        local currentMapID = C_Map.GetBestMapForUnit("player")
        if currentMapID == ARDENWEALD_UIMAPID then
            return true
        end

        if cache[currentMapID] ~= nil then
            return cache[currentMapID]
        end

        local mapID = currentMapID
        while true do
            local info = C_Map.GetMapInfo(mapID)
            if info and info.parentMapID ~= 0 then
                mapID = info.parentMapID
                if mapID == ARDENWEALD_UIMAPID then
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
    if in_ardenweald() then
        cancel_VIGNETTE_MINIMAP_UPDATED = false
        ns.OnEvent.VIGNETTE_MINIMAP_UPDATED = VIGNETTE_MINIMAP_UPDATED
        -- if already registered, will simple overwrite it self

        -- VIGNETTE_MINIMAP_UPDATED does not trigger for already existing vignettes
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

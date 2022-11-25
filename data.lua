local ADDONNAME, ns = ...

ns.ARDENWEALD_UIMAPID = 1565
ns.MALDRAXXUS_UIMAPID = 1536

ns.MAP_DISTANCE = {
    [ns.ARDENWEALD_UIMAPID] = 10 / 10000,
    [ns.MALDRAXXUS_UIMAPID] = 150 / 10000,
}

ns.TREASURES = {
    -- Ardenweald: Lunarpods
    LARGE = "large",
    DREAMSHRINE = "Dreamshrine",
    GLITTERFALL_HEIGHTS_EAST = "Glitterfall Heights (East)",
    GLITTERFALL_HEIGHTS_WEST = "Glitterfall Heights (West)",
    GARDEN_OF_NIGHT = "Garden of Night",
    EVENTIDE_GROVE = "Eventide Grove",

    -- Maldraxxus: Runecoffers
    CHOSEN = "chosen",
    HOUSE_OF_CONSTRUCTS = "House of Constructs",
    HOUSE_OF_RITUALS = "House of Rituals",
}

ns.TREASURE_MAP = {
    [ns.TREASURES.LARGE] = ns.ARDENWEALD_UIMAPID,
    [ns.TREASURES.DREAMSHRINE] = ns.ARDENWEALD_UIMAPID,
    [ns.TREASURES.GLITTERFALL_HEIGHTS_EAST] = ns.ARDENWEALD_UIMAPID,
    [ns.TREASURES.GLITTERFALL_HEIGHTS_WEST] = ns.ARDENWEALD_UIMAPID,
    [ns.TREASURES.GARDEN_OF_NIGHT] = ns.ARDENWEALD_UIMAPID,
    [ns.TREASURES.EVENTIDE_GROVE] = ns.ARDENWEALD_UIMAPID,

    [ns.TREASURES.CHOSEN] = ns.MALDRAXXUS_UIMAPID,
    [ns.TREASURES.HOUSE_OF_CONSTRUCTS] = ns.MALDRAXXUS_UIMAPID,
    [ns.TREASURES.HOUSE_OF_RITUALS] = ns.MALDRAXXUS_UIMAPID,
}

local ARDENWEALD_ICON do
    local ICON_PATH = "Interface/AddOns/" .. ADDONNAME .. "/icons/minimap_icon_ardenweald.blp"
    ARDENWEALD_ICON = GetFileIDFromPath(ICON_PATH) or ICON_PATH
end
local MALDRAXXUS_ICON do
    local ICON_PATH = "Interface/AddOns/" .. ADDONNAME .. "/icons/minimap_icon_maldraxxus.blp"
    MALDRAXXUS_ICON = GetFileIDFromPath(ICON_PATH) or ICON_PATH
end
ns.TREASURE_ICON = {
    [ns.TREASURES.LARGE] = ARDENWEALD_ICON,
    [ns.TREASURES.DREAMSHRINE] = ARDENWEALD_ICON,
    [ns.TREASURES.GLITTERFALL_HEIGHTS_EAST] = ARDENWEALD_ICON,
    [ns.TREASURES.GLITTERFALL_HEIGHTS_WEST] = ARDENWEALD_ICON,
    [ns.TREASURES.GARDEN_OF_NIGHT] = ARDENWEALD_ICON,
    [ns.TREASURES.EVENTIDE_GROVE] = ARDENWEALD_ICON,

    [ns.TREASURES.CHOSEN] = MALDRAXXUS_ICON,
    [ns.TREASURES.HOUSE_OF_CONSTRUCTS] = MALDRAXXUS_ICON,
    [ns.TREASURES.HOUSE_OF_RITUALS] = MALDRAXXUS_ICON,
}

ns.TREASURE_DATA = {}

--@debug@
function LLPH() -- luacheck: ignore 111/LLPH
    local first = true
    for _, vignetteGUID in pairs(C_VignetteInfo.GetVignettes()) do
        local vignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
        if vignetteInfo then
            print("Name:", vignetteInfo.name)
            print("GUID:", vignetteInfo.vignetteGUID)
            if vignetteInfo.objectGUID then
                local _, _, _, _, _, objectID = string.split("-", vignetteInfo.objectGUID)
                print(" objectGUID:", vignetteInfo.objectGUID)
                print(" objectID:", objectID)
            end
            if first then
                print(" ")
                first = false
            end
        end
    end
end
function LLPH_I(index) -- luacheck: ignore 111/LLPH_I
    index = tonumber(index) or 1
    local list = C_VignetteInfo.GetVignettes()
    local vignetteGUID = list[index]
    if not vignetteGUID then
        index = 1
        vignetteGUID = list[index]
    end
    local vignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUID)

    if vignetteInfo then
        print("[" .. index .. "] = {")
        for key, value in pairs(vignetteInfo) do
            -- [key] = value,
            print(" [" .. tostring(key) .. "]" .. " = " .. tostring(value) .. ",")
        end
        print("}")
    else
        print("No vignettes")
    end
end
--@end-debug@

ns.ACTIVE_TREASURES = {
    -- Ardenweald: Lunarpods
    ["356821"] = ns.TREASURES.LARGE,

    ["353769"] = ns.TREASURES.EVENTIDE_GROVE,
    ["353770"] = ns.TREASURES.GARDEN_OF_NIGHT,
    ["353771"] = ns.TREASURES.GLITTERFALL_HEIGHTS_WEST,
    ["353772"] = ns.TREASURES.GLITTERFALL_HEIGHTS_EAST,
    ["353773"] = ns.TREASURES.DREAMSHRINE,

    -- Maldraxxus: Runecoffers
    ["356759"] = ns.TREASURES.CHOSEN,
    ["355037"] = ns.TREASURES.HOUSE_OF_CONSTRUCTS,
    ["355038"] = ns.TREASURES.HOUSE_OF_RITUALS,
}

ns.FINISHED_TREASURES = {
    -- Ardenweald: Lunarpods
    ["356820"] = ns.TREASURES.LARGE,

    ["353681"] = ns.TREASURES.EVENTIDE_GROVE,
    ["353683"] = ns.TREASURES.GARDEN_OF_NIGHT,
    ["353684"] = ns.TREASURES.GLITTERFALL_HEIGHTS_WEST,
    ["353686"] = ns.TREASURES.DREAMSHRINE,
    ["353685"] = ns.TREASURES.GLITTERFALL_HEIGHTS_EAST,

    -- Maldraxxus: Runecoffers
    ["355035"] = ns.TREASURES.CHOSEN,
    ["364531"] = ns.TREASURES.HOUSE_OF_CONSTRUCTS,
    ["355036"] = ns.TREASURES.HOUSE_OF_RITUALS,
}

local SET = {
    ONE = "one",
    TWO = "two",
    THREE = "three",
    FOUR = "four",
    FIVE = "five",
    SIX = "six",
}

local LARGE_LUNAR_POD_QUEST_SET_POSISTIONS = {
    [61692] = {
        [51183249] = SET.ONE,
        [49943206] = SET.TWO,
        [50523181] = SET.THREE,
        [51013227] = SET.FOUR,
        [50253163] = SET.FIVE,
    },
    [61693] = {
        [50863301] = SET.ONE,
        [50323271] = SET.TWO,
        [50373295] = SET.THREE,
        [50593357] = SET.FOUR,
        [50033325] = SET.FIVE,
    },
    [61694] = {
        [51423329] = SET.ONE,
        [51883337] = SET.TWO,
        [51463408] = SET.THREE,
        [51813383] = SET.FOUR,
        [51003438] = SET.FIVE,
    },
    [61695] = {
        [51793235] = SET.ONE,
        [52003200] = SET.TWO,
        [51873145] = SET.THREE,
        [52323168] = SET.FOUR,
        [51983091] = SET.FIVE,
    },
    [61696] = {
        [52513374] = SET.ONE,
        [52903320] = SET.TWO,
        [52253243] = SET.THREE,
        [53093299] = SET.FOUR,
        [52463340] = SET.FIVE,
    },
}
ns.TREASURE_DATA[ns.TREASURES.LARGE] = LARGE_LUNAR_POD_QUEST_SET_POSISTIONS

-- Dreamshrine Basin
local DREAMSHRINE_QUEST_POSITIONS = {
    [60820] = {
        [60515642] = SET.ONE,
    },
    [60821] = {
        [60405734] = SET.ONE,
    },
    [60822] = {
        [61895684] = SET.ONE,
    },
    [60823] = {
        [61455626] = SET.ONE,
    },
    [60824] = {
        [61415754] = SET.ONE,
    },
}
ns.TREASURE_DATA[ns.TREASURES.DREAMSHRINE] = DREAMSHRINE_QUEST_POSITIONS

-- Glitterfall Heights
local GLITTERFALL_HEIGHTS_EAST_QUEST_POSITIONS = {
    [60815] = {
        [55683962] = SET.ONE,
    },
    [60816] = {
        [56043870] = SET.ONE,
    },
    [60817] = {
        [55283815] = SET.ONE,
    },
    [60818] = {
        [56143941] = SET.ONE,
    },
    [60819] = {
        [55173918] = SET.ONE,
    },
}
ns.TREASURE_DATA[ns.TREASURES.GLITTERFALL_HEIGHTS_EAST] = GLITTERFALL_HEIGHTS_EAST_QUEST_POSITIONS

local GLITTERFALL_HEIGHTS_WEST_QUEST_POSITIONS = {
    [60810] = {
        [48123582] = SET.ONE,
    },
    [60811] = {
        [47643433] = SET.ONE,
    },
    [60812] = {
        [48283372] = SET.ONE,
    },
    [60813] = {
        [48963447] = SET.ONE,
    },
    [60814] = {
        [48503463] = SET.ONE,
    },
}
ns.TREASURE_DATA[ns.TREASURES.GLITTERFALL_HEIGHTS_WEST] = GLITTERFALL_HEIGHTS_WEST_QUEST_POSITIONS

local GARDEN_OF_NIGHT_QUEST_POSITIONS = {
    [60805] = {
        [39665351] = SET.ONE,
    },
    [60806] = {
        [38855363] = SET.ONE,
    },
    [60807] = {
        [39185366] = SET.ONE,
    },
    [60808] = {
        [39485444] = SET.ONE,
    },
    [60809] = {
        [38795424] = SET.ONE,
    },
}
ns.TREASURE_DATA[ns.TREASURES.GARDEN_OF_NIGHT] = GARDEN_OF_NIGHT_QUEST_POSITIONS

-- Eventide Grove
local EVENTIDE_GROVE_QUEST_POSITIONS = {
    [60800] = {
        [47787097] = SET.ONE,
    },
    [60801] = {
        [48307120] = SET.ONE,
    },
    [60802] = {
        [48307152] = SET.ONE,
    },
    [60803] = {
        [48027019] = SET.ONE,
    },
    [60804] = {
        [48396998] = SET.ONE,
    },
}
ns.TREASURE_DATA[ns.TREASURES.EVENTIDE_GROVE] = EVENTIDE_GROVE_QUEST_POSITIONS

-- Chosen Runecoffer
local CHOSEN_RUNECOFFER_QUEST_POSITIONS = {
    [61648] = {
        [37626510] = SET.ONE,
        [38706414] = SET.TWO,
        [37806437] = SET.THREE,
        [38186463] = SET.FOUR,
    },
    [61649] = {
        [38936585] = SET.ONE,
        [39806545] = SET.TWO,
        [38096673] = SET.THREE,
        [39606432] = SET.FOUR,
    },
    [61650] = {
        [40156652] = SET.ONE,
        [39306639] = SET.TWO,
        [39116408] = SET.THREE,
        [38816662] = SET.FOUR,
    },
}
ns.TREASURE_DATA[ns.TREASURES.CHOSEN] = CHOSEN_RUNECOFFER_QUEST_POSITIONS

-- HOUSE_OF_CONSTRUCTS
local HOUSE_OF_CONSTRUCTS_QUEST_POSITIONS = {
    [61120] = {
        [31822260] = SET.ONE,
        [32432901] = SET.TWO,
        [26804641] = SET.THREE,
        [24333481] = SET.FOUR,
        [33093612] = SET.FIVE,
        [35493030] = SET.SIX,
    },
    [61121] = {
        [35322309] = SET.ONE,
        [30503136] = SET.TWO,
        [27545020] = SET.THREE,
        [26653130] = SET.FOUR,
        [31343356] = SET.FIVE,
        [35372786] = SET.SIX,
    },
    [61122] = {
        [33592224] = SET.ONE,
        [28952836] = SET.TWO,
        [26014796] = SET.THREE,
        [26613837] = SET.FOUR,
        [29353789] = SET.FIVE,
        [34003000] = SET.SIX,
    },
}
ns.TREASURE_DATA[ns.TREASURES.HOUSE_OF_CONSTRUCTS] = HOUSE_OF_CONSTRUCTS_QUEST_POSITIONS

local HOUSE_OF_RITUALS_QUEST_POSITIONS = {
    [61117] = {
        [63763324] = SET.ONE,
        [70143131] = SET.TWO,
        [69572843] = SET.THREE,
        [67362669] = SET.FOUR,
    },
    [61118] = {
        [65673461] = SET.ONE,
        [71633525] = SET.TWO,
        [66722905] = SET.THREE,
        [64802640] = SET.FOUR,
    },
    [61119] = {
        [64843583] = SET.ONE,
        [71603296] = SET.TWO, -- NOTE: below the carpet
        [68643200] = SET.THREE,
        [65422855] = SET.FOUR,
    },
}
ns.TREASURE_DATA[ns.TREASURES.HOUSE_OF_RITUALS] = HOUSE_OF_RITUALS_QUEST_POSITIONS

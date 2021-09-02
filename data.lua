local ADDONNAME, ns = ...


ns.ARDENWEALD_UIMAPID = 1565

ns.PODS = {
    LARGE = "large",
    DREAMSHRINE = "Dreamshrine",
    GLITTERFALL_HEIGHTS_EAST = "Glitterfall Heights (East)",
    GLITTERFALL_HEIGHTS_WEST = "Glitterfall Heights (West)",
    GARDEN_OF_NIGHT = "Garden of Night",
}

ns.POD_DATA = {}

ns.ACTIVE_PODS = {
    -- ["objectID"] = ns.PODS.NAME,
    ["356821"] = ns.PODS.LARGE,

    ["353772"] = ns.PODS.GLITTERFALL_HEIGHTS_EAST,
    ["353771"] = ns.PODS.GLITTERFALL_HEIGHTS_WEST,
    ["353773"] = ns.PODS.DREAMSHRINE,
    ["353770"] = ns.PODS.GARDEN_OF_NIGHT,
}

-- Missing Lunarpods objectIDs
-- 48.0 71.2 : 353769 => 353681

ns.FINISHED_PODS = {
    -- ["objectID"] = ns.PODS.NAME,
    ["356820"] = ns.PODS.LARGE,

    ["353685"] = ns.PODS.GLITTERFALL_HEIGHTS_EAST,
    ["353684"] = ns.PODS.GLITTERFALL_HEIGHTS_WEST,
    ["353686"] = ns.PODS.DREAMSHRINE,
    ["353683"] = ns.PODS.GARDEN_OF_NIGHT,
}

local SET = {
    ONE = "one",
    TWO = "two",
    THREE = "three",
    FOUR = "four",
    FIVE = "five",
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
ns.POD_DATA[ns.PODS.LARGE] = LARGE_LUNAR_POD_QUEST_SET_POSISTIONS

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
ns.POD_DATA[ns.PODS.DREAMSHRINE] = DREAMSHRINE_QUEST_POSITIONS

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
ns.POD_DATA[ns.PODS.GLITTERFALL_HEIGHTS_EAST] = GLITTERFALL_HEIGHTS_EAST_QUEST_POSITIONS

local GLITTERFALL_HEIGHTS_WEST_QUEST_POSITIONS = {
    [60810] = {
        [48123582] = true,
    },
    [60811] = {
        [47643433] = true,
    },
    [60812] = {
        [48283372] = true,
    },
    [60813] = {
        [48963447] = true,
    },
    [60814] = {
        [48503463] = true,
    },
}
ns.POD_DATA[ns.PODS.GLITTERFALL_HEIGHTS_WEST] = GLITTERFALL_HEIGHTS_WEST_QUEST_POSITIONS

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
ns.POD_DATA[ns.PODS.GARDEN_OF_NIGHT] = GARDEN_OF_NIGHT_QUEST_POSITIONS

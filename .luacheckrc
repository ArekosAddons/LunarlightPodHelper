std = "lua51"

max_code_line_length = 120
max_string_line_length = false
max_comment_line_length = false

max_cyclomatic_complexity = 32

ignore = {
    "211/ADDONNAME",
    "211/ns",
    "212/self",
    "212/event",
    -- "212/...",
}

read_globals = {
    "LibStub",

    "wipe",
    "string.split",

    "C_Map.GetBestMapForUnit",
    "C_Map.GetMapInfo",
    "C_Map.GetPlayerMapPosition",
    "C_QuestLog.IsQuestFlaggedCompleted",
    "C_Timer.After",
    "C_Timer.NewTicker",
    "C_VignetteInfo.GetVignetteInfo",
    "C_VignetteInfo.GetVignettes",

    "DEFAULT_CHAT_FRAME",

    "CallErrorHandler",
    "CreateFrame",
    "CreateFramePool",
    "GetFileIDFromPath",
    "GetServerTime",
    "IsLoggedIn",
    "UnitOnTaxi",
}

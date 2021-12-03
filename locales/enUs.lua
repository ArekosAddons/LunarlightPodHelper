local ADDONNAME = ...
local debug = false -- luacheck: ignore 311/debug
--@debug@
debug = true
--@end-debug@

local L = LibStub("AceLocale-3.0"):NewLocale(ADDONNAME, "enUS", true, debug) -- luacheck: ignore 113/LibStub
if not L then return end

L.NO_POSITION_FOUND_S = "%s: Try to stand still for the next one for a moment."

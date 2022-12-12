local ADDONNAME, ns = ...


do-- Event handling
    local frame = CreateFrame("Frame")
    local events = setmetatable({}, { __index = function(t, event)
        local callbacks = setmetatable({}, { __call = function(self, ...)
            for func in pairs(self) do
                local clear = securecallfunction(func, event, ...)

                if clear then
                    self[func] = nil
                end
            end

            if not next(self) then
                t[event] = nil
                frame:UnregisterEvent(event)
            end
        end})
        rawset(t, event, callbacks)

        securecallfunction(frame.RegisterEvent, frame, event)

        return callbacks
    end})

    ns.OnEvent = setmetatable({}, {
        __newindex = function(_, event, func)
            if type(func) == "function" then
                events[event][func] = true
            end
        end,
        __call = function(_, event, ...)
            if type(event) == "string" then
                events[event](...)
            end
        end,
    })

    frame:SetScript("OnEvent", function(self, event, ...)
        events[event](...)
    end)
end

do-- Callback handling
    -- callbacks = { -- metatable which will create inner tables for callbacks
    --     [callbackName] = { -- metatable when called calls its children, with callbackName and given arguments
    --         [function() end] = true, -- when returning true when called will be remove from list
    --     }
    -- },

    local callbacks = setmetatable({}, { __index = function(t, callbackName)
        local v = setmetatable({}, { __call = function(self, ...)
            for func in pairs(self) do
                local clear = securecallfunction(func, callbackName, ...)
                if clear then
                    self[func] = nil
                end
            end
        end})

        rawset(t, callbackName, v)
        return v
    end})

    -- Setting an index with a func will register a callback to be called
    -- Getting an index and calling it will fire all associate callbacks with the given arguments
    ns.OnCallback = setmetatable({}, {
        __newindex = function(_, callbackName, func) -- registering for a callback
            if type(func) == "function" then
                callbacks[callbackName][func] = true
            end
        end,
        __index = function(_, callbackName) -- firing callbacks
            return callbacks[callbackName]
        end,
    })
end

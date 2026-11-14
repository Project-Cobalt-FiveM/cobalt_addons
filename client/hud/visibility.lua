local hud <const> = exports.cobalt_hud

---@type table<string, true>
local hiders <const> = {}

local function hideEachFrame()
    while next(hiders) do
        HideHudAndRadarThisFrame()
        HideHelpTextThisFrame()
        Wait(0)
    end
end

local Visibility <const> = {}

---Hides the game HUD and cobalt_hud until every key passed here is shown again.
---@param key string
function Visibility.hide(key)
    if hiders[key] then return end

    local alreadyHidden <const> = next(hiders) ~= nil

    hiders[key] = true
    hud:SetHiddenBy(key, true)

    if not alreadyHidden then CreateThread(hideEachFrame) end
end

---@param key string
function Visibility.show(key)
    if not hiders[key] then return end

    hiders[key] = nil
    hud:SetHiddenBy(key, false)
end

return Visibility

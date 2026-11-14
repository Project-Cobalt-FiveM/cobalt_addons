local config <const> = require 'config'

---@class AddonsRemovedObject
---@field coords vector3
---@field radius number
---@field model integer

---@type AddonsRemovedObject[]
local removed <const> = config.removedObjects

for i = 1, #removed do
    local object <const> = removed[i]
    local coords <const> = object.coords

    CreateModelHideExcludingScriptObjects(coords.x, coords.y, coords.z, object.radius, object.model, true)
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end

    for i = 1, #removed do
        local object <const> = removed[i]
        local coords <const> = object.coords

        RemoveModelHide(coords.x, coords.y, coords.z, object.radius, object.model, false)
    end
end)

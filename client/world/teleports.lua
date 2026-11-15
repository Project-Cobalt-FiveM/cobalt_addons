local config <const> = require 'config'
local core <const> = exports.cobalt_core

local FADE_MS <const> = 300
local DEFAULT_PROMPT <const> = 'elevator'

---@class AddonsPortal
---@field coords vector3
---@field heading number
---@field length number
---@field width number
---@field allowVehicle boolean
---@field prompt? string key under `teleport` in locales/en.json

---@class AddonsPortalLink
---@field portal AddonsPortal
---@field destination AddonsPortal

---@type AddonsPortalLink?
local current
local travelling = false
local prompting = false

local function hidePrompt()
    if not prompting then return end

    prompting = false
    core:HideTextUI()
end

---@return boolean
local function canTravel()
    local state <const> = LocalPlayer.state

    if state.isDead or state.cuffed or state.escortedBy or state.jailed then return false end

    return not IsEntityAttached(cache.ped) and not IsPedRagdoll(cache.ped)
end

---@param link AddonsPortalLink
local function teleport(link)
    local ped <const> = cache.ped
    local coords <const> = link.destination.coords

    DoScreenFadeOut(FADE_MS)
    Wait(FADE_MS)

    if link.portal.allowVehicle then
        SetPedCoordsKeepVehicle(ped, coords.x, coords.y, coords.z)
    else
        SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    end

    SetEntityHeading(ped, link.destination.heading)
    Wait(FADE_MS)
    DoScreenFadeIn(FADE_MS)
end

local keybind <const> = lib.addKeybind({
    name = 'cobalt_addons_teleport',
    description = locale('teleport.keybind'),
    defaultKey = 'E',
    disabled = true,
    onReleased = function()
        local link <const> = current

        if not link or travelling or not canTravel() then return end

        travelling = true
        hidePrompt()
        teleport(link)
        travelling = false
    end,
})

---@param link AddonsPortalLink
local function enter(link)
    current = link
    keybind:disable(false)
    prompting = true

    local action <const> = locale(('teleport.%s'):format(link.portal.prompt or DEFAULT_PROMPT))

    core:ShowTextUI(locale('teleport.prompt', keybind:getCurrentKey(), action))
end

---@param link AddonsPortalLink
local function leave(link)
    if current ~= link then return end

    current = nil
    keybind:disable(true)
    hidePrompt()
end

for _, portals in ipairs(config.teleports) do
    for index, portal in ipairs(portals) do
        ---@type AddonsPortalLink
        local link <const> = { portal = portal, destination = portals[index == 1 and 2 or 1] }

        lib.zones.box({
            coords = portal.coords,
            size = vec3(portal.length, portal.width, 4.0),
            rotation = portal.heading,
            onEnter = function() enter(link) end,
            onExit = function() leave(link) end,
        })
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end

    hidePrompt()

    if IsScreenFadedOut() or IsScreenFadingOut() then DoScreenFadeIn(0) end
end)

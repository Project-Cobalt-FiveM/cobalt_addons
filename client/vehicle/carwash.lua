local config <const> = require 'config'
local core <const> = exports.cobalt_core

local blipConfig <const> = config.carWash.blip

local insideWash = false
local washing = false

---@param key string
---@param type string
local function notify(key, type)
    core:Notify({ description = locale(key), type = type, duration = 3000 })
end

---@type CKeybind
local keybind
local prompting = false

---@return boolean
local function driving()
    return cache.vehicle and cache.seat == -1 or false
end

local function refreshPrompt()
    local ready <const> = insideWash and not washing and driving()

    keybind:disable(not ready)

    if ready then
        prompting = true
        core:ShowTextUI(locale('wash.prompt', keybind:getCurrentKey()), { position = 'left-center' })
    elseif prompting then
        prompting = false
        core:HideTextUI()
    end
end

local function wash()
    local vehicle <const> = cache.vehicle

    if not vehicle or washing or not driving() then return end

    if GetVehicleDirtLevel(vehicle) <= config.carWash.dirtLevel then
        return notify('wash.clean', 'info')
    end

    washing = true
    refreshPrompt()

    local completed <const> = core:Progressbar({
        duration = math.random(4000, 8000),
        label = locale('wash.in_progress'),
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true },
    })

    if not completed then
        notify('wash.cancel', 'error')
    elseif lib.callback.await('cobalt_addons:server:washVehicle', false) then
        SetVehicleDirtLevel(vehicle, 0.0)
        SetVehicleUndriveable(vehicle, false)
        WashDecalsFromVehicle(vehicle, 1.0)
        notify('wash.done', 'success')
    end

    washing = false
    refreshPrompt()
end

keybind = lib.addKeybind({
    name = 'cobalt_addons_carwash',
    description = locale('wash.keybind'),
    defaultKey = 'E',
    disabled = true,
    onReleased = wash,
})

---@param inside boolean
local function setInside(inside)
    insideWash = inside
    refreshPrompt()
end

lib.onCache('vehicle', function()
    if insideWash then SetTimeout(0, refreshPrompt) end
end)

lib.onCache('seat', function()
    if insideWash then SetTimeout(0, refreshPrompt) end
end)

AddTextEntry(('BLIP_CAT_%d'):format(blipConfig.category), locale('wash.blip_category'))

for _, location in ipairs(config.carWash.locations) do
    lib.zones.box({
        coords = location.coords,
        size = vec3(location.length, location.width, 10.0),
        rotation = location.heading,
        onEnter = function() setInside(true) end,
        onExit = function() setInside(false) end,
    })

    local blip <const> = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)

    SetBlipSprite(blip, blipConfig.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, blipConfig.scale)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, blipConfig.colour)
    SetBlipCategory(blip, blipConfig.category)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(locale('wash.blip'))
    EndTextCommandSetBlipName(blip)
end

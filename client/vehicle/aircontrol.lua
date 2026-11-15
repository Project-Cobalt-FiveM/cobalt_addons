local config <const> = require 'config'

if not config.disable.airControl then return end

local IsEntityInAir <const> = IsEntityInAir
local DisableControlAction <const> = DisableControlAction

local INPUT_VEH_MOVE_LR <const> = 59
local INPUT_VEH_MOVE_UD <const> = 60
local AIR_CHECK_MS <const> = 100

---@type table<integer, true> motorcycle, cycle, boat, helicopter, plane
local exemptClasses <const> = {
    [8] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
}

---@type integer?
local watcher
local airborne = false

---@param vehicle integer
local function lockWhileAirborne(vehicle)
    airborne = true

    while watcher and cache.vehicle == vehicle and IsEntityInAir(vehicle) do
        DisableControlAction(0, INPUT_VEH_MOVE_LR, true)
        DisableControlAction(0, INPUT_VEH_MOVE_UD, true)
        Wait(0)
    end

    airborne = false
end

local function stop()
    if not watcher then return end

    ClearInterval(watcher)
    watcher = nil
end

---@param vehicle integer | false
---@param seat integer | false
local function update(vehicle, seat)
    stop()

    if not vehicle or seat ~= -1 then return end

    if exemptClasses[GetVehicleClass(vehicle)] then return end

    watcher = SetInterval(function()
        if airborne or not IsEntityInAir(vehicle) then return end

        CreateThread(function()
            lockWhileAirborne(vehicle)
        end)
    end, AIR_CHECK_MS)
end

lib.onCache('vehicle', function(vehicle)
    update(vehicle, cache.seat)
end)

lib.onCache('seat', function(seat)
    update(cache.vehicle, seat)
end)

update(cache.vehicle, cache.seat)

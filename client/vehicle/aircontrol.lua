local config <const> = require 'config'

if not config.disable.airControl then return end

local IsEntityInAir <const> = IsEntityInAir
local DisableControlAction <const> = DisableControlAction

local INPUT_VEH_MOVE_LR <const> = 59
local INPUT_VEH_MOVE_UD <const> = 60

---@type table<integer, true> motorcycle, cycle, boat, helicopter, plane
local exemptClasses <const> = {
    [8] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
}

---@type integer?
local interval

local function stop()
    if not interval then return end

    ClearInterval(interval)
    interval = nil
end

---@param vehicle integer | false
---@param seat integer | false
local function update(vehicle, seat)
    stop()

    if not vehicle or seat ~= -1 then return end

    if exemptClasses[GetVehicleClass(vehicle)] then return end

    interval = SetInterval(function()
        if not IsEntityInAir(vehicle) then return end

        DisableControlAction(0, INPUT_VEH_MOVE_LR, true)
        DisableControlAction(0, INPUT_VEH_MOVE_UD, true)
    end, 0)
end

lib.onCache('vehicle', function(vehicle)
    update(vehicle, cache.seat)
end)

lib.onCache('seat', function(seat)
    update(cache.vehicle, seat)
end)

update(cache.vehicle, cache.seat)

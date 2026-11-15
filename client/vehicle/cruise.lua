local core <const> = exports.cobalt_core
local GetEntitySpeed <const> = GetEntitySpeed

local MIN_FUEL <const> = 10
local DROP_TOLERANCE <const> = 1.5
local RECOVER_RATE <const> = 3.0
local INPUT_VEH_MOVE_LEFT_ONLY <const> = 63
local INPUT_VEH_MOVE_RIGHT_ONLY <const> = 64
local INPUT_VEH_HANDBRAKE <const> = 76
local INPUT_VEH_BRAKE <const> = 72

---@type table<integer, true> cycle, boat, helicopter, plane, train
local blockedClasses <const> = {
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
    [21] = true,
}

---@param key string
---@param kind string
local function notify(key, kind)
    core:Notify({ description = locale(key), type = kind, duration = 3000 })
end

local active = false

---@return boolean
local function steering()
    return IsControlPressed(2, INPUT_VEH_HANDBRAKE)
        or IsControlPressed(2, INPUT_VEH_MOVE_LEFT_ONLY)
        or IsControlPressed(2, INPUT_VEH_MOVE_RIGHT_ONLY)
end

---@param vehicle integer
---@param speed number
---@return boolean stillDriving
local function hold(vehicle, speed)
    local previous = GetEntitySpeed(vehicle)

    while active do
        if GetPedInVehicleSeat(vehicle, -1) ~= cache.ped then return false end

        if IsControlJustPressed(2, INPUT_VEH_BRAKE) then return true end
        if not GetIsVehicleEngineRunning(vehicle) then return true end

        local current <const> = GetEntitySpeed(vehicle)

        if current < previous - DROP_TOLERANCE then return true end

        if current < speed and not steering() and IsVehicleOnAllWheels(vehicle) then
            SetVehicleForwardSpeed(vehicle, math.min(speed, current + RECOVER_RATE * GetFrameTime()))
        end

        previous = current
        Wait(0)
    end

    return true
end

---@param vehicle integer
local function cruise(vehicle)
    local speed <const> = GetEntitySpeed(vehicle)

    if speed <= 0 or GetVehicleCurrentGear(vehicle) <= 0 then return end

    if (Entity(vehicle).state.fuel or GetVehicleFuelLevel(vehicle)) <= MIN_FUEL then
        return notify('cruise.not_enough_fuel', 'error')
    end

    active = true
    notify('cruise.activated', 'success')

    local stillDriving <const> = hold(vehicle, speed)
    active = false

    if stillDriving then notify('cruise.deactivated', 'error') end
end

lib.addKeybind({
    name = 'cobalt_addons_cruise',
    description = locale('keys.cruise'),
    defaultKey = 'Y',
    onPressed = function()
        if active then
            active = false
            return
        end

        local vehicle <const> = cache.vehicle

        if not vehicle or cache.seat ~= -1 or blockedClasses[GetVehicleClass(vehicle)] then return end

        cruise(vehicle)
    end,
})

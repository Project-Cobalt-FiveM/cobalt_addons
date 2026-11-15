local config <const> = require 'config'
local Cobalt <const> = exports.cobalt_core:GetCoreObject()
local core <const> = exports.cobalt_core

local PRICE <const> = config.carWash.price
local REASON <const> = 'car-washed'

---@param coords vector3
---@return boolean
local function atCarWash(coords)
    for _, location in ipairs(config.carWash.locations) do
        if #(coords - location.coords) <= math.max(location.length, location.width) then
            return true
        end
    end

    return false
end

---@param source integer
---@return table? player the washing driver, when they drive a vehicle at a wash
local function washingDriver(source)
    local ped <const> = GetPlayerPed(source)
    local vehicle <const> = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= ped then return end
    if not atCarWash(GetEntityCoords(ped)) then return end

    return Cobalt.Functions.GetPlayer(source)
end

---@param source integer
---@return boolean
local function refuseBroke(source)
    core:Notify(source, { description = locale('wash.no_money'), type = 'error' })

    return false
end

lib.callback.register('cobalt_addons:server:canWash', function(source)
    local player <const> = washingDriver(source)

    if not player then return false end

    local functions <const> = player.Functions

    if functions.GetMoney('cash') >= PRICE or functions.GetMoney('bank') >= PRICE then return true end

    return refuseBroke(source)
end)

lib.callback.register('cobalt_addons:server:washVehicle', function(source)
    local player <const> = washingDriver(source)

    if not player then return false end

    local functions <const> = player.Functions

    if functions.RemoveMoney('cash', PRICE, REASON) or functions.RemoveMoney('bank', PRICE, REASON) then
        return true
    end

    return refuseBroke(source)
end)

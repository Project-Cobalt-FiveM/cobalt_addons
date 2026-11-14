local config <const> = require 'config'
local Cobalt <const> = exports.cobalt_core:GetCoreObject()
local core <const> = exports.cobalt_core

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

lib.callback.register('cobalt_addons:server:washVehicle', function(source)
    local ped <const> = GetPlayerPed(source)
    local vehicle <const> = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= ped then return false end
    if not atCarWash(GetEntityCoords(ped)) then return false end

    local player <const> = Cobalt.Functions.GetPlayer(source)

    if not player then return false end

    local price <const> = config.carWash.price

    if player.Functions.RemoveMoney('cash', price, 'car-washed') or player.Functions.RemoveMoney('bank', price, 'car-washed') then
        return true
    end

    core:Notify(source, { description = locale('wash.no_money'), type = 'error' })

    return false
end)

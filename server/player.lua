local config <const> = require 'config'
local Cobalt <const> = exports.cobalt_core:GetCoreObject()
local core <const> = exports.cobalt_core

local TACKLE_RANGE <const> = 3.0
local TACKLE_MIN_SPEED <const> = 2.0
local TACKLE_COOLDOWN <const> = 5000
local TACKLED_IMMUNITY <const> = 8000

---@type table<integer, integer>
local nextTackleAt <const> = {}
---@type table<integer, integer>
local tackleableAt <const> = {}

---@param source integer
---@return boolean
local function canTackle(source)
    local state <const> = Player(source).state

    if state.cuffed or state.isDead then return false end

    local ped <const> = GetPlayerPed(source)

    return GetVehiclePedIsIn(ped, false) == 0 and GetEntitySpeed(ped) >= TACKLE_MIN_SPEED
end

RegisterNetEvent('cobalt_addons:server:tackle', function(target)
    local source <const> = source

    if type(target) ~= 'number' or target == source then return end

    local now <const> = GetGameTimer()

    if (nextTackleAt[source] or 0) > now or (tackleableAt[target] or 0) > now then return end

    local targetPed <const> = GetPlayerPed(target)

    if targetPed == 0 or not canTackle(source) then return end

    if #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(targetPed)) > TACKLE_RANGE then return end

    nextTackleAt[source] = now + TACKLE_COOLDOWN
    tackleableAt[target] = now + TACKLED_IMMUNITY

    TriggerClientEvent('cobalt_addons:client:tackled', target)
end)

Cobalt.Commands.Add('id', locale('commands.id'), {}, false, function(source)
    core:Notify(source, { description = locale('player.id', source) })
end)

AddEventHandler('playerDropped', function()
    nextTackleAt[source] = nil
    tackleableAt[source] = nil
end)

if config.discord.enabled and config.discord.showPlayerCount then
    local function publishPlayerCount()
        GlobalState.playerCount = #GetPlayers()
    end

    GlobalState.maxPlayers = GetConvarInt('sv_maxclients', 48)
    publishPlayerCount()
    AddEventHandler('playerJoining', publishPlayerCount)
    AddEventHandler('playerDropped', function()
        SetTimeout(0, publishPlayerCount)
    end)
end

AddEventHandler('entityCreating', function(entity)
    local model <const> = GetEntityModel(entity)

    if config.blacklistedVehicles[model] or config.blacklistedPeds[model] then
        CancelEvent()
    end
end)

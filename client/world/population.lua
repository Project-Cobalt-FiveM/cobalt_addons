local config <const> = require 'config'

local density <const> = config.density
local MAX_WANTED_LEVEL <const> = 5

local function disableScenarios()
    for _, scenario in ipairs(config.blacklistedScenarios.types) do
        SetScenarioTypeEnabled(scenario, false)
    end

    for _, group in ipairs(config.blacklistedScenarios.groups) do
        SetScenarioGroupEnabled(group, false)
    end
end

local function clearCarGenerators()
    for _, area in ipairs(config.clearedCarGenerators) do
        local c <const>, r <const> = area.coords, area.radius

        RemoveVehiclesFromGeneratorsInArea(c.x - r, c.y - r, c.z - r, c.x + r, c.y + r, c.z + r)
    end
end

local function prepareWorld()
    disableScenarios()
    clearCarGenerators()
end

prepareWorld()
RegisterNetEvent('cobalt_core:Client:OnPlayerLoaded', prepareWorld)

if config.pauseMapTitle then
    AddTextEntry('FE_THDR_GTAO', locale('pause_map.title'))
end

if config.disable.ambience then
    StartAudioScene('CHARACTER_CHANGE_IN_SKY_SCENE')
    SetAudioFlag('DisableFlightMusic', true)
end

SetAudioFlag('PoliceScannerDisabled', true)
SetGarbageTrucks(false)
SetCreateRandomCops(false)
SetCreateRandomCopsNotOnScenarios(false)
SetCreateRandomCopsOnScenarios(false)
DistantCopCarSirens(false)

---@type table<string, integer>
local DISPATCH_SERVICES <const> = {
    policeCars = 1,
    policeHelicopters = 2,
    fireTrucks = 3,
    swatVans = 4,
    ambulances = 5,
    policeBikes = 6,
    policeBackup = 7,
    roadblocks = 8,
    policePullover = 9,
    cruisingPolice = 10,
    gangs = 11,
    swatHelicopters = 12,
    policeBoats = 13,
    army = 14,
    bikerBackup = 15,
}

for name, service in pairs(DISPATCH_SERVICES) do
    EnableDispatchService(service, config.aiResponse.dispatchServices[name] == true)
end

SetMaxWantedLevel(config.aiResponse.wantedLevels and MAX_WANTED_LEVEL or 0)

if config.disable.driveby then
    SetPlayerCanDoDriveBy(cache.playerId, false)
end

if config.disable.idleCamera then
    DisableIdleCamera(true)
end

AddEventHandler('gameEventTriggered', function(name, args)
    if name ~= 'CEventNetworkEntityDamage' or args[1] ~= cache.ped or args[7] ~= `WEAPON_STUNGUN` then return end

    SetPedMinGroundTimeForStungun(cache.ped, math.random(4000, 7000))
end)

CreateThread(function()
    while true do
        SetParkedVehicleDensityMultiplierThisFrame(density.parked)
        SetVehicleDensityMultiplierThisFrame(density.vehicle)
        SetRandomVehicleDensityMultiplierThisFrame(density.multiplier)
        SetPedDensityMultiplierThisFrame(density.peds)
        SetScenarioPedDensityMultiplierThisFrame(density.scenario, density.scenario)
        Wait(0)
    end
end)

lib.onCache('vehicle', function(vehicle)
    if vehicle and config.disable.carRadio then
        SetVehRadioStation(vehicle, 'OFF')
    end
end)

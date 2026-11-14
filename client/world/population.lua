local config <const> = require 'config'

local density <const> = config.density
local MAX_WANTED_LEVEL <const> = 5

---@type { coords: vector3, radius: number }[]
local clearedGenerators <const> = {
    { coords = vec3(335.2616, -1432.455, 46.51), radius = 300.0 },
    { coords = vec3(441.8465, -987.99, 30.68), radius = 500.0 },
    { coords = vec3(316.79, -592.36, 43.28), radius = 300.0 },
    { coords = vec3(-2150.44, 3075.99, 32.8), radius = 500.0 },
    { coords = vec3(-1108.35, 4920.64, 217.2), radius = 300.0 },
    { coords = vec3(-458.24, 6019.81, 31.34), radius = 300.0 },
    { coords = vec3(1854.82, 3679.4, 33.82), radius = 300.0 },
    { coords = vec3(-724.46, -1444.03, 5.0), radius = 300.0 },
}

local function disableScenarios()
    for _, scenario in ipairs(config.blacklistedScenarios.types) do
        SetScenarioTypeEnabled(scenario, false)
    end

    for _, group in ipairs(config.blacklistedScenarios.groups) do
        SetScenarioGroupEnabled(group, false)
    end
end

disableScenarios()
RegisterNetEvent('cobalt_core:Client:OnPlayerLoaded', disableScenarios)

AddTextEntry('FE_THDR_GTAO', config.pauseMapText ~= '' and config.pauseMapText or 'FiveM')

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

for _, area in ipairs(clearedGenerators) do
    local c <const>, r <const> = area.coords, area.radius

    RemoveVehiclesFromGeneratorsInArea(c.x - r, c.y - r, c.z - r, c.x + r, c.y + r, c.z + r)
end

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

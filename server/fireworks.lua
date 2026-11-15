local config <const> = require 'config'
local core <const> = exports.cobalt_core
local inventory <const> = exports.cobalt_inventory

local settings <const> = config.fireworks
local MODEL <const> = joaat(settings.model)
local PLACE_SLACK <const> = 1.5
local MAX_HEIGHT_GAP <const> = 3.0
local SPAWN_TIMEOUT <const> = 2000
local LAUNCH_ASSET <const> = 'scr_indep_fireworks'
local LAUNCH_EFFECT <const> = 'scr_indep_firework_trailburst'
local LAUNCH_SHOTS <const> = 2
local LAUNCH_GAP <const> = 350
local FIRST_BURST_DELAY <const> = 1500
local BURST_SPREAD <const> = 4.0

---@type table<string, string[]>
local bursts <const> = {
    proj_xmas_firework = {
        'scr_firework_xmas_ring_burst_rgw',
        'scr_firework_xmas_burst_rgw',
        'scr_firework_xmas_repeat_burst_rgw',
        'scr_firework_xmas_spiral_burst_rgw',
        'scr_xmas_firework_sparkle_spawn',
    },
    scr_indep_fireworks = {
        'scr_indep_firework_sparkle_spawn',
        'scr_indep_firework_starburst',
        'scr_indep_firework_shotburst',
        'scr_indep_firework_trailburst',
        'scr_indep_firework_trailburst_spawn',
        'scr_indep_firework_burst_spawn',
        'scr_indep_firework_trail_spawn',
        'scr_indep_firework_fountain',
    },
    proj_indep_firework = {
        'scr_indep_firework_grd_burst',
        'scr_indep_launcher_sparkle_spawn',
        'scr_indep_firework_air_burst',
        'proj_indep_flare_trail',
    },
    proj_indep_firework_v2 = {
        'scr_firework_indep_burst_rwb',
        'scr_firework_indep_spiral_burst_rwb',
        'scr_xmas_firework_sparkle_spawn',
        'scr_firework_indep_ring_burst_rwb',
        'scr_xmas_firework_burst_fizzle',
        'scr_firework_indep_repeat_burst_rwb',
    },
}

---@class FireworkSpot
---@field coords vector3 where the box's origin goes, on the ground
---@field heading number

---@class FireworkFlash
---@field asset string
---@field effect string
---@field offset vector3 from the box
---@field scale number
---@field wait integer milliseconds after the previous flash

---@type table<integer, integer>
local lastLit <const> = {}

---@type table<integer, integer>
local boxes <const> = {}

---@param source integer
---@param key string
local function notifyError(source, key)
    core:Notify(source, { description = locale(key), type = 'error', duration = 3000 })
end

---@param source integer
---@return boolean
local function coolingDown(source)
    local last <const> = lastLit[source]

    return last ~= nil and GetGameTimer() - last < settings.cooldown * 1000
end

---@param source integer
---@param spot unknown
---@return FireworkSpot?
local function parseSpot(source, spot)
    if type(spot) ~= 'table' or type(spot.coords) ~= 'vector3' or type(spot.heading) ~= 'number' then return end

    local coords <const> = spot.coords
    local ped <const> = GetEntityCoords(GetPlayerPed(source))

    if #(coords.xy - ped.xy) > settings.placeDistance + PLACE_SLACK then return end
    if math.abs(coords.z - ped.z) > MAX_HEIGHT_GAP then return end

    return { coords = coords, heading = spot.heading % 360.0 }
end

---@param spot FireworkSpot
---@param bucket integer
---@return integer?
local function spawnBox(spot, bucket)
    local at <const> = spot.coords
    local entity <const> = CreateObjectNoOffset(MODEL, at.x, at.y, at.z, true, true, false)
    local deadline <const> = GetGameTimer() + SPAWN_TIMEOUT

    while not DoesEntityExist(entity) do
        if GetGameTimer() > deadline then
            if entity ~= 0 then DeleteEntity(entity) end

            return
        end

        Wait(0)
    end

    SetEntityHeading(entity, spot.heading)
    FreezeEntityPosition(entity, true)
    SetEntityRoutingBucket(entity, bucket)

    return entity
end

---@param netId integer
local function removeBox(netId)
    local entity <const> = boxes[netId]
    boxes[netId] = nil

    if entity and DoesEntityExist(entity) then DeleteEntity(entity) end
end

---@param coords vector3
---@param range number
---@param bucket integer
---@return integer[]
local function playersNear(coords, range, bucket)
    local ids <const> = {}

    for _, player in ipairs(lib.getNearbyPlayers(coords, range)) do
        if GetPlayerRoutingBucket(player.id) == bucket then ids[#ids + 1] = player.id end
    end

    return ids
end

---@return FireworkFlash[]
local function buildShow()
    local show <const> = {}

    for shot = 1, LAUNCH_SHOTS do
        show[#show + 1] = {
            asset = LAUNCH_ASSET,
            effect = LAUNCH_EFFECT,
            offset = vec3(0.0, 0.0, 0.2),
            scale = 1.0,
            wait = shot == 1 and 0 or LAUNCH_GAP,
        }
    end

    local list <const> = bursts[settings.asset]

    for burst = 1, math.random(5, 10) do
        show[#show + 1] = {
            asset = settings.asset,
            effect = list[math.random(#list)],
            offset = vec3(
                (math.random() * 2 - 1) * BURST_SPREAD,
                (math.random() * 2 - 1) * BURST_SPREAD,
                settings.burstHeight + (math.random() * 2 - 1) * BURST_SPREAD
            ),
            scale = math.random() * 0.3 + 0.5,
            wait = burst == 1 and FIRST_BURST_DELAY or math.random(0, 500),
        }
    end

    return show
end

---@param source integer
---@param item string
---@param spot FireworkSpot
local function light(source, item, spot)
    local bucket <const> = GetPlayerRoutingBucket(source)
    local entity <const> = spawnBox(spot, bucket)

    if not entity then
        inventory:AddItem(source, item, 1, nil, nil, 'cobalt_addons:firework')
        return
    end

    local netId <const> = NetworkGetNetworkIdFromEntity(entity)
    local coords <const> = spot.coords

    boxes[netId] = entity

    for remaining = settings.delay, 1, -1 do
        local watching <const> = playersNear(coords, settings.countdownRange, bucket)

        lib.triggerClientEvent('cobalt_addons:client:fireworkFuse', watching, coords, remaining)
        Wait(1000)

        if boxes[netId] ~= entity then return end
    end

    local viewers <const> = playersNear(coords, settings.viewRange, bucket)

    lib.triggerClientEvent('cobalt_addons:client:fireworkLaunch', viewers, coords, buildShow())

    SetTimeout(settings.cleanupDelay * 1000, function()
        if boxes[netId] == entity then removeBox(netId) end
    end)
end

exports('Firework', function(event, _, used, item, spot)
    local source <const> = used.source

    if event == 'usingItem' then
        if coolingDown(source) then
            notifyError(source, 'firework.cooldown')
            return false
        end

        local ok <const>, raw <const> = pcall(lib.callback.await, 'cobalt_addons:client:fireworkSpot', source)
        local parsed <const> = ok and parseSpot(source, raw)

        if not parsed then
            notifyError(source, 'firework.no_room')
            return false
        end

        lastLit[source] = GetGameTimer()

        return parsed
    end

    CreateThread(function()
        light(source, item.name, spot)
    end)
end)

AddEventHandler('playerDropped', function()
    lastLit[source] = nil
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end

    for netId in pairs(boxes) do
        removeBox(netId)
    end
end)

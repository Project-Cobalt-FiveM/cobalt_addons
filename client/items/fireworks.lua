local config <const> = require 'config'
local core <const> = exports.cobalt_core

local settings <const> = config.fireworks
local FUSE_ASSET <const> = 'scr_indep_fireworks'
local FUSE_EFFECT <const> = 'scr_indep_firework_sparkle_spawn'
local FUSE_HEIGHT <const> = 0.3
local FUSE_SCALE <const> = 0.4
local COUNTDOWN_HOLD <const> = 1500

---@type string?
local countdown
local countdownToken = 0

---@type table<string, integer>
local assetUsers <const> = {}

local function hideCountdown()
    if not countdown then return end

    local _, shown <const> = core:IsTextUIOpen()

    if shown == countdown then core:HideTextUI() end

    countdown = nil
end

---@param remaining integer
local function showCountdown(remaining)
    countdown = locale('firework.time_left', remaining)
    countdownToken += 1

    local token <const> = countdownToken

    core:ShowTextUI(countdown, { position = 'left-center' })

    SetTimeout(COUNTDOWN_HOLD, function()
        if countdownToken == token then hideCountdown() end
    end)
end

---@param coords vector3
local function sparkFuse(coords)
    lib.requestNamedPtfxAsset(FUSE_ASSET)
    UseParticleFxAssetNextCall(FUSE_ASSET)
    StartParticleFxNonLoopedAtCoord(
        FUSE_EFFECT,
        coords.x,
        coords.y,
        coords.z + FUSE_HEIGHT,
        0.0,
        0.0,
        0.0,
        FUSE_SCALE,
        false,
        false,
        false
    )
end

lib.callback.register('cobalt_addons:client:fireworkSpot', function()
    if cache.vehicle or IsPedSwimming(cache.ped) then return end

    local front <const> = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, settings.placeDistance, 0.0)
    local found <const>, groundZ <const> = GetGroundZFor_3dCoord(front.x, front.y, front.z + 1.0, false)

    if not found then return end

    local model <const> = lib.requestModel(settings.model)
    local min <const> = GetModelDimensions(model)

    SetModelAsNoLongerNeeded(model)

    return { coords = vec3(front.x, front.y, groundZ - min.z), heading = GetEntityHeading(cache.ped) }
end)

RegisterNetEvent('cobalt_addons:client:fireworkFuse', function(coords, remaining)
    if remaining then showCountdown(remaining) end

    sparkFuse(coords)
end)

---@param asset string
local function holdAsset(asset)
    assetUsers[asset] = (assetUsers[asset] or 0) + 1
    lib.requestNamedPtfxAsset(asset)
end

---@param asset string
local function releaseAsset(asset)
    local users <const> = assetUsers[asset] - 1

    if users > 0 then
        assetUsers[asset] = users
        return
    end

    assetUsers[asset] = nil
    RemoveNamedPtfxAsset(asset)
end

---@param show FireworkFlash[]
---@return table<string, true>
local function assetsOf(show)
    local assets <const> = {}

    for _, flash in ipairs(show) do
        assets[flash.asset] = true
    end

    return assets
end

RegisterNetEvent('cobalt_addons:client:fireworkLaunch', function(coords, show)
    countdownToken += 1
    hideCountdown()

    local assets <const> = assetsOf(show)

    for asset in pairs(assets) do
        holdAsset(asset)
    end

    for _, flash in ipairs(show) do
        Wait(flash.wait)

        local at <const> = coords + flash.offset

        UseParticleFxAssetNextCall(flash.asset)
        StartParticleFxNonLoopedAtCoord(
            flash.effect,
            at.x,
            at.y,
            at.z,
            0.0,
            0.0,
            0.0,
            flash.scale,
            false,
            false,
            false
        )
    end

    for asset in pairs(assets) do
        releaseAsset(asset)
    end
end)

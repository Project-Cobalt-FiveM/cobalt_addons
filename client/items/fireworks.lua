local config <const> = require 'config'
local core <const> = exports.cobalt_core

local SHOW_COUNTDOWN_RANGE <const> = 50.0
local BURST_HEIGHT <const> = 42.5

---@type table<string, string[]>
local effects <const> = {
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

---@param coords vector3
---@param asset string
local function burst(coords, asset)
    local list <const> = effects[asset]

    for _ = 1, math.random(5, 10) do
        UseParticleFxAssetNextCall(asset)
        StartNetworkedParticleFxNonLoopedAtCoord(
            list[math.random(#list)],
            coords.x,
            coords.y,
            coords.z + BURST_HEIGHT,
            0.0,
            0.0,
            0.0,
            math.random() * 0.3 + 0.5,
            false,
            false,
            false
        )
        Wait(math.random() * 500)
    end
end

---@param text string
local function hideCountdown(text)
    local _, shown <const> = core:IsTextUIOpen()

    if shown == text then core:HideTextUI() end
end

local Fireworks <const> = {}

function Fireworks.launch()
    local coords <const> = GetEntityCoords(cache.ped)

    CreateThread(function()
        local asset <const> = config.fireworks.asset

        lib.requestNamedPtfxAsset(asset)

        local countdown

        for remaining = config.fireworks.delay, 1, -1 do
            if #(GetEntityCoords(cache.ped) - coords) < SHOW_COUNTDOWN_RANGE then
                countdown = locale('firework.time_left', remaining)
                core:ShowTextUI(countdown, { position = 'left-center' })
            elseif countdown then
                hideCountdown(countdown)
                countdown = nil
            end

            Wait(1000)
        end

        if countdown then hideCountdown(countdown) end
        burst(coords, asset)
        RemoveNamedPtfxAsset(asset)
    end)
end

return Fireworks

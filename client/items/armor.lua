local config <const> = require 'config'
local core <const> = exports.cobalt_core

local VEST_COMPONENT <const> = 9

---@type { drawable: integer, texture: integer }?
local savedVest

local Armor <const> = {}

function Armor.wear()
    local ped <const> = cache.ped
    local drawable <const> = GetPedDrawableVariation(ped, VEST_COMPONENT)
    local texture <const> = GetPedTextureVariation(ped, VEST_COMPONENT)

    savedVest = savedVest or { drawable = drawable, texture = texture }

    if config.disable.vestDrawable then return end

    if core:GetPlayerData().charinfo.gender ~= 0 then
        SetPedComponentVariation(ped, VEST_COMPONENT, 30, 0, 2)
    elseif drawable == 7 then
        SetPedComponentVariation(ped, VEST_COMPONENT, 19, texture, 2)
    else
        SetPedComponentVariation(ped, VEST_COMPONENT, 5, 2, 2)
    end
end

lib.callback.register('cobalt_addons:client:removeVest', function()
    if not savedVest then
        core:Notify({ description = locale('consumables.armor_empty'), type = 'error', duration = 3000 })
        return false
    end

    local removed <const> = core:Progressbar({
        duration = 2500,
        label = locale('consumables.remove_armor_progress'),
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, combat = true },
    })

    if not removed then
        core:Notify({ description = locale('consumables.canceled'), type = 'error', duration = 3000 })
        return false
    end

    local armour <const> = GetPedArmour(cache.ped)

    SetPedComponentVariation(cache.ped, VEST_COMPONENT, savedVest.drawable, savedVest.texture, 2)
    SetPedArmour(cache.ped, 0)
    savedVest = nil

    return true, armour
end)

return Armor

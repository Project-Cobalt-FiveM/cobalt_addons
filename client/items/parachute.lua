local config <const> = require 'config'
local core <const> = exports.cobalt_core
local appearance <const> = exports['illenium-appearance']

local BAG_COMPONENT <const> = 5
local PARACHUTE_BAG <const> = 7

---@type { drawable: integer, texture: integer }?
local savedBag

---@param drawable integer
---@param texture integer
local function setBag(drawable, texture)
    appearance:setPedComponent(cache.ped, { component_id = BAG_COMPONENT, drawable = drawable, texture = texture })
end

local function playShirtExit()
    local anim <const> = config.parachute.anim

    lib.playAnim(cache.ped, anim.dict, anim.clip, 8.0, 1.0, -1, anim.flag)
end

local Parachute <const> = {}

function Parachute.wear()
    local ped <const> = cache.ped

    savedBag = savedBag or {
        drawable = GetPedDrawableVariation(ped, BAG_COMPONENT),
        texture = GetPedTextureVariation(ped, BAG_COMPONENT),
    }

    GiveWeaponToPed(ped, `GADGET_PARACHUTE`, 1, false, false)
    setBag(PARACHUTE_BAG, 0)
    playShirtExit()
end

lib.callback.register('cobalt_addons:client:packParachute', function()
    if not HasPedGotWeapon(cache.ped, `GADGET_PARACHUTE`, false) then
        core:Notify({ description = locale('consumables.no_parachute'), type = 'error', duration = 3000 })
        return false
    end

    local packed <const> = core:Progressbar({
        duration = config.parachute.packDuration,
        label = locale('consumables.pack_parachute_progress'),
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, combat = true },
        anim = config.parachute.anim,
    })

    if not packed then
        core:Notify({ description = locale('consumables.canceled'), type = 'error', duration = 3000 })
        return false
    end

    local bag <const> = savedBag or { drawable = 0, texture = 0 }

    savedBag = nil
    RemoveWeaponFromPed(cache.ped, `GADGET_PARACHUTE`)
    setBag(bag.drawable, bag.texture)
    playShirtExit()

    return true
end)

RegisterNetEvent('cobalt_core:Client:OnPlayerUnload', function()
    savedBag = nil
end)

return Parachute

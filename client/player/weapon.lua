local config <const> = require 'config'

local ARMED_GUN_OR_EXPLOSIVE <const> = 6
local INPUT_MELEE_ATTACK_LIGHT <const> = 140
local INPUT_MELEE_ATTACK_HEAVY <const> = 141
local INPUT_MELEE_ATTACK_ALTERNATE <const> = 142

---@type table<integer, true>
local infiniteAmmoWeapons <const> = {
    [`WEAPON_FIREEXTINGUISHER`] = true,
    [`WEAPON_PETROLCAN`] = true,
}

local equipped = 0

---@param token integer
---@param recoil number?
---@param blockMelee boolean
local function holdWeapon(token, recoil, blockMelee)
    while equipped == token do
        if blockMelee then
            DisableControlAction(1, INPUT_MELEE_ATTACK_LIGHT, true)
            DisableControlAction(1, INPUT_MELEE_ATTACK_HEAVY, true)
            DisableControlAction(1, INPUT_MELEE_ATTACK_ALTERNATE, true)
        end

        if recoil and IsPedShooting(cache.ped) then
            SetGameplayCamRelativePitch(GetGameplayCamRelativePitch() + recoil, 1.0)
        end

        Wait(0)
    end
end

lib.onCache('weapon', function(weapon)
    equipped += 1

    if not weapon then return end

    local ped <const> = cache.ped

    if config.blacklistedWeapons[weapon] then
        RemoveWeaponFromPed(ped, weapon)
        return
    end

    if infiniteAmmoWeapons[weapon] then
        SetPedInfiniteAmmo(ped, true, weapon)
    end

    local recoil <const> = config.recoils[weapon]
    local blockMelee <const> = config.disable.pistolWhipping and IsPedArmed(ped, ARMED_GUN_OR_EXPLOSIVE)

    if not recoil and not blockMelee then return end

    local token <const> = equipped

    CreateThread(function()
        holdWeapon(token, recoil, blockMelee)
    end)
end)

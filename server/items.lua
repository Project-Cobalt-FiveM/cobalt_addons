local Cobalt <const> = exports.cobalt_core:GetCoreObject()
local core <const> = exports.cobalt_core
local inventory <const> = exports.cobalt_inventory
local management <const> = exports.cobalt_management

---@class AddonsWornVest
---@field item string
---@field armour integer

---@type table<integer, true>
local parachutes <const> = {}
---@type table<integer, AddonsWornVest>
local vests <const> = {}

local VEST_REFUND_RATIO <const> = 0.95
local FREEFALL_SPEED <const> = -8.0
local FALL_CHECK_MS <const> = 250

---@param source integer
---@param key string
local function notifyError(source, key)
    core:Notify(source, { description = locale(key), type = 'error', duration = 3000 })
end

---@param source integer
---@param callback string
---@param ... any
---@return boolean
local function askClient(source, callback, ...)
    local ok <const>, result <const> = pcall(lib.callback.await, callback, source, ...)

    return ok and result == true
end

exports('Armor', function(event, item, used)
    local source <const> = used.source
    local ped <const> = GetPlayerPed(source)
    local armour <const> = item.server.armour

    if event == 'usingItem' then
        if GetPedArmour(ped) < armour then return end

        notifyError(source, 'consumables.armor_full')
        return false
    end

    SetPedArmour(ped, armour)

    if item.client?.effect == 'vest' then vests[source] = { item = item.name, armour = armour } end
end)

---@param playerId integer
---@return boolean
local function isFreefalling(playerId)
    local ped <const> = GetPlayerPed(playerId)

    if ped == 0 or GetVehiclePedIsIn(ped, false) ~= 0 then return false end

    return GetEntityVelocity(ped).z < FREEFALL_SPEED
end

local function watchJumps()
    while next(parachutes) do
        for playerId in pairs(parachutes) do
            if isFreefalling(playerId) then parachutes[playerId] = nil end
        end

        Wait(FALL_CHECK_MS)
    end
end

exports('Parachute', function(event, _, used)
    if event ~= 'usedItem' then return end

    local watching <const> = next(parachutes) ~= nil

    parachutes[used.source] = true

    if not watching then CreateThread(watchJumps) end
end)

Cobalt.Commands.Add('resetarmor', locale('commands.resetarmor'), {}, false, function(source)
    if management:GetJob(source)?.type ~= 'leo' then
        return notifyError(source, 'consumables.police_only')
    end

    local vest <const> = vests[source]

    if not vest then
        return notifyError(source, 'consumables.armor_empty')
    end

    local armourBefore <const> = GetPedArmour(GetPlayerPed(source))
    local ok <const>, removed <const>, armourAfter <const> = pcall(lib.callback.await, 'cobalt_addons:client:removeVest', source)

    if not ok or removed ~= true or vests[source] ~= vest then return end

    vests[source] = nil
    SetPedArmour(GetPlayerPed(source), 0)

    if math.min(armourBefore, tonumber(armourAfter) or 0) < vest.armour * VEST_REFUND_RATIO then
        return notifyError(source, 'consumables.armor_damaged')
    end

    inventory:AddItem(source, vest.item, 1, nil, nil, 'cobalt_addons:resetarmor')
end)

Cobalt.Commands.Add('resetparachute', locale('commands.resetparachute'), {}, false, function(source)
    if not parachutes[source] then
        return notifyError(source, 'consumables.no_parachute')
    end

    if not askClient(source, 'cobalt_addons:client:packParachute') then return end

    parachutes[source] = nil
    inventory:AddItem(source, 'parachute', 1, nil, nil, 'cobalt_addons:resetparachute')
end)

---@param source integer
local function forget(source)
    parachutes[source] = nil
    vests[source] = nil
end

AddEventHandler('playerDropped', function()
    forget(source)
end)

AddEventHandler('cobalt_core:Server:OnPlayerUnload', forget)

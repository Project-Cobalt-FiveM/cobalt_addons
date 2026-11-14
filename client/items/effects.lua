local generation = 0
local runCount = 0

---@type table<integer, number> sprint multiplier of each running stimulant
local sprinting <const> = {}

---@param chance integer
---@param outOf? integer
---@return boolean
local function roll(chance, outOf)
    return math.random(1, outOf or 100) < chance
end

---@param started integer
---@return boolean
local function live(started)
    return started == generation
end

---@param started integer
---@param ms integer
---@return boolean live
local function sleep(started, ms)
    Wait(ms)

    return live(started)
end

local function applySprint()
    local multiplier = 1.0

    for _, value in pairs(sprinting) do
        multiplier = math.max(multiplier, value)
    end

    SetRunSprintMultiplierForPlayer(cache.playerId, multiplier)
end

local CLOWNS <const> = 'DrugsTrevorClownsFight'
local ALIENS <const> = 'DrugsMichaelAliensFight'

local function resetAll()
    generation += 1
    table.wipe(sprinting)
    SetRunSprintMultiplierForPlayer(cache.playerId, 1.0)

    for _, prefix in ipairs({ CLOWNS, ALIENS }) do
        StopScreenEffect(prefix .. 'In')
        StopScreenEffect(prefix)
        StopScreenEffect(prefix .. 'Out')
    end
end

local function ragdollIfRunning()
    if not IsPedRunning(cache.ped) then return end

    SetPedToRagdoll(cache.ped, math.random(1000, 3000), math.random(1000, 3000), 3, false, false, false)
end

---@param started integer
---@param prefix string
---@param hold fun(): integer
local function screenEffect(started, prefix, hold)
    local enter <const>, loop <const>, leave <const> = prefix .. 'In', prefix, prefix .. 'Out'

    StartScreenEffect(enter, 3.0, false)

    if sleep(started, hold()) then
        StartScreenEffect(loop, 3.0, false)

        if sleep(started, hold()) then StartScreenEffect(leave, 3.0, false) end
    end

    StopScreenEffect(enter)
    StopScreenEffect(loop)
    StopScreenEffect(leave)
end

---@param started integer
local function trevorEffect(started)
    screenEffect(started, CLOWNS, function() return 3000 end)
end

---@param started integer
local function alienEffect(started)
    screenEffect(started, ALIENS, function() return math.random(5000, 8000) end)
end

---@class AddonsStimulant
---@field sprint number
---@field seconds integer
---@field onStart fun(started: integer)
---@field onTick fun(started: integer)

---@param stimulant AddonsStimulant
---@return boolean finished false when death, unload or a resource stop cut it short
local function stimulate(stimulant)
    local started <const> = generation

    runCount += 1

    local run <const> = runCount

    stimulant.onStart(started)

    if not live(started) then return false end

    sprinting[run] = stimulant.sprint
    applySprint()

    for _ = 1, stimulant.seconds do
        if not sleep(started, 1000) then return false end

        stimulant.onTick(started)
    end

    if not live(started) then return false end

    sprinting[run] = nil
    applySprint()

    return true
end

local Effects <const> = {}

function Effects.meth()
    stimulate({
        sprint = 1.49,
        seconds = 8,
        onStart = trevorEffect,
        onTick = function(started)
            if roll(10) then
                RestorePlayerStamina(cache.playerId, 1.0)
            end
            if roll(51) then
                trevorEffect(started)
            end
        end,
    })
end

function Effects.crack()
    local finished <const> = stimulate({
        sprint = 1.3,
        seconds = 8,
        onStart = alienEffect,
        onTick = function(started)
            if roll(10) then
                RestorePlayerStamina(cache.playerId, 1.0)
            end

            if roll(60) and IsPedRunning(cache.ped) then
                SetPedToRagdoll(cache.ped, math.random(1000, 2000), math.random(1000, 2000), 3, false, false, false)
            end

            if roll(51) then
                alienEffect(started)
            end
        end,
    })

    if finished then ragdollIfRunning() end
end

function Effects.coke()
    local finished <const> = stimulate({
        sprint = 1.1,
        seconds = 20,
        onStart = alienEffect,
        onTick = function(started)
            if roll(20) then
                RestorePlayerStamina(cache.playerId, 1.0)
            end
            if roll(10) then
                ragdollIfRunning()
            end

            if roll(10, 300) then
                alienEffect(started)
                sleep(started, math.random(3000, 6000))
            end
        end,
    })

    if finished then ragdollIfRunning() end
end

function Effects.ecstasy()
    local started <const> = generation

    SetFlash(0, 0, 500, 7000, 500)

    for _ = 1, 30 do
        if not sleep(started, 1000) then return end

        RestorePlayerStamina(cache.playerId, 1.0)

        if roll(51) then
            SetFlash(0, 0, 500, 7000, 500)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08)
        end
    end

    ragdollIfRunning()
end

function Effects.oxy()
    local started <const> = generation

    ClearPedBloodDamage(cache.ped)

    for _ = 1, 9 do
        if not sleep(started, 1000) then return end

        SetEntityHealth(cache.ped, GetEntityHealth(cache.ped) + 6)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then resetAll() end
end)

RegisterNetEvent('cobalt_core:Client:OnPlayerUnload', resetAll)

AddStateBagChangeHandler('isDead', ('player:%s'):format(cache.serverId), function(_, _, dead)
    if dead then resetAll() end
end)

return Effects

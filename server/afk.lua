local config <const> = require 'config'
local core <const> = exports.cobalt_core

if config.afk.secondsUntilKick <= 0 then return end

local CHECK_SECONDS <const> = 10
local MOVE_TOLERANCE <const> = 0.05
local WARN_AT <const> = { 900, 600, 300, 150, 60, 30, 20, 10 }

---@class AfkState
---@field coords vector3
---@field remaining? integer
---@field nextWarning integer index into WARN_AT of the next warning still to give

---@type table<integer, AfkState>
local tracked <const> = {}

---@param seconds integer
---@return string
local function timeLeft(seconds)
    local minutes <const>, rest <const> = seconds // 60, seconds % 60

    if minutes == 0 then return locale('afk.seconds', rest) end

    local minuteText <const> = minutes == 1 and locale('afk.one_minute') or locale('afk.minutes', minutes)

    if rest == 0 then return minuteText end

    return locale('afk.minutes_and_seconds', minuteText, rest)
end

---@param source integer
---@param state AfkState
local function warnIfDue(source, state)
    local due = false

    while WARN_AT[state.nextWarning] and WARN_AT[state.nextWarning] >= state.remaining do
        state.nextWarning += 1
        due = true
    end

    if not due then return end

    core:Notify(source, {
        description = locale('afk.will_kick', timeLeft(state.remaining)),
        type = 'error',
        duration = 10000,
    })
end

---@param source integer
---@return boolean
local function isExempt(source)
    for _, ace in ipairs(config.afk.exemptAces) do
        if IsPlayerAceAllowed(source, ace) then return true end
    end

    return false
end

---@param source integer
local function check(source)
    if not Player(source).state.LoggedIn and not config.afk.kickInCharMenu then
        tracked[source] = nil
        return
    end

    if isExempt(source) then return end

    local coords <const> = GetEntityCoords(GetPlayerPed(source))
    local state <const> = tracked[source]

    if not state or #(coords - state.coords) > MOVE_TOLERANCE then
        tracked[source] = { coords = coords, nextWarning = 1 }
        return
    end

    if not state.remaining then
        state.remaining = config.afk.secondsUntilKick
        return
    end

    if state.remaining <= 0 then
        tracked[source] = nil
        DropPlayer(tostring(source), locale('afk.kick_message'))
        return
    end

    warnIfDue(source, state)
    state.remaining -= CHECK_SECONDS
end

SetInterval(function()
    for _, id in ipairs(GetPlayers()) do
        check(tonumber(id) --[[@as integer]])
    end
end, CHECK_SECONDS * 1000)

AddEventHandler('playerDropped', function()
    tracked[source] = nil
end)

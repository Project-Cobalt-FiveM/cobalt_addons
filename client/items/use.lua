local drugs <const> = require 'client.items.effects'
local armor <const> = require 'client.items.armor'
local parachute <const> = require 'client.items.parachute'
local fireworks <const> = require 'client.items.fireworks'

---@type table<string, fun()>
local effects <const> = {
    meth = drugs.meth,
    crack = drugs.crack,
    coke = drugs.coke,
    ecstasy = drugs.ecstasy,
    oxy = drugs.oxy,
    vest = armor.wear,
    parachute = parachute.wear,
    firework = fireworks.launch,
}

exports('ItemEffect', function(event, item)
    if event ~= 'usedItem' then return end

    local effect <const> = effects[item.client?.effect]

    if effect then effect() end
end)

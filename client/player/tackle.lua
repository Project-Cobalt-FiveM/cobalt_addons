local TACKLE_DICT <const> = 'swimming@first_person@diving'
local TACKLE_CLIP <const> = 'dive_run_fwd_-45_loop'
local TACKLE_RANGE <const> = 2.0
local MIN_SPEED <const> = 2.5

local function playTackle()
    local ped <const> = cache.ped

    if IsEntityPlayingAnim(ped, TACKLE_DICT, TACKLE_CLIP, 3) then
        ClearPedTasksImmediately(ped)
        return
    end

    lib.playAnim(ped, TACKLE_DICT, TACKLE_CLIP, 3.0, 3.0, -1, 49)
    Wait(250)
    ClearPedTasksImmediately(ped)
    SetPedToRagdoll(ped, 150, 150, 0, false, false, false)
end

---@return boolean
local function canTackle()
    local ped <const> = cache.ped

    return not cache.vehicle
        and GetEntitySpeed(ped) > MIN_SPEED
        and not LocalPlayer.state.cuffed
        and not IsPedRagdoll(ped)
end

local function tackle()
    if not canTackle() then return end

    local target <const> = lib.getClosestPlayer(GetEntityCoords(cache.ped), TACKLE_RANGE, false)

    if not target then return end

    TriggerServerEvent('cobalt_addons:server:tackle', GetPlayerServerId(target))
    playTackle()
end

lib.addKeybind({
    name = 'tackle',
    description = locale('keys.tackle'),
    defaultKey = 'LMENU',
    onPressed = tackle,
})

RegisterNetEvent('cobalt_addons:client:tackled', function()
    SetPedToRagdoll(cache.ped, math.random(1000, 6000), math.random(1000, 6000), 0, false, false, false)
end)

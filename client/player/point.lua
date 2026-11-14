local POINT_DICT <const> = 'anim@mp_point'
local POINT_FLAG <const> = 36
local FIRST_PERSON <const> = 4

local pointing = false

---@param ped integer
local function startPointing(ped)
    lib.requestAnimDict(POINT_DICT)
    SetPedCurrentWeaponVisible(ped, false, true, true, true)
    SetPedConfigFlag(ped, POINT_FLAG, true)
    TaskMoveNetworkByName(ped, 'task_mp_pointing', 0.5, false, POINT_DICT, 24)
    RemoveAnimDict(POINT_DICT)
end

---@param ped integer
local function stopPointing(ped)
    if IsPedInjured(ped) then return end

    RequestTaskMoveNetworkStateTransition(ped, 'Stop')
    ClearPedSecondaryTask(ped)

    if not IsPedInAnyVehicle(ped, true) then
        SetPedCurrentWeaponVisible(ped, true, true, true, true)
    end

    SetPedConfigFlag(ped, POINT_FLAG, false)
end

---@param ped integer
local function updatePointing(ped)
    local pitch = GetGameplayCamRelativePitch()
    local heading = GetGameplayCamRelativeHeading()
    local cosHeading <const> = Cos(heading)
    local sinHeading <const> = Sin(heading)

    pitch = (math.max(-70.0, math.min(42.0, pitch)) + 70.0) / 112.0
    heading = (math.max(-180.0, math.min(180.0, heading)) + 180.0) / 360.0

    local reach <const> = 0.4 * heading + 0.3
    local coords <const> = GetOffsetFromEntityInWorldCoords(
        ped,
        (cosHeading * -0.2) - (sinHeading * reach),
        (sinHeading * -0.2) + (cosHeading * reach),
        0.6
    )
    local ray <const> = StartShapeTestCapsule(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7)
    local _, blocked <const> = GetShapeTestResult(ray)

    SetTaskMoveNetworkSignalFloat(ped, 'Pitch', pitch)
    SetTaskMoveNetworkSignalFloat(ped, 'Heading', heading * -1.0 + 1.0)
    SetTaskMoveNetworkSignalBool(ped, 'isBlocked', blocked)
    SetTaskMoveNetworkSignalBool(ped, 'isFirstPerson', GetCamViewModeForContext(GetCamActiveViewModeContext()) == FIRST_PERSON)
end

local function toggle()
    local ped <const> = cache.ped

    if cache.vehicle then return end

    pointing = not pointing

    if not pointing then
        return stopPointing(ped)
    end

    startPointing(ped)

    while pointing and not cache.vehicle do
        updatePointing(ped)
        Wait(16)
    end

    if pointing then
        pointing = false
        stopPointing(ped)
    end
end

lib.addKeybind({
    name = 'point',
    description = locale('keys.point'),
    defaultKey = 'B',
    onPressed = toggle,
})

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource and pointing then stopPointing(cache.ped) end
end)

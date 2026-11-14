local CROUCH_CLIPSET <const> = 'move_ped_crouched'
local CROUCH_STRAFE <const> = 'move_ped_crouched_strafing'

local crouching = false

---@param ped integer
---@return boolean
local function canCrouch(ped)
    return not IsPedSittingInAnyVehicle(ped)
        and not IsPedFalling(ped)
        and not IsPedSwimming(ped)
        and not IsPedSwimmingUnderWater(ped)
        and not IsPauseMenuActive()
end

---@param ped integer
local function standUp(ped)
    crouching = false
    ResetPedMovementClipset(ped, 1.0)
    ResetPedWeaponMovementClipset(ped)
    ResetPedStrafeClipset(ped)
    SetPedStealthMovement(ped, false, 'DEFAULT_ACTION')
end

local function toggle()
    local ped <const> = cache.ped

    if not canCrouch(ped) then return end

    ClearPedTasks(ped)

    if not crouching then
        crouching = true
        lib.requestAnimSet(CROUCH_CLIPSET)
        SetPedMovementClipset(ped, CROUCH_CLIPSET, 1.0)
        SetPedStrafeClipset(ped, CROUCH_STRAFE)
        return
    end

    standUp(ped)
end

lib.addKeybind({
    name = 'togglecrouch',
    description = locale('keys.crouch'),
    defaultKey = 'LCONTROL',
    onPressed = toggle,
})

lib.onCache('vehicle', function(vehicle)
    if vehicle and crouching then standUp(cache.ped) end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource and crouching then standUp(cache.ped) end
end)

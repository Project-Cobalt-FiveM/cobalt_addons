local config <const> = require 'config'
local visibility <const> = require 'client.hud.visibility'

local settings <const> = config.binoculars
local FOV_MIN <const> = settings.minFov
local FOV_MAX <const> = settings.maxFov

local SCENARIO <const> = 'WORLD_HUMAN_BINOCULARS'
local HUD_KEY <const> = 'binoculars'
local RAISE_MS <const> = 2500
local LOOK_SPEED <const> = 8.0
local ZOOM_EASE <const> = 0.05
local SKEL_HEAD <const> = 31086
local EYE_OFFSET <const> = 0.35
local MAX_PITCH <const> = 20.0
local VIEW_MARGIN <const> = 5.0
local INPUT_LOOK_LR <const> = 220
local INPUT_LOOK_UD <const> = 221
local INPUT_ZOOM_IN <const> = 241
local INPUT_ZOOM_OUT <const> = 242
local INPUT_VEH_ZOOM_IN <const> = 17
local INPUT_VEH_ZOOM_OUT <const> = 16

---@class BinocularView
---@field cam integer
---@field scaleform integer
---@field fov number
---@field inVehicle boolean

local active = false

---@type BinocularView?
local current

---The lowest pitch whose bottom view ray still points ahead of the camera, so the player's body stays out of frame.
---@param fov number
---@return number
local function minPitch(fov)
    return -90.0 + fov * 0.5 + VIEW_MARGIN
end

---Places the camera in front of the eyes along the view heading, clear of the head and the binocular prop.
---@param view BinocularView
---@param heading number
local function placeCamera(view, heading)
    local head <const> = GetPedBoneCoords(cache.ped, SKEL_HEAD, 0.0, 0.0, 0.0)
    local radians <const> = math.rad(heading)

    SetCamCoord(view.cam, head.x - math.sin(radians) * EYE_OFFSET, head.y + math.cos(radians) * EYE_OFFSET, head.z)
end

---@param view BinocularView
local function look(view)
    local fov <const> = GetCamFov(view.cam)
    local zoom <const> = (fov - FOV_MIN) / (FOV_MAX - FOV_MIN) + 0.1
    local rot <const> = GetCamRot(view.cam, 2)
    local heading <const> = rot.z - GetDisabledControlNormal(0, INPUT_LOOK_LR) * LOOK_SPEED * zoom
    local pitch <const> = math.max(math.min(MAX_PITCH, rot.x - GetDisabledControlNormal(0, INPUT_LOOK_UD) * LOOK_SPEED * zoom), minPitch(fov))

    SetCamRot(view.cam, pitch, 0.0, heading, 2)
    placeCamera(view, heading)

    if not view.inVehicle then
        SetEntityHeading(cache.ped, heading)
    end
end

---@param view BinocularView
local function zoom(view)
    local zoomIn <const> = view.inVehicle and INPUT_VEH_ZOOM_IN or INPUT_ZOOM_IN
    local zoomOut <const> = view.inVehicle and INPUT_VEH_ZOOM_OUT or INPUT_ZOOM_OUT

    if IsControlJustPressed(0, zoomIn) then
        view.fov = math.max(view.fov - settings.zoomSpeed, FOV_MIN)
    elseif IsControlJustPressed(0, zoomOut) then
        view.fov = math.min(view.fov + settings.zoomSpeed, FOV_MAX)
    end

    local fov <const> = GetCamFov(view.cam)

    SetCamFov(view.cam, math.abs(view.fov - fov) < 0.1 and view.fov or fov + (view.fov - fov) * ZOOM_EASE)
end

---@return boolean
local function viewing()
    local ped <const> = cache.ped

    return active
        and not IsPedDeadOrDying(ped, true)
        and (current?.inVehicle or IsPedUsingScenario(ped, SCENARIO))
end

local function close()
    local view <const> = current

    active = false

    if not view then return end

    current = nil
    visibility.show(HUD_KEY)
    ClearExtraTimecycleModifier()
    RenderScriptCams(false, false, 0, true, false)
    SetScaleformMovieAsNoLongerNeeded(view.scaleform)
    DestroyCam(view.cam, false)
end

local function open()
    local ped <const> = cache.ped
    local inVehicle <const> = IsPedSittingInAnyVehicle(ped)

    if not inVehicle then
        TaskStartScenarioInPlace(ped, SCENARIO, 0, true)
    end

    Wait(RAISE_MS)

    if not active then return end

    local heading <const> = GetEntityHeading(ped)

    ---@type BinocularView
    local view <const> = {
        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true),
        scaleform = lib.requestScaleformMovie('BINOCULARS') --[[@as integer]],
        fov = FOV_MAX,
        inVehicle = inVehicle,
    }

    current = view
    visibility.hide(HUD_KEY)
    SetExtraTimecycleModifier('default')
    SetExtraTimecycleModifierStrength(0.3)
    SetCamRot(view.cam, 0.0, 0.0, heading, 2)
    SetCamFov(view.cam, FOV_MAX)
    placeCamera(view, heading)
    RenderScriptCams(true, false, 0, true, false)
    BeginScaleformMovieMethod(view.scaleform, 'SET_CAM_LOGO')
    ScaleformMovieMethodAddParamInt(0)
    EndScaleformMovieMethod()

    while viewing() do
        look(view)
        zoom(view)
        DrawScaleformMovieFullscreen(view.scaleform, 255, 255, 255, 255, 0)
        Wait(0)
    end

    close()
end

local function store()
    if not active then return end

    PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
    close()
    ClearPedTasks(cache.ped)
end

lib.addKeybind({
    name = 'cobalt_binoculars_store',
    description = locale('keys.binoculars_store'),
    defaultKey = settings.storeKey,
    onPressed = store,
})

exports('Binoculars', function(event)
    if event ~= 'usedItem' then return end

    if active then return store() end

    active = true
    CreateThread(open)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then close() end
end)

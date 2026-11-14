local config <const> = require 'config'

local disabledControls <const> = lib.disableControls

if #config.disable.controls == 0 then return end

disabledControls:Add(config.disable.controls)

CreateThread(function()
    while true do
        disabledControls()
        Wait(0)
    end
end)

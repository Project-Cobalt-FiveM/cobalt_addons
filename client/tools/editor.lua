local core <const> = exports.cobalt_core

---@param key string
---@param kind string
local function notify(key, kind)
    core:Notify({ description = locale(key), type = kind, duration = 3000 })
end

---@param name string
---@param help string
---@param handler fun()
local function addCommand(name, help, handler)
    RegisterCommand(name, handler, false)
    TriggerEvent('chat:addSuggestion', ('/%s'):format(name), help)
end

addCommand('record', locale('commands.record'), function()
    StartRecording(1)
    notify('editor.started', 'success')
end)

addCommand('clip', locale('commands.clip'), function()
    StartRecording(0)
    notify('editor.clip', 'success')
end)

addCommand('saveclip', locale('commands.saveclip'), function()
    StopRecordingAndSaveClip()
    notify('editor.save', 'success')
end)

addCommand('delclip', locale('commands.delclip'), function()
    StopRecordingAndDiscardClip()
    notify('editor.delete', 'error')
end)

addCommand('editor', locale('commands.editor'), function()
    NetworkSessionLeaveSinglePlayer()
    ActivateRockstarEditor()
    notify('editor.editor', 'info')
end)

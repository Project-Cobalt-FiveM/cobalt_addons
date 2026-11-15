local config <const> = require 'config'

local discord <const> = config.discord

if not discord.enabled then return end

SetDiscordAppId(discord.applicationId)
SetDiscordRichPresenceAsset(discord.iconLarge)
SetDiscordRichPresenceAssetText(locale('discord.large_icon'))
SetDiscordRichPresenceAssetSmall(discord.iconSmall)
SetDiscordRichPresenceAssetSmallText(locale('discord.small_icon'))

for index, button in ipairs(discord.buttons) do
    SetDiscordRichPresenceAction(index - 1, locale(('discord.%s'):format(button.label)), button.url)
end

if not discord.showPlayerCount then return end

---@param count? integer
local function showPlayerCount(count)
    SetRichPresence(locale('discord.players', count or 0, GlobalState.maxPlayers))
end

showPlayerCount(GlobalState.playerCount)

AddStateBagChangeHandler('playerCount', 'global', function(_, _, count)
    showPlayerCount(count)
end)

local config <const> = require 'config'

local discord <const> = config.discord

if not discord.enabled then return end

SetDiscordAppId(discord.applicationId)
SetDiscordRichPresenceAsset(discord.iconLarge)
SetDiscordRichPresenceAssetText(discord.iconLargeHoverText)
SetDiscordRichPresenceAssetSmall(discord.iconSmall)
SetDiscordRichPresenceAssetSmallText(discord.iconSmallHoverText)

for index, button in ipairs(discord.buttons) do
    SetDiscordRichPresenceAction(index - 1, button.text, button.url)
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

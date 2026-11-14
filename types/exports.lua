---@meta

---@class CobaltAddonsExports
local CobaltAddonsExports = {}

---**Server.** The armor items' server export. On `usingItem` it refuses while the player's armour is already at `item.server.armour`; on `usedItem` it sets it, and marks a vest for `/resetarmor` when `item.client.effect` is `vest`.
---@param event 'usingItem' | 'usedItem'
---@param item { server: { armour: integer }, client?: { effect?: string } }
---@param inventory { id: string, source: integer }
---@return false?
function CobaltAddonsExports:Armor(event, item, inventory) end

---**Server.** The parachute item's server export; marks the parachute for `/resetparachute`.
---@param event 'usingItem' | 'usedItem'
---@param item table
---@param inventory { id: string, source: integer }
function CobaltAddonsExports:Parachute(event, item, inventory) end

---**Client.** Plays the effect named by `item.client.effect` (`coke`, `crack`, `meth`, `ecstasy`, `oxy`, `vest`, `parachute` or `firework`) after the item is used.
---@param event 'usingItem' | 'usedItem'
---@param item { client: { effect: string } }
function CobaltAddonsExports:ItemEffect(event, item) end

---**Client.** The binoculars item's client export; toggles the binocular view.
---@param event 'usingItem' | 'usedItem'
function CobaltAddonsExports:Binoculars(event) end

---@alias AddonsNetEvent
---| 'cobalt_addons:server:tackle' # **Server.** `(target: integer)` asks to tackle a player within 3 m; the server checks range and sends `client:tackled`.
---| 'cobalt_addons:client:tackled' # **Client.** Ragdolls the local player after a tackle.

---@alias AddonsCallback
---| 'cobalt_addons:server:washVehicle' # **Server.** Charges the car wash price, cash then bank, when the player drives a vehicle at a wash; returns `boolean`.
---| 'cobalt_addons:client:removeVest' # **Client.** Takes the vest off with a progress bar; returns `boolean`.
---| 'cobalt_addons:client:packParachute' # **Client.** Packs the parachute with a progress bar; returns `boolean`.

---@alias AddonsGlobalState
---| 'maxPlayers' # **Shared.** `integer`, the server's `sv_maxclients`; set only while Discord rich presence shows the player count.
---| 'playerCount' # **Shared.** `integer`, players online, updated on join and drop; set only while Discord rich presence shows the player count.

exports.cobalt_addons = CobaltAddonsExports

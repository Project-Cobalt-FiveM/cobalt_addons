---@meta

---@class CobaltAddonsExports
local CobaltAddonsExports = {}

---**Server.** The armor items' server export. On `usingItem` it refuses while the player's armour is already at `item.server.armour`; on `usedItem` it sets it, and marks a vest for `/resetarmor` when `item.client.effect` is `vest`.
---@param event 'usingItem' | 'usedItem'
---@param item { server: { armour: integer }, client?: { effect?: string } }
---@param inventory { id: string, source: integer }
---@return false?
function CobaltAddonsExports:Armor(event, item, inventory) end

---**Server.** The parachute item's server export; marks the parachute for `/resetparachute` until the server sees the player in freefall.
---@param event 'usingItem' | 'usedItem'
---@param item table
---@param inventory { id: string, source: integer }
function CobaltAddonsExports:Parachute(event, item, inventory) end

---**Server.** The firework items' server export. On `usingItem` it refuses while the player is on `fireworks.cooldown` or has no flat ground in front of them, and returns the spot their client picked; on `usedItem` it sets a firework box down there, runs the countdown for players nearby, launches it and removes the box.
---@param event 'usingItem' | 'usedItem'
---@param item table
---@param inventory { id: string, source: integer }
---@param slot { name: string }
---@param spot? { coords: vector3, heading: number } the value `usingItem` returned
---@return { coords: vector3, heading: number } | false?
function CobaltAddonsExports:Firework(event, item, inventory, slot, spot) end

---**Client.** Plays the effect named by `item.client.effect` (`coke`, `crack`, `meth`, `ecstasy`, `oxy`, `vest` or `parachute`) after the item is used.
---@param event 'usingItem' | 'usedItem'
---@param item { client: { effect: string } }
function CobaltAddonsExports:ItemEffect(event, item) end

---**Client.** The binoculars item's client export; toggles the binocular view.
---@param event 'usingItem' | 'usedItem'
function CobaltAddonsExports:Binoculars(event) end

---@alias AddonsNetEvent
---| 'cobalt_addons:server:tackle' # **Server.** `(target: integer)` asks to tackle a player within 3 m in the same routing bucket who is not dead, cuffed, escorted or in a vehicle; the server sends `client:tackled`.
---| 'cobalt_addons:client:tackled' # **Client.** Ragdolls the local player after a tackle.
---| 'cobalt_addons:client:fireworkFuse' # **Client.** `(coords: vector3, remaining?: integer)` sparks the fuse of a firework box nearby; `remaining` is sent only to the player who lit it, who sees the countdown.
---| 'cobalt_addons:client:fireworkLaunch' # **Client.** `(coords: vector3, show: FireworkFlash[])` plays the launch and bursts the server picked, the same for every player in view.

---@alias AddonsCallback
---| 'cobalt_addons:server:canWash' # **Server.** Whether the player drives a vehicle at a wash and has the price in cash or bank; returns `boolean`.
---| 'cobalt_addons:server:washVehicle' # **Server.** Charges the car wash price, cash then bank, when the player drives a vehicle at a wash; returns `boolean`.
---| 'cobalt_addons:client:removeVest' # **Client.** Takes the vest off with a progress bar; returns `boolean` and, once removed, the armour left as `integer`.
---| 'cobalt_addons:client:packParachute' # **Client.** Packs the parachute with a progress bar; returns `boolean`.
---| 'cobalt_addons:client:fireworkSpot' # **Client.** Finds the ground in front of the player for a firework box; returns `{ coords: vector3, heading: number }` or nothing.

---@alias AddonsGlobalState
---| 'maxPlayers' # **Shared.** `integer`, the server's `sv_maxclients`; set only while Discord rich presence shows the player count.
---| 'playerCount' # **Shared.** `integer`, players online, updated on join and drop; set only while Discord rich presence shows the player count.

exports.cobalt_addons = CobaltAddonsExports

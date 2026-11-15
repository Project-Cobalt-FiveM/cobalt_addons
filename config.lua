local shirtAnim <const> = { dict = 'clothingshirt', clip = 'try_shirt_positive_d', flag = 49 }

return {
    -- Pause menu
    pauseMapTitle = true, -- true shows pause_map.title from locales/en.json as the pause map title; false keeps FiveM's own

    -- AFK kick
    afk = {
        secondsUntilKick = 0, -- seconds standing still before a kick, checked every 10 s; 0 turns the AFK kick off
        kickInCharMenu = false, -- kick players idling in character selection
        exemptAces = { 'group.staff' }, -- ACEs never kicked, e.g. 'group.staff' or 'command.afkexempt'; group.staff covers admin and owner
    },

    -- Binoculars item
    binoculars = {
        zoomSpeed = 10.0, -- degrees of field of view each scroll step zooms in or out
        minFov = 5.0, -- narrowest field of view in degrees, the strongest zoom
        maxFov = 50.0, -- widest field of view in degrees, where the view starts; 50 matches normal on-foot vision
        -- Key names: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
        storeKey = 'BACK', -- default key that puts the binoculars away; players can rebind it in Settings > Key Bindings > FiveM
    },

    -- World density, each a multiplier from 0.0 (none) to 1.0 (GTA default)
    density = {
        parked = 0.9, -- parked cars
        vehicle = 0.4, -- moving traffic
        multiplier = 0.7, -- random vehicles such as service and emergency traffic
        peds = 0.6, -- pedestrians
        scenario = 0.0, -- peds and vehicles spawned by world scenarios
    },

    -- Areas whose car generators are emptied on join and on each character load: a centre and a radius in meters
    clearedCarGenerators = {
        { coords = vec3(335.2616, -1432.455, 46.51), radius = 300.0 },
        { coords = vec3(441.8465, -987.99, 30.68), radius = 500.0 },
        { coords = vec3(316.79, -592.36, 43.28), radius = 300.0 },
        { coords = vec3(-2150.44, 3075.99, 32.8), radius = 500.0 },
        { coords = vec3(-1108.35, 4920.64, 217.2), radius = 300.0 },
        { coords = vec3(-458.24, 6019.81, 31.34), radius = 300.0 },
        { coords = vec3(1854.82, 3679.4, 33.82), radius = 300.0 },
        { coords = vec3(-724.46, -1444.03, 5.0), radius = 300.0 },
    },

    -- GTA's own police and emergency response
    aiResponse = {
        wantedLevels = false, -- false keeps the wanted level at zero
        -- AI services that respond to crimes; true lets that service turn up
        dispatchServices = {
            policeCars = false, -- patrol cars chasing wanted players
            policeHelicopters = false, -- police helicopters
            fireTrucks = false, -- fire trucks at fires
            swatVans = false, -- SWAT vans
            ambulances = false, -- ambulances at injured peds
            policeBikes = false, -- police motorbikes
            policeBackup = false, -- extra units joining a chase
            roadblocks = false, -- police roadblocks
            policePullover = false, -- police stopping at a pull-over
            cruisingPolice = false, -- police cruising the streets
            gangs = false, -- gang members responding
            swatHelicopters = false, -- SWAT helicopters
            policeBoats = false, -- police boats
            army = false, -- army units
            bikerBackup = false, -- biker gang backup
        },
    },

    -- World scenarios that never spawn: scenario type names and scenario group names
    blacklistedScenarios = {
        -- Scenario type names: https://github.com/DurtyFree/gta-v-data-dumps/blob/master/scenariosCompact.json
        types = {
            'WORLD_VEHICLE_MILITARY_PLANES_SMALL',
            'WORLD_VEHICLE_MILITARY_PLANES_BIG',
            'WORLD_VEHICLE_AMBULANCE',
            'WORLD_VEHICLE_POLICE_NEXT_TO_CAR',
            'WORLD_VEHICLE_POLICE_CAR',
            'WORLD_VEHICLE_POLICE_BIKE',
        },
        -- Scenario group names: https://github.com/DurtyFree/gta-v-data-dumps/blob/master/scenarioGroupNames.json
        groups = {
            'LSA_Planes',
            'Sandy_Planes',
            'Grapeseed_Planes',
            'ng_planes',
        },
    },

    -- Ped models that never spawn, as [`model`] = true
    -- Model names: https://docs.fivem.net/docs/game-references/ped-models/
    blacklistedPeds = {
        [`s_m_y_ranger_01`] = true,
        [`s_m_y_sheriff_01`] = true,
        [`s_m_y_cop_01`] = true,
        [`s_f_y_sheriff_01`] = true,
        [`s_f_y_cop_01`] = true,
        [`s_m_y_hwaycop_01`] = true,
    },

    -- Weapons taken away as soon as a player equips one, as [`WEAPON_NAME`] = true
    -- Weapon names: https://docs.fivem.net/docs/game-references/weapon-models/
    blacklistedWeapons = {
        [`WEAPON_RAILGUN`] = true,
    },

    -- Vehicle models that never spawn, as [`model`] = true
    -- Model names: https://docs.fivem.net/docs/game-references/vehicle-references/vehicle-models/
    blacklistedVehicles = {
        [`jet`] = true,
        [`lazer`] = true,
        [`buzzard`] = true,
        [`buzzard2`] = true,
        [`annihilator`] = true,
        [`savage`] = true,
        [`titan`] = true,
        [`rhino`] = true,
        [`blimp`] = true,
        [`camper`] = true,
        [`hydra`] = true,
        [`technical3`] = true,
        [`insurgent3`] = true,
        [`apc`] = true,
        [`tampa3`] = true,
        [`trailersmall2`] = true,
        [`halftrack`] = true,
        [`hunter`] = true,
        [`vigilante`] = true,
        [`akula`] = true,
        [`barrage`] = true,
        [`khanjali`] = true,
        [`blimp3`] = true,
        [`menacer`] = true,
        [`oppressor2`] = true,
        [`scramjet`] = true,
        [`strikeforce`] = true,
        [`cerberus`] = true,
        [`cerberus2`] = true,
        [`cerberus3`] = true,
        [`scarab`] = true,
        [`scarab2`] = true,
        [`scarab3`] = true,
        [`rrocket`] = true,
        [`cargoplane2`] = true,
    },

    -- GTA features to switch off
    disable = {
        -- Game controls blocked by number, e.g. { 140, 141 }; cobalt_inventory already blocks the weapon wheel (37)
        -- Full list: https://docs.fivem.net/docs/game-references/controls/
        controls = {},
        ambience = true, -- mute ambient world sound and flight music
        idleCamera = true, -- stop the camera drifting into idle cinematic mode
        vestDrawable = true, -- stop armour items putting a vest model on the player
        pistolWhipping = true, -- stop melee attacks with a gun in hand
        driveby = false, -- stop shooting from vehicles
        carRadio = true, -- vehicle radios start off when entering a vehicle
        airControl = true, -- stop steering cars while they are in the air
    },

    -- Parachute item: packing a used parachute back into an item
    parachute = {
        packDuration = 40000, -- milliseconds to pack it
        anim = shirtAnim, -- animation while packing
    },

    -- Firework items: the box is set down in front of the player, counts down, then launches
    fireworks = {
        model = 'ind_prop_firework_03', -- prop placed on the ground; the item's placing animation is in cobalt_inventory's data/items.lua
        placeDistance = 0.8, -- meters in front of the player the box is set down
        delay = 5, -- seconds of countdown before it launches
        cooldown = 10, -- seconds a player waits before placing another firework
        countdownRange = 50.0, -- meters within which players see the countdown and the sparking fuse
        viewRange = 400.0, -- meters within which players see the launch and the bursts
        burstHeight = 42.5, -- meters above the box the bursts go off
        asset = 'proj_indep_firework', -- burst particle set: proj_indep_firework, proj_indep_firework_v2, proj_xmas_firework or scr_indep_fireworks
        cleanupDelay = 15, -- seconds the spent box stays on the ground after launch
    },

    -- Discord rich presence, shown on each player's Discord profile; its texts are the discord keys in locales/en.json
    discord = {
        enabled = false, -- true turns it on; needs a Discord application
        applicationId = '00000000000000000', -- application id from the Discord developer portal
        iconLarge = 'logo_name', -- large image asset key uploaded to that application; its hover text is discord.large_icon
        iconSmall = 'small_logo_name', -- small image asset key; its hover text is discord.small_icon
        showPlayerCount = true, -- show players online out of the server's sv_maxclients slots
        buttons = { -- up to two buttons, each a label (a key under discord in locales/en.json) and a link
            { label = 'connect_button', url = 'fivem://connect/localhost:30120' },
            { label = 'docs_button', url = 'https://docs.projectcobalt.net' },
        },
    },

    -- Car washes
    carWash = {
        dirtLevel = 0.1, -- GTA dirt level (0.0 clean to 15.0 filthy) at or below which a car counts as clean
        price = 20, -- dollars per wash
        blip = { -- FiveM blip sprite, colour and scale; category is the map legend group, named by the wash.blip_category locale
            -- category ids from 10 up are custom; pick one no other resource uses (banking 12, garages 13, impound 15)
            sprite = 100,
            colour = 37,
            scale = 0.75,
            category = 14,
        },
        locations = { -- wash bays: centre, length and width in meters, heading in degrees
            { coords = vec3(174.81, -1736.77, 28.87), length = 7.0, width = 8.8, heading = 359 },
            { coords = vec3(25.2, -1391.98, 28.91), length = 6.6, width = 8.2, heading = 0 },
            { coords = vec3(-74.27, 6427.72, 31.02), length = 9.4, width = 8.0, heading = 315 },
            { coords = vec3(1362.69, 3591.81, 34.5), length = 6.4, width = 8.0, heading = 21 },
            { coords = vec3(-699.84, -932.68, 18.59), length = 11.8, width = 5.2, heading = 0 },
        },
    },

    -- World props hidden for everyone: every prop of that model within radius meters of coords
    -- For permanent map edits, a ymap (entity removal or LOD edits) is the recommended way; this list is for quick cases
    -- Model names: https://github.com/DurtyFree/gta-v-data-dumps/blob/master/ObjectList.ini
    removedObjects = {
        { coords = vec3(266.09, -349.35, 44.74), radius = 3.0, model = `prop_sec_barier_02b` },
        { coords = vec3(285.28, -355.78, 45.13), radius = 3.0, model = `prop_sec_barier_02a` },
    },

    -- Two-way teleports, each a pair of portals; standing in one shows a prompt and the interact key moves the player to the other
    -- length and width size the portal box in meters, heading is the direction faced on arrival there,
    -- allowVehicle takes the vehicle along, prompt names the teleport key in locales/en.json shown at that portal (default 'elevator')
    teleports = {
        {
            { coords = vec3(3540.74, 3675.59, 20.99), heading = 167.5, length = 2, width = 2, allowVehicle = false },
            { coords = vec3(3540.74, 3675.59, 28.11), heading = 172.5, length = 2, width = 2, allowVehicle = false },
        },
    },

    -- Weapon recoil: degrees the camera kicks up per shot, by weapon hash; 0.0 for none
    recoils = {
        [`WEAPON_PISTOL`] = 0.3,
        [`WEAPON_PISTOL_MK2`] = 0.5,
        [`WEAPON_COMBATPISTOL`] = 0.2,
        [`WEAPON_APPISTOL`] = 0.3,
        [`WEAPON_STUNGUN`] = 0.1,
        [`WEAPON_PISTOL50`] = 0.6,
        [`WEAPON_SNSPISTOL`] = 0.2,
        [`WEAPON_HEAVYPISTOL`] = 0.5,
        [`WEAPON_VINTAGEPISTOL`] = 0.4,
        [`WEAPON_FLAREGUN`] = 0.9,
        [`WEAPON_MARKSMANPISTOL`] = 0.9,
        [`WEAPON_REVOLVER`] = 0.6,
        [`WEAPON_REVOLVER_MK2`] = 0.6,
        [`WEAPON_DOUBLEACTION`] = 0.3,
        [`WEAPON_SNSPISTOL_MK2`] = 0.3,
        [`WEAPON_RAYPISTOL`] = 0.3,
        [`WEAPON_CERAMICPISTOL`] = 0.3,
        [`WEAPON_NAVYREVOLVER`] = 0.3,
        [`WEAPON_GADGETPISTOL`] = 0.3,

        [`WEAPON_MICROSMG`] = 0.5,
        [`WEAPON_SMG`] = 0.4,
        [`WEAPON_SMG_MK2`] = 0.1,
        [`WEAPON_ASSAULTSMG`] = 0.1,
        [`WEAPON_COMBATPDW`] = 0.2,
        [`WEAPON_MACHINEPISTOL`] = 0.3,
        [`WEAPON_MINISMG`] = 0.1,
        [`WEAPON_RAYCARBINE`] = 0.3,

        [`WEAPON_PUMPSHOTGUN`] = 0.4,
        [`WEAPON_SAWNOFFSHOTGUN`] = 0.7,
        [`WEAPON_ASSAULTSHOTGUN`] = 0.4,
        [`WEAPON_BULLPUPSHOTGUN`] = 0.2,
        [`WEAPON_MUSKET`] = 0.7,
        [`WEAPON_HEAVYSHOTGUN`] = 0.2,
        [`WEAPON_DBSHOTGUN`] = 0.7,
        [`WEAPON_AUTOSHOTGUN`] = 0.2,
        [`WEAPON_PUMPSHOTGUN_MK2`] = 0.4,
        [`WEAPON_COMBATSHOTGUN`] = 0.0,

        [`WEAPON_ASSAULTRIFLE`] = 0.5,
        [`WEAPON_ASSAULTRIFLE_MK2`] = 0.2,
        [`WEAPON_CARBINERIFLE`] = 0.3,
        [`WEAPON_CARBINERIFLE_MK2`] = 0.1,
        [`WEAPON_ADVANCEDRIFLE`] = 0.1,
        [`WEAPON_SPECIALCARBINE`] = 0.2,
        [`WEAPON_BULLPUPRIFLE`] = 0.2,
        [`WEAPON_COMPACTRIFLE`] = 0.3,
        [`WEAPON_SPECIALCARBINE_MK2`] = 0.2,
        [`WEAPON_BULLPUPRIFLE_MK2`] = 0.2,
        [`WEAPON_MILITARYRIFLE`] = 0.0,

        [`WEAPON_MG`] = 0.1,
        [`WEAPON_COMBATMG`] = 0.1,
        [`WEAPON_GUSENBERG`] = 0.1,
        [`WEAPON_COMBATMG_MK2`] = 0.1,

        [`WEAPON_SNIPERRIFLE`] = 0.5,
        [`WEAPON_HEAVYSNIPER`] = 0.7,
        [`WEAPON_MARKSMANRIFLE`] = 0.3,
        [`WEAPON_REMOTESNIPER`] = 1.2,
        [`WEAPON_HEAVYSNIPER_MK2`] = 0.6,
        [`WEAPON_MARKSMANRIFLE_MK2`] = 0.3,

        [`WEAPON_RPG`] = 0.0,
        [`WEAPON_GRENADELAUNCHER`] = 1.0,
        [`WEAPON_GRENADELAUNCHER_SMOKE`] = 1.0,
        [`WEAPON_MINIGUN`] = 0.1,
        [`WEAPON_FIREWORK`] = 0.3,
        [`WEAPON_RAILGUN`] = 2.4,
        [`WEAPON_HOMINGLAUNCHER`] = 0.0,
        [`WEAPON_COMPACTLAUNCHER`] = 0.5,
        [`WEAPON_RAYMINIGUN`] = 0.3,
    },
}

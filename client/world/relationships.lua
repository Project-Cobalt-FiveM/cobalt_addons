local COMPANION <const> = 1

local calmGroups <const> = {
    `AMBIENT_GANG_HILLBILLY`,
    `AMBIENT_GANG_BALLAS`,
    `AMBIENT_GANG_MEXICAN`,
    `AMBIENT_GANG_FAMILY`,
    `AMBIENT_GANG_MARABUNTE`,
    `AMBIENT_GANG_SALVA`,
    `AMBIENT_GANG_LOST`,
    `GANG_1`,
    `GANG_2`,
    `GANG_9`,
    `GANG_10`,
    `FIREMAN`,
    `MEDIC`,
    `COP`,
    `PRISONER`,
}

for i = 1, #calmGroups do
    SetRelationshipBetweenGroups(COMPANION, calmGroups[i], `PLAYER`)
end

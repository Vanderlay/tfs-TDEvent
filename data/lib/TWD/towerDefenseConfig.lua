twdConfig = {
    loseHealth = 10, -- How much % should player lose, when the monster walk inside your base
    eventStartTime = 30, -- How long until the event starts, when player step in the teleport [seconds]
    startingCoins = 200, -- How much coins should the player start with!
    startNextWaveTime = 15, -- How long until next wave starts [seconds]
    resetEventTime = 10 -- How long until next player can enter, if someone already was in there [30 seconds] is recommended.
}

-- Write unused storage
playingGameStorage = 1000
coinStorage = 1001

-- Write unused global storage
waveLevelGlobalStorage = 100 -- Here write
totalMonsterCountGlobalStorage = 101
totalMonsterKillCountGlobalStorage = 102

-- Positions
eventRoomPosition = Position(31530, 32785, 7) -- Where should player get teleported in the event room?
eventCenterPosition = Position(31540, 32792, 7) -- Center of the event room
summonMonsterPosition = Position(31530, 32782, 7) -- Where should the monster be created?

turrets = {
    -- AttackTypes = target, aoe and targetAoe
    -- When you create new turret, make sure to write it's looktype in the [allTurretsId]

    allTurretsId = {129},
    [129] = { -- This Example of a target/aoe and targetAoe Turrent [Define by lookType]
        combat = {
            [1] = {attackType = "target", combatType = COMBAT_PHYSICALDAMAGE, combatArea = 0, dmgValues = {10, 20}, magicEffect = CONST_ME_NONE, shootEffect = CONST_ANI_ARROW},
            [2] = {attackType = "targetAoe", combatType = COMBAT_PHYSICALDAMAGE, combatArea = burstArrowArea, dmgValues = {30, 50}, magicEffect = CONST_ME_FIREAREA, shootEffect = CONST_ANI_BURSTARROW},
            [3] = {attackType = "aoe", combatType = COMBAT_PHYSICALDAMAGE, combatArea = AREA_CIRCLE2X2, dmgValues = {50, 70}, magicEffect = CONST_ME_GROUNDSHAKER, shootEffect = CONST_ANI_NONE}
        },
        cfg = {
            turretName = "Starter Turret",
            [1] = {buildPrice = 60, sellPrice = 30, upgradePrice = 120, rangeX = 3, rangeY = 3, colorId = 64, attackSpeed = 1000},
            [2] = {sellPrice = 60, upgradePrice = 180, rangeX = 4, rangeY = 4, colorId = 64, attackSpeed = 800},
            [3] = {sellPrice = 120, upgradePrice = 250, rangeX = 6, rangeY = 6, colorId = 64, attackSpeed = 500}
        }
    }
}

monsters = {-- monsterName, "drop" coins, current Health + extraHealth, speed
    ["Rat"] = {
        coins = 5,
        extraHealth = 0,
        speed = 400
    },
    ["Cave Rat"] = {
        coins = 5,
        extraHealth = 10,
        speed = 100
    }
}

waves = {
    maxWaveLevel = 3,
    [1] = {
        interval = 1000,
        goldBonus = 100,
        expBonus = 200,
        monsters = {
            {name = "Rat", count = 10, interval = 500}
        }
    },
    [2] = {
        interval = 1000,
        goldBonus = 150,
        expBonus = 3000,
        monsters = {
            {name = "Cave Rat", count = 10, interval = 500}
        }
    },
    [3] = {
        interval = 1000,
        goldBonus = 300,
        expBonus = 500,
        monsters = {
            {name = "Rat", count = 10, interval = 500},
            {name = "Cave Rat", count = 10, interval = 500}
        }
    }
}
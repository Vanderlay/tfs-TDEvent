dofile('data/lib/TWD/towerDefenseLib.lua')

local function sendToNextWave(cid)
    local player = Player(cid)
    if not player then
        return false
    end

    local waveLevel = getWaveLevel()
    setWaveLevel(waveLevel + 1) -- Let's add + 1 to our current wave
    waveLevel = getWaveLevel() -- Let's refresh the variable

    if waveLevel <= waves.maxWaveLevel then -- Let's make sure there is more waves / Else end the event
        local waveTable = waves[waveLevel]
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("You have advanced to wave level %s, gained %s coins and %s experience points.", waveLevel, waveTable.goldBonus, waveTable.expBonus))
        startNextWave(waveLevel, twdConfig.startNextWaveTime)
        Game.setStorageValue(totalMonsterKillCountGlobalStorage, 0)
        player:addCoins(waveTable.goldBonus)
        player:addExperience(waveTable.expBonus, true)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have now total ".. player:getCoins() .." coins.")
    else
        sendReward(cid)
        resetEvent()
    end
end

function onDeath(cid, corpse, killerId, mostDamageKiller, unjustified, mostDamageUnjustified)
    local creature = Creature(cid)
    local player = getPlayerInEvent(20, 20)
    if not player then -- Make sure that the players exsist in the arena, to prevent errors
        return true
    end
    local killer = Creature(killerId)
    if killer and killer:isNpc() then
        local cfg = monsters[creature:getName()]
        creature:say("+" ..cfg.coins, TALKTYPE_MONSTER_SAY)
        player:addCoins(cfg.coins)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have total ".. player:getCoins() .." coins.")
    end

    Game.setStorageValue(totalMonsterKillCountGlobalStorage, Game.getStorageValue(totalMonsterKillCountGlobalStorage) + 1)
    if Game.getStorageValue(totalMonsterKillCountGlobalStorage) >= Game.getStorageValue(totalMonsterCountGlobalStorage) then
        sendToNextWave(player:getId())
    end
    return true
end
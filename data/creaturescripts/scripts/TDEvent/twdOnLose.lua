dofile('data/lib/TWD/towerDefenseLib.lua')


function onPrepareDeath(player, killer)
    if player:getStorageValue(playingGameStorage) ~= 1 then
        return true
    end

    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have lost the Tower Of Defence Event.")
    player:resetValues()
    addEvent(resetEvent, twdConfig.resetEventTime * 1000)
    return false
end
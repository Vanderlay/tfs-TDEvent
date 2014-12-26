dofile('data/lib/TWD/towerDefenseLib.lua')

function onModalWindow(player, modalWindowId, buttonId, choiceId)
    if modalWindowId ~= 100 then -- Not our window
             return false
       elseif buttonId == 1 then -- Cancel
             return false
       end

     local choice = turrets[choiceId]
       if not choice then
        return false
    end

    local table = choice.cfg[1]
    if player:getCoins() < choice.cfg[1].buildPrice then
        player:sendCancelMessage("You don't have enough of coins.")
        return false
    end

    local npc = Game.createNpc("Turret", turretPosition, false, true)
    if not npc then
        return false
    end

    player:addCoins(-choice.cfg[1].buildPrice)
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have total ".. player:getCoins() .." coins.")

    local setColor = table.colorId
    npc:setOutfit({lookType = choiceId, lookHead = setColor , lookBody = setColor, lookLegs = setColor, lookFeet = setColor})
    npc:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
       return true
end
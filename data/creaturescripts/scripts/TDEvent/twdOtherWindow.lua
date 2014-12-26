dofile('data/lib/TWD/towerDefenseLib.lua')

function onModalWindow(player, modalWindowId, buttonId, choiceId)
    if modalWindowId ~= 101 then -- Not our window
             return false
       elseif buttonId == 1 then -- Cancel
             return false
       end

    local npc = targetTurret
    local npcLvl = npc:getTurretLevel()
    local table = turrets[npc:getOutfit().lookType].cfg[npcLvl]

       if choiceId == 0 then
        if player:getCoins() < table.upgradePrice then
            player:sendCancelMessage("You don't have enough of coins.")
            return false
        end

        npcLvl = npcLvl + 1
        local setColor = table.colorId
        npc:setOutfit({lookType = npc:getOutfit().lookType, lookHead = setColor , lookBody = setColor, lookLegs = setColor, lookFeet = setColor, lookAddons = npcLvl})
        npc:getPosition():sendMagicEffect(math.random(CONST_ME_FIREWORK_YELLOW, CONST_ME_FIREWORK_BLUE))
        player:addCoins(-table.upgradePrice)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have total ".. player:getCoins() .." coins.")
        targetTurret = nil
    else
        player:addCoins(table.sellPrice)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have total ".. player:getCoins() .." coins.")
        npc:say("+" ..table.sellPrice, TALKTYPE_MONSTER_SAY)
        player:addCoins(table.sellPrice)
        npc:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
        npc:remove()
        targetTurret = nil
    end
       return true
end
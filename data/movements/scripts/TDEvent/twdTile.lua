dofile('data/lib/TWD/towerDefenseLib.lua')
 
function onStepIn(cid, item, position, fromPosition)
        local creature = Creature(cid)
        if item.uid == 3333 then
                if not creature:isMonster() then
                        return false
                end
 
                local maxHealthDmg = creature:getMaxHealth()
                doTargetCombatHealth(0, creature, COMBAT_PHYSICALDAMAGE, -maxHealthDmg, -maxHealthDmg, CONST_ME_FIREAREA)
 
                local player = getPlayerInEvent(20, 20)
                if not player then -- Make sure that the players exsist in the arena, to prevent errors
                        return true
                end
 
                local calcHealthDmg = (player:getMaxHealth() * twdConfig.loseHealth) / 100
                doTargetCombatHealth(0, player:getId(), COMBAT_PHYSICALDAMAGE, -calcHealthDmg, -calcHealthDmg, CONST_ME_DRAWBLOOD)
        else
                if not creature:isPlayer() then
                        return false
                end
 
                -- Let's make sure none is playing, before entrance
                if getWaveLevel() > 0 then
                        creature:teleportTo(fromPosition, true)
                        fromPosition:sendMagicEffect(CONST_ME_TELEPORT)
                        creature:sendTextMessage(MESSAGE_INFO_DESCR, "There is someone already in the event.")
                        return true
                end
 
                -- Prepare Player
                creature:teleportTo(eventRoomPosition)
                creature:addHealth(creature:getMaxHealth())
                creature:setStorageValue(playingGameStorage, 1)
                creature:addCoins(twdConfig.startingCoins)
                creature:addItem(2557, 1)
 
                -- Setup Game
                setWaveLevel(1)
                startNextWave(1, twdConfig.eventStartTime)
                Game.setStorageValue(totalMonsterKillCountGlobalStorage, 0)
 
                -- Send Effects
                eventRoomPosition:sendMagicEffect(CONST_ME_TELEPORT)
                local pointingSummonPosition = summonMonsterPosition
                Position(pointingSummonPosition.x + 1, pointingSummonPosition.y, pointingSummonPosition.z):sendMagicEffect(CONST_ME_TUTORIALARROW)
 
                -- Send Messages
                creature:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have total ".. creature:getCoins() .." coins.")
                creature:sendTextMessage(MESSAGE_INFO_DESCR, "Welcome to the Tower Defense Event. The first wave will start in ".. twdConfig.eventStartTime .." seconds. Please build your first turret.")
                creature:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "The blue arrow, points where the monsters are comming from. Use the hammer, to build your first turret.")
 
                -- Register Events
                creature:registerEvent("TWDOnLose")
                creature:registerEvent("TWDHealthChange")
                creature:registerEvent("TWDBuildWindow")
                creature:registerEvent("TWDOtherWindow")
        end
        return true
end
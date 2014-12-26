dofile('data/lib/TWD/towerDefenseSpellsArea.lua')
dofile('data/lib/TWD/towerDefenseConfig.lua')
 
targetTurret = nil
turretPosition = nil
 
local twdEvents = {
    "TWDOnLose",
    "TWDBuildWindow",
    "TWDOtherWindow",
    "TWDHealthChange"
}
 
function Player.resetValues(self)
    self:removeItem(2557, 1)
    self:setStorageValue(coinStorage, 0)
    self:addHealth(self:getMaxHealth())
    self:setStorageValue(playingGameStorage, 0)
    self:teleportTo(self:getTown():getTemplePosition())
    for i = 1, #twdEvents do
        self:unregisterEvent(twdEvents[i])
    end
end
 
function sendReward(cid)
    local player = Player(cid)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have won the Tower Of Defense Event.")
    player:addItem(2160, 10)
    player:resetValues()
end
 
function resetEvent()
    turretPosition = nil
    targetTurret = nil
    setWaveLevel(0)
    Game.setStorageValue(totalMonsterKillCountGlobalStorage, 0)
    Game.setStorageValue(totalMonsterCountGlobalStorage, 0)
 
    local specs, turrets = Game.getSpectators(eventCenterPosition, false, false, 40, 40, 40, 40)
    for i = 1, #specs do
        turrets = specs[i]
        if turrets:isNpc() and turrets:getName() == "Turret" then
            turrets:remove()
        end
    end
end

function monsterPathFinding(currentDirection, pos)
    local newPos = getNextTile(currentDirection, pos)
    if newPos then
        if checkTile(newPos) then
            return newPos, currentDirection
        elseif currentDirection == 'EAST' or currentDirection == 'WEST' then
            northPos = Position(pos.x, pos.y - 1, pos.z)
            southPos = Position(pos.x, pos.y + 1, pos.z)
            if checkTile(northPos) then
                return northPos, 'NORTH'
            elseif checkTile(southPos) then
                return southPos, 'SOUTH'
            end
        elseif currentDirection == 'SOUTH' or currentDirection == 'NORTH' then
            westPos = Position(pos.x - 1, pos.y, pos.z)
            eastPos = Position(pos.x + 1, pos.y, pos.z)
            if checkTile(westPos) then
                return westPos, 'WEST'
            elseif checkTile(eastPos) then
                return eastPos, 'EAST'
            end
        end
    end
    return false, currentDirection
end

function getNextTile(currentDirection, pos)
    local newPos
    if currentDirection == 'EAST' then
        newPos = Position(pos.x + 1, pos.y, pos.z)
    elseif currentDirection == 'WEST' then
        newPos = Position(pos.x - 1, pos.y, pos.z)
    elseif currentDirection == 'SOUTH' then
        newPos = Position(pos.x, pos.y + 1, pos.z)
    elseif currentDirection == 'NORTH' then
        newPos = Position(pos.x, pos.y - 1, pos.z)
    end

    return newPos
end

function checkTile(position)
    local tile = position:getTile()
    if tile then
        if not tile:hasProperty(CONST_PROP_IMMOVABLEBLOCKSOLID) then
            return true
        end
    end

    return false
end
 
local function monsterWalkTo(monster, currentDirection) -- Limos - Rewritted entirely by Vanderlay
    if monster then
        local newPos, direction = monsterPathFinding(currentDirection, monster:getPosition())
        if newPos then
            monster:teleportTo(newPos, true)
            local speed = monsters[monster:getName()].speed
            if not speed then
                speed = 0
            end
            addEvent(monsterWalkTo, 1000 - speed, monster, direction)
        end
    end
end
 
function Npc.searchTarget(self, xRange, yRange)
    local target = self:getTarget()
    local specs, creatures = Game.getSpectators(self:getPosition(), false, false, xRange, xRange, yRange, yRange)
    for i = 1, #specs do
        if target then -- We already have a target, which is in range. Let's break the loop then
            break
        end
 
        creatures = specs[i]
        if creatures:isMonster() then -- Let's pick a target, which is a monster
            return self:setTarget(creatures)
        end
    end
end
 
function Npc.shootSpell(self, attackType, target, combat, area, min, max, magicEffect, distEffect)
    if attackType == "aoe" then
        doAreaCombatHealth(self, combat, self:getPosition(), area, -min, -max, magicEffect)
    elseif attackType == "targetAoe" then
        doAreaCombatHealth(self, combat, target:getPosition(), area, -min, -max, magicEffect)
        self:getPosition():sendDistanceEffect(target:getPosition(), distEffect)
    else
        doTargetCombatHealth(self, target, combat, -min, -max, magicEffect)
        self:getPosition():sendDistanceEffect(target:getPosition(), distEffect)
    end
end
 
function getPlayerInEvent(xRange, yRange)
    local player
    if player then
        return player
    end
 
    local specs = Game.getSpectators(eventCenterPosition, false, true, xRange, xRange, yRange, yRange)
    for i = 1, #specs do
        if specs[i]:getStorageValue(playingGameStorage) == 1 then
            player = specs[i]
            return player
        end
    end
end
 
local function summonMonster(name)
    local monster = Game.createMonster(name .."_TWD", summonMonsterPosition, false, true)
    if monster then
        monster:setDirection(EAST)
        monsterWalkTo(monster, 'EAST')
        summonMonsterPosition:sendMagicEffect(CONST_ME_TELEPORT)
        monster:changeSpeed(-monster:getSpeed() + 130)
 
        local extraHealth = monsters[name].extraHealth
        if extraHealth then
            monster:setMaxHealth(monster:getMaxHealth() + extraHealth)
            monster:addHealth(monster:getMaxHealth())
        end
    end
end
 
function startWaveLevel(level) -- Ninja
    local table, total = waves, 0
    for a = 1, #waves do
        table = waves[level]
        for b = 1, #table.monsters do
            for c = 1, table.monsters[b].count do
                addEvent(function()
                    addEvent(summonMonster, b * table.monsters[b].interval, table.monsters[b].name)
                end, c * table.interval)
            end
 
            total = total + table.monsters[b].count
        end
        break
    end
 
    Game.setStorageValue(totalMonsterCountGlobalStorage, total)
end      
 
function startNextWave(level, interval)
    addEvent(startWaveLevel, interval * 1000, level)
end
 
function Npc.setTurretLevel(self, level)
    if level > 3 then
        level = 3
    end
 
    local lookId = self:getOutfit().lookType
    local setColor = turrets[lookId].cfg[level].colorId
    self:setOutfit({lookType = lookId, lookHead = setColor , lookBody = setColor, lookLegs = setColor, lookFeet = setColor, lookAddons = level})
end
 
function Npc.getTurretLevel(self)
    local addon = self:getOutfit().lookAddons
    if addon == 0 then
        return 1
    end
 
    return addon
end
 
function getWaveLevel()
    return Game.getStorageValue(waveLevelGlobalStorage) or 0
end
 
function setWaveLevel(lvl)
    Game.setStorageValue(waveLevelGlobalStorage, lvl)
end
 
function Player.getCoins(self)
    return self:getStorageValue(coinStorage)
end
 
function Player.addCoins(self, amount)
    self:setStorageValue(coinStorage, math.max(0, self:getStorageValue(coinStorage)) + amount)
end
dofile('data/lib/TWD/towerDefenseLib.lua')

function onUse(cid, item, fromPosition, target, toPosition, isHotkey)
    local player = Player(cid)
    if player:getStorageValue(playingGameStorage) ~= 1 then
        return false
    end

    local tile = toPosition:getTile()
    if tile then
        if not tile:hasFlag(TILESTATE_PROTECTIONZONE) or tile:hasProperty(CONST_PROP_IMMOVABLEBLOCKSOLID) then
            player:sendCancelMessage("You cannot place the turret here.")
            return true
        end
        local npc = Creature(tile:getTopCreature())
        if not npc then
            local modalWindow = ModalWindow(100, "Build Turret", "Here you can select variations of turrets to build.")
            local turret, cfgTable = turrets.allTurretsId
            for i = 1, #turret do
                turret = turrets.allTurretsId[i]
                cfgTable = turrets[turret].cfg
                modalWindow:addChoice(turret, string.format("%s [%s coins]", cfgTable.turretName, cfgTable[1].buildPrice))
            end

            modalWindow:addButton(0, "Build")
            modalWindow:setDefaultEnterButton(0)
            modalWindow:addButton(1, "Cancel")
            modalWindow:setDefaultEscapeButton(1)
            modalWindow:sendToPlayer(player)
            turretPosition = toPosition
        elseif npc:isNpc() and npc:getName() == "Turret" then
            local table = turrets[npc:getOutfit().lookType]
            local lvl = npc:getTurretLevel()
            local cfg, cfgCombat = table.cfg[lvl], table.combat[lvl]

            local turrentInfo = string.format("Turret Information\n----------------------------\nTurret Level: %s\nAttack Type: %s\nRange SQM: %sx%s\nTurret Damage: [%s - %s]\nAttack Speed: %s\nSell/Upgrade Price: [%s / %s]", lvl, string.upper(cfgCombat.attackType), cfg.rangeX, cfg.rangeY, cfgCombat.dmgValues[1], cfgCombat.dmgValues[2], cfg.attackSpeed, cfg.sellPrice, cfg.upgradePrice)
            local playerInfo = string.format("Player Information\n----------------------------\nWave Level: %s\nYour Coins: %s", getWaveLevel(), player:getCoins())
            local modalWindow = ModalWindow(101, "Information", string.format("%s\n\n%s", turrentInfo, playerInfo))

            if lvl < 3 then
                modalWindow:addChoice(0, "Upgrade")
            end
            modalWindow:addChoice(1, "Sell")

            modalWindow:addButton(0, "Yes")
            modalWindow:setDefaultEnterButton(0)
            modalWindow:addButton(0x01, "Cancel")
            modalWindow:setDefaultEscapeButton(1)
            modalWindow:sendToPlayer(player)
            targetTurret = npc
        end
    end
    return true
end
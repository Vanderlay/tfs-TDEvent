local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

dofile('data/lib/TWD/towerDefenseLib.lua')   

local function searchForTarget(cid)
    local npc = Npc(cid)
    if not npc then
        return false
    end

    local lvl = npc:getTurretLevel()
    local table = turrets[npc:getOutfit().lookType]
    if not table then
        print("[ERROR]: This turret does not exsist in the turrets table.")
        return false
    end

    local cfg = table.cfg[lvl]
    npc:searchTarget(cfg.rangeX, cfg.rangeY)
    addEvent(searchForTarget, 100, cid)
end

local function onAttack(cid)
    local npc = Npc(cid)
    if not npc then
        return false
    end

    local lvl = npc:getTurretLevel()
    local table = turrets[npc:getOutfit().lookType]
    local cfg = table.cfg[lvl]

    if not table then
        print("[ERROR]: This turret does not exsist in the turrets table.")
        return false
    end

    local target = npc:getTarget()
    if target then
        local cfgCombat = table.combat[lvl]
        npc:shootSpell(cfgCombat.attackType, target, cfgCombat.combatType, cfgCombat.combatArea, cfgCombat.dmgValues[1], cfgCombat.dmgValues[2], cfgCombat.magicEffect, cfgCombat.shootEffect)
        npc:setFocus(target)
    end

    addEvent(onAttack, cfg.attackSpeed, cid)
end

function onCreatureAppear(cid)
    local creature = Creature(cid)
    onAttack(cid)
    searchForTarget(cid)
    npcHandler:onCreatureAppear(creature)
end
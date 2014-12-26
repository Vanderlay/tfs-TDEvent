function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if primaryType == COMBAT_HEALING then
        return false
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end
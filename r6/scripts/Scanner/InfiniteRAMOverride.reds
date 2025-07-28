// InfiniteRAMOverride.reds
// REDmod Script - Grants player unlimited RAM for quickhacks
// High-tier black ICE bypass for advanced netrunners

module InfiniteRAMOverride

import Cyberpunk.PlayerPuppet
import gamedataStatType
import gamedataStatPoolType

@wrapMethod(PlayerPuppet)
public func GetStatValue(statType: gamedataStatType) -> Float {
    // Override total available RAM stat
    if statType == gamedataStatType.RAMAvailable {
        return 999.0
    }
    return wrappedMethod(statType)
}

@wrapMethod(PlayerPuppet)
public func GetStatPoolValue(statType: gamedataStatPoolType) -> Float {
    // Override RAM pool internal value (used when hacks consume RAM)
    if statType == gamedataStatPoolType.RAM {
        return 999.0
    }
    return wrappedMethod(statType)
}

@wrapMethod(PlayerPuppet)
public func GetStatPoolCurrentValue(statType: gamedataStatPoolType) -> Float {
    // Ensure the current RAM pool stays full
    if statType == gamedataStatPoolType.RAM {
        return 999.0
    }
    return wrappedMethod(statType)
}

@wrapMethod(PlayerPuppet)
public func GetStatPoolMax(statType: gamedataStatPoolType) -> Float {
    // Ensure max RAM is high enough to support infinite logic
    if statType == gamedataStatPoolType.RAM {
        return 999.0
    }
    return wrappedMethod(statType)
}

@wrapMethod(PlayerPuppet)
public func IsQuickHackUploadBlocked() -> Bool {
    // Disable any restrictions on quickhack uploads (e.g. not enough RAM)
    return false
}

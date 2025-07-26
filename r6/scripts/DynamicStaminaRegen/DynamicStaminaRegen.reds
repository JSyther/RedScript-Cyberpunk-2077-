module DynamicStaminaRegen

import Cyberpunk.PlayerPuppet
import gamedataStatType
import gameStatPools

@addField(PlayerPuppet)
let staminaRegenMultiplier: Float

@wrapMethod(PlayerPuppet)
func OnGameAttached() -> Void {
    wrappedMethod()

    // Initialize multiplier at normal regen speed
    this.staminaRegenMultiplier = 1.0
}

@wrapMethod(PlayerPuppet)
func OnUpdate(deltaTime: Float) -> Void {
    wrappedMethod(deltaTime)

    let isInCombat: Bool = this.IsInCombat()
    let currentStamina: Float = this.GetStatValue(gamedataStatType.Stamina)
    let maxStamina: Float = this.GetStatValue(gamedataStatType.MaxStamina)

    // Calculate stamina percentage
    let staminaPercent: Float = currentStamina / maxStamina * 100.0

    // Update regen multiplier based on combat and stamina
    if (isInCombat) {
        this.staminaRegenMultiplier = 0.5 // slower regen in combat
    } else if (staminaPercent < 40.0) {
        this.staminaRegenMultiplier = 2.0 // faster regen when stamina is low and out of combat
    } else {
        this.staminaRegenMultiplier = 1.0 // normal regen otherwise
    }

    // Apply multiplier to stamina regen stat pool
    this.AdjustStaminaRegen(this.staminaRegenMultiplier)
}

// Function to adjust stamina regeneration by multiplier
func AdjustStaminaRegen(multiplier: Float) -> Void {
    let staminaPool: ref<gameStatPools.PoolData> = this.GetStatPool(gamedataStatType.Stamina)
    if (staminaPool != null) {
        staminaPool.regenRate = staminaPool.regenRate * multiplier
    }
}

module DynamicStaminaRegen

import Cyberpunk.PlayerPuppet
import GameInstance
import gamedataStatType

@wrapMethod(PlayerPuppet)
func OnStaminaChanged(newValue: Float) -> Void {
    wrappedMethod(newValue)

    // Get current stamina value
    let currentStamina: Float = this.GetStatValue(gamedataStatType.Stamina)
    // Check if player is in combat
    let isInCombat: Bool = this.IsInCombat()

    if (currentStamina < 40.0 && !isInCombat) {
        // Out of combat and low stamina: increase stamina regen speed x2
        this.ModifyStaminaRegenRate(2.0)
    } else if (isInCombat) {
        // In combat: decrease stamina regen speed to 50%
        this.ModifyStaminaRegenRate(0.5)
    } else {
        // Normal stamina regen speed
        this.ModifyStaminaRegenRate(1.0)
    }
}

// Helper function to modify stamina regeneration rate by a multiplier
func ModifyStaminaRegenRate(multiplier: Float) -> Void {
    // Placeholder for actual implementation:
    // Adjust the game's stamina regeneration rate using multiplier.
    // This depends on game internals and may require hooking into stats or attributes.
}

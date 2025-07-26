module DynamicCreditIncome

import Cyberpunk.PlayerPuppet
import gameScriptableSystems.InventorySystem
import gameScriptableSystems.ScriptableSystemContext
import gameScriptableSystems.GameplaySystem
import gameItemData
import gameScriptableSystems.GameplayTransaction

@addField(PlayerPuppet)
let creditMultiplier: Float

@wrapMethod(PlayerPuppet)
func OnGameAttached() -> Void {
    wrappedMethod()
    this.creditMultiplier = 1.0
}

@wrapMethod(PlayerPuppet)
func OnEnemyKilled(enemy: ref<GameObject>, isStealth: Bool, isHeadshot: Bool) -> Void {
    wrappedMethod(enemy, isStealth, isHeadshot)

    let baseCreditReward: Int32 = 100  // Base reward for kill, example value
    var finalReward: Int32 = baseCreditReward

    if (isStealth) {
        finalReward = Cast<Int32>(Float(finalReward) * 1.5) // 50% bonus for stealth kills
    }
    if (isHeadshot) {
        finalReward = Cast<Int32>(Float(finalReward) * 1.25) // 25% bonus for headshots
    }
    finalReward = Cast<Int32>(Float(finalReward) * this.creditMultiplier)

    // Adjust credit multiplier based on player status (e.g., wanted level)
    if (this.IsWanted()) {
        finalReward = Cast<Int32>(Float(finalReward) * 0.5) // Halve credits if player is wanted
    }

    this.AddCredits(finalReward)
}

// Function to add credits to player inventory
func AddCredits(amount: Int32) -> Void {
    let inventorySystem = GameInstance.GetScriptableSystemsContainer().Get(n"InventorySystem") as InventorySystem
    if (inventorySystem != null) {
        inventorySystem.GiveCurrency(this, gameItemData.Currencies.Eurodollars, amount)
    }
}

// Placeholder for wanted status check
func IsWanted() -> Bool {
    // Replace with actual check, for example querying the police or notoriety system
    return false
}

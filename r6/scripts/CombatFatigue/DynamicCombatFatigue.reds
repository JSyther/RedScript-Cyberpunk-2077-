module DynamicCombatFatigue

import Cyberpunk.PlayerPuppet
import gameevents.DamageEvent
import GameInstance
import gamedataStatType
import gameTimeSystem

// === Fields ===
@addField(PlayerPuppet)
let fatigueLevel: Float

@addField(PlayerPuppet)
let fatigueCooldownTime: Float

@addField(PlayerPuppet)
let lastFatigueIncreaseTime: Float

@addField(PlayerPuppet)
let fatigueCooldownActive: Bool

// === Constants ===
const float FATIGUE_INCREASE_PER_SECOND_IN_COMBAT = 8.0
const float FATIGUE_INCREASE_ON_HIT = 12.0
const float FATIGUE_DECAY_PER_SECOND_OUT_OF_COMBAT = 5.0
const float FATIGUE_MAX = 100.0
const float FATIGUE_COOLDOWN_SECONDS = 6.0

// === Initialization ===
@wrapMethod(PlayerPuppet)
func OnGameAttached() -> Void {
    wrappedMethod()
    this.fatigueLevel = 0.0
    this.fatigueCooldownTime = FATIGUE_COOLDOWN_SECONDS
    this.lastFatigueIncreaseTime = 0.0
    this.fatigueCooldownActive = false
}

// === Damage Event Hook ===
@wrapMethod(PlayerPuppet)
func OnTakeDamage(evt: ref<DamageEvent>) -> Void {
    wrappedMethod(evt)

    let now: Float = GameInstance.GetTimeSystem().GetGameTime()
    if (!this.fatigueCooldownActive || (now - this.lastFatigueIncreaseTime) > FATIGUE_COOLDOWN_SECONDS) {
        this.IncreaseFatigue(FATIGUE_INCREASE_ON_HIT)
        this.lastFatigueIncreaseTime = now
        this.fatigueCooldownActive = true
        GameInstance.GetDelaySystem().DelayCallback(this, n"ResetFatigueCooldown", FATIGUE_COOLDOWN_SECONDS, false)
    }
}

// === Update Hook (called every frame) ===
@wrapMethod(PlayerPuppet)
func OnUpdate(deltaTime: Float) -> Void {
    wrappedMethod(deltaTime)

    if (this.IsInCombat()) {
        // Increase fatigue gradually during combat
        this.IncreaseFatigue(FATIGUE_INCREASE_PER_SECOND_IN_COMBAT * deltaTime)
    } else {
        // Decrease fatigue gradually out of combat
        this.DecreaseFatigue(FATIGUE_DECAY_PER_SECOND_OUT_OF_COMBAT * deltaTime)
    }

    this.ApplyFatigueEffects()
}

// === Fatigue Control ===
func IncreaseFatigue(amount: Float) -> Void {
    this.fatigueLevel += amount
    if (this.fatigueLevel > FATIGUE_MAX) {
        this.fatigueLevel = FATIGUE_MAX
    }
    this.NotifyFatigueChanged()
}

func DecreaseFatigue(amount: Float) -> Void {
    this.fatigueLevel -= amount
    if (this.fatigueLevel < 0.0) {
        this.fatigueLevel = 0.0
    }
    this.NotifyFatigueChanged()
}

@addMethod(PlayerPuppet)
func ResetFatigueCooldown() -> Void {
    this.fatigueCooldownActive = false
}

// === Fatigue Effects Application ===
func ApplyFatigueEffects() -> Void {
    // Movement speed penalty scales from 0% to -25%
    let movementPenalty: Float = (this.fatigueLevel / FATIGUE_MAX) * 0.25
    // Aiming stability penalty scales from 0% to -30%
    let aimingPenalty: Float = (this.fatigueLevel / FATIGUE_MAX) * 0.30
    // Stamina regen penalty scales from 0% to -40%
    let staminaRegenPenalty: Float = (this.fatigueLevel / FATIGUE_MAX) * 0.40

    this.SetMovementSpeedMultiplier(1.0 - movementPenalty)
    this.SetAimStabilityMultiplier(1.0 - aimingPenalty)
    this.SetStaminaRegenMultiplier(1.0 - staminaRegenPenalty)
}

func SetMovementSpeedMultiplier(multiplier: Float) -> Void {
    // Clamp multiplier to reasonable range (e.g., 0.5 to 1.0)
    let clampedMultiplier = math.clamp(multiplier, 0.5, 1.0)

    // Get CharacterMovementComponent
    let moveComp = this.GetCharacterMovementComponent()
    if (moveComp != null) {
        // Set Max Walk Speed Multiplier (relative speed modifier)
        moveComp.SetMaxWalkSpeedMultiplier(clampedMultiplier)
    }
}

func SetAimStabilityMultiplier(multiplier: Float) -> Void {
    // Clamp between 0.7 and 1.0 (lower means less stable)
    let clampedMultiplier = math.clamp(multiplier, 0.7, 1.0)

    // Adjust aiming stability stat, or spread modifiers
    // Pseudo-example: modify stat "AimStability" dynamically

    let statType = gamedataStatType.AimStability  // Assuming this exists
    let currentValue = this.GetStatValue(statType)
    let newValue = currentValue * clampedMultiplier

    this.SetStatValue(statType, newValue)
}


func SetStaminaRegenMultiplier(multiplier: Float) -> Void {
    let staminaPool = this.GetStatPool(gamedataStatType.Stamina)
    if (staminaPool != null) {
        // Clamp multiplier between 0.5 (half regen) and 1.0 (normal regen)
        let clampedMultiplier = math.clamp(multiplier, 0.5, 1.0)

        // Directly modify the regenRate value (if writable)
        staminaPool.regenRate = staminaPool.regenRate * clampedMultiplier
    }
}

func NotifyFatigueChanged() -> Void {
    // Example debug log:
    Log(n"CombatFatigue", s"Fatigue Level: \(this.fatigueLevel)")

    // Trigger UI event or HUD update (requires UI modding setup)
    let eventSystem = GameInstance.GetScriptableSystemsContainer().Get(n"UISystem")
    if (eventSystem != null) {
        eventSystem.QueueUIEvent(n"CombatFatigueUpdate", this.fatigueLevel)
    }

    // Play screen vignette or blur effect (pseudo-code)
    let playerController = this.GetPlayerController()
    if (playerController != null) {
        playerController.PlayPostProcessEffect(n"FatigueVignette", this.fatigueLevel / 100.0)
    }
}


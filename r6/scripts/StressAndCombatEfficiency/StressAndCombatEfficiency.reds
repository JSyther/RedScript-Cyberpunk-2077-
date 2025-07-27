module StressAndCombatEfficiency

import Cyberpunk.PlayerPuppet
import gameStatPools
import gameevents.DamageEvent
import GameInstance
import gamedataStatType
import gameTimeSystem

// === FIELDS ===
@addField(PlayerPuppet)
let stressLevel: Float

@addField(PlayerPuppet)
let lastStressIncreaseTime: Float

@addField(PlayerPuppet)
let stressCooldownSeconds: Float

@addField(PlayerPuppet)
let isInStressCooldown: Bool

// === INITIALIZATION ===
@wrapMethod(PlayerPuppet)
func OnGameAttached() -> Void {
    wrappedMethod()
    this.stressLevel = 0.0
    this.stressCooldownSeconds = 10.0  // 10 seconds cooldown between stress increments
    this.isInStressCooldown = false
    this.lastStressIncreaseTime = 0.0
}

// === DAMAGE HOOK ===
@wrapMethod(PlayerPuppet)
func OnTakeDamage(evt: ref<DamageEvent>) -> Void {
    wrappedMethod(evt)

    // Increase stress on damage if cooldown elapsed
    let now: Float = GameInstance.GetTimeSystem().GetGameTime()
    if (!this.isInStressCooldown || (now - this.lastStressIncreaseTime) > this.stressCooldownSeconds) {
        this.IncreaseStress(15.0)  // +15 stress per damage hit (tune as needed)
        this.lastStressIncreaseTime = now
        this.isInStressCooldown = true

        // Start cooldown timer reset
        let delaySys = GameInstance.GetDelaySystem()
        delaySys.DelayCallback(this, n"ResetStressCooldown", this.stressCooldownSeconds, false)
    }
}

// === COMBAT STATE CHECK ===
@wrapMethod(PlayerPuppet)
func OnUpdate(deltaTime: Float) -> Void {
    wrappedMethod(deltaTime)

    // Decay stress over time if out of combat
    if (!this.IsInCombat() && this.stressLevel > 0.0) {
        this.DecreaseStress(5.0 * deltaTime)  // Decay 5 stress points per second
    }

    // Apply negative effects based on stress level
    this.ApplyStressEffects()
}

// === STRESS CONTROL FUNCTIONS ===
func IncreaseStress(amount: Float) -> Void {
    this.stressLevel += amount
    if (this.stressLevel > 100.0) {
        this.stressLevel = 100.0
    }

    // === Optional: Trigger visual stress feedback (e.g. red vignette, heartbeat sound) ===
    let visualSystem = GameInstance.GetVisualSystem()
    if visualSystem != null {
        let intensity: Float = this.stressLevel / 100.0
        visualSystem.PlayScreenEffect(n"fx_stress_vignette", intensity)
    }

    let audioSystem = GameInstance.GetAudioSystem()
    if audioSystem != null && this.stressLevel >= 75.0 {
        audioSystem.PlaySound(n"ui_stress_heartbeat_loop")
    }
}

func DecreaseStress(amount: Float) -> Void {
    this.stressLevel -= amount
    if (this.stressLevel < 0.0) {
        this.stressLevel = 0.0
    }

    // === Optional: Remove stress effects if stressLevel is low ===
    if this.stressLevel <= 20.0 {
        let visualSystem = GameInstance.GetVisualSystem()
        if visualSystem != null {
            visualSystem.StopScreenEffect(n"fx_stress_vignette")
        }

        let audioSystem = GameInstance.GetAudioSystem()
        if audioSystem != null {
            audioSystem.StopSound(n"ui_stress_heartbeat_loop")
        }
    }
}


@addMethod(PlayerPuppet)
func ResetStressCooldown() -> Void {
    this.isInStressCooldown = false
}

// === APPLY NEGATIVE EFFECTS ===
func ApplyStressEffects() -> Void {
    // Example: reduce aiming accuracy and stamina regen proportional to stress level

    // Aim accuracy penalty: up to -30% at max stress
    let aimPenalty: Float = (this.stressLevel / 100.0) * 0.3  // 0.0 to 0.3

    // Stamina regen penalty: up to -50% at max stress
    let staminaPenalty: Float = (this.stressLevel / 100.0) * 0.5  // 0.0 to 0.5

    // Apply penalties (pseudo-functions, replace with real game calls)
    this.SetAimAccuracyModifier(1.0 - aimPenalty)
    this.SetStaminaRegenMultiplier(1.0 - staminaPenalty)
}

// === PLACEHOLDER FUNCTIONS ===
// Replace these with actual game API calls or hooks for stats adjustment

// === AIM ACCURACY MODIFIER ===
func SetAimAccuracyModifier(multiplier: Float) -> Void {
    let statSystem = GameInstance.GetStatPoolsSystem()
    if statSystem == null {
        return
    }

    let owner = this.GetEntityID()
    let accuracyMod = statSystem.GetStatModifier(owner, gamedataStatType.SpreadReduction)
    
    // Remove any existing custom modifier with our ID
    statSystem.RemoveModifier(owner, gamedataStatType.SpreadReduction, n"AimMod")

    // Apply new accuracy modifier (SpreadReduction increases accuracy)
    let mod = StatModifierData()
    mod.modifierType = gameStatModifierType.Multiply
    mod.value = multiplier
    mod.modifierName = n"AimMod"

    statSystem.AddModifier(owner, gamedataStatType.SpreadReduction, mod)
}


// === STAMINA REGEN MULTIPLIER ===
func SetStaminaRegenMultiplier(multiplier: Float) -> Void {
    let statSystem = GameInstance.GetStatPoolsSystem()
    if statSystem == null {
        return
    }

    let owner = this.GetEntityID()
    let regenType = gamedataStatType.StaminaRegenRate

    // Remove previous modifier if applied
    statSystem.RemoveModifier(owner, regenType, n"StaminaMod")

    let mod = StatModifierData()
    mod.modifierType = gameStatModifierType.Multiply
    mod.value = multiplier
    mod.modifierName = n"StaminaMod"

    statSystem.AddModifier(owner, regenType, mod)
}


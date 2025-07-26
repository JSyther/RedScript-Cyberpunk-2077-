module TacticalTimeDilation

import Cyberpunk.PlayerPuppet
import GameInstance
import gameevents.DamageEvent
import gameDelaySystem
import gameTimeSystem

@addField(PlayerPuppet)
let tacticalTimeActive: Bool

@wrapMethod(PlayerPuppet)
func OnTakeDamage(evt: ref<DamageEvent>) -> Void {
    wrappedMethod(evt)

    // Do nothing if already in slow motion
    if (this.tacticalTimeActive) {
        return
    }

    let health: Float = this.GetStatValue(gamedataStatType.Health)
    let isInCombat: Bool = this.IsInCombat()

    // Trigger time dilation if health is below 35% and in combat
    if (health < 35.0 && isInCombat) {
        this.ActivateTacticalTimeDilation(0.35, 3.0)
    }
}

func ActivateTacticalTimeDilation(factor: Float, duration: Float) {
    this.tacticalTimeActive = true

    let timeSystem = GameInstance.GetTimeSystem()
    timeSystem.SetTimeDilation(n"TTD_Mod", factor)

    let delaySystem = GameInstance.GetDelaySystem()
    delaySystem.DelayCallback(this, n"EndTacticalTimeDilation", duration, false)
}

@addMethod(PlayerPuppet)
func EndTacticalTimeDilation() -> Void {
    GameInstance.GetTimeSystem().ClearTimeDilation(n"TTD_Mod")
    this.tacticalTimeActive = false
}

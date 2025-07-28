// ThermalFlux.reds
// REDmod Script - Enhances damage of Overheat quickhack

module ThermalFlux

import Cyberpunk.PlayerPuppet
import gameevents.DamageEvent
import gamedataDamageType

@wrapMethod(PlayerPuppet)
public func OnQuickHackApplied(target: ref<GameObject>, quickhackID: TweakDBID) -> Void {
    wrappedMethod(target, quickhackID)

    let damageMultiplier: Float = 1.8

    if quickhackID == t"QuickHack.Overheat" {
        ApplyDamageBoost(target, damageMultiplier)
    }
}

func ApplyDamageBoost(target: ref<GameObject>, multiplier: Float) -> Void {
    let evt = new DamageEvent()
    evt.instigator = GameInstance.GetPlayerSystem().GetLocalPlayerMainGameObject()
    evt.target = target
    evt.damageType = gamedataDamageType.Fire
    evt.baseDamage = 40.0 * multiplier
    evt.attackType = gamedataAttackType.Hacking

    target.QueueEvent(evt)
}

// NeuroCrash.reds
// REDmod Script - Enhances damage of Brain Melt quickhack

module NeuroCrash

import Cyberpunk.PlayerPuppet
import gameevents.DamageEvent
import gamedataDamageType

@wrapMethod(PlayerPuppet)
public func OnQuickHackApplied(target: ref<GameObject>, quickhackID: TweakDBID) -> Void {
    wrappedMethod(target, quickhackID)

    let damageMultiplier: Float = 2.5

    if quickhackID == t"QuickHack.BrainMelt" {
        ApplyDamageBoost(target, damageMultiplier)
    }
}

func ApplyDamageBoost(target: ref<GameObject>, multiplier: Float) -> Void {
    let evt = new DamageEvent()
    evt.instigator = GameInstance.GetPlayerSystem().GetLocalPlayerMainGameObject()
    evt.target = target
    evt.damageType = gamedataDamageType.Psychic
    evt.baseDamage = 75.0 * multiplier
    evt.attackType = gamedataAttackType.Hacking

    target.QueueEvent(evt)
}

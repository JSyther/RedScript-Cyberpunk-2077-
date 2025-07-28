// ElectroSurge.reds
// REDmod Script - Amplifies damage of Short Circuit quickhack by Syther

module ElectroSurge

import Cyberpunk.PlayerPuppet
import gameevents.DamageEvent
import gamedataDamageType

@wrapMethod(PlayerPuppet)
public func OnQuickHackApplied(target: ref<GameObject>, quickhackID: TweakDBID) -> Void {
    wrappedMethod(target, quickhackID)

    let damageMultiplier: Float = 2.0

    if quickhackID == t"QuickHack.ShortCircuit" {
        ApplyDamageBoost(target, damageMultiplier)
    }
}

func ApplyDamageBoost(target: ref<GameObject>, multiplier: Float) -> Void {
    let evt = new DamageEvent()
    evt.instigator = GameInstance.GetPlayerSystem().GetLocalPlayerMainGameObject()
    evt.target = target
    evt.damageType = gamedataDamageType.Electric
    evt.baseDamage = 60.0 * multiplier
    evt.attackType = gamedataAttackType.Hacking

    target.QueueEvent(evt)
}

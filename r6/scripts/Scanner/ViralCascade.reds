// ViralCascade.reds
// REDmod Script - Boosts damage of Contagion quickhack

module ViralCascade

import Cyberpunk.PlayerPuppet
import gameevents.DamageEvent
import gamedataDamageType

@wrapMethod(PlayerPuppet)
public func OnQuickHackApplied(target: ref<GameObject>, quickhackID: TweakDBID) -> Void {
    wrappedMethod(target, quickhackID)

    let damageMultiplier: Float = 2.2

    if quickhackID == t"QuickHack.Contagion" {
        ApplyDamageBoost(target, damageMultiplier)
    }
}

func ApplyDamageBoost(target: ref<GameObject>, multiplier: Float) -> Void {
    let evt = new DamageEvent()
    evt.instigator = GameInstance.GetPlayerSystem().GetLocalPlayerMainGameObject()
    evt.target = target
    evt.damageType = gamedataDamageType.Biochemical
    evt.baseDamage = 35.0 * multiplier
    evt.attackType = gamedataAttackType.Hacking

    target.QueueEvent(evt)
}

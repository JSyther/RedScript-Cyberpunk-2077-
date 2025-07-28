// SystemCorrupt.reds
// REDmod Script - Boosts damage of Cyberware Malfunction quickhack

module SystemCorrupt

import Cyberpunk.PlayerPuppet
import gameevents.DamageEvent
import gamedataDamageType

@wrapMethod(PlayerPuppet)
public func OnQuickHackApplied(target: ref<GameObject>, quickhackID: TweakDBID) -> Void {
    wrappedMethod(target, quickhackID)

    let damageMultiplier: Float = 1.9

    if quickhackID == t"QuickHack.CyberwareMalfunction" {
        ApplyDamageBoost(target, damageMultiplier)
    }
}

func ApplyDamageBoost(target: ref<GameObject>, multiplier: Float) -> Void {
    let evt = new DamageEvent()
    evt.instigator = GameInstance.GetPlayerSystem().GetLocalPlayerMainGameObject()
    evt.target = target
    evt.damageType = gamedataDamageType.Electric
    evt.baseDamage = 50.0 * multiplier
    evt.attackType = gamedataAttackType.Hacking

    target.QueueEvent(evt)
}

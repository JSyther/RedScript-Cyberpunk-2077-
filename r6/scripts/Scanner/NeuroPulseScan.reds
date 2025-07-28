module NeuroPulseScan

import GameInstance
import GameObject
import gameeffects
import gamedataStatType
import AI
import gamedev_debug

const float PULSE_RADIUS = 15.0
const float DISORIENT_DURATION = 6.0
const float COOLDOWN = 30.0

const name DISORIENT_EFFECT_NAME = n"NeuroDisorientDebuff"
const name NEURAL_IMPLANT_TAG = n"NeuralImplant"

@persistent
private let lastPulseTime: Float = -100.0

func CanActivatePulse() -> Bool {
    let currentTime = GameInstance.GetTimeSystem().GetGameTime()
    return (currentTime - lastPulseTime) >= COOLDOWN
}

func ActivateNeuroPulse(player: ref<GameObject>) -> Void {
    if !CanActivatePulse() {
        gamedev_debug.DebugPrint("NeuroPulse: Ability on cooldown.")
        return
    }

    lastPulseTime = GameInstance.GetTimeSystem().GetGameTime()

    let npcsInRange = QueryNPCsInRadius(player, PULSE_RADIUS)

    for npc in npcsInRange {
        if HasNeuralImplant(npc) {
            ApplyRevealEffect(player, npc)
            ApplyDisorientDebuff(npc)
        }
    }

    PlayVisualEffect(player)
    PlaySoundEffect(player)
}

func QueryNPCsInRadius(origin: ref<GameObject>, radius: Float) -> array<ref<GameObject>> {
    let allNPCs = AI.GetAllNPCs()
    let result: array<ref<GameObject>> = []

    if origin == null {
        return result
    }

    let originPos = origin.GetWorldPosition()

    for npc in allNPCs {
        if npc == null || npc.IsDead() || npc.IsPlayer() {
            continue
        }

        let npcPos = npc.GetWorldPosition()
        let dist = Vector4.Distance(originPos, npcPos)

        if dist <= radius {
            result.push(npc)
        }
    }

    return result
}

func HasNeuralImplant(npc: ref<GameObject>) -> Bool {
    if npc == null {
        return false
    }

    // Check if NPC has a cyberware item with NeuralImplant tag
    let cyberwareList = npc.GetItemListBySlotName(n"Cyberware")

    for item in cyberwareList {
        if item.HasTag(NEURAL_IMPLANT_TAG) {
            return true
        }
    }

    return false
}

func ApplyRevealEffect(player: ref<GameObject>, npc: ref<GameObject>) -> Void {
    // Tag NPC as revealed to player HUD with a timer
    let playerUID = player.GetEntityID()
    let npcUID = npc.GetEntityID()

    GameInstance.GetUISystem().RegisterRevealedEntityForPlayer(playerUID, npcUID, DISORIENT_DURATION)
}

func ApplyDisorientDebuff(npc: ref<GameObject>) -> Void {
    if npc == null {
        return
    }

    let effect = gameeffects.GetEffectRecordByName(DISORIENT_EFFECT_NAME)
    if effect != null {
        npc.ApplyEffect(effect, DISORIENT_DURATION)
    } else {
        gamedev_debug.DebugPrint("NeuroPulse: Disorient effect record not found: " + DISORIENT_EFFECT_NAME)
    }
}

func PlayVisualEffect(player: ref<GameObject>) -> Void {
    // Example: spawn particle effect at player location for pulse visualization
    let effectName: name = n"NeuroPulse_VisualEffect"

    let playerPos = player.GetWorldPosition()
    GameInstance.GetEffectSystem().SpawnEffectAtLocation(effectName, playerPos)
}

func PlaySoundEffect(player: ref<GameObject>) -> Void {
    let soundName: name = n"NeuroPulse_SoundEffect"

    GameInstance.GetSoundSystem().PlayOneShotSoundAtEntity(player, soundName)
}



// NeuroPulseScan Module
//
// This module implements a cyberpunk-style neural pulse scanner ability.
//
// Purpose:
// - Allows the player to emit a short-range neural pulse that scans for NPCs
//   with cybernetic neural implants within a set radius.
//
// Core Features:
// - Emits a pulse affecting all NPCs within PULSE_RADIUS (default 15 meters).
// - Detects NPCs possessing neural implant cyberware (tagged accordingly).
// - Reveals detected NPCs on player's HUD or minimap for situational awareness.
// - Applies a temporary disorientation debuff to affected NPCs to hinder combat performance.
// - Enforces a cooldown (default 30 seconds) to prevent ability spamming.
// - Plays immersive visual and audio effects upon activation.
//
// Implementation Details:
// - Uses spatial queries to find all NPCs alive and non-player within the pulse radius.
// - Checks NPC cyberware components or tags to identify neural implants.
// - Applies two primary effects per valid target:
//     1. Reveal effect to highlight NPC on player HUD for DISORIENT_DURATION seconds.
//     2. Disorientation debuff effect applying vision blur, aim sway, or slowed reaction.
// - Visual feedback includes particle or screen effects representing the pulse.
// - Audio feedback includes a distinct electronic pulse sound cue.
//
// Design Notes:
// - The radius, cooldown, and effect duration are configurable constants for gameplay balance.
// - Requires HUD integration to properly mark revealed targets.
// - The disorientation effect must be defined in the mod’s effect database.
// - Debug logs assist in development and troubleshooting.
//
// Usage:
// - Call ActivateNeuroPulse(player) when the player triggers the ability.
// - Ensure proper game systems are initialized and the player reference is valid.
// - Extend QueryNPCsInRadius and HasNeuralImplant with game-specific API calls.
//
// Summary:
// NeuroPulseScan provides a tactical neuro-hacking scanner tool that fits a futuristic cyberpunk setting,
// giving the player an edge by revealing and disrupting cybernetically enhanced enemies in their vicinity.

// PhantomSignal Module
//
// This module enables the player to trigger a deceptive alert ("Phantom Signal")
// at the location they are currently aiming. When activated, it causes police NPCs 
// within a defined radius around the targeted spot to investigate the area, 
// creating a tactical distraction.


// Key Features:
// - Raycasts from the player's camera to determine aimed location.
// - Detects police NPCs near that location based on faction tagging.
// - Commands detected NPCs to investigate the false alert location.
// - Provides optional player feedback through UI notifications.
// - Designed for stealth and tactical gameplay, enabling creative distractions.


module PhantomSignal

import GameInstance
import GameObject
import gameinput
import gameevents
import Vector4
import physics

const float ALERT_RADIUS = 5.0
const name POLICE_FACTION_TAG = n"Police"
const float RAYCAST_DISTANCE = 20.0

@persistent
private let physicsSystem = GameInstance.GetPhysicsSystem()

func TriggerPhantomSignal(player: ref<GameObject>) -> Void {
    if player == null {
        return
    }

    let targetLocation = GetPlayerAimedLocation(player)
    if targetLocation == null {
        return
    }

    AlertNearbyPoliceNPCs(targetLocation, ALERT_RADIUS)

    // Optional: Show notification to player
    let uiSystem = GameInstance.GetUISystem()
    if uiSystem != null {
        uiSystem.ShowNotification("Phantom Signal triggered at targeted location.")
    }
}

func GetPlayerAimedLocation(player: ref<GameObject>) -> Vector4 {
    // Perform a raycast from the player's camera forward direction
    let cam = player.GetAttachedCamera()
    if cam == null {
        return null
    }

    let camPos = cam.GetWorldPosition()
    let camForward = cam.GetWorldForward()

    let rayEnd = camPos + camForward * RAYCAST_DISTANCE

    let hitResult: physics.HitResult
    let hit = physicsSystem.Raycast(camPos, rayEnd, out hitResult)
    if hit {
        return hitResult.position
    }

    // If no hit, return point at max distance
    return rayEnd
}

func AlertNearbyPoliceNPCs(location: Vector4, radius: Float) -> Void {
    let policeNPCs = QueryNPCsByFactionNearLocation(POLICE_FACTION_TAG, location, radius)

    for npc in policeNPCs {
        if npc == null {
            continue
        }

        npc.CommandInvestigateLocation(location)
    }
}

func QueryNPCsByFactionNearLocation(factionTag: name, location: Vector4, radius: Float) -> array<ref<GameObject>> {
    let allNPCs = AI.GetAllNPCs()
    let result: array<ref<GameObject>> = []

    for npc in allNPCs {
        if npc == null || npc.IsDead() || npc.IsPlayer() {
            continue
        }

        if !npc.HasTag(factionTag) {
            continue
        }

        let npcPos = npc.GetWorldPosition()
        let dist = Vector4.Distance(npcPos, location)

        if dist <= radius {
            result.push(npc)
        }
    }

    return result
}

func GameObject.CommandInvestigateLocation(location: Vector4) -> Void {
    // Example: set AI behavior state to Investigate location
    let aiController = this.GetAIController()
    if aiController == null {
        return
    }

    aiController.SetInvestigationTarget(location)
    aiController.SetState(n"Investigate")

    // Optional: log for debugging
    let debugSystem = GameInstance.GetDebugSystem()
    if debugSystem != null {
        debugSystem.Log("NPC " + this.GetName() + " is investigating location " + location.ToString())
    }
}

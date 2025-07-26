module ProAimAssist

import Cyberpunk.PlayerPuppet
import gameObject
import gameVisionModeSystem
import Vector4

@addField(PlayerPuppet)
let aimAssistEnabled: Bool

@addField(PlayerPuppet)
let aimAssistFOV: Float  // degrees

@addField(PlayerPuppet)
let aimSmoothingSpeed: Float

@wrapMethod(PlayerPuppet)
func OnGameAttached() -> Void {
    wrappedMethod()
    this.aimAssistEnabled = false
    this.aimAssistFOV = 15.0
    this.aimSmoothingSpeed = 10.0
}

@wrapMethod(PlayerPuppet)
func OnUpdate(deltaTime: Float) -> Void {
    wrappedMethod(deltaTime)
    if (!this.aimAssistEnabled) {
        return
    }

    let target = this.FindBestAimAssistTarget()
    if (target != null) {
        this.SmoothAimToTarget(target, deltaTime)
        this.RemoveRecoilAndSpread()
    }
}

func FindBestAimAssistTarget() -> ref<GameObject> {
    let enemies = this.GetEnemiesInRange(1000.0) // 1000 units max
    var bestTarget: ref<GameObject> = null
    var bestScore: Float = 999999.0

    for enemy in enemies {
        if (!this.CanSeeEnemy(enemy)) {
            continue
        }

        let screenPos = this.WorldToScreen(enemy.GetWorldPosition())
        let angleToTarget = this.GetAngleToScreenPosition(screenPos)
        if (angleToTarget > this.aimAssistFOV) {
            continue
        }

        let distance = this.GetDistanceTo(enemy)
        if (distance < bestScore) {
            bestScore = distance
            bestTarget = enemy
        }
    }
    return bestTarget
}

func SmoothAimToTarget(target: ref<GameObject>, deltaTime: Float) -> Void {
    let playerCamRot = this.GetPlayerCameraRotation()
    let targetDir = (target.GetWorldPosition() - this.GetWorldPosition()).Normalized()

    // Calculate desired rotation to look at target
    let desiredRot = this.VectorToRotation(targetDir)

    // Smoothly interpolate camera rotation towards target
    let newRot = this.SlerpRotation(playerCamRot, desiredRot, deltaTime * this.aimSmoothingSpeed)
    this.SetPlayerCameraRotation(newRot)
}

func RemoveRecoilAndSpread() -> Void {
    // Pseudo-code: forcibly reset recoil/spread values to zero each frame
    // Actual implementation depends on weapon stats access or animation hooks
    this.ResetCurrentWeaponRecoil()
    this.ResetCurrentWeaponSpread()
}

// Helper functions (pseudo-implementations)

func GetEnemiesInRange(range: Float) -> array<ref<GameObject>> {
    // Query enemies around player within range
    // Requires game API support, or approximate using game vision system
    return []
}

func CanSeeEnemy(enemy: ref<GameObject>) -> Bool {
    // Check line of sight and visibility to enemy
    return true
}

func WorldToScreen(worldPos: Vector4) -> Vector4 {
    // Convert world position to screen coordinates
    return Vector4(0,0,0,0)
}

func GetAngleToScreenPosition(screenPos: Vector4) -> Float {
    // Calculate angular difference between screen center and screenPos
    return 0.0
}

func GetDistanceTo(obj: ref<GameObject>) -> Float {
    // Calculate distance between player and obj
    return 0.0
}

func GetPlayerCameraRotation() -> Quaternion {
    // Return current camera rotation
    return Quaternion.Identity()
}

func VectorToRotation(dir: Vector4) -> Quaternion {
    // Convert direction vector to rotation quaternion
    return Quaternion.Identity()
}

func SlerpRotation(a: Quaternion, b: Quaternion, t: Float) -> Quaternion {
    // Spherical linear interpolation between rotations
    return Quaternion.Identity()
}

func SetPlayerCameraRotation(rot: Quaternion) -> Void {
    let playerController = this.GetPlayerController()
    if (playerController != null) {
        let camera = playerController.GetPlayerCamera()
        if (camera != null) {
            camera.SetWorldRotation(rot)
        }
    }
}

func ResetCurrentWeaponRecoil() -> Void {
    let weaponSystem = GameInstance.GetScriptableSystemsContainer().Get(n"WeaponSystem")
    if (weaponSystem != null) {
        let currentWeapon = weaponSystem.GetActiveWeapon(this)
        if (currentWeapon != null) {
            currentWeapon.ResetRecoil() // Assuming this function exists
        }
    }
}

func ResetCurrentWeaponSpread() -> Void {
    let weaponSystem = GameInstance.GetScriptableSystemsContainer().Get(n"WeaponSystem")
    if (weaponSystem != null) {
        let currentWeapon = weaponSystem.GetActiveWeapon(this)
        if (currentWeapon != null) {
            currentWeapon.ResetSpread() // Assuming this function exists
        }
    }
}




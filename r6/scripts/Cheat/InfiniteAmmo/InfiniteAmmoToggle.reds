module InfiniteAmmoToggle

@addField(PlayerPuppet)
let isInfiniteAmmoEnabled: Bool = false

@wrapMethod(PlayerPuppet)
protected cb func OnAction(action: ListenerAction, consumer: ScriptRef<gameIActionConsumer>) -> Bool {
    let result = wrappedMethod(action, consumer)

    let inputSystem = GameInstance.GetInputSystem()
    let isRightCtrlDown = inputSystem.IsKeyPressed(n"IK_RightCtrl")

    if isRightCtrlDown && action.IsAction(n"ToggleInfiniteAmmo") && action.IsButtonJustPressed() {
        this.ToggleInfiniteAmmo()
    }

    return result
}

@addMethod(PlayerPuppet)
public func ToggleInfiniteAmmo() {
    this.isInfiniteAmmoEnabled = !this.isInfiniteAmmoEnabled

    if this.isInfiniteAmmoEnabled {
        this.EnableInfiniteAmmo()
        GameInstance.GetDebug().Notification("Infinite Ammo: ON")
    } else {
        this.DisableInfiniteAmmo()
        GameInstance.GetDebug().Notification("Infinite Ammo: OFF")
    }
}

@addMethod(PlayerPuppet)
private func EnableInfiniteAmmo() {
    // Placeholder: set ammo to max or hook shooting event to prevent ammo decrease
    let inventorySystem = this.GetInventorySystem()
    if IsDefined(inventorySystem) {
        // Example: Refill ammo of equipped weapon to max (adjust as per API)
        inventorySystem.RefillAmmo()
    }
}

@addMethod(PlayerPuppet)
private func DisableInfiniteAmmo() {
    // No special action needed or reset ammo usage normal
}

module InfiniteHealthToggle

@addField(PlayerPuppet)
let isInfiniteHealthEnabled: Bool = false

@wrapMethod(PlayerPuppet)
protected cb func OnAction(action: ListenerAction, consumer: ScriptRef<gameIActionConsumer>) -> Bool {
    let result = wrappedMethod(action, consumer)

    let inputSystem = GameInstance.GetInputSystem()
    let isRightCtrlDown = inputSystem.IsKeyPressed(n"IK_RightCtrl")

    if isRightCtrlDown && action.IsAction(n"ToggleInfiniteHealth") && action.IsButtonJustPressed() {
        this.ToggleInfiniteHealth()
    }

    return result
}

@addMethod(PlayerPuppet)
public func ToggleInfiniteHealth() {
    this.isInfiniteHealthEnabled = !this.isInfiniteHealthEnabled

    if this.isInfiniteHealthEnabled {
        this.EnableInfiniteHealth()
        GameInstance.GetDebug().Notification("Infinite Health: ON")
    } else {
        this.DisableInfiniteHealth()
        GameInstance.GetDebug().Notification("Infinite Health: OFF")
    }
}

@addMethod(PlayerPuppet)
private func EnableInfiniteHealth() {
    // Set player's health to very high and prevent damage
    let playerStats = this.GetStatPoolsSystem()
    if IsDefined(playerStats) {
        playerStats.SetValue(n"Health", 999999)
        playerStats.SetValue(n"HealthMax", 999999)
    }
}

@addMethod(PlayerPuppet)
private func DisableInfiniteHealth() {
    // Reset health to normal (example: 100)
    let playerStats = this.GetStatPoolsSystem()
    if IsDefined(playerStats) {
        playerStats.SetValue(n"Health", 100)
        playerStats.SetValue(n"HealthMax", 100)
    }
}

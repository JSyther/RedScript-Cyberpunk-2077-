module InfiniteCreditToggle

@addField(PlayerPuppet)
let isInfiniteCreditEnabled: Bool = false  // Is infinite credit enabled?

@wrapMethod(PlayerPuppet)
protected cb func OnAction(action: ListenerAction, consumer: ScriptRef<gameIActionConsumer>) -> Bool {
    let result = wrappedMethod(action, consumer)

    let inputSystem = GameInstance.GetInputSystem()
    let isRightCtrlDown = inputSystem.IsKeyPressed(n"IK_RightCtrl")  // Check if Right CTRL is pressed

    if isRightCtrlDown && action.IsAction(n"ToggleInfiniteCredit") && action.IsButtonJustPressed() {
        this.ToggleInfiniteCredit()  // Toggle infinite credit mode
    }

    return result
}

@addMethod(PlayerPuppet)
public func ToggleInfiniteCredit() {
    this.isInfiniteCreditEnabled = !this.isInfiniteCreditEnabled  // Toggle the state

    if this.isInfiniteCreditEnabled {
        this.EnableInfiniteCredit()
        GameInstance.GetDebug().Notification("Infinite Credit: ON")  // Show notification
    } else {
        this.DisableInfiniteCredit()
        GameInstance.GetDebug().Notification("Infinite Credit: OFF")  // Show notification
    }
}

@addMethod(PlayerPuppet)
private func EnableInfiniteCredit() {
    let playerWallet = this.GetWalletSystem()  // Get player's wallet system
    if IsDefined(playerWallet) {
        playerWallet.AddMoney(999999999)  // Add a large amount of money
    }
}

@addMethod(PlayerPuppet)
private func DisableInfiniteCredit() {
    // No special action needed when disabling infinite credit
}

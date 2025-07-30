module ToggleHUD

@addField(PlayerPuppet)
let isHUDHidden: Bool = false

@wrapMethod(PlayerPuppet)
protected cb func OnAction(action: ListenerAction, consumer: ScriptRef<gameIActionConsumer>) -> Bool {
    let result = wrappedMethod(action, consumer)

    // H tuşu: "IK_H" - Tüm inputlar enums.gamedataInputKey altında
    if action.IsAction(n"ToggleHUD") && action.IsButtonJustPressed() {
        this.ToggleHUD()
    }

    return result
}

@addMethod(PlayerPuppet)
public func ToggleHUD() {
    let uiSystem = GameInstance.GetSystem(n"inkISystem") as inkISystem

    if IsDefined(uiSystem) {
        this.isHUDHidden = !this.isHUDHidden
        uiSystem.SetUIVisible(!this.isHUDHidden)

        let status = this.isHUDHidden ? "Hidden" : "Visible"
        GameInstance.GetDebug().Notification("HUD: " + status)
    }
}

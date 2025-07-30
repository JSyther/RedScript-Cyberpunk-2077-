module MinimapZoomOut

@addField(PlayerPuppet)
let currentZoom: Float = 1.0

@wrapMethod(PlayerPuppet)
protected cb func OnAction(action: ListenerAction, consumer: ScriptRef<gameIActionConsumer>) -> Bool {
    let result = wrappedMethod(action, consumer)

    // Sağ CTRL basılı mı kontrol et
    let isRightCtrlDown = GameInstance.GetInputSystem().IsKeyPressed(n"IK_RightCtrl")

    if isRightCtrlDown && action.IsAction(n"ZoomIn") && action.IsButtonJustPressed() {
        this.AdjustMinimapZoom(0.1)
    }

    if isRightCtrlDown && action.IsAction(n"ZoomOut") && action.IsButtonJustPressed() {
        this.AdjustMinimapZoom(-0.1)
    }

    return result
}

@addMethod(PlayerPuppet)
public func AdjustMinimapZoom(amount: Float) {
    let hudManager = GameInstance.GetSystem(n"HUDManager") as HUDManager
    if !IsDefined(hudManager) {
        GameInstance.GetDebug().Notification("HUDManager not found")
        return
    }

    let minimap = hudManager.GetMinimapGameController()
    if !IsDefined(minimap) {
        GameInstance.GetDebug().Notification("Minimap controller not found")
        return
    }

    this.currentZoom += amount
    this.currentZoom = ClampF(this.currentZoom, 0.5, 2.0)

    minimap.SetZoomLevel(this.currentZoom)

    GameInstance.GetDebug().Notification("Minimap Zoom: " + ToString(this.currentZoom))
}

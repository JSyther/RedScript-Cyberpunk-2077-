module RandomRadio

import gameaudio
import GameInstance
import Cyberpunk.PlayerPuppet
import gameTimeSystem

@addField(PlayerPuppet)
let radioStations: array<gameaudio.RadioStation>

@addField(PlayerPuppet)
let changeIntervalSeconds: Float

@addField(PlayerPuppet)
let nextChangeTime: Float

@wrapMethod(PlayerPuppet)
func OnGameAttached() -> Void {
    wrappedMethod()

    // Initialize your list of radio stations (use real station IDs)
    this.radioStations = [
        gameaudio.RadioStation.Create(n"Radio.Music.Pop"),
        gameaudio.RadioStation.Create(n"Radio.Music.Rock"),
        gameaudio.RadioStation.Create(n"Radio.Music.HipHop"),
        gameaudio.RadioStation.Create(n"Radio.Music.Electronic")
    ]

    this.changeIntervalSeconds = 120.0 // Change every 2 minutes
    this.nextChangeTime = GameInstance.GetTimeSystem().GetGameTime() + this.changeIntervalSeconds

    this.PlayRandomStation()
}

@wrapMethod(PlayerPuppet)
func OnUpdate(deltaTime: Float) -> Void {
    wrappedMethod(deltaTime)

    let currentTime = GameInstance.GetTimeSystem().GetGameTime()
    if (currentTime >= this.nextChangeTime) {
        this.PlayRandomStation()
        this.nextChangeTime = currentTime + this.changeIntervalSeconds
    }
}

func PlayRandomStation() -> Void {
    if (ArraySize(this.radioStations) == 0) {
        return
    }

    let randIndex = RandomInt(0, ArraySize(this.radioStations) - 1)
    let station = this.radioStations[randIndex]

    let radioSystem = GameInstance.GetScriptableSystemsContainer().Get(n"RadioSystem") as gameaudio.RadioSystem
    if (radioSystem != null) {
        radioSystem.PlayRadioStation(station)
        this.ShowStationNotification(station)
    }
}

func ShowStationNotification(station: gameaudio.RadioStation) -> Void {
    let uiSystem = GameInstance.GetScriptableSystemsContainer().Get(n"UISystem")
    if (uiSystem != null) {
        let stationName = station.GetName()
        uiSystem.ShowNotification("Radio: " + stationName)
    }
}

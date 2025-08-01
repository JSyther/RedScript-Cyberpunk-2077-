module InfiniteJump

// === CONFIGURATION ===
@addField(PlayerPuppet)
let iJump_MaxJumps: Int32 = -1; // -1 = infinite
@addField(PlayerPuppet)
let iJump_Height: Float = 4.5; // Default jump is ~2.5–3.5, increase for higher jumps

@addField(PlayerPuppet)
let iJump_JumpCount: Int32 = 0;

@wrapMethod(PlayerPuppet)
public func OnGameAttach() -> Void 
{
    wrappedMethod();
    this.iJump_JumpCount = 0;

    LogChannel(n"InfiniteJump", n"Mod initialized.");
}

@wrapMethod(PlayerPuppet)
protected cb func OnJump(input: ListenerAction, consumer: ListenerActionConsumer) -> Bool
{
    if !this.CanAttemptJump() {
        return false;
    };

    this.PerformJump(); // normal jump trigger
    this.iJump_JumpCount += 1;

    LogChannel(n"InfiniteJump", n"Jumped: count = " + ToString(this.iJump_JumpCount));

    return true;
}

@wrapMethod(PlayerPuppet)
public func CanAttemptJump() -> Bool
{
    if this.IsInAir() {
        if this.iJump_MaxJumps < 0 {
            return true; // infinite
        };
        return this.iJump_JumpCount < this.iJump_MaxJumps;
    };

    this.iJump_JumpCount = 0; // reset when grounded
    return true;
}

@wrapMethod(CharacterMovementComponent)
protected func GetJumpHeight() -> Float 
{
    let owner = GameInstance.GetPlayerSystem(GetGameInstance()).GetLocalPlayerControlledPuppet();
    if IsDefined(owner) && owner is PlayerPuppet
    {
        let pp = owner as PlayerPuppet;
        return pp.iJump_Height;
    };

    return wrappedMethod(); // fallback
}

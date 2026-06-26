Scriptname OSFSeduceManager extends Quest
{Lifecycle owner for OSF Seduce's policy callbacks. OSFSeduce is a library of
global functions with no `self` to persist registration, and static callback
registration is runtime DLL state that does NOT survive a save/load — so this
quest re-registers on first init and on every game load. Attach it to a
start-game-enabled quest in OSFSeduce.esp (CK: Quest > Scripts > Add OSFSeduceManager).}

; First load of a new/updated save: register once.
Event OnInit()
    OSFSeduce.RegisterEvents()
    RegisterForRemoteEvent(Game.GetPlayer(), "OnPlayerLoadGame")
EndEvent

; Every subsequent game load: the DLL forgot our callbacks, so re-register.
Event Actor.OnPlayerLoadGame(Actor akSender)
    OSFSeduce.RegisterEvents()
EndEvent

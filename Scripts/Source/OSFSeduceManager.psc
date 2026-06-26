Scriptname OSFSeduceManager extends Quest
{Lifecycle owner AND policy layer for OSF Seduce. Two jobs:

 1. Callback lifecycle. Static/instance callback registration is runtime DLL
    state that does NOT survive a save/load, so this quest registers on first
    init and re-registers on every game load.

 2. Affinity policy with runtime config. Unlike the OSFSeduce global library
    (which has no `self` and so can't hold filled Properties), a quest instance
    CAN. We register THIS instance as the cue receiver, which lets the affinity
    reward read live GlobalVariable config and resolve COM_Affinity /
    COM_AngerLevel from CK-filled ActorValue Properties (no hardcoded form ids).

 CK setup (OSFSeduce.esp):
   - Attach to a start-game-enabled quest. Add this script.
   - Fill COM_Affinity / COM_AngerLevel with the base-game companion ActorValues
     (pick them by name in the dropdown -- this is the form binding the old
     bridge had to guess at).
   - Create + fill the four config GlobalVariables (see defaults below). The
     companion terminal edits these same globals via the mutator functions.}

; --- callback receiver token (so we can cleanly re-register on load) ----------
int iCueToken = 0

; --- config: runtime-editable via the companion terminal ----------------------
; Defaults mirror SAF Seduce's shipped values. Set the GlobalVariable record
; defaults in CK to match (toggles 1.0, affinity 25.0, anger 5.0).
GlobalVariable Property SeduceChangeAffinityGlobal Auto      ; 0/1 -- apply affinity reward?
GlobalVariable Property SeduceAffinityIncreaseGlobal Auto    ; affinity added per finished scene
GlobalVariable Property SeduceChangeAngerLevelGlobal Auto    ; 0/1 -- apply anger reduction?
GlobalVariable Property SeduceAngerLevelDecreaseGlobal Auto  ; anger subtracted per finished scene

; --- the relationship ActorValues (CK-filled; no form-id guessing) ------------
ActorValue Property COM_Affinity Auto
ActorValue Property COM_AngerLevel Auto

; HUD notifications on scene start/end.
bool Property CfgFeedback = true Auto

; ---------------------------------------------------------------------------
; Lifecycle
; ---------------------------------------------------------------------------

; First load of a new/updated save: register once.
Event OnInit()
    Debug.Trace("OSFSeduce: onInit")
    RegisterCallbacks()
    RegisterForRemoteEvent(Game.GetPlayer(), "OnPlayerLoadGame")
EndEvent

; Every subsequent game load: the DLL forgot our callbacks, so re-register.
Event Actor.OnPlayerLoadGame(Actor akSender)
    Debug.Trace("OSFSeduce: OnPlayerLoadGame")
    RegisterCallbacks()
EndEvent

; Register THIS instance (not the global library) so the handler can hold state.
; Release any prior token first so a re-register doesn't stack duplicate relays.
Function RegisterCallbacks()
    if iCueToken
        OSF.UnregisterSceneCallback(iCueToken)
    endif
    iCueToken = OSF.RegisterSceneCallback(self, "OnSceneEvent", 0, OSF.EVENT_CUE() + OSF.EVENT_SCENE_END())
EndFunction

; ---------------------------------------------------------------------------
; Policy layer (instance methods -- can read Properties / GlobalVariables)
; ---------------------------------------------------------------------------

; Single relay entry. The DLL delivers one snapshot struct per event; dispatch
; on eventType. The reward keys on the "orgasm" CUE (genuine completion, fired
; while the scene is still LIVE so the handle resolves participants). SCENE_END
; is teardown only -- it fires after the slot is released, so it carries no
; participants and is used for HUD feedback only.
Function OnSceneEvent(OSFTypes:SceneEvent akEvent)
    if akEvent.eventType == OSF.EVENT_CUE()
        if akEvent.cue == "orgasm"
            OnCueOrgasm(akEvent.sceneHandle)
        endif
    elseif akEvent.eventType == OSF.EVENT_SCENE_END()
        if CfgFeedback
            Debug.Notification("OSF Seduce: scene ended")
        endif
    endif
EndFunction

; Genuine completion. The "orgasm" cue fires once while the scene is still live,
; so the handle still resolves participants -- unlike SCENE_END. Reward every NPC
; partner (whoever isn't the player; handles NPC-top and NPC-bottom alike).
Function OnCueOrgasm(int aiSceneHandle)
    Actor[] akActors = OSF.GetSceneParticipants(aiSceneHandle)
    int i = 0
    while i < akActors.Length
        Actor a = akActors[i]
        if a && a != Game.GetPlayer()
            ApplyRelationshipReward(a)
        endif
        i = i + 1
    endwhile
EndFunction

; Mirrors SAF's SetRelationships: + affinity, - anger on the NPC, each gated by
; its runtime toggle and guarded on the ActorValue Property being filled (no-op
; if a fill is missing).
Function ApplyRelationshipReward(Actor akNPC)
    if SeduceChangeAffinityGlobal.GetValue() == 1.0 && COM_Affinity
        akNPC.SetValue(COM_Affinity, akNPC.GetValue(COM_Affinity) + SeduceAffinityIncreaseGlobal.GetValue())
        Debug.Trace("OSFSeduce: +" + SeduceAffinityIncreaseGlobal.GetValue() + " affinity on " + akNPC)
    endif
    if SeduceChangeAngerLevelGlobal.GetValue() == 1.0 && COM_AngerLevel
        akNPC.SetValue(COM_AngerLevel, akNPC.GetValue(COM_AngerLevel) - SeduceAngerLevelDecreaseGlobal.GetValue())
        Debug.Trace("OSFSeduce: -" + SeduceAngerLevelDecreaseGlobal.GetValue() + " anger on " + akNPC)
    endif
EndFunction

; ---------------------------------------------------------------------------
; Config mutators -- called by the companion terminal fragments so the actual
; logic stays in version control (the fragments are one-liners). Defaults match
; SAF Seduce's terminal (affinity steps by 25, anger by 5).
; ---------------------------------------------------------------------------

Function SetAffinityEnabled(bool abEnabled)
    float v = 0.0
    if abEnabled
        v = 1.0
    endif
    SeduceChangeAffinityGlobal.SetValue(v)
EndFunction

Function NudgeAffinityAmount(float afDelta)
    float v = SeduceAffinityIncreaseGlobal.GetValue() + afDelta
    if v < 0.0
        v = 0.0
    endif
    SeduceAffinityIncreaseGlobal.SetValue(v)
EndFunction

Function SetAngerEnabled(bool abEnabled)
    float v = 0.0
    if abEnabled
        v = 1.0
    endif
    SeduceChangeAngerLevelGlobal.SetValue(v)
EndFunction

Function NudgeAngerAmount(float afDelta)
    float v = SeduceAngerLevelDecreaseGlobal.GetValue() + afDelta
    if v < 0.0
        v = 0.0
    endif
    SeduceAngerLevelDecreaseGlobal.SetValue(v)
EndFunction

; Restore SAF's shipped defaults in one button.
Function ResetConfigDefaults()
    SeduceChangeAffinityGlobal.SetValue(1.0)
    SeduceAffinityIncreaseGlobal.SetValue(25.0)
    SeduceChangeAngerLevelGlobal.SetValue(1.0)
    SeduceAngerLevelDecreaseGlobal.SetValue(5.0)
EndFunction

; Read current settings to the HUD (terminal "show settings" button).
Function ShowConfig()
    Debug.Notification("Affinity reward: " + (SeduceChangeAffinityGlobal.GetValue() as int) + " (amount " + (SeduceAffinityIncreaseGlobal.GetValue() as int) + ")")
    Debug.Notification("Anger reduction: " + (SeduceChangeAngerLevelGlobal.GetValue() as int) + " (amount " + (SeduceAngerLevelDecreaseGlobal.GetValue() as int) + ")")
EndFunction

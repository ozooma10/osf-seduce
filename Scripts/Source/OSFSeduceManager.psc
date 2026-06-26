Scriptname OSFSeduceManager extends Quest

; --- OSF callback receiver token (so we can cleanly re-register on load) ----------
int iCueToken = 0

; --- config: runtime-editable via the companion terminal ----------------------
; Defaults mirror SAF Seduce's shipped values. Set the GlobalVariable record defaults in CK to match (affinity 25.0, anger 5.0).
GlobalVariable Property SeduceChangeAffinityGlobal Auto      ; 0/1 -- apply affinity reward?
GlobalVariable Property SeduceAffinityIncreaseGlobal Auto    ; affinity added per finished scene
GlobalVariable Property SeduceChangeAngerLevelGlobal Auto    ; 0/1 -- apply anger reduction?
GlobalVariable Property SeduceAngerLevelDecreaseGlobal Auto  ; anger subtracted per finished scene

; --- the relationship ActorValues ------------
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
    iCueToken = OSF.RegisterSceneCallback(self, "OnSceneEvent", 0, OSF.EVENT_CUE() + OSF.EVENT_SCENE_END() + OSF.EVENT_SCENE_BEGIN())
EndFunction

; ---------------------------------------------------------------------------
; Policy layer (instance methods -- can read Properties / GlobalVariables)
; ---------------------------------------------------------------------------
Function OnSceneEvent(OSFTypes:SceneEvent akEvent)
    if akEvent.eventType == OSF.EVENT_CUE()
        if akEvent.cue == "orgasm"
            OnCueOrgasm(akEvent.sceneHandle)
        endif
    elseif akEvent.eventType == OSF.EVENT_SCENE_END()
        if CfgFeedback
            Debug.Notification("OSF Seduce: scene ended")
        endif
    elseif akEvent.eventType == OSF.EVENT_SCENE_BEGIN()
        ; scene started
    endif
EndFunction

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

; ---------------------------------------------------------------------------
; Debug helpers -- the OSF analog of SAF's version/force-update terminal. OSF
; has no save-version migration; the useful dev actions are rescanning packs
; (after editing pack JSON) and reporting the framework version.
; ---------------------------------------------------------------------------

; Rescan Data/OSF packs (picks up edited *.osf.json without a game restart).
Function ReloadPacks()
    OSFSeduce.Reload()
EndFunction

Function ShowVersion()
    Debug.Notification("OSF framework v" + OSF.GetVersion())
EndFunction

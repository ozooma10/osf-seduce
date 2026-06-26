Scriptname OSFSeduceManager extends Quest

; --- OSF callback receiver token (so we can cleanly re-register on load) ----------
int iCueToken = 0

; --- config: runtime-editable via the companion terminal ----------------------
; Defaults mirror SAF Seduce's shipped values. Set the GlobalVariable record defaults in CK to match (affinity 25.0, anger 5.0).
GlobalVariable Property SeduceChangeAffinityGlobal Auto      ; 0/1 -- apply affinity reward?
GlobalVariable Property SeduceAffinityIncreaseGlobal Auto    ; affinity added per finished scene
GlobalVariable Property SeduceChangeAngerLevelGlobal Auto    ; 0/1 -- apply anger reduction?
GlobalVariable Property SeduceAngerLevelDecreaseGlobal Auto  ; anger subtracted per finished scene

; --- per-start scene overrides (fed to OSFTypes:SceneOptions at scene start) ----
; Tri-states store the OSF convention: -1 inherit the pack default, 0 force OFF, 1 force ON.
; Set the GlobalVariable record defaults in CK to -1 / -1 / -1 / 1.0 so an un-touched config = no override.
GlobalVariable Property SeduceStripMode Auto         ; strip actors:  -1 inherit / 0 off / 1 on
GlobalVariable Property SeduceLockPlayerMode Auto    ; lock player:   -1 inherit / 0 off / 1 on
GlobalVariable Property SeduceFadeMode Auto          ; start fade:    -1 inherit / 0 off / 1 on
GlobalVariable Property SeduceLoopScale Auto         ; scene length multiplier (1.0 = unchanged)

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

; Restore shipped defaults in one button (affinity/anger AND the scene overrides).
Function ResetConfigDefaults()
    SeduceChangeAffinityGlobal.SetValue(1.0)
    SeduceAffinityIncreaseGlobal.SetValue(25.0)
    SeduceChangeAngerLevelGlobal.SetValue(1.0)
    SeduceAngerLevelDecreaseGlobal.SetValue(5.0)
    SeduceStripMode.SetValue(-1.0)       ; inherit
    SeduceLockPlayerMode.SetValue(-1.0)  ; inherit
    SeduceFadeMode.SetValue(-1.0)        ; inherit
    SeduceLoopScale.SetValue(1.0)        ; no scaling
EndFunction

; Read current settings to the HUD (terminal "show settings" button).
Function ShowConfig()
    Debug.Notification("Affinity reward: " + (SeduceChangeAffinityGlobal.GetValue() as int) + " (amount " + (SeduceAffinityIncreaseGlobal.GetValue() as int) + ")")
    Debug.Notification("Anger reduction: " + (SeduceChangeAngerLevelGlobal.GetValue() as int) + " (amount " + (SeduceAngerLevelDecreaseGlobal.GetValue() as int) + ")")
    Debug.Notification("Strip: " + TriStateLabel(SeduceStripMode) + " | Lock player: " + TriStateLabel(SeduceLockPlayerMode) + " | Fade: " + TriStateLabel(SeduceFadeMode))
    Debug.Notification("Scene length: " + SeduceLoopScale.GetValue() + "x")
EndFunction

; ---------------------------------------------------------------------------
; Scene-override config -- read by BuildSceneOptions at scene start, mutated by
; the companion terminal. Tri-states use the OSF convention (-1/0/1).
; ---------------------------------------------------------------------------

; Build the per-start SceneOptions from the current config. Each field is only
; written when its GlobalVariable property is filled; an unfilled one leaves the
; struct default (StripMode/.. = -1 inherit, LoopScale = 1.0 no-op), so a missing
; record can never accidentally force a policy off.
OSFTypes:SceneOptions Function BuildSceneOptions()
    OSFTypes:SceneOptions opts = new OSFTypes:SceneOptions
    if SeduceStripMode
        opts.StripMode = SeduceStripMode.GetValue() as int
    endif
    if SeduceLockPlayerMode
        opts.LockPlayerMode = SeduceLockPlayerMode.GetValue() as int
    endif
    if SeduceFadeMode
        opts.FadeMode = SeduceFadeMode.GetValue() as int
    endif
    if SeduceLoopScale
        opts.LoopScale = SeduceLoopScale.GetValue()
    endif
    return opts
EndFunction

; Stateless bridge for the dialogue fragments: cast a passed-in quest (the topic's
; GetOwningQuest()) to this manager and return its configured SceneOptions, or None
; if the cast fails (manager not on that quest) so the scene still plays with pack
; defaults. Global so a TIF fragment can call it without holding a property:
;   OSFSeduce.BridgePlayerTop(akSpeaker, OSFSeduceManager.OptsFromQuest(GetOwningQuest()))
OSFTypes:SceneOptions Function OptsFromQuest(Quest akQuest) global
    OSFSeduceManager mgr = akQuest as OSFSeduceManager
    if mgr
        return mgr.BuildSceneOptions()
    endif
    return None
EndFunction

; Terminal mutators -- cycle the tri-states INHERIT -> OFF -> ON -> INHERIT.
Function CycleStripMode()
    SeduceStripMode.SetValue(NextTriState(SeduceStripMode.GetValue()))
EndFunction

Function CycleLockPlayerMode()
    SeduceLockPlayerMode.SetValue(NextTriState(SeduceLockPlayerMode.GetValue()))
EndFunction

Function CycleFadeMode()
    SeduceFadeMode.SetValue(NextTriState(SeduceFadeMode.GetValue()))
EndFunction

; Scene length: step the multiplier and clamp to a sane 0.25 .. 5.0 (the Director
; hard-caps at 20x; this terminal range is the practical one).
Function NudgeLoopScale(float afDelta)
    float v = SeduceLoopScale.GetValue() + afDelta
    if v < 0.25
        v = 0.25
    elseif v > 5.0
        v = 5.0
    endif
    SeduceLoopScale.SetValue(v)
EndFunction

; -1 -> 0 -> 1 -> -1
float Function NextTriState(float afValue)
    int v = afValue as int
    if v == -1
        return 0.0
    elseif v == 0
        return 1.0
    endif
    return -1.0
EndFunction

string Function TriStateLabel(GlobalVariable akMode)
    if !akMode
        return "inherit"
    endif
    int v = akMode.GetValue() as int
    if v == 0
        return "off"
    elseif v == 1
        return "on"
    endif
    return "inherit"
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

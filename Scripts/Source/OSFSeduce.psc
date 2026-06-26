ScriptName OSFSeduce
{OSF Seduce: consumer-content bridge for the Seduce animation set. The scene
work (sync, staging, cue sounds, undress) lives in OSF Director; this script
only chooses definitions, builds arrays for console/quest callers, and
receives cue events for anything Papyrus-side (HUD, affinity, quest hooks).
Moan audio needs NO code here — pack cues carry the sounds.}

; Wire the policy callbacks. MUST run on every game load — static-callback
; registration is runtime DLL state, not saved — so a quest in the ESM calls this
; from OnInit AND Actor.OnPlayerLoadGame (see OSFSeduceManager). The reward keys on
; the "orgasm" CUE (genuine completion, fired while the scene is still live so the
; handle resolves participants); SCENE_END is teardown only (fires on Stop /
; save-load too, after the slot is released, so it carries no participants).
Function RegisterEvents() global
    OSF.RegisterSceneCallbackStatic("OSFSeduce", "OnSceneEvent", 0, OSF.EVENT_CUE() + OSF.EVENT_SCENE_END())
EndFunction

; Pre-scene actor prep (SAF parity): drop any combat alarm and sheathe weapons
; so actors don't enter the scene mid-alert or with a gun drawn. Director owns
; the rest of the prep (undress, camera, input lock, positioning).
Function PrepActors(Actor[] akActors) global
    int i = 0
    while i < akActors.Length
        Actor a = akActors[i]
        if a
            a.StopCombatAlarm()
            a.SheatheWeapon()
        endif
        i = i + 1
    endwhile
EndFunction

; The ordered, combat-prepped actor list every play path shares: slot 0 is the
; bottom, slot 1 is the top. The pack assigns gender slots and its "voice": false
; key (the silent top) by this order, so it must stay fixed across callers.
Actor[] Function SceneActors(Actor akBottom, Actor akTop) global
    Actor[] actors = new Actor[2]
    actors[0] = akBottom
    actors[1] = akTop
    PrepActors(actors)
    return actors
EndFunction

; --- explicit id play (escape hatch) -----------------------------------------
; Plays one specific animation by its pack id. This DOES couple the caller to a
; particular pack's ids; prefer the tag helpers below for pack-agnostic content.
Function Play(string asId, Actor akBottom, Actor akTop) global
    Actor[] sceneActors = SceneActors(akBottom, akTop)
    bool ok = OSF.StartScene(sceneActors, asId)
    if ok
        OnSceneStart(sceneActors)
    endif
    Debug.Trace("OSFSeduce.Play: " + asId + " -> " + ok)
EndFunction

Function PlayPlayerTop(string asId, Actor akNPC) global
    Play(asId, akNPC, Game.GetPlayer())
EndFunction

Function PlayPlayerBottom(string asId, Actor akNPC) global
    Play(asId, Game.GetPlayer(), akNPC)
EndFunction

; --- tag play (pack-agnostic; preferred) -------------------------------------
; Picks a random installed scene carrying ALL of osf + seduce + asSubTag, so the
; caller binds to a CONCEPT (the pose) rather than one pack's animation id. Any
; pack that tags a scene to match can satisfy these.
Function PlayTag(string asSubTag, Actor akBottom, Actor akTop) global
    string[] tags = new string[1]
    tags[0] = asSubTag
    Actor[] sceneActors = SceneActors(akBottom, akTop)
    
    string id = OSF.StartSceneByTags(sceneActors, tags)
    Debug.Trace("OSFSeduce.PlayTag: " + asSubTag + " -> " + id)
    if id
        OnSceneStart(sceneActors)
    endif
EndFunction

Function PlayTagPlayerTop(string asSubTag, Actor akNPC) global
    PlayTag(asSubTag, akNPC, Game.GetPlayer())
EndFunction

Function PlayTagPlayerBottom(string asSubTag, Actor akNPC) global
    PlayTag(asSubTag, Game.GetPlayer(), akNPC)
EndFunction

; --- named pose helpers (tag-based) ------------------------------------------
Function Bridge(Actor akBottom, Actor akTop) global
    PlayTag("bridge", akBottom, akTop)
EndFunction

Function BridgePlayerTop(Actor akNPC) global
    PlayTagPlayerTop("bridge", akNPC)
EndFunction

Function BridgePlayerBottom(Actor akNPC) global
    PlayTagPlayerBottom("bridge", akNPC)
EndFunction

Function DownDog(Actor akBottom, Actor akTop) global
    PlayTag("downdog", akBottom, akTop)
EndFunction

Function DownDogPlayerTop(Actor akNPC) global
    PlayTagPlayerTop("downdog", akNPC)
EndFunction

Function DownDogPlayerBottom(Actor akNPC) global
    PlayTagPlayerBottom("downdog", akNPC)
EndFunction

Function Eagle(Actor akBottom, Actor akTop) global
    PlayTag("eagle", akBottom, akTop)
EndFunction

Function EaglePlayerTop(Actor akNPC) global
    PlayTagPlayerTop("eagle", akNPC)
EndFunction

Function EaglePlayerBottom(Actor akNPC) global
    PlayTagPlayerBottom("eagle", akNPC)
EndFunction

; Each custom scene carries both the "custom" group tag and a per-pose tag
; ("custom01".."custom06") in the pack, so aiIndex selects a specific one by tag
; without naming a pack id. Use Random() / PlayTag("custom") for any custom.
Function Custom(int aiIndex, Actor akBottom, Actor akTop) global
    PlayTag("custom0" + aiIndex, akBottom, akTop)
EndFunction

Function CustomPlayerTop(int aiIndex, Actor akNPC) global
    PlayTagPlayerTop("custom0" + aiIndex, akNPC)
EndFunction

Function CustomPlayerBottom(int aiIndex, Actor akNPC) global
    PlayTagPlayerBottom("custom0" + aiIndex, akNPC)
EndFunction

; Random pick across the whole set (any paired osf-tagged definition).
Function Random(Actor akBottom, Actor akTop) global
    string[] tags = new string[2]
    tags[0] = "osf"
    tags[1] = "seduce"
    Actor[] sceneActors = SceneActors(akBottom, akTop)
    string id = OSF.StartSceneByTags(sceneActors, tags)
    if id > 0
        OnSceneStart(sceneActors)
    endif
    Debug.Trace("OSFSeduce.Random -> " + id)
EndFunction

Function RandomPlayerTop(Actor akNPC) global
    Random(akNPC, Game.GetPlayer())
EndFunction

Function RandomPlayerBottom(Actor akNPC) global
    Random(Game.GetPlayer(), akNPC)
EndFunction

Function Stage(Actor akActor, int aiStage) global
    bool ok = OSF.SetSceneStageForActor(akActor, aiStage)
    Debug.Trace("OSFSeduce.Stage: " + aiStage + " -> " + ok)
EndFunction

Function Stop(Actor akActor) global
    bool ok = OSF.StopSceneForActor(akActor)
    Debug.Trace("OSFSeduce.Stop: " + ok)
EndFunction

Function Reload() global
    int count = OSF.ReloadPacks()
    Debug.Notification("OSF Seduce: " + count + " animations registered")
EndFunction

; ---------------------------------------------------------------------------
; Policy layer
;
; These run as the DLL fires scene/cue events. OSFSeduce is a library of GLOBAL
; functions (so RegisterSceneCallback and cgf can reach them), which means the
; handlers are STATELESS: a global function has no `self`, so it can't hold
; script variables or fillable Properties. Anything that needs persistent state
; (an arousal meter), a config menu, or ESM forms (affinity GlobalVariables,
; quest stages) belongs in a quest script in the OSF Seduce ESM that registers
; these same callbacks. Treat what's here as the reference reactions: stateless,
; argument-derived, and form-free wherever possible.
; ---------------------------------------------------------------------------

; -- config (compile-time literals; flip here, or shadow from the ESM layer) --
bool Function CfgFeedback() global        ; HUD notifications on scene start/end
    return true
EndFunction
bool Function CfgChangeAffinity() global  ; warm the NPC partner on a finished scene
    return true
EndFunction
float Function CfgAffinityGain() global  ; SAF Seduce's shipped default
    return 25.0
EndFunction
float Function CfgAngerDrop() global     ; SAF default unknown (its menu never resets it)
    return 5.0
EndFunction

; Companion affinity / anger ActorValues. A global function can't hold a filled
; Property, so these resolve the base-game forms by id. FormIDs extracted from
; NAFSeduce.esp's quest VMAD (the COM_Affinity / COM_AngerLevel bindings SAF
; Seduce shipped with) — not yet re-verified in-game here. If a game patch ever
; moves them, a None return makes the reward no-op safely.
ActorValue Function AffinityAV() global
    return Game.GetFormFromFile(0x000A1B80, "Starfield.esm") as ActorValue
EndFunction
ActorValue Function AngerAV() global
    return Game.GetFormFromFile(0x0002DA12, "Starfield.esm") as ActorValue
EndFunction

; Single relay entry (the name registered in RegisterEvents). The DLL delivers one
; snapshot struct per event; dispatch on eventType. Do NOT call live getters that
; depend on the handle at SCENE_END — by then the slot is released (see OnCueOrgasm).
Function OnSceneEvent(OSFTypes:SceneEvent akEvent) global
    if akEvent.eventType == OSF.EVENT_CUE()
        if akEvent.cue == "orgasm"
            OnCueOrgasm(akEvent.sceneHandle)
        endif
    elseif akEvent.eventType == OSF.EVENT_SCENE_END()
        if CfgFeedback()
            Debug.Notification("OSF Seduce: scene ended")
        endif
    endif
EndFunction

; Genuine completion. The "orgasm" cue (climax stage in the pack) fires once while
; the scene is still LIVE, so the handle still resolves participants — unlike
; SCENE_END, which fires after ReleaseSlot, returning an empty list. Reward every
; NPC partner (whoever isn't the player; handles NPC-top and NPC-bottom alike).
Function OnCueOrgasm(int aiSceneHandle) global
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

Function OnSceneStart(Actor[] akActors) global
    if CfgFeedback()
        Debug.Notification("OSF Seduce: scene started")
    endif
EndFunction

; Mirrors SAF's SetRelationships: + affinity, - anger on the NPC, gated by
; config and guarded on the ActorValues resolving (no-op if AffinityAV is None).
Function ApplyRelationshipReward(Actor akNPC) global
    if !CfgChangeAffinity()
        return
    endif
    ActorValue av = AffinityAV()
    if av
        akNPC.SetValue(av, akNPC.GetValue(av) + CfgAffinityGain())
        Debug.Trace("OSFSeduce: +" + CfgAffinityGain() + " affinity on " + akNPC)
    endif
    ActorValue anger = AngerAV()
    if anger
        akNPC.SetValue(anger, akNPC.GetValue(anger) - CfgAngerDrop())
    endif
EndFunction
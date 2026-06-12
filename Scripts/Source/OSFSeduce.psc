ScriptName OSFSeduce
{OSF Seduce: consumer-content bridge for the Seduce animation set. The scene
work (sync, staging, cue sounds, undress) lives in OSF Director; this script
only chooses definitions, builds arrays for console/quest callers, and
receives cue events for anything Papyrus-side (HUD, affinity, quest hooks).
Moan audio needs NO code here — pack cues carry the sounds.}

Function RegisterEvents() global
    OSF.RegisterSceneCallback("OSFSeduce", "OnOSFScene")
    OSF.RegisterCueCallback("OSFSeduce", "OnOSFCue")
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

; --- explicit id play (escape hatch) -----------------------------------------
; Plays one specific animation by its pack id. This DOES couple the caller to a
; particular pack's ids; prefer the tag helpers below for pack-agnostic content.
Function Play(string asId, Actor akBottom, Actor akTop) global
    Actor[] actors = new Actor[2]
    actors[0] = akBottom
    actors[1] = akTop
    PrepActors(actors)
    bool ok = OSF.PlayDefined(asId, actors, 0)
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
    Actor[] actors = new Actor[2]
    actors[0] = akBottom
    actors[1] = akTop
    PrepActors(actors)
    string[] tags = new string[3]
    tags[0] = "osf"
    tags[1] = "seduce"
    tags[2] = asSubTag
    string id = OSF.PlayByTags(actors, tags)
    Debug.Trace("OSFSeduce.PlayTag: " + asSubTag + " -> " + id)
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
    Actor[] actors = new Actor[2]
    actors[0] = akBottom
    actors[1] = akTop
    PrepActors(actors)
    string[] tags = new string[2]
    tags[0] = "osf"
    tags[1] = "seduce"
    string id = OSF.PlayByTags(actors, tags)
    Debug.Trace("OSFSeduce.Random -> " + id)
EndFunction

Function RandomPlayerTop(Actor akNPC) global
    Random(akNPC, Game.GetPlayer())
EndFunction

Function RandomPlayerBottom(Actor akNPC) global
    Random(Game.GetPlayer(), akNPC)
EndFunction

Function Stage(Actor akActor, int aiStage) global
    bool ok = OSF.SetSceneStage(akActor, aiStage)
    Debug.Trace("OSFSeduce.Stage: " + aiStage + " -> " + ok)
EndFunction

Function Stop(Actor akActor) global
    bool ok = OSF.StopScene(akActor)
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

Function OnOSFScene(string asEvent, Actor[] akActors, int aiStage) global
    if asEvent == "start"
        OnSceneStart(akActors)
    elseif asEvent == "end"
        OnSceneEnd(akActors)
    endif
    ; "stage" / "loop" arrive here too — slot handlers in as needed.
    Debug.Trace("OSFSeduce.OnOSFScene: " + asEvent + " stage=" + aiStage + " actors=" + akActors.Length)
EndFunction

Function OnSceneStart(Actor[] akActors) global
    if CfgFeedback()
        Debug.Notification("OSF Seduce: scene started")
    endif
EndFunction

Function OnSceneEnd(Actor[] akActors) global
    ; The climax sound is now a lastLoop cue in the pack (fires once on the final
    ; loop of stage 3, correctly timed and positioned), so nothing to play here.
    ; SAF-style reward: nudge every NPC partner's standing toward the player.
    ; CAVEAT: "end" also fires on StopScene / save-load teardown, so a stricter
    ; mod should gate the reward on the "orgasm" cue (genuine completion) and
    ; track it in an ESM quest; this stateless reference rewards on any end.
    int i = 0
    while i < akActors.Length
        Actor a = akActors[i]
        if a && a != Game.GetPlayer()
            ApplyRelationshipReward(a)
        endif
        i = i + 1
    endwhile
    if CfgFeedback()
        Debug.Notification("OSF Seduce: scene ended")
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

Function OnOSFCue(string asCue, Actor akActor, int aiStage, float afTime) global
    ; Per-cue policy. The DLL already voiced the moan from the pack; this hook is
    ; for gameplay/visual reactions. Dispatch on the cue tag so reactions can be
    ; keyed to intensity (short/med/loud). akActor is the cue's target (slot 0,
    ; the moaning actor).
    if asCue == "moan_short"
        OnCueMoan(akActor, 1)
    elseif asCue == "moan_med"
        OnCueMoan(akActor, 2)
    elseif asCue == "moan_loud"
        OnCueMoan(akActor, 3)
    elseif asCue == "orgasm"
        OnCueClimax(akActor)
    endif
    Debug.Trace("OSFSeduce.OnOSFCue: " + asCue + " stage=" + aiStage + " time=" + afTime + " actor=" + akActor)
EndFunction

; Reference reaction per moan tier (1=short, 2=med, 3=loud). No gameplay effect
; by default — the sound is already playing. Extension points for content: drive
; a facial morph, partner dialogue, a screen pulse, or feed an arousal meter
; (accumulate the meter in the ESM quest, since this handler is stateless).
Function OnCueMoan(Actor akActor, int aiIntensity) global
EndFunction

; Climax: the "orgasm" cue (lastLoop in the pack) fires once on the final loop
; of the last stage. The DLL already played the climax sound from the cue's
; "$moan_loud" pool; this is the reliable "scene completed for real" signal
; (unlike "end", which also fires on teardown). akActor is the moaning actor —
; a content/ESM layer can hang fade-out, dialogue, or the affinity reward here.
Function OnCueClimax(Actor akActor) global
EndFunction

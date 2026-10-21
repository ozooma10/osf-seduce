ScriptName OSFSeduce

; Recheck at scene start because console/script callers bypass dialogue conditions.
bool Function AreAdultActors(Actor akBottom, Actor akTop) global
    if !akBottom || !akTop
        Debug.Trace("OSFSeduce: scene rejected - missing actor")
        return false
    endif
    if akBottom.IsChild() || akTop.IsChild()
        Debug.Trace("OSFSeduce: scene rejected - child participant")
        return false
    endif
    return true
EndFunction

Actor[] Function SceneActors(Actor akBottom, Actor akTop) global
    Actor[] actors = new Actor[2]
    actors[0] = akBottom
    actors[1] = akTop
    return actors
EndFunction

; --- OSF Intimacy ---------------------------------------------------------------
; Scenes start as OSF Intimacy encounters owned by Seduce, so OSFSeduceManager hears only its own
; climax events. Intimacy also checks eligibility (adult, alive, loaded, not in combat or another scene).

string Function Owner() global
    return "OSFSeduce"
EndFunction

; The top actor is preferred onto the "top" role; the terminal's strip and length settings carry over.
OSFIntimacyTypes:EncounterRequest Function NewRequest(Actor akTop, OSFTypes:SceneOptions akOpts) global
    OSFIntimacyTypes:EncounterRequest req = new OSFIntimacyTypes:EncounterRequest
    req.Owner = Owner()
    req.PreferActor = akTop
    req.PreferRole = "top"
    if akOpts
        req.StripMode = akOpts.StripMode
        req.LengthScale = akOpts.LoopScale
    endif
    return req
EndFunction

int Function StartEncounter(Actor akBottom, Actor akTop, OSFIntimacyTypes:EncounterRequest akRequest, string asWhat) global
    int handle = OSFIntimacy.StartEncounter(SceneActors(akBottom, akTop), akRequest)
    if handle > 0
        Debug.Trace("OSFSeduce." + asWhat + ": encounter " + handle)
    else
        Debug.Trace("OSFSeduce." + asWhat + ": " + OSFIntimacy.RefusalName(handle) + " - " + OSFIntimacy.GetLastRefusal(Owner()))
    endif
    return handle
EndFunction

; --- explicit id play (escape hatch) -----------------------------------------
; Plays one specific animation by its pack id. This DOES couple the caller to a particular pack's ids; prefer the tag helpers below for pack-agnostic content.
Function Play(string asId, Actor akBottom, Actor akTop, OSFTypes:SceneOptions akOpts = None) global
    if !AreAdultActors(akBottom, akTop)
        return
    endif
    OSFIntimacyTypes:EncounterRequest req = NewRequest(akTop, akOpts)
    req.SceneId = asId
    if asId == "osf_seduce_bridge" || asId == "osf_seduce_downdog"
        req.Progression = OSFIntimacy.PROGRESSION_MANUAL() ; interactive manual; auto fallback when OSF UI is unavailable
        req.Control = OSFIntimacy.CONTROL_PLAYER()
        req.Tags = "paired"
        req.AnyTags = "bridge,downdog"
        req.AllowPoolSwitching = true
    endif
    StartEncounter(akBottom, akTop, req, "Play " + asId)
EndFunction

Function PlayPlayerTop(string asId, Actor akNPC, OSFTypes:SceneOptions akOpts = None) global
    Play(asId, akNPC, Game.GetPlayer(), akOpts)
EndFunction

Function PlayPlayerBottom(string asId, Actor akNPC, OSFTypes:SceneOptions akOpts = None) global
    Play(asId, Game.GetPlayer(), akNPC, akOpts)
EndFunction

; --- tag play (pack-agnostic; preferred) -------------------------------------
; Picks a random installed scene carrying asSubTag (plus OSF Intimacy's adult and composition tags).
; Any pack that tags a scene to match can satisfy these.
Function PlayTag(string asSubTag, Actor akBottom, Actor akTop, OSFTypes:SceneOptions akOpts = None) global
    if !AreAdultActors(akBottom, akTop)
        return
    endif
    OSFIntimacyTypes:EncounterRequest req = NewRequest(akTop, akOpts)
    req.Tags = asSubTag
    if asSubTag == "bridge" || asSubTag == "downdog"
        req.InitialTags = "seduce," + asSubTag
        req.Progression = OSFIntimacy.PROGRESSION_MANUAL() ; interactive manual; auto fallback when OSF UI is unavailable
        req.Control = OSFIntimacy.CONTROL_PLAYER()
        req.Tags = "paired"
        req.AnyTags = "bridge,downdog"
        req.AllowPoolSwitching = true
    endif
    StartEncounter(akBottom, akTop, req, "PlayTag " + asSubTag)
EndFunction

Function PlayTagPlayerTop(string asSubTag, Actor akNPC, OSFTypes:SceneOptions akOpts = None) global
    PlayTag(asSubTag, akNPC, Game.GetPlayer(), akOpts)
EndFunction

Function PlayTagPlayerBottom(string asSubTag, Actor akNPC, OSFTypes:SceneOptions akOpts = None) global
    PlayTag(asSubTag, Game.GetPlayer(), akNPC, akOpts)
EndFunction

; --- named pose helpers (tag-based) ------------------------------------------
Function Bridge(Actor akBottom, Actor akTop, OSFTypes:SceneOptions akOpts = None) global
    PlayTag("bridge", akBottom, akTop, akOpts)
EndFunction

Function BridgePlayerTop(Actor akNPC, OSFTypes:SceneOptions akOpts = None) global
    PlayTagPlayerTop("bridge", akNPC, akOpts)
EndFunction

Function BridgePlayerBottom(Actor akNPC, OSFTypes:SceneOptions akOpts = None) global
    PlayTagPlayerBottom("bridge", akNPC, akOpts)
EndFunction

Function DownDog(Actor akBottom, Actor akTop, OSFTypes:SceneOptions akOpts = None) global
    PlayTag("downdog", akBottom, akTop, akOpts)
EndFunction

Function DownDogPlayerTop(Actor akNPC, OSFTypes:SceneOptions akOpts = None) global
    PlayTagPlayerTop("downdog", akNPC, akOpts)
EndFunction

Function DownDogPlayerBottom(Actor akNPC, OSFTypes:SceneOptions akOpts = None) global
    PlayTagPlayerBottom("downdog", akNPC, akOpts)
EndFunction

Function Eagle(Actor akBottom, Actor akTop, OSFTypes:SceneOptions akOpts = None) global
    PlayTag("eagle", akBottom, akTop, akOpts)
EndFunction

Function EaglePlayerTop(Actor akNPC, OSFTypes:SceneOptions akOpts = None) global
    PlayTagPlayerTop("eagle", akNPC, akOpts)
EndFunction

Function EaglePlayerBottom(Actor akNPC, OSFTypes:SceneOptions akOpts = None) global
    PlayTagPlayerBottom("eagle", akNPC, akOpts)
EndFunction

; Random pick across the whole set (any paired osf-tagged definition).
Function Random(Actor akBottom, Actor akTop, OSFTypes:SceneOptions akOpts = None) global
    if !AreAdultActors(akBottom, akTop)
        return
    endif
    OSFIntimacyTypes:EncounterRequest req = NewRequest(akTop, akOpts)
    req.Tags = "osf,seduce"
    StartEncounter(akBottom, akTop, req, "Random")
EndFunction

Function RandomPlayerTop(Actor akNPC, OSFTypes:SceneOptions akOpts = None) global
    Random(akNPC, Game.GetPlayer(), akOpts)
EndFunction

Function RandomPlayerBottom(Actor akNPC, OSFTypes:SceneOptions akOpts = None) global
    Random(Game.GetPlayer(), akNPC, akOpts)
EndFunction

Function Stage(Actor akActor, int aiStage) global
    bool ok = OSF.SetSceneStageForActor(akActor, aiStage)
    Debug.Trace("OSFSeduce.Stage: " + aiStage + " -> " + ok)
EndFunction

; Stops the actor's encounter; falls back to any OSF scene the actor is in.
Function Stop(Actor akActor) global
    int encounter = OSFIntimacy.GetEncounterForActor(akActor)
    bool ok
    if encounter > 0
        ok = OSFIntimacy.StopEncounter(encounter)
    else
        ok = OSF.StopSceneForActor(akActor)
    endif
    Debug.Trace("OSFSeduce.Stop: " + ok)
EndFunction

Function Reload() global
    int count = OSF.ReloadPacks()
    Debug.Notification("OSF Seduce: " + count + " animations registered")
EndFunction

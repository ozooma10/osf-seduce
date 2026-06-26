ScriptName OSFSeduce

Actor[] Function SceneActors(Actor akBottom, Actor akTop) global
    Actor[] actors = new Actor[2]
    actors[0] = akBottom
    actors[1] = akTop
    return actors
EndFunction

; --- explicit id play (escape hatch) -----------------------------------------
; Plays one specific animation by its pack id. This DOES couple the caller to a particular pack's ids; prefer the tag helpers below for pack-agnostic content.
Function Play(string asId, Actor akBottom, Actor akTop, OSFTypes:SceneOptions akOpts = None) global
    bool ok = OSF.StartScene(SceneActors(akBottom, akTop), asId, akOpts)
    Debug.Trace("OSFSeduce.Play: " + asId + " -> " + ok)
EndFunction

Function PlayPlayerTop(string asId, Actor akNPC, OSFTypes:SceneOptions akOpts = None) global
    Play(asId, akNPC, Game.GetPlayer(), akOpts)
EndFunction

Function PlayPlayerBottom(string asId, Actor akNPC, OSFTypes:SceneOptions akOpts = None) global
    Play(asId, Game.GetPlayer(), akNPC, akOpts)
EndFunction

; --- tag play (pack-agnostic; preferred) -------------------------------------
; Picks a random installed scene carrying ALL of asSubTag. Any pack that tags a scene to match can satisfy these.
Function PlayTag(string asSubTag, Actor akBottom, Actor akTop, OSFTypes:SceneOptions akOpts = None) global
    string[] tags = new string[1]
    tags[0] = asSubTag
    string id = OSF.StartSceneByTags(SceneActors(akBottom, akTop), tags, akOpts)
    Debug.Trace("OSFSeduce.PlayTag: " + asSubTag + " -> " + id)
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
    string[] tags = new string[2]
    tags[0] = "osf"
    tags[1] = "seduce"
    string id = OSF.StartSceneByTags(SceneActors(akBottom, akTop), tags, akOpts)
    Debug.Trace("OSFSeduce.Random -> " + id)
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

Function Stop(Actor akActor) global
    bool ok = OSF.StopSceneForActor(akActor)
    Debug.Trace("OSFSeduce.Stop: " + ok)
EndFunction

Function Reload() global
    int count = OSF.ReloadPacks()
    Debug.Notification("OSF Seduce: " + count + " animations registered")
EndFunction

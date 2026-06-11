ScriptName OSFSeduce
{OSF Seduce: consumer-content bridge for the Seduce animation set. The scene
work (sync, staging, cue sounds, undress) lives in OSF Director; this script
only chooses definitions, builds arrays for console/quest callers, and
receives cue events for anything Papyrus-side (HUD, affinity, quest hooks).
Moan audio needs NO code here — pack cues carry the sounds.}

Function RegisterEvents() global
    SFW.RegisterSceneCallback("OSFSeduce", "OnOSFScene")
    SFW.RegisterCueCallback("OSFSeduce", "OnOSFCue")
EndFunction

Function Play(string asId, Actor akBottom, Actor akTop) global
    Actor[] actors = new Actor[2]
    actors[0] = akBottom
    actors[1] = akTop
    bool ok = SFW.PlayDefined(asId, actors, 0)
    Debug.Trace("OSFSeduce.Play: " + asId + " -> " + ok)
EndFunction

Function Bridge(Actor akBottom, Actor akTop) global
    Play("osf_seduce_bridge", akBottom, akTop)
EndFunction

Function DownDog(Actor akBottom, Actor akTop) global
    Play("osf_seduce_downdog", akBottom, akTop)
EndFunction

Function Eagle(Actor akBottom, Actor akTop) global
    Play("osf_seduce_eagle", akBottom, akTop)
EndFunction

Function Custom(int aiIndex, Actor akBottom, Actor akTop) global
    string id = "osf_seduce_custom0" + aiIndex
    Play(id, akBottom, akTop)
EndFunction

; Random pick across the whole set (any paired osf-tagged definition).
Function Random(Actor akBottom, Actor akTop) global
    Actor[] actors = new Actor[2]
    actors[0] = akBottom
    actors[1] = akTop
    string[] tags = new string[2]
    tags[0] = "osf"
    tags[1] = "seduce"
    string id = SFW.PlayByTags(actors, tags)
    Debug.Trace("OSFSeduce.Random -> " + id)
EndFunction

Function Stage(Actor akActor, int aiStage) global
    bool ok = SFW.SetSceneStage(akActor, aiStage)
    Debug.Trace("OSFSeduce.Stage: " + aiStage + " -> " + ok)
EndFunction

Function Stop(Actor akActor) global
    bool ok = SFW.StopScene(akActor)
    Debug.Trace("OSFSeduce.Stop: " + ok)
EndFunction

Function Reload() global
    int count = SFW.ReloadPacks()
    Debug.Notification("OSF Seduce: " + count + " animations registered")
EndFunction

Function OnOSFScene(string asEvent, Actor[] akActors, int aiStage) global
    Debug.Trace("OSFSeduce.OnOSFScene: " + asEvent + " stage=" + aiStage + " actors=" + akActors.Length)
EndFunction

Function OnOSFCue(string asCue, Actor akActor, int aiStage, float afTime) global
    ; Sounds are played by the DLL; this is the policy hook (e.g. "orgasm"
    ; cue -> affinity/quest reactions) once the ESM layer exists.
    Debug.Trace("OSFSeduce.OnOSFCue: " + asCue + " stage=" + aiStage + " time=" + afTime + " actor=" + akActor)
EndFunction

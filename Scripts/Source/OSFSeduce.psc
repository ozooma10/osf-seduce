ScriptName OSFSeduce
{OSF Seduce: consumer-content bridge for the Seduce animation set. The scene
work (sync, staging, cue sounds, undress) lives in OSF Director; this script
only chooses definitions and builds arrays for console/quest callers.
Moan audio needs NO code here — pack cues carry the sounds.

Stateful policy (affinity reward, runtime config, the companion terminal, cue
callbacks) lives in OSFSeduceManager: a quest INSTANCE can hold filled
Properties / GlobalVariables that these GLOBAL functions cannot, and it owns
the cue callback registration. Keep this file free of saved state and ESM-form
lookups.}

; The ordered actor list every play path shares: slot 0 is the
; bottom, slot 1 is the top. The pack assigns gender slots and its "voice": false
; key (the silent top) by this order, so it must stay fixed across callers.
Actor[] Function SceneActors(Actor akBottom, Actor akTop) global
    Actor[] actors = new Actor[2]
    actors[0] = akBottom
    actors[1] = akTop
    return actors
EndFunction

; --- explicit id play (escape hatch) -----------------------------------------
; Plays one specific animation by its pack id. This DOES couple the caller to a
; particular pack's ids; prefer the tag helpers below for pack-agnostic content.
Function Play(string asId, Actor akBottom, Actor akTop) global
    bool ok = OSF.StartScene(SceneActors(akBottom, akTop), asId)
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
    string id = OSF.StartSceneByTags(SceneActors(akBottom, akTop), tags)
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
    string[] tags = new string[2]
    tags[0] = "osf"
    tags[1] = "seduce"
    string id = OSF.StartSceneByTags(SceneActors(akBottom, akTop), tags)
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


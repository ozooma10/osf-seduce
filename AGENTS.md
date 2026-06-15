# OSF Seduce

Papyrus/ESP/content consumer mod built on the OSF framework (native side:
`C:\Modding\Starfield\OSF Animation` — read its `CLAUDE.md` for the OSF API, pack JSON schema,
scheduled-voice model, and cue events before changing content here).

This repo is the **git source of truth**; the live MO2 mod is a deploy copy.

## Layout

- `OSFSeduce.esp` + `meta.ini` — plugin + MO2 metadata.
- `Scripts\Source\OSFSeduce.psc` — the bridge script (registers OSF callbacks, drives scenes).
- `Scripts\Source\Fragments\` — TIF (topic-info fragment) sources; compiled output mirrors to
  `Scripts\` / `Scripts\Fragments\TopicInfos\`.
- `OSF\SFW\OSFSeduce.json` — the scene pack (animation ids `osf_seduce_*`; SLAL-shaped schema,
  stages declare `{loops, intensity, peak}` — hand-timed cue ladders were deleted in the
  scheduled-voice migration). `OSFSeduce.dialogue.json` — dialogue data.
- `OSF\Voices\seduce_female.voice.json` — voice set (vocal pools by intensity + peak pool +
  interval). Pools were tiered by a duration heuristic — re-tier by ear when touching them.
- `OSF\Seduce\Animations\` — 54 Seduce GLBs (repackaged SAF_Seduce_ assets: fine locally,
  **DO NOT distribute** without the Seduce author's OK).
- `Sound\OSF\Seduce\Female\` — 77 female voice wavs.

## Build & deploy

```powershell
.\Build.ps1            # compile OSFSeduce.psc + TIF fragments, then deploy
.\Build.ps1 -NoDeploy  # compile only
.\Build.ps1 -NoCompile # deploy only
```

Deployment copies `OSFSeduce.esp`, `meta.ini`, `OSF`, `Scripts`, `Sound`; it overwrites but
never mirror-deletes. The default `-Target` is `MO2\mods\OSF Seduce`, which matches the live
MO2 mod folder as of 2026-06-12 (the old `osf-seduce` folder is gone). ⚠ Still check which
mod MO2 has enabled before trusting a deploy — if the names disagree, pass `-Target`
explicitly (a default run will silently create a second mod folder).

## Test in-game

Enable the mod (+ the native plugin mod: `OSF Animation`) in MO2, launch via SFSE, then in
the console:

```text
cgf "OSFSeduce.Bridge" <refA> <refB>     # play the bridge scene
cgf "OSFSeduce.Random" <refA> <refB>
cgf "OSFSeduce.Stage"  ...               # stage jump
cgf "OSFSeduce.Stop"   <refA>
cgf "OSFSeduce.Reload"                   # rescan Data/OSF packs
```

Voice/cue behavior arrives via OSF events: `OnOSFCue` keys on `"vocal"` / `"peak"`; the top
actor is `"voice": false` in the pack. Runtime evidence:
`<Documents>\My Games\Starfield\SFSE\Logs\OSF Director.log` (becomes `OSF Animation.log`
once the renamed target is deployed — check for both).

## Gotchas

- Papyrus compile needs the script *name* (not path) and `-import` covering both this repo's
  sources and `C:\Modding\Starfield\PapyrusSource` — Build.ps1 handles this; don't hand-roll.
- Pack offsets are meters + heading in **degrees**; in-game alignment fixes via Director's
  numpad adjust hotkeys write back into pack JSON (strips `//` comments on save).
- Schema changes belong in Director (PackRegistry), not here — content must stay loadable by
  the shipped `kPackSchemaVersion`.

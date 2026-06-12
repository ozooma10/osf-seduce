# In-game verification checklist

Things changed or flagged during the SAF-parity audit (2026-06-12) that need a
human at the keyboard. Check off / delete items as they're confirmed.

## Blocking (all shipped content depends on these)

- [ ] **Player-in-scene** — Director's CameraService / PlayerControlService
  (force third person, input lock, restore) has never been live-validated
  (OSF Director CLAUDE.md, AUDIT §13 Q3), and every dialogue path here is a
  player scene. Test: `cgf "OSFSeduce.RandomPlayerBottom" <npc>` — camera
  forced to 3rd person, controls locked during, both restored after.
- [ ] **Loop-count stage advance** — Director marks it "built, untested
  in-game", and the pack uses `loops` as the ONLY advance mechanism (no
  `timer` fallback) on all 9 animations. Same test as above: scene must
  advance through all 3 stages and end on its own.
- [ ] **MO2 setup** — the new mod folder `MO2\mods\OSF Seduce Animations`
  must be enabled (and `OSF Seduce` pointing at the right folder; the old
  `osf-seduce` deploy is gone). If the pack mod isn't enabled, every tag
  query finds nothing and scenes silently refuse to start. Sanity:
  `cgf "OSFSeduce.Reload"` should report the 9 Seduce animations.

## New since the audit (verify the fix works)

- [ ] **Male voice set** (pack commit `b78564d`) — with a male voiced
  participant (e.g. male player as bottom), scheduled moans + climax play.
  Then judge the tiers by ear: pools were mirrored from the female set,
  which was itself tiered by a duration heuristic — shuffle misfits between
  `moans[0..2]` in `OSF/Voices/seduce_male.voice.json`.
- [ ] **Affinity/anger reward** — AffinityAV/AngerAV now resolve
  COM_Affinity `0x000A1B80` / COM_AngerLevel `0x0002DA12` (Starfield.esm;
  extracted from NAFSeduce.esp's quest VMAD, not yet re-verified in-game).
  Test with a companion: note `getvalue COM_Affinity` on them in console,
  run a scene to completion, confirm +25 affinity / −5 anger and the
  `OSFSeduce: +25 affinity` trace line. Caveat (documented in the script):
  the reward fires on ANY "end", including StopScene/teardown.
- [ ] **Tag-based pose helpers** — `cgf "OSFSeduce.Bridge" <a> <b>` etc. now
  select via PlayByTags(osf/seduce/<pose>) instead of ids; spot-check one
  named pose and one `Custom <n>`.

## Audit backlog (not yet implemented)

- [ ] Combat-stop + sheathe before scene start; SAF-style fade-to-black
  around the start/end snap (audit item 4/5).
- [ ] Bump pack stage loops to SAF's shipped feel (1/3/3) if scenes feel
  short at 1/1/1.
- [ ] xEdit pass on OSFSeduce.esp: dead terminal-menu records and
  `Chem_SeductionPheromone` inherited from NAFSeduce.esp (we ship no
  terminal fragment scripts).
- [ ] `sceneEquipment` erection support — needs an answer on whether
  PackRegistry resolves ARMO forms from external plugins
  (Robert S Body Replacer.esm form 2052 / Dick.esm form 2077), or proxy
  ARMOs in OSFSeduce.esp.

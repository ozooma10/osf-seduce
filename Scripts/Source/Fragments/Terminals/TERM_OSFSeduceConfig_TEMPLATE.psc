;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
; TEMPLATE -- OSF Seduce config terminal, mirroring SAF Seduce's terminals as far as OSF allows.
;
; ONLY the affinity/anger rewards + a small debug section are settable: everything else SAF's
; terminals controlled (stage loop counts, strip/undress, anim sync, fade, erection equip, camera,
; player-lock) is now either baked into the pack JSON or handled automatically by the Director, with
; no Papyrus toggle. Those SAF menus have NO OSF equivalent and are intentionally omitted.
;
; The actual logic lives on OSFSeduceManager (version-controlled); these fragments are one-liners.
;
; CK WIRING (the generated fragment script is named after the Terminal's EditorID + FormID, so this
; file is a paste source, not the final script):
;   1. Create the GlobalVariables (CK, Float, save-baked): SeduceChangeAffinityGlobal (1),
;      SeduceAffinityIncreaseGlobal (25), SeduceChangeAngerLevelGlobal (1),
;      SeduceAngerLevelDecreaseGlobal (5). Fill them on the OSFSeduceManager quest's properties,
;      along with COM_Affinity / COM_AngerLevel (vanilla ActorValues).
;   2. Create a Terminal (TERM) record with body text and ONE menu item per fragment below, IN ORDER
;      (CK assigns Fragment_TerminalMenu_00, _01, ... by menu-item order).
;   3. Add the fragments in CK, then paste each ;BEGIN CODE body into the matching generated fragment.
;   4. Fill the generated script's OSFSeduceMgr property with the quest that holds OSFSeduceManager.
;   5. Give the player access however SAF did (an aid/misc item or a placed terminal that opens this
;      TERM). The terminal itself is just a settings menu -- no world placement is required for logic.
Scriptname Fragments:Terminals:TERM_OSFSeduceConfig_TEMPLATE Extends TerminalMenu Hidden Const

;BEGIN FRAGMENT Fragment_TerminalMenu_00   ; "Show current settings"
Function Fragment_TerminalMenu_00(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_01   ; "Affinity reward: ON"
Function Fragment_TerminalMenu_01(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.SetAffinityEnabled(true)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_02   ; "Affinity reward: OFF"
Function Fragment_TerminalMenu_02(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.SetAffinityEnabled(false)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_03   ; "Affinity amount +25"
Function Fragment_TerminalMenu_03(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.NudgeAffinityAmount(25.0)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_04   ; "Affinity amount -25"
Function Fragment_TerminalMenu_04(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.NudgeAffinityAmount(-25.0)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_05   ; "Anger reduction: ON"
Function Fragment_TerminalMenu_05(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.SetAngerEnabled(true)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_06   ; "Anger reduction: OFF"
Function Fragment_TerminalMenu_06(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.SetAngerEnabled(false)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_07   ; "Anger amount +5"
Function Fragment_TerminalMenu_07(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.NudgeAngerAmount(5.0)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_08   ; "Anger amount -5"
Function Fragment_TerminalMenu_08(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.NudgeAngerAmount(-5.0)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_09   ; "Reset to defaults"
Function Fragment_TerminalMenu_09(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.ResetConfigDefaults()
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_10   ; "[Debug] Reload OSF packs"
Function Fragment_TerminalMenu_10(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.ReloadPacks()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_11   ; "[Debug] Show OSF version"
Function Fragment_TerminalMenu_11(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.ShowVersion()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

OSFSeduceManager Property OSFSeduceMgr Auto Const Mandatory

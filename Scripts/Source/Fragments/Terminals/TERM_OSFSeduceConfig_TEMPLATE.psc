;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
; OSF Seduce config terminal fragment script. The terminal menu record (SeduceTerminalMenuMain,
; 0004DB) is wired DIRECTLY in the ESP (via Mutagen, not CK): its menu items have IDs 1..18 and each
; dispatches Fragment_TerminalMenu_<ID> here (so these are 1-based to match the item IDs). The menu's
; fragment-script property OSFSeduceMgr is set to SeduceMainQuest (the quest that holds OSFSeduceManager).
; The logic lives on OSFSeduceManager; these stay one-liners.
Scriptname Fragments:Terminals:TERM_OSFSeduceConfig_TEMPLATE Extends TerminalMenu Hidden Const

;BEGIN FRAGMENT Fragment_TerminalMenu_01   ; "Show current settings"
Function Fragment_TerminalMenu_01(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_02   ; "Affinity reward: ON"
Function Fragment_TerminalMenu_02(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.SetAffinityEnabled(true)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_03   ; "Affinity reward: OFF"
Function Fragment_TerminalMenu_03(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.SetAffinityEnabled(false)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_04   ; "Affinity amount +25"
Function Fragment_TerminalMenu_04(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.NudgeAffinityAmount(25.0)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_05   ; "Affinity amount -25"
Function Fragment_TerminalMenu_05(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.NudgeAffinityAmount(-25.0)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_06   ; "Anger reduction: ON"
Function Fragment_TerminalMenu_06(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.SetAngerEnabled(true)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_07   ; "Anger reduction: OFF"
Function Fragment_TerminalMenu_07(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.SetAngerEnabled(false)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_08   ; "Anger amount +5"
Function Fragment_TerminalMenu_08(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.NudgeAngerAmount(5.0)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_09   ; "Anger amount -5"
Function Fragment_TerminalMenu_09(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.NudgeAngerAmount(-5.0)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_10   ; "Strip actors: cycle inherit/off/on"
Function Fragment_TerminalMenu_10(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.CycleStripMode()
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_11   ; "Scene length: 1x (normal)"
Function Fragment_TerminalMenu_11(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.SetLoopScale(1.0)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_12   ; "Scene length: 2x"
Function Fragment_TerminalMenu_12(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.SetLoopScale(2.0)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_13   ; "Scene length: 3x"
Function Fragment_TerminalMenu_13(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.SetLoopScale(3.0)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_14   ; "Scene length: +0.25x"
Function Fragment_TerminalMenu_14(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.NudgeLoopScale(0.25)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_15   ; "Scene length: -0.25x"
Function Fragment_TerminalMenu_15(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.NudgeLoopScale(-0.25)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_16   ; "Reset to defaults"
Function Fragment_TerminalMenu_16(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.ResetConfigDefaults()
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_17   ; "[Debug] Reload OSF packs"
Function Fragment_TerminalMenu_17(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.ReloadPacks()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_18   ; "[Debug] Show OSF version"
Function Fragment_TerminalMenu_18(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.ShowVersion()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

OSFSeduceManager Property OSFSeduceMgr Auto Const Mandatory

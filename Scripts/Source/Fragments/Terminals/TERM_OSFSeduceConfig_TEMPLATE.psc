;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
; TEMPLATE — port of SAF Seduce's companion config terminal onto OSFSeduceManager.
;
; CK will generate its OWN copy of this script when you add fragments to the
; Terminal record, named Fragments:Terminals:TERM_<EditorID>_<FormID>. Either:
;   (a) create the Terminal + its menu items in CK, then paste each ;BEGIN CODE
;       body below into the matching generated fragment, OR
;   (b) rename this file to match CK's generated name and fill OSFSeduceMgr.
;
; The actual logic lives on OSFSeduceManager (version-controlled); these
; fragments are deliberately one-liners. Fill the OSFSeduceMgr property with the
; quest that has the OSFSeduceManager script.
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

;BEGIN FRAGMENT Fragment_TerminalMenu_07   ; "Anger amount +5 / -5" (wire two buttons if you want both)
Function Fragment_TerminalMenu_07(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.NudgeAngerAmount(5.0)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_08   ; "Reset to defaults"
Function Fragment_TerminalMenu_08(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.ResetConfigDefaults()
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

OSFSeduceManager Property OSFSeduceMgr Auto Const Mandatory

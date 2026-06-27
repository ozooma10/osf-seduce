;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
; Legacy companion settings terminal fragment retained by SeduceTerminalMenuCompanion
; (0004DD). The menu's fragment-script property OSFSeduceMgr must be set to
; SeduceMainQuest, which holds OSFSeduceManager.
Scriptname Fragments:Terminals:TERM_SeduceTerminalMenuCompa_010004DD Extends TerminalMenu Hidden Const

;BEGIN FRAGMENT Fragment_TerminalMenu_01   ; "Print companion settings"
Function Fragment_TerminalMenu_01(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_02   ; "Affinity change on"
Function Fragment_TerminalMenu_02(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.SetAffinityEnabled(true)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_03   ; "Affinity change off"
Function Fragment_TerminalMenu_03(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.SetAffinityEnabled(false)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_04   ; "Affinity increase up 25"
Function Fragment_TerminalMenu_04(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.NudgeAffinityAmount(25.0)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_05   ; "Affinity increase down 25"
Function Fragment_TerminalMenu_05(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.NudgeAffinityAmount(-25.0)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_06   ; "Anger change on"
Function Fragment_TerminalMenu_06(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.SetAngerEnabled(true)
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_07   ; "Anger change off"
Function Fragment_TerminalMenu_07(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.SetAngerEnabled(false)
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

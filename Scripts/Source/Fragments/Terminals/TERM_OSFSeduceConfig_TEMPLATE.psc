;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_OSFSeduceConfig_TEMPLATE Extends TerminalMenu Hidden Const

;BEGIN FRAGMENT Fragment_TerminalMenu_01
Function Fragment_TerminalMenu_01(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_03
Function Fragment_TerminalMenu_03(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.CycleStripMode()
OSFSeduceMgr.ShowConfig()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_04
Function Fragment_TerminalMenu_04(ObjectReference akTerminalRef)
;BEGIN CODE
game.getplayer().additem(Chem_SeductionPheromone, 10, false)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_05
Function Fragment_TerminalMenu_05(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.ReloadPacks()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_TerminalMenu_06
Function Fragment_TerminalMenu_06(ObjectReference akTerminalRef)
;BEGIN CODE
OSFSeduceMgr.ShowVersion()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

OSFSeduceManager Property OSFSeduceMgr Auto Const Mandatory
Potion Property Chem_SeductionPheromone Auto Const

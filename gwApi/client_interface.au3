
#include-once

#Region Windows
;~ Description: Close all in-game windows.
Func CloseAllPanels()
   Return PerformAction(0x85, 0x18)
EndFunc   ;==>CloseAllPanels

;~ Description: Toggle hero window.
Func ToggleHeroWindow()
   Return PerformAction(0x8A, 0x18)
EndFunc   ;==>ToggleHeroWindow

;~ Description: Toggle inventory window.
Func ToggleInventory()
   Return PerformAction(0x8B, 0x18)
EndFunc   ;==>ToggleInventory

;~ Description: Toggle all bags window.
Func ToggleAllBags()
   Return PerformAction(0xB8, 0x18)
EndFunc   ;==>ToggleAllBags

;~ Description: Toggle world map.
Func ToggleWorldMap()
   Return PerformAction(0x8C, 0x18)
EndFunc   ;==>ToggleWorldMap

;~ Description: Toggle options window.
Func ToggleOptions()
   Return PerformAction(0x8D, 0x18)
EndFunc   ;==>ToggleOptions

;~ Description: Toggle quest window.
Func ToggleQuestWindow()
   Return PerformAction(0x8E, 0x18)
EndFunc   ;==>ToggleQuestWindow

;~ Description: Toggle skills window.
Func ToggleSkillWindow()
   Return PerformAction(0x8F, 0x18)
EndFunc   ;==>ToggleSkillWindow

;~ Description: Toggle mission map.
Func ToggleMissionMap()
   Return PerformAction(0xB6, 0x18)
EndFunc   ;==>ToggleMissionMap

;~ Description: Toggle friends list window.
Func ToggleFriendList()
   Return PerformAction(0xB9, 0x18)
EndFunc   ;==>ToggleFriendList

;~ Description: Toggle guild window.
Func ToggleGuildWindow()
   Return PerformAction(0xBA, 0x18)
EndFunc   ;==>ToggleGuildWindow

;~ Description: Toggle party window.
Func TogglePartyWindow()
   Return PerformAction(0xBF, 0x18)
EndFunc   ;==>TogglePartyWindow

;~ Description: Toggle score chart.
Func ToggleScoreChart()
   Return PerformAction(0xBD, 0x18)
EndFunc   ;==>ToggleScoreChart

;~ Description: Toggle layout window.
Func ToggleLayoutWindow()
   Return PerformAction(0xC1, 0x18)
EndFunc   ;==>ToggleLayoutWindow

;~ Description: Toggle minions window.
Func ToggleMinionList()
   Return PerformAction(0xC2, 0x18)
EndFunc   ;==>ToggleMinionList

;~ Description: Toggle a hero panel.
Func ToggleHeroPanel($aHeroNumber)
   If $aHeroNumber < 4 Then
	  Return PerformAction(0xDB + $aHeroNumber, 0x18)
   ElseIf $aHeroNumber < 8 Then
	  Return PerformAction(0xFE + $aHeroNumber, 0x18)
   EndIf
EndFunc   ;==>ToggleHeroPanel

;~ Description: Toggle hero's pet panel.
Func ToggleHeroPetPanel($aHeroNumber)
   If $aHeroNumber < 4 Then
	  Return PerformAction(0xDF + $aHeroNumber, 0x18)
   ElseIf $aHeroNumber < 8 Then
	  Return PerformAction(0xFA + $aHeroNumber, 0x18)
   EndIf
EndFunc   ;==>ToggleHeroPetPanel

;~ Description: Toggle pet panel.
Func TogglePetPanel()
   Return PerformAction(0xDF, 0x18)
EndFunc   ;==>TogglePetPanel

;~ Description: Toggle help window.
Func ToggleHelpWindow()
   Return PerformAction(0xE4, 0x18)
EndFunc   ;==>ToggleHelpWindow
#EndRegion Windows

#Region Display
;~ Description: Display all names.
Func DisplayAll($aDisplay)
   DisplayAllies($aDisplay)
   Return DisplayEnemies($aDisplay)
EndFunc   ;==>DisplayAll

;~ Description: Display the names of allies.
Func DisplayAllies($aDisplay)
   If $aDisplay Then
	  Return PerformAction(0x89, 0x18)
   Else
	  Return PerformAction(0x89, 0x1A)
   EndIf
EndFunc   ;==>DisplayAllies

;~ Description: Display the names of enemies.
Func DisplayEnemies($aDisplay)
   If $aDisplay Then
	  Return PerformAction(0x94, 0x18)
   Else
	  Return PerformAction(0x94, 0x1A)
   EndIf
EndFunc   ;==>DisplayEnemies
#EndRegion Display

#Region Cinematic
;~ Description: Skip a cinematic.
Func SkipCinematic()
   Return SendPacket(0x4, $CtoGS_MSG_SkipCinematic)
EndFunc   ;==>SkipCinematic

;~ Description: Returns true if theres a cinematic played that can be skipped.
Func DetectCinematic()
   If MemoryRead($mCinematic) <> 0 Then
	  Dim $Cinematic = True
	  Return True
   Else
	  Dim $Cinematic = False
	  Return False
   EndIf
EndFunc

;~ Description: Sleeps until there is a cinematic to be skipped and skips then.
Func SecureSkipCinematic($aDeadlock = 60000)
   Local $lDeadlock = TimerInit()
   While Not DetectCinematic()
	  Sleep(1000)
	  If TimerDiff($lDeadlock) > $aDeadlock Then Return False ; no cinematic detected
   WEnd
   SkipCinematic()
   Do
	  Sleep(1000)
   Until Not DetectCinematic()
   Return True
EndFunc

;~ Descriptions: Waits for GetMapLoading() to return <> and then skips cinematic if detected.
Func WaitLoadingAndSkipCinematic($aDeadlock = 10000)
   Local $lDeadlock = TimerInit()
   Do
	  If TimerDiff($lDeadlock) > $aDeadlock Then Return False
	  Sleep(1000)
   Until GetMapLoading() <> 2
   $lDeadlock = TimerInit() ; reset the clock
   Do
	  If TimerDiff($lDeadlock) > $aDeadlock Then Return False
	  Sleep(1000)
   Until DetectCinematic()
   Return SkipCinematic()
EndFunc
#EndRegion Cinematic

#Region Misc
;~ Description: Changes game language to english.
Func EnsureEnglish($aEnsure)
   If $aEnsure Then
	  Return MemoryWrite($mEnsureEnglish, 1)
   Else
	  Return MemoryWrite($mEnsureEnglish, 0)
   EndIf
EndFunc   ;==>EnsureEnglish

;~ Description: Change game language.
Func ToggleLanguage()
   DllStructSetData($mToggleLanguage, 2, 0x18)
   Return Enqueue($mToggleLanguagePtr, 8)
EndFunc   ;==>ToggleLanguage

;~ Description: Take a screenshot.
Func MakeScreenshot()
   Return PerformAction(0xAE, 0x18)
EndFunc   ;==>MakeScreenshot

;~ Description: Changes the maximum distance you can zoom out.
Func ChangeMaxZoom($aZoom = 750)
   MemoryWrite($mZoomStill, $aZoom, "float")
   Return MemoryWrite($mZoomMoving, $aZoom, "float")
EndFunc   ;==>ChangeMaxZoom
#EndRegion Misc



#Region NewRendering from Tecka/4d1
Global $g__NewRenderer_Function = Ptr(0x00619BB0) ; 53 8D 0C 40 A1 (-0x2B)
Global $g__NewRenderer_Return	= Ptr($g__NewRenderer_Function + 0x3)
Global $g__NewRenderer_DetourBuffer
Global $g__NewRenderer_DetourASM

#cs
mov ebp,esp
cmp dword ptr ds:[0xABABABAB],0
jnz 0xCDCDCDCD
pop ebp
pop eax
push 0x32
push eax
jmp dword ptr ds:[0xEFEFEFEF]
#ce

Func _NewRenderer_Init()

	$g__NewRenderer_DetourBuffer = DllCall($mKernelHandle, 'ptr', 'VirtualAllocEx', 'handle', $mGWProcHandle, 'ptr', 0, 'ulong_ptr', 0x100, 'dword', 0x1000, 'dword', 0x40)[0]
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $g__DetourNewRenderer_Buffer = ' & $g__NewRenderer_DetourBuffer & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
	$g__NewRenderer_DetourASM = Ptr($g__NewRenderer_DetourBuffer + 0x4)
	Local $lASM = DllStructCreate('align 1;byte[4];ptr;byte[3];ptr;byte[7];ptr')
	DllStructSetData($lASM,1,'0x89E5833D')
	DllStructSetData($lASM,2,$g__NewRenderer_DetourBuffer)
	DllStructSetData($lASM,3,'0x000F84')
	DllStructSetData($lASM,4,$g__NewRenderer_Return - ($g__NewRenderer_DetourASM + 15))
	DllStructSetData($lASM,5,'0x5D586A6450FF25')
	DllStructSetData($lASM,6,GetValue('Sleep'))

	DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'int', $mGWProcHandle, 'int', $g__NewRenderer_DetourASM, 'struct*', $lASM, 'int', DllStructGetSize($lASM), 'int', '')

	Local $lDetour = DllStructCreate('align 1;byte;ptr;byte[4]')
	DllStructSetData($lDetour,1,0x68)
	DllStructSetData($lDetour,2,$g__NewRenderer_DetourASM)
	DllStructSetData($lDetour,3,'0xC355EBF7')

	DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'int', $mGWProcHandle, 'int', $g__NewRenderer_Function - 0x6, 'struct*', $lDetour, 'int', DllStructGetSize($lDetour), 'int', '')

EndFunc


Func _NewRenderer_SetHook($aValue)
	MemoryWrite($g__NewRenderer_DetourBuffer,Int($aValue))
EndFunc
#EndRegion NewRendering from Tecka/4d1




#Region Rendering
;~ Description: Enable graphics rendering.
Func EnableRendering($aSetState = True)
   If $aSetState Then WinSetState($mGWHwnd, "", @SW_SHOW)
   $mRendering = True
   Return _NewRenderer_SetHook($mRendering)
EndFunc   ;==>EnableRendering

;~ Description: Disable graphics rendering.
Func DisableRendering($aSetState = True)
   If $aSetState Then WinSetState($mGWHwnd, "", @SW_HIDE)
   $mRendering = False
   Return _NewRenderer_SetHook($mRendering)
EndFunc   ;==>DisableRendering

;~ Description: Turns rendering On if Off, Off if On
;~ Func ToggleRendering()
;~    If $mRendering Then
;~ 	  $mRendering = False
;~ 	  _ToggleRenderingNew()
;~    Else
;~ 	  $mRendering = True
;~ 	  _ToggleRenderingNew()
;~    EndIf
;~ EndFunc   ;==>ToggleRendering


;$mRendering = Not $mRendering
Func _ToggleRenderingNew()
$mRendering = Not $mRendering
WinSetState($mGWHwnd, '', $mRendering ? @SW_HIDE : @SW_SHOW)
Return MemoryWrite($g__NewRenderer_DetourBuffer,Int($mRendering))
EndFunc   ;==>_ToggleRendering



#EndRegion Rendering

#Region ClientMemorySize
;~ Description: Emptys client memory.
Func ClearMemory()
   Return DllCall($mKernelHandle, 'int', 'SetProcessWorkingSetSize', 'handle', $mGWProcHandle, 'int', -1, 'int', -1) <> 0
EndFunc   ;==>ClearMemory

;~ Description: Emptys client memory, if paged pool usage bigger than $aSize.
;~ $aSize in bytes -> 250mb = 262144000 bytes (250 * 1024 * 1024)
Func ClearMemoryEx($aSize = 262144000)
	Local $lTemp = DllStructCreate('dword;dword;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr')
	DllCall('psapi.dll', 'bool', 'GetProcessMemoryInfo', 'handle', $mGWProcHandle, 'struct*', $lTemp, 'int', DllStructGetSize($lTemp))
	Return ((DllStructGetData($lTemp, 4) > $aSize) ? (DllCall($mKernelHandle, 'int', 'SetProcessWorkingSetSize', 'int', $mGWProcHandle, 'int', -1, 'int', -1) <> 0) :(-1))
EndFunc

;~ Description: Toggles rendering.
;~ If $aReduceSize >= 0 then client memory will be cleared with SetProcessWorkingSetSize.
Func _PurgeHook($aReduceSize = -1)
   If Not $mRendering Then Return -1
   Update("Purging engine hook")
   _ToggleRenderingNew()
   Sleep(Random(4000, 5000))
   Local $lReturn = _ToggleRenderingNew()
   If $aReduceSize = -1 Then ; dont reduce size
	  Return $lReturn
   ElseIf $aReduceSize = 0 Then
	  Return ClearMemory()
   ElseIf $aReduceSize > 0 Then
	  Return ClearMemoryEx($aReduceSize)
   EndIf
EndFunc   ;==>_PurgeHook



;~ Func _PurgeHook($aSetState = True, $aReduceSize = -1)
;~    If $mRendering Then Return -1
;~    Update("Purging engine hook")
;~    ToggleRendering($aSetState)
;~    Sleep(Random(4000, 5000))
;~    Local $lReturn = ToggleRendering($aSetState)
;~    If $aReduceSize = -1 Then ; dont reduce size
;~ 	  Return $lReturn
;~    ElseIf $aReduceSize = 0 Then
;~ 	  Return ClearMemory()
;~    ElseIf $aReduceSize > 0 Then
;~ 	  Return ClearMemoryEx($aReduceSize)
;~    EndIf
;~ EndFunc   ;==>_PurgeHook






;~ Description: Changes the maximum memory client can use.
Func SetMaxMemory($aMemory = 15728640)
   Return DllCall($mKernelHandle, 'int', 'SetProcessWorkingSetSizeEx', 'handle', $mGWProcHandle, 'int', 1, 'int', $aMemory, 'int', 6) <> 0
EndFunc   ;==>SetMaxMemory
#EndRegion ClientMemorySize

#include-once

#Region ChatControl
;~ Description: Write a message in chat (can only be seen by botter).
Func WriteChat($aMessage, $aSender = 'GWA²')
   Local $lMessage, $lSender
   Local $lAddress = 256 * $mQueueCounter + $mQueueBase
   If $mQueueCounter = $mQueueSize Then
	  $mQueueCounter = 0
   Else
	  $mQueueCounter = $mQueueCounter + 1
   EndIf
   If StringLen($aSender) > 19 Then
	  $lSender = StringLeft($aSender, 19)
   Else
	  $lSender = $aSender
   EndIf
   MemoryWrite($lAddress + 4, $lSender, 'wchar[20]')
   If StringLen($aMessage) > 100 Then
	  $lMessage = StringLeft($aMessage, 100)
   Else
	  $lMessage = $aMessage
   EndIf
   MemoryWrite($lAddress + 44, $lMessage, 'wchar[101]')
   Local $lRet = DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'handle', $mGWProcHandle, 'ptr', $lAddress, 'ptr', $mWriteChatPtr, 'ulong_ptr', 4, 'ulong_ptr*', 0)
   If StringLen($aMessage) > 100 Then WriteChat(StringTrimLeft($aMessage, 100), $aSender)
   Return SetExtended($lRet[5], $lRet <> 0)
EndFunc   ;==>WriteChat

;~ Description: Send a whisper to another player.
Func SendWhisper($aReceiver, $aMessage)
   Local $lTotal = 'whisper ' & $aReceiver & ',' & $aMessage
   If StringLen($lTotal) > 120 Then
	  Local $lMessage = StringLeft($lTotal, 120)
   Else
	  Local $lMessage = $lTotal
   EndIf
   Local $lReturn = SendChat($lMessage, '/')
   If StringLen($lTotal) > 120 Then SendWhisper($aReceiver, StringTrimLeft($lTotal, 120))
   Return $lReturn
EndFunc   ;==>SendWhisper

;~ Description: Send a message to chat.
Func SendChat($aMessage, $aChannel = '!')
   Local $lMessage
   Local $lAddress = 256 * $mQueueCounter + $mQueueBase
   If $mQueueCounter = $mQueueSize Then
	  $mQueueCounter = 0
   Else
	  $mQueueCounter = $mQueueCounter + 1
   EndIf
   If StringLen($aMessage) > 120 Then
	  $lMessage = StringLeft($aMessage, 120)
   Else
	  $lMessage = $aMessage
   EndIf
   MemoryWrite($lAddress + 8, $aChannel & $lMessage, 'wchar[122]')
   Local $lRet = DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'handle', $mGWProcHandle, 'ptr', $lAddress, 'ptr', $mSendChatPtr, 'ulong_ptr', 8, 'ulong_ptr*', 0)
   If StringLen($aMessage) > 120 Then SendChat(StringTrimLeft($aMessage, 120), $aChannel)
   Return SetExtended($lRet[5], $lRet <> 0)
EndFunc   ;==>SendChat

;~ Description: Writes text to chat.
Func Update($aText, $aFlag = '')
   If $OldGuiText == $aText Then Return
;~    Out($aText)
   $OldGuiText = $aText
   If $WriteIGChat Then WriteChat($aText, $aFlag)
;~    ConsoleWrite($aText & @CRLF)
OUT($aText)
EndFunc   ;==>Update
#EndRegion Chat

#Region ChatSends
;~ Description: Kneel.
Func Kneel()
   Update("Kneel")
   Return SendChat('kneel', '/')
EndFunc   ;==>Kneel

;~ Description: Stuck.
Func Stuck()
   Return SendChat('stuck', '/')
EndFunc   ;==>Stuck

;~ Description: Resign.
Func Resign()
   Return SendChat('resign', '/')
EndFunc   ;==>Resign

;~ Description: Resigns and returns to main function.
Func ResignAndWaitForReturn($aTimeOut = 60000)
   Local $lOldPartyValue = MemoryRead($mBasePtr184C + 0x14)
   Sleep(3000)
   Local $lDeadlock = TimerInit()
   Update("Resigning")
   Resign()
   Do
	  If TimerDiff($lDeadlock) > $aTimeout Then Return
	  Sleep(1000)
   Until MemoryRead($mBasePtr184C + 0x14) <> $lOldPartyValue
   Sleep(1000)
   Update("Returning To Outpost")
   ReturnToOutpost()
   Return WaitMapLoading()
EndFunc   ;==>ResignAndReturn

;~ Description: Resigns and returns to main function.
Func ResignAndWaitForReturn_($aTimeOut = 60000)
   Sleep(3000)
   For $i = 1 To 10
	  Update("Resigning")
	  Resign()
	  Sleep(4000)
	  Update("Returning To Outpost")
	  ReturnToOutpost()
	  Sleep(1000)
	  If GetMapLoading() <> 1 Then ExitLoop
   Next
   For $i = 1 To 10
	  Sleep(2000)
	  If GetMapLoading() = 0 Then Return SetPointers()
   Next
EndFunc   ;==>ResignAndReturn
#EndRegion
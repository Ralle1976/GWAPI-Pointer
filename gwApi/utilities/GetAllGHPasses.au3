148
;~ #include "gwapi.au3"

Global $GHPassKeyBuffer = DllStructCreate('dword;dword;dword;dword')

;~ Initialize()

;~ RandomTravelGH()

;~ Sleep(3000)

;~ RestoreDetour()

;~ Description: Randomly travels to any gh in GuildHallArray.
Func RandomTravelGH()
   Static Local $lGuildHallArray = 0
   If $lGuildHallArray = 0 Then $lGuildHallArray = GetAllGHPasses()
   If $lGuildHallArray[0][0] = 1 Then
	  Local $lRandom = 1
   ElseIf $lGuildHallArray[0][0] <= 0 Then
	  Return
   Else
	  Local $lRandom = Random(1, $lGuildHallArray[0][0], 1)
   EndIf
   Return TravelGHEx($lGuildHallArray[$lRandom][0], $lGuildHallArray[$lRandom][1], $lGuildHallArray[$lRandom][2], $lGuildHallArray[$lRandom][3])
EndFunc

;~ Description: Travels to own gh if $aPass1 = 0, or to specified gh passes.
Func TravelGHEx($aPass1 = 0, $aPass2 = 0, $aPass3 = 0, $aPass4 = 0)
   Local $lResult = 0
   If $aPass1 = 0 Then
	  Static Local $lGHPtr = 0
	  If $lGHPtr = 0 Then
		 Local $lOffset[4] = [0, 0x18, 0x3C, 0]
		 $lGHPtr = MemoryReadPtrChain($mBasePointer, $lOffset, 'ptr')
	  EndIf
	  Local $lBuffer = DllStructCreate('dword;dword;dword;dword')
	  MemoryReadToStruct($lGHPtr + 0x64, $lBuffer)
	  $lResult = SendPacket(0x18, 0xB0, DllStructGetData($lBuffer, 1), DllStructGetData($lBuffer, 2), DllStructGetData($lBuffer, 3), DllStructGetData($lBuffer, 4), 1)  ;~ old -> 	  $lResult = SendPacket(0x18, 0xAA, DllStructGetData($lBuffer, 1), DllStructGetData($lBuffer, 2), DllStructGetData($lBuffer, 3), DllStructGetData($lBuffer, 4), 1)
   Else
	  $lResult = SendPacket(0x18, 0xB0, $aPass1, $aPass2, $aPass3, $aPass4, 1)  ;~ old -> 	  $lResult = SendPacket(0x18, 0xAA, $aPass1, $aPass2, $aPass3, $aPass4, 1)
   EndIf
   If $lResult then Return WaitMapLoading()
EndFunc

;~ Description: Return guild hall passkeys to owned guild hall in 1D array.
Func GetGuildHallPass($aGHPtr)
   Local $lReturnArray[4]
   MemoryReadToStruct($aGHPtr + 0x64, $GHPassKeyBuffer)
   $lReturnArray[0] = DllStructGetData($GHPassKeyBuffer, 1)
   $lReturnArray[1] = DllStructGetData($GHPassKeyBuffer, 2)
   $lReturnArray[2] = DllStructGetData($GHPassKeyBuffer, 3)
   $lReturnArray[3] = DllStructGetData($GHPassKeyBuffer, 4)
   Return $lReturnArray
EndFunc

;~ Description: Return guild hall visitor passkeys in 2D array. First element contains amount of passkeys.
Func GetGuildHallVisitorPasses($aGHPtr, $aVisitorPassCount = 0)
   If $aVisitorPassCount = 0 Then $aVisitorPassCount = MemoryRead($aGHPtr + 0x340, 'long')
   Local $lReturnArray[$aVisitorPassCount + 1][4]
   Local $lOffset[3] = [0x32C, 0x4, 0xA0]
   Local $lVisitorBasePtr = MemoryReadPtrChain($aGHPtr, $lOffset, 'ptr')
   For $i = 1 To $aVisitorPassCount
	  MemoryReadToStruct($lVisitorBasePtr, $GHPassKeyBuffer)
	  $lReturnArray[$i][0] = DllStructGetData($GHPassKeyBuffer, 1)
	  $lReturnArray[$i][1] = DllStructGetData($GHPassKeyBuffer, 2)
	  $lReturnArray[$i][2] = DllStructGetData($GHPassKeyBuffer, 3)
	  $lReturnArray[$i][3] = DllStructGetData($GHPassKeyBuffer, 4)
	  $lVisitorBasePtr += 0xB8
   Next
   $lReturnArray[0][0] = $aVisitorPassCount
   Return $lReturnArray
EndFunc

;~ Description: Return guild hall alliance passkeys in 2D array, except for passkey to own guild hall. First element contains amount of passkeys.
Func GetGuildHallAllianceOtherPasses($aGHPtr, $aSkipPass1 = 0)
   If $aSkipPass1 = 0 Then $aSkipPass1 = MemoryRead($aGHPtr + 0x64)
   Local $lReturnArray[11][4]
   $lReturnArray[0][0] = 0
   Local $lAllianceBasePtr = MemoryRead($aGHPtr + 0xC, 'ptr')
   Local $lTemp = MemoryRead($lAllianceBasePtr + 0x8, 'long')
   While $lTemp <= 10 And $lTemp > 0 And $lReturnArray[0][0] < 10
	  MemoryReadToStruct($lAllianceBasePtr + 0xC, $GHPassKeyBuffer)
	  If DllStructGetData($GHPassKeyBuffer, 1) <> $aSkipPass1 Then
		 $lReturnArray[0][0] = $lReturnArray[0][0] + 1
		 $lReturnArray[$lReturnArray[0][0]][0] = DllStructGetData($GHPassKeyBuffer, 1)
		 $lReturnArray[$lReturnArray[0][0]][1] = DllStructGetData($GHPassKeyBuffer, 2)
		 $lReturnArray[$lReturnArray[0][0]][2] = DllStructGetData($GHPassKeyBuffer, 3)
		 $lReturnArray[$lReturnArray[0][0]][3] = DllStructGetData($GHPassKeyBuffer, 4)
	  EndIf
	  $lAllianceBasePtr += 0x58
	  $lTemp = MemoryRead($lAllianceBasePtr + 0x8, 'long')
   WEnd
   Return $lReturnArray
EndFunc

;~ Description: Returns array with all available visitor gh passes and owned gh.
Func GetAllGHPasses($aGetAlliance = True, $aGetVisitors = True)
   ; GHPtr
   Static Local $lGHPtr = 0
   If $lGHPtr = 0 Then
	  Local $lOffset[4] = [0, 0x18, 0x3C, 0]
	  $lGHPtr = MemoryReadPtrChain($mBasePointer, $lOffset, 'ptr')
   EndIf
   ; Passkey Array -> max size = $lVisitorPassCount + 10 (alliance) + 1 (my gh) + 1
   Local $lVisitorPassCount = MemoryRead($lGHPtr + 0x340, 'long')
   Local $lPasskeyArray[$lVisitorPassCount + 12][4]
   ; My Guild Hall
   $lPasskeyArray[0][0] = 1
   Local $lTempArray = GetGuildHallPass($lGHPtr)
   $lPasskeyArray[1][0] = $lTempArray[0]
   $lPasskeyArray[1][1] = $lTempArray[1]
   $lPasskeyArray[1][2] = $lTempArray[2]
   $lPasskeyArray[1][3] = $lTempArray[3]
   ; Visitor Guild Halls
   Local $lTempArray = GetGuildHallVisitorPasses($lGHPtr, $lVisitorPassCount)
   For $i = 1 To $lTempArray[0][0]
	  $lPasskeyArray[0][0] += 1
	  $lPasskeyArray[$lPasskeyArray[0][0]][0] = $lTempArray[$i][0]
	  $lPasskeyArray[$lPasskeyArray[0][0]][1] = $lTempArray[$i][1]
	  $lPasskeyArray[$lPasskeyArray[0][0]][2] = $lTempArray[$i][2]
	  $lPasskeyArray[$lPasskeyArray[0][0]][3] = $lTempArray[$i][3]
   Next
   ; Alliance Guild Halls
   Local $lTempArray = GetGuildHallAllianceOtherPasses($lGHPtr, $lPasskeyArray[1][0])
   For $i = 1 To $lTempArray[0][0]
	  $lPasskeyArray[0][0] += 1
	  $lPasskeyArray[$lPasskeyArray[0][0]][0] = $lTempArray[$i][0]
	  $lPasskeyArray[$lPasskeyArray[0][0]][1] = $lTempArray[$i][1]
	  $lPasskeyArray[$lPasskeyArray[0][0]][2] = $lTempArray[$i][2]
	  $lPasskeyArray[$lPasskeyArray[0][0]][3] = $lTempArray[$i][3]
   Next
   ReDim $lPasskeyArray[$lPasskeyArray[0][0] + 1][4]
   Return $lPasskeyArray
EndFunc

Func GetGuildAnnouncement()
	Static $lOffset[4] = [0, 0x18, 0x3C,0x78]
	Return MemoryReadPtr($mBasePointer, $lOffset,'wchar[255]')[1]
EndFunc

Func SetGuildAnnouncement($aMsg)
	Static $lBuf = DllStructCreate('ptr;dword;dword;dword;wchar[254]')
	DllStructSetData($lBuf,1,GetValue('CommandPacketSend'))
	DllStructSetData($lBuf,2,0x208)
	DllStructSetData($lBuf,3,0xC0)
	DllStructSetData($lBuf,5,$aMsg)
	Enqueue(DllStructGetPtr($lBuf),DllStructGetSize($lBuf))
EndFunc

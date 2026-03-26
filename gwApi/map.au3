
#include-once

#Region MapLoad
;~ Description: Sets value of GetMapIsLoaded() to 0.
Func InitMapLoad()
   Return MemoryWrite($mMapIsLoaded, 0)
EndFunc   ;==>InitMapLoad

;~ Description: Returns if map has been loaded. Reset with InitMapLoad().
Func GetMapIsLoaded()
   Return MemoryRead($mMapIsLoaded) And GetAgentExists(-2)
EndFunc   ;==>GetMapIsLoaded

;~ Description: Wait for map to load. Returns true if successful.
Func WaitMapLoading($aMapID = 0, $aDeadlock = 15000)
   If $aMapID = Default Then $aMapID = 0
   If $aDeadlock = Default Then $aDeadlock = 7500
   InitMapLoad()
   Local $lDeadlock = TimerInit()
   While GetMapLoading() <> 2
	  Sleep(200)
	  If TimerDiff($lDeadlock) > $aDeadlock Then Return
   WEnd
   $lDeadlock = TimerInit()
   Do
	  Sleep(1000)
	  If TimerDiff($lDeadlock) > $aDeadlock Then Return
   Until GetMapLoading <> 2 And MemoryRead($mLoggedCounter) <> 0
   Sleep($mSleepAfterPort)
;~   IF $mRendering Then  _PurgeHook(262144000)
   If Not SetPointers() Then Return
   If GetMapLoading() = 1 Then
	  $mPartyArray = GetAgentPtrArray(2, 0xDB, 1)
   Else
	  $mMaxPartySize = GetMaxPartySize(GetMapID())
	  $mPartyArray = 0
   EndIf

   Return (($aMapID = 0) ? (True) : (GetMapID() = $aMapID))
EndFunc
#EndRegion MapLoad

#Region MapTravel
;~ Description: Map travel to an outpost.
Func TravelTo($aMapID, $aDistrict = 0, $aRegion = -1, $aLanguage = -1)
   Local $lLanguage = $aLanguage
   Local $lRegion = $aRegion
   Local $lDistrict = $aDistrict
   ; returns true if already there
   If GetMapID() = $aMapID And GetMapLoading() = 0 Then
	  If $aDistrict <= 0 And $aRegion < 0 And $aLanguage < 0 Then Return True
	  If $aDistrict > 0 Then $lDistrict = GetDistrict()
	  If $aRegion >= 0 Then $lRegion = GetRegion()
	  If $aLanguage >= 0 Then $lLanguage = GetLanguage()
	  If $aDistrict = $lDistrict And $aRegion = $lRegion And $aLanguage = $lLanguage Then Return True
   EndIf
   If $aDistrict > 0 Then
	  $lDistrict = $aDistrict
   ElseIf $lDistrict < 0 Then
	  $lDistrict = 0
   EndIf
   If $aRegion >= 0 Then
	  $lRegion = $aRegion
   ElseIf $lRegion < 0 Then
	  $lRegion = GetRegion()
   EndIf
   If $aLanguage >= 0 Then
	  $lLanguage = $aLanguage
   ElseIf $lLanguage < 0 Then
	  $lLanguage = GetLanguage()
   EndIf
   Update("Travel to map: " & $aMapID)
   If MoveMap($aMapID, $lRegion, $lDistrict, $lLanguage) Then
	  Return WaitMapLoading($aMapID)
   Else
	  Return False
   EndIf
EndFunc   ;==>TravelTo

;~ Description: Internal use for map travel.
Func MoveMap($aMapID, $aRegion, $aDistrict, $aLanguage)
   Return SendPacket(0x18, $CtoGS_MSG_TravelTo, $aMapID, $aRegion, $aDistrict, $aLanguage, False)
EndFunc   ;==>MoveMap

;~ Description: Returns to outpost after resigning/failure.
Func ReturnToOutpost()
   Return SendPacket(0x4, $CtoGS_MSG_ReturnToOutpost)
EndFunc   ;==>ReturnToOutpost

;~ Description: Switch district to on randomly chosen.
Func DistrictChange($aMapID = 0, $aUseRegions = 5, $aUseLanguages = 6)
   If $aMapID = 0 Or $aMapID = Default Then $aMapID = GetMapID()
   If $aUseRegions > 5 Or $aUseRegions = Default Then $aUseRegions = 5
   If $aUseRegions < 0 Then $aUseRegions = 0
   If $aUseLanguages > 6 Or $aUseLanguages = Default Then $aUseLanguages = 6
   If $aUseLanguages < 0 Then $aUseLanguages = 0
   Static Local $lLanguages[7] = [10, 9, 5, 4, 3, 2, 0]
   Static Local $lRegions[6] = [2, 1, 3, 4, -2, 0]
   Local $lNewRegion = 0
   Local $lNewLanguage = 0
   Local $lCurrentRegion = GetRegion()
   Local $lCurrentLanguage = -1
   If $aUseRegions > 0 And $aUseLanguages > 0 Then
	  Do
		 $lNewRegion = $lRegions[Random(0, $aUseRegions, 1)]
		 If $lNewRegion = 2 And $lCurrentRegion = 2 Then
			If $lCurrentLanguage = -1 Then $lCurrentLanguage = GetLanguage()
			Do
			   $lNewLanguage = $lLanguages[Random(0, $aUseLanguages, 1)]
			Until $lNewLanguage <> $lCurrentLanguage
		 ElseIf $lNewRegion = 2 Then
			$lNewLanguage = $lLanguages[Random(0, $aUseLanguages, 1)]
		 EndIf
	  Until $lCurrentRegion <> $lNewRegion
   EndIf
   MoveMap($aMapID, $lNewRegion, 0, $lNewLanguage)
   Return WaitMapLoading($aMapID)
EndFunc   ;==>DistrictChange
#EndRegion MapTravel

#Region EnterChallenge
;~ Description: Enter a challenge mission/pvp.
Func EnterChallenge()
   Return SendPacket(0x8, $CtoGS_MSG_EnterChallenge, 1)
EndFunc   ;==>EnterChallenge

;~ Description: Enter a foreign challenge mission/pvp.
Func EnterChallengeForeign()
   Return SendPacket(0x8, $CtoGS_MSG_EnterChallenge, 0)
EndFunc   ;==>EnterChallengeForeign

;~ Description: Enters challenge mission/pvp and waits for end of loading screen.
Func SecureEnterChallenge()
   If Not EnterChallengeForeign() Then Return
   Do
	  Sleep(1000)
   Until GetMapLoading() = 2
   Do
	  Sleep(1000)
   Until GetMapLoading() <> 2
   SetPointers()
   Return True
EndFunc
#EndRegion EnterChallenge

#Region Guildhall
;~ Description: Tries to travel to GH. Checks first if already in gh and returns false if not successful.
Func TravelGuildHall($aMapID = GetMapID())
   If CheckGuildHallMapID($aMapID) Then Return True
   TravelGH()
   Sleep(1000)
   Return CheckGuildHallMapID(GetMapID())
EndFunc   ;==>TravelGuildHall

;~ Description: Return true if MapID belongs to any Guild Hall.
Func CheckGuildHallMapID($aMapID)
   Switch $aMapID
	  Case 4, 5, 6, 52, 176, 177, 178, 179, 275, 276, 359, 360, 529, 530, 537, 538
		 Return True
   EndSwitch
EndFunc

;~ Description: Travel to your guild hall.
Func TravelGH()
   Static Local $lGHPtr = 0
   If $lGHPtr = 0 Then
	  Local $lOffset[4] = [0, 0x18, 0x3C, 0]
	  $lGHPtr = MemoryReadPtrChain($mBasePointer, $lOffset, 'ptr')
   EndIf
   MemoryReadToStruct($lGHPtr + 0x64, $GHPassKeyBuffer)
   SendPacket(0x18, $CtoGS_MSG_TravelGH, DllStructGetData($GHPassKeyBuffer, 1), DllStructGetData($GHPassKeyBuffer, 2), DllStructGetData($GHPassKeyBuffer, 3), DllStructGetData($GHPassKeyBuffer, 4), 1)
   Return WaitMapLoading()
EndFunc   ;==>TravelGH

;~ Description: Travels to own gh if $aPass1 = 0, or to specified gh passes.
Func TravelGHEx($aPass1 = 0, $aPass2 = 0, $aPass3 = 0, $aPass4 = 0)
Static $lOffset[4] = [0, 0x18, 0x3C, 0]
Local $lResult = 0
If $aPass1 = 0 Then
	Static Local $lGHPtr = 0
	MemoryReadToStruct((($lGHPtr = 0) ?  ($lGHPtr = MemoryReadPtrChain($mBasePointer, $lOffset, 'ptr')) : ($lGHPtr)) + 0x64, $GHPassKeyBuffer)
	$lResult = SendPacket(0x18, $CtoGS_MSG_TravelGH, DllStructGetData($GHPassKeyBuffer, 1), DllStructGetData($GHPassKeyBuffer, 2), DllStructGetData($GHPassKeyBuffer, 3), DllStructGetData($GHPassKeyBuffer, 4), 1)  ;~ old -> 	$lResult = SendPacket(0x18, 0xAA, DllStructGetData($GHPassKeyBuffer, 1), DllStructGetData($GHPassKeyBuffer, 2), DllStructGetData($GHPassKeyBuffer, 3), DllStructGetData($GHPassKeyBuffer, 4), 1)
Else
	$lResult = SendPacket(0x18, $CtoGS_MSG_TravelGH, $aPass1, $aPass2, $aPass3, $aPass4, 1)  ;~ old -> 	$lResult = SendPacket(0x18, 0xAA, $aPass1, $aPass2, $aPass3, $aPass4, 1)
EndIf
If $lResult then Return WaitMapLoading()
EndFunc

;~ Description: Leave your guild hall.
Func LeaveGH()
   Local $lLastMapID = MemoryRead($mLastMapID)
   If CheckGuildHallMapID($lLastMapID) Then Return ;$lLastMapID = 0
   SendPacket(0x8, $CtoGS_MSG_LeaveGH, 0x1)
   Return WaitMapLoading($lLastMapID)
EndFunc   ;==>LeaveGH
#EndRegion Guildhall

#Region MapInfo
;~ Description: Returns current load-state.
Func GetMapLoading()
   Return MemoryRead($mMapLoading)
EndFunc   ;==>GetMapLoading

;~ Description: Amount of time the current instance has been active.
Func GetInstanceUpTime()
   Static Local $lTimerPtr = 0
   If $lTimerPtr = 0 Then
	  Local $lOffset[4] = [0, 0x18, 0x8, 0x1AC]
	  $lTimerPtr = MemoryReadPtrChain($mBasePointer, $lOffset, 'ptr')
   EndIf
   Return MemoryRead($lTimerPtr)
EndFunc   ;==>GetInstanceUpTime

;~ Description: Returns current map ID.
Func GetMapID()
   Return MemoryRead($mMapID)
EndFunc   ;==>GetMapID

;~ Description: Returns current district.
Func GetDistrict()
   Static Local $lDistrictPtr = 0
   If $lDistrictPtr = 0 Then
	  Local $lOffset[4] = [0, 0x18, 0x44, 0]
	  $lDistrictPtr = MemoryReadPtrChain($mBasePointer, $lOffset, 'ptr') + 0x1B4
   EndIf
   Return MemoryRead($lDistrictPtr)
EndFunc   ;==>GetDistrict

;~ Description: Internal use for travel functions.
Func GetRegion()
   Return MemoryRead($mRegion)
EndFunc   ;==>GetRegion

;~ Description: Internal use for travel functions. Returns Language.
Func GetLanguage()
   Return MemoryRead($mLanguage)
EndFunc   ;==>GetLanguage

;~ Description: Returns number of foes that have been killed so far.
Func GetFoesKilled()
   Return MemoryRead($mBasePtr182C + 0x84C)
EndFunc   ;==>GetFoesKilled

;~ Description: Returns number of enemies left to kill for vanquish.
Func GetFoesToKill()
   Return MemoryRead($mBasePtr182C + 0x850)
EndFunc   ;==>GetFoesToKill

;~ Description: Tests if an area has been vanquished.
Func GetAreaVanquished()
   Return GetFoesToKill() = 0
EndFunc   ;==>GetAreaVanquished
#EndRegion

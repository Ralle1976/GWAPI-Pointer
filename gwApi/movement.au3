#include-once

#Region Move
;~ Description: Move to a location.
Func Move($aX, $aY, $aRandom = 50)
   If $aX = 0 Or $aY = 0 Then Return
   DllStructSetData($mMove, 2, $aX + Random(-$aRandom, $aRandom))
   DllStructSetData($mMove, 3, $aY + Random(-$aRandom, $aRandom))
   Return Enqueue($mMovePtr, 16)
EndFunc   ;==>Move

;~ Description: Move to exact location, no random number added.
Func Move_($aX, $aY)
   If $aX = 0 Or $aY = 0 Then Return
   DllStructSetData($mMove, 2, $aX)
   DllStructSetData($mMove, 3, $aY)
   Return Enqueue($mMovePtr, 16)
EndFunc   ;==>Move_

;~ Description: Move to a location and wait until you reach it.
Func MoveTo($aX, $aY, $aRandom = 50, $aMyID = GetMyID(), $aMe = GetAgentPtr($aMyID))
   If GetIsDead($aMe) Then Return False
   If $aRandom = Default Then $aRandom = 50
   Local $lBlocked = 0
   Local $lRubberbanding = 0
   Local $lAlpha = 0
   Local $lDistance, $lDistanceOld, $lOut, $lStuckX, $lStuckY
   Local $lMoveX, $lMoveY, $lMeX, $lMeY, $lNewX, $lNewY, $lOldX = 0, $lOldY = 0
   UpdateAgentPosByPtr($aMe, $lMeX, $lMeY)
   If ComputeDistance($lMeX, $lMeY, $aX, $aY) <= $aRandom Then Return True
   Local $lMapLoading = GetMapLoading(), $lMapLoadingOld
   If $lMapLoading = 2 Then Return False
   Local $lDestX = $aX + Random(-$aRandom, $aRandom)
   Local $lDestY = $aY + Random(-$aRandom, $aRandom)
   Move_($lDestX, $lDestY)
   Sleep(500 + GetPing())
   Do
	  Sleep(500)
	  If MemoryRead($aMe + 304, 'float') <= 0 Then Return False
	  $lMapLoadingOld = $lMapLoading
	  $lMapLoading = GetMapLoading()
	  If $lMapLoading <> $lMapLoadingOld Then Return False
	  UpdateAgentMoveByPtr($aMe, $lMoveX, $lMoveY)
	  If $lMoveX = 0 And $lMoveY = 0 Then ; not moving
		 UpdateAgentPosByPtr($aMe, $lMeX, $lMeY)
		 $lStuckX = $lMeX
		 $lStuckY = $lMeY
		 $lDistanceOld = ComputeDistance($lMeX, $lMeY, $lDestX, $lDestY)
		 If $lDistanceOld <= $aRandom Or $lDistanceOld <= 150 Then Return True
		 $lBlocked += 1
		 If $lBlocked > 1 Then
			If $lOldX <> $lMeX And $lOldY <> $lMeY Then
			   $lAlpha = ATan(($lMeX - $lOldX) / ($lMeY - $lOldY)) + 5.24
			Else
			   $lAlpha = 0
			EndIf
			$lOldX = $lMeX
			$lOldY = $lMeY
			$lOut = False
			For $i = 1 To 9
			   $lNewX = Sin($lAlpha) * 300 + $lMeX
			   $lNewY = Cos($lAlpha) * 300 + $lMeY
			   ConsoleWrite($lNewX & ', ' & $lNewY & @CRLF)
			   Move($lNewX, $lNewY)
			   Sleep(1000)
			   UpdateAgentPosByPtr($aMe, $lMeX, $lMeY)
			   If ComputePseudoDistance($lMeX, $lMeY, $lNewX, $lNewY) < 22500 Then
				  ConsoleWrite("Moving again." & @CRLF)
				  $lOut = True
				  ExitLoop
			   EndIf
			   $lAlpha += 0.524
			Next
			If Not $lOut And ComputePseudoDistance($lMeX, $lMeY, $lOldX, $lOldY) < 10000 Then
			   ConsoleWrite("Got really stuck." & @CRLF)
			   Return False
			EndIf
			If $lBlocked > 2 Then
			   For $i = 1 To 9
				  $lNewX = Sin($lAlpha) * 300 + $lStuckX
				  $lNewY = Cos($lAlpha) * 300 + $lStuckY
				  Move($lNewX, $lNewY)
				  Sleep(500)
				  UpdateAgentPosByPtr($aMe, $lMeX, $lMeY)
				  $lAlpha += 0.524
			   Next
			   $lNewX = Sin($lAlpha) * 300 + $lStuckX
			   $lNewY = Cos($lAlpha) * 300 + $lStuckY
			   Move_($lNewX, $lNewY)
			   Sleep(500)
			EndIf
			Move_($lDestX, $lDestY)
			Sleep(500 + GetPing())
		 EndIf
	  ElseIf Not GetMoving($aMyID) Then ; rubberbanding
		 UpdateAgentPosByPtr($aMe, $lMeX, $lMeY)
		 If ComputeDistance($lMeX, $lMeY, $lDestX, $lDestY) <= $aRandom Then Return True
		 $lRubberbanding += 1
		 If $lRubberbanding > 20 Then Return False
		 If Mod($lRubberbanding, 2) = 0 Then
			UpdateAgentPos($aMyID)
			Sleep(250)
			Move_($lDestX, $lDestY)
			Sleep(500 + GetPing())
		 EndIf
	  Else
		 $lOldX = $lMeX
		 $lOldY = $lMeY
	  EndIf
	  UpdateAgentPosByPtr($aMe, $lMeX, $lMeY)
   Until ComputeDistance($lMeX, $lMeY, $lDestX, $lDestY) <= $aRandom
   Return True
EndFunc   ;==>MoveTo

;~ Description: Updates agent position, internal use only.
Func UpdateAgentPos($aAgentID = -2)
;~    If $aAgentID = -2 Then
;~ 	  $aAgentID = GetMyID()
;~    ElseIf $aAgentID = -1 Then
;~ 	  ConsoleWrite("Cant update agent pos for target." & @CRLF)
;~ 	  Return False
;~    EndIf


   If $mAgentMovement = 0 Then $mAgentMovement = GetAgentMovementPtr()
   Local $lAgentMovementPtr = MemoryRead($mAgentMovement + 4 * ConvertID($aAgentID))

   If $lAgentMovementPtr = 0 Then
	ConsoleWrite("Error getting movement struct pointer." & @CRLF)
	Return False
   EndIf
   Local $lAgentMovementID = MemoryRead($lAgentMovementPtr + 16, 'long')


   If $lAgentMovementID <> $aAgentID Then
	  Local $lNewID = GetMyID()
	  If $lNewID <> $MyID Then SetPointers()
	  If $lNewID <> $lAgentMovementID Then
		 $mAgentMovement = GetAgentMovementPtr()
		 ConsoleWrite("Error, outdated AgentMovementPtr." & @CRLF)
		 Return False
	  EndIf
   EndIf
   If MemoryRead($lAgentMovementPtr + 60, 'long') <> 0 Then
	  ConsoleWrite("Error, we are moving again." & @CRLF)
	  Return
   EndIf

   Local Static $lBuffer = DllStructCreate('byte X[4];byte Y[4]')
   MemoryReadToStruct($lAgentMovementPtr + 120, $lBuffer)
   If DllStructGetData($lBuffer, 'X') = 0 And DllStructGetData($lBuffer, 'Y') = 0 Then
	  ConsoleWrite("Error reading movement struct." & @CRLF)
	  Return False
   EndIf
   ConsoleWrite(DllStructGetData($lBuffer, 'X') & ' | ' & DllStructGetData($lBuffer, 'Y') & @CRLF)
   DllStructSetData($mUpdateAgentPos, 2, 0x21)
   DllStructSetData($mUpdateAgentPos, 3, $aAgentID)
   DllStructSetData($mUpdateAgentPos, 4, DllStructGetData($lBuffer, 'X'))
   DllStructSetData($mUpdateAgentPos, 5, DllStructGetData($lBuffer, 'Y'))
   DllStructSetData($mUpdateAgentPos, 6, 0)
   DllStructSetData($mUpdateAgentPos, 7, 0)
   Return Enqueue($mUpdateAgentPosPtr, 28)
EndFunc   ;==>UpdateAgentPos

#Region MoveAggroing
;~ Description: Params: MoveX, MoveY, Sleep after moving. Requires UpdateWorld() variables.
Func MoveAggroing($aMoveToX, $aMoveToY, $aSleepTime = 3600000, $aMyID = GetMyID(), $aMe = GetAgentPtr($aMyID))
   If $aSleepTime = Default Then $aSleepTime = 3600000
   Local Static $WaypointCounter = 1
   Local $lBlocked = 0
   Local $lAngle = 0
   Local $lMapLoading, $MyLocation
   If GetMapLoading() = 2 Then Return False ; loading screen
   Update("Move to waypoint #" & $WaypointCounter)
   $WaypointCounter += 1
   Move($aMoveToX, $aMoveToY)
   Local $lSleepTimer = TimerInit()
   Local $lAgentArray = GetAgentPtrArray(1) ; all living
   For $i = 1 To 400
	  PingSleep(200)
	  If Mod($i, 2) = 0 Then Local $lAgentArray = GetAgentPtrArray(1) ; all living
	  If Not UpdateWorld($lAgentArray, 1350, $aMyID, $aMe) Then
		 ConsoleWrite("UpdateWorld." & @CRLF)
		 If Death($lAgentArray, $aMe) Then ExitLoop
	  EndIf
	  If Not MoveIfHurt($aMe) Then
		 ConsoleWrite("MoveIfHurt." & @CRLF)
		 If Death($lAgentArray, $aMe) Then ExitLoop
	  EndIf
	  If Not AttackRange($lAgentArray, 1350, $aMe) Then
		 ConsoleWrite("AttackRange." & @CRLF)
		 If Death($lAgentArray, $aMe) Then ExitLoop
	  EndIf
	  If Not SmartCast($aMe) Then
		 ConsoleWrite("Smartcast." & @CRLF)
		 If Death($lAgentArray, $aMe) Then ExitLoop
	  EndIf
	  If Not PickUpLoot(2, $aMyID, $aMe) Then
		 ConsoleWrite("PickUpLoot." & @CRLF)
		 If Death($lAgentArray, $aMe) Then ExitLoop
	  EndIf
	  If Not $boolRun Then
		 ConsoleWrite("ExitLoop." & @CRLF)
		 ExitLoop
	  EndIf
	  GetHealthCheck($lAgentArray)
	  Disconnected()
	  $lMapLoading = GetMapLoading()
	  If Not $SkipCinematic And $lMapLoading <> 1 Then
		 ExitLoop ; only explorable
	  EndIf
	  If $SkipCinematic And $lMapLoading <> 1 Then ; loading screen before cinematic?
		 If WaitLoadingAndSkipCinematic() Then ; skipped cinematic, probably new loading screen now
			$SkipCinematic = False
			For $i = 1 To 10
			   Sleep(1000)
			   $lMapLoading = GetMapLoading()
			   If $lMapLoading <> 2 Then ExitLoop
			Next
			SetPointers()
		 Else
			$lMapLoading = GetMapLoading()
		 EndIf
		 If $lMapLoading <> 1 Then Return ; cinematic yes or no, we are not in kansas anymore
	  EndIf
	  If $SkipCinematic And DetectCinematic() Then
		 $SkipCinematic = False
		 Return SecureSkipCinematic()
	  EndIf
	  If MemoryRead($aMe + 44, 'long') <> $aMyID Then
		 ConsoleWrite("MyID incorrect." & @CRLF)
		 ExitLoop
	  EndIf
	  $MyLocation = XandYLocation($aMe) ; returns array
	  If $mLowestEnemy = 0 And Not GetIsMoving($aMe) Then
		 $lBlocked += 1
		 Move($aMoveToX, $aMoveToY)
		 Sleep(200)
		 If Mod($lBlocked, 2) = 0 And Not GetIsMoving($aMe) Then
			$lAngle += 40
			Move($MyLocation[0] + 200 * Sin($lAngle), $MyLocation[1] + 200 * Cos($lAngle))
			PingSleep(500)
		 EndIf
	  EndIf
	  Sleep(100)
	  If ComputeDistance($aMoveToX, $aMoveToY, $MyLocation[0], $MyLocation[1]) < 200 And $EnemyAttacker = 0 Then Return True
	  If TimerDiff($lSleepTimer) > $aSleepTime Then Return False
   Next
   ConsoleWrite("Resign." & @CRLF)
   ResignAndWaitForReturn()
EndFunc   ;==>MoveAggroing

;~ Description: Returns true if agent and party is dead.
Func Death(ByRef $aAgentArray, $aAgent = GetAgentPtr(-2), $aResign = False)
   If Not IsArray($aAgentArray) Then Return
   If IsPtr($aAgent) <> 0 Then
	  Local $lAgentPtr = $aAgent
   Else
	  Local $lAgentPtr = GetAgentPtr($aAgent)
   EndIf
   Local $lPartyDead = False
   If BitAND(MemoryRead($lAgentPtr + 312, 'long'), 0x0010) Then
	  If $aAgentArray[0] <> 0 Then
		 For $i = 1 to 5
			If GetMapLoading() <> 1 Then
			   $lPartyDead = True
			   ExitLoop
			EndIf
			For $j = 1 To $aAgentArray[0]
			   If MemoryRead($aAgentArray[$j] + 433, 'byte') <> 1 Then ContinueLoop ; Allegiance
			   If BitAND(MemoryRead($aAgentArray[$j] + 312, 'long'), 0x0010) Then
				  $lPartyDead = True
			   Else
				  $lPartyDead = False
			   EndIf
			Next
			RndSleep(100)
		 Next
	  Else
		 $lPartyDead = True
	  EndIf
	  ConsoleWrite("Test2." & @CRLF)
	  If $lPartyDead And $aResign Then ResignAndWaitForReturn()
	  Return $lPartyDead
   EndIf
EndFunc   ;==>Death

;~ Description: Internal use MoveAggroing(). ---
Func AttackRange(ByRef $aAgentArray, $Distance = 1350, $aMe = GetAgentPtr(-2)) ; Cast Range
   If GetIsDead($aMe) Then Return False
   If GetMapLoading() <> 1 Then Return True
   If $mLowestEnemy <> 0 Then
	  Attack($mLowestEnemy)
   Else
	  Local $VIP = GetVIP_($aAgentArray, $Distance)
	  Local $VIPsTarget = GetTarget($VIP)
	  If $VIPsTarget > 0 Then
		 Attack($VIPsTarget)
	  EndIf
   EndIf
EndFunc   ;==>AttackRange

;~ Description: Don't Continue on while anyone has low health, Returns TRUE if all have good HP. Internal use MoveAggroing()
Func GetHealthCheck(ByRef $aAgentArray)
   Local $MoveX, $MoveY
   If $mClosestEnemy <> 0 Then Return True ; Return if someone to fight
   For $i = 1 To $aAgentArray[0]
	  If MemoryRead($aAgentArray[$i] + 433, 'byte') <> 1 Then ContinueLoop ; Allegiance
	  If MemoryRead($aAgentArray[$i] + 304, 'float') < 0.40 Then
		 Update("Waiting for party heal")
		 UpdateAgentPosByPtr($aAgentArray[$i], $MoveX, $MoveY)
		 Move($MoveX, $MoveY)
		 RndSleep(1000)
		 Return False
	  EndIf
   Next
   Return True
EndFunc   ;==>GetHealthCheck

;~ Description: Moves around if health is below 70%.
Func MoveIfHurt($aMe = GetAgentPtr(-2))
   Local $lX, $lY, $lRandom = 300, $lBlocked = 0
   If $NumberOfFoesInAttackRange < 1 Then Return True
   If GetMapLoading() <> 1 Then Return True
   If GetIsDead($aMe) Then Return False
   If GetHealth($aMe) < 0.7 Then
	  If TimerDiff($HurtTimer) > 1000 And Not GetHasDegenHex($aMe) Then
		 Local $theta = Random(0, 360)
		 $HurtTimer = TimerInit()
		 UpdateAgentPosByPtr($mHighestAlly, $lX, $lY)
		 Move(50 * Cos($theta * 0.01745) + $lX, 50 * Sin($theta * 0.01745) + $lY, 0)
		 Sleep(300)
	  EndIf
   EndIf
EndFunc   ;==>MoveIfHurt
#EndRegion MoveAggroing
#EndRegion

#Region GoTo
;~ Description: Run to or follow a player.
Func GoPlayer($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Return SendPacket(0x8, 0x2D, MemoryRead($aAgent + 44, 'long'))
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return SendPacket(0x8, 0x2D, DllStructGetData($aAgent, 'ID'))
   Else
	  Return SendPacket(0x8, 0x2D, ConvertID($aAgent))
   EndIf
EndFunc   ;==>GoPlayer

;~ Description: Talk to an NPC.
Func GoNPC($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Local $lAgentID = MemoryRead($aAgent + 44, 'long')
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Local $lAgentID = DllStructGetData($aAgent, 'ID')
   Else
	  Local $lAgentID = ConvertID($aAgent)
   EndIf
   ChangeTarget($lAgentID)
   Return SendPacket(0xC, 0x33, $lAgentID)
EndFunc   ;==>GoNPC

;~ Description: Go and talk to NPC.
;~ Author: 4D1.
Func GoNPCasm($aAgent, $aCallTarget = 0)
   If IsPtr($aAgent) Then
	  $aAgent = MemoryRead($aAgent + 44,'dword')
   Else
	  $aAgent = ConvertId($aAgent)
   EndIf
   DllStructSetData($mGoNpc, 2, $aAgent)
   DllStructSetData($mGoNpc, 3, $aCallTarget)
   Return Enqueue($mGoNpcPtr, 12)
EndFunc

;~ Description: Waits until you reach npc and talks to NPC. Uses GoNPCasm instead of Sendpacket and MoveTo.
Func GoToNPC($aAgent, $aMyID = GetMyID(), $aMe = GetAgentPtr($aMyID), $aCallTarget = 0, $aTimeOut = 30000)
   Local $lAgentPtr, $lAgentID, $lMoveX, $lMoveY, $lOldX, $lOldY, $lMeX, $lMeY, $lAlpha, $lStuckX, $lStuckY
   Local $lAgentX = 0
   Local $lAgentY = 0
   Local $lBlocked = 0
   Local $lRubberbanding = 0
   If IsPtr($aAgent) <> 0 Then
	  $lAgentPtr = $aAgent
	  $lAgentID = MemoryRead($aAgent + 44, 'long')
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  $lAgentID = DllStructGetData($aAgent, 'ID')
	  $lAgentPtr = GetAgentPtr($lAgentID)
   Else
	  $lAgentID = ConvertID($aAgent)
	  $lAgentPtr = GetAgentPtr($lAgentID)
   EndIf
   UpdateAgentPosByPtr($aMe, $lOldX, $lOldY)
   MemoryWrite($mDialogOwnerID, 0, 'word')
   If GoNPCasm($lAgentID) Then
	  Local $lAlpha
	  Local $lDeadlock = TimerInit()
	  Do
		 Sleep(250)
		 UpdateAgentPosByPtr($aMe, $lMeX, $lMeY)
		 UpdateAgentMoveByPtr($aMe, $lMoveX, $lMoveY)
		 If $lMoveX = 0 And $lMoveY = 0 Then ; not moving
			$lStuckX = $lMeX
			$lStuckY = $lMeY
			If $lAgentX = 0 Then UpdateAgentPosByPtr($lAgentPtr, $lAgentX, $lAgentY)
			Local $lDistanceOld = ComputeDistance($lMeX, $lMeY, $lAgentX, $lAgentY)
			If $lDistanceOld <= 150 Then
			   If MemoryRead($mDialogOwnerID, 'word') = $lAgentID Then Return True
			   Return GoNPC($lAgentPtr)
			EndIf
			$lBlocked += 1
			If $lBlocked > 1 Then
			   If $lOldX <> $lMeX And $lOldY <> $lMeY Then
				  $lAlpha = ATan(($lMeX - $lOldX) / ($lMeY - $lOldY)) + 5.24
			   Else
				  $lAlpha = 0
			   EndIf
			   $lOldX = $lMeX
			   $lOldY = $lMeY
			   Local $lOut = False
			   For $i = 1 To 9
				  $lNewX = Sin($lAlpha) * 300 + $lMeX
				  $lNewY = Cos($lAlpha) * 300 + $lMeY
				  Move($lNewX, $lNewY)
				  Sleep(1000)
				  UpdateAgentPosByPtr($aMe, $lMeX, $lMeY)
				  If ComputePseudoDistance($lMeX, $lMeY, $lNewX, $lNewY) < 22500 Then
					 $lOut = True
					 ExitLoop
				  EndIf
				  $lAlpha += 0.524
			   Next
			   If Not $lOut And ComputePseudoDistance($lMeX, $lMeY, $lOldX, $lOldY) < 10000 Then
				  ConsoleWrite("Got really stuck." & @CRLF)
				  Return False
			   EndIf
			   If $lBlocked > 2 Then
				  For $i = 1 To 9
					 $lNewX = Sin($lAlpha) * 300 + $lStuckX
					 $lNewY = Cos($lAlpha) * 300 + $lStuckY
					 Move($lNewX, $lNewY)
					 Sleep(500)
					 UpdateAgentPosByPtr($aMe, $lMeX, $lMeY)
					 $lAlpha += 0.524
				  Next
				  $lNewX = Sin($lAlpha) * 300 + $lStuckX
				  $lNewY = Cos($lAlpha) * 300 + $lStuckY
				  Move_($lNewX, $lNewY)
				  Sleep(500)
			   EndIf
			   Move_($lAgentX, $lAgentY)
			   Sleep(500 + GetPing())
			EndIf
		 ElseIf Not GetMoving($aMyID) Then ; rubberbanding
			UpdateAgentPosByPtr($aMe, $lMeX, $lMeY)
			If $lAgentX = 0 Then UpdateAgentPosByPtr($lAgentPtr, $lAgentX, $lAgentY)
			$lDistanceOld = ComputeDistance($lMeX, $lMeY, $lAgentX, $lAgentY)
			If $lDistanceOld <= 150 Then
			   If MemoryRead($mDialogOwnerID, 'word') = $lAgentID Then Return True
			   Return GoNPC($lAgentPtr)
			EndIf
			$lRubberbanding += 1
			If $lRubberbanding > 20 Then Return False
			If Mod($lRubberbanding, 2) = 0 Then
			   UpdateAgentPos($aMyID)
			   Sleep(250)
			   Move_($lAgentX, $lAgentY)
			   Sleep(500 + GetPing())
			EndIf
		 Else
			$lOldX = $lMeX
			$lOldY = $lMeY
		 EndIf
		 If MemoryRead($mDialogOwnerID, 'word') = $lAgentID Then Return True
	  Until TimerDiff($lDeadlock) > $aTimeOut
   EndIf
EndFunc

;~ Description: Talks to NPC and waits until you reach them. Uses Sendpacket and MoveTo.
Func GoToNPC_($aAgent, $aMyID = GetMyID(), $aMe = GetAgentPtr($aMyID))
   If IsPtr($aAgent) <> 0 Then
	  Local $lAgentID = MemoryRead($aAgent + 44, 'long')
	  Local $lAgentPtr = $aAgent
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Local $lAgentID = DllStructGetData($aAgent, 'ID')
	  Local $lAgentPtr = GetAgentPtr($lAgentID)
   Else
	  Local $lAgentID = $aAgent
	  Local $lAgentPtr = GetAgentPtr($lAgentID)
   EndIf
   Local $lAgentX, $lAgentY
   UpdateAgentPosByPtr($lAgentPtr, $lAgentX, $lAgentY)
   Local $lDistance = 100
   Do
	  $lDistance += 50
	  If $lDistance > 350 Then Return False ; cant reach
   Until MoveTo($lAgentX, $lAgentY, $lDistance, $aMyID, $aMe)
   Sleep(100)
   GoNPC($lAgentPtr)
   Sleep(500 + $lDistance)
   Return True
EndFunc   ;==>GoToNPC

;~ Description: Run to a signpost.
Func GoSignpost($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Return SendPacket(0xC, 0x4B, MemoryRead($aAgent + 44, 'long'), 0)
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return SendPacket(0xC, 0x4B, DllStructGetData($aAgent, 'ID'), 0)
   Else
	  Return SendPacket(0xC, 0x4B, ConvertID($aAgent), 0)
   EndIf
EndFunc   ;==>GoSignpost

;~ Description: Go to signpost and waits until you reach it.
Func GoToSignpost($aAgent, $aMyID = GetMyID(), $aMe = GetAgentPtr($aMyID))
   If IsPtr($aAgent) <> 0 Then
	  Local $lAgentPtr = $aAgent
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Local $lAgentID = DllStructGetData($aAgent, 'ID')
	  Local $lAgentPtr = GetAgentPtr($lAgentID)
   Else
	  Local $lAgentPtr = GetAgentPtr($aAgent)
   EndIf
   Local $lBlocked = 0, $lMeX, $lMeY, $lAgentX, $lAgentY
   Local $lMapLoading = GetMapLoading(), $lMapLoadingOld
   Local $lMoveX, $lMoveY, $lMeX, $lMeY, $lAgentX, $lAgentY
   UpdateAgentPosByPtr($lAgentPtr, $lAgentX, $lAgentY)
   Local $lDistance = 50
   Do
	  $lDistance += 50
	  If $lDistance > 300 Then Return False ; cant reach
   Until MoveTo($lAgentX, $lAgentY, $lDistance, $aMyID, $aMe)
   Sleep(100)
   GoSignpost($lAgentPtr)
   Sleep($lDistance)
   Return True
EndFunc   ;==>GoToSignpost

;~ Description: Finds NPC nearest given coords and talks to him/her.
Func GoToNPCNearestCoords($aX, $aY, $aMyID = GetMyID(), $aMe = GetAgentPtr($aMyID))
   Local $lAgent
   For $i = 1 To 20 ; about 1 sec time to retrieve npc
	  $lAgent = GetNearestNPCPtrToCoords($aX, $aY)
	  Sleep(125)
	  If $lAgent <> 0 Then
		 ChangeTarget($lAgent)
		 Return GoToNPC($lAgent, $aMyID, $aMe)
	  EndIf
   Next
EndFunc   ;==>GoToNPCNearestCoords

;~ Description: Goes to NPC with playernumber and talks to that NPC.
Func GoToNPCbyPlayernumber($aPlayernumber, $aMyID = GetMyID(), $aMe = GetAgentPtr($aMyID))
   Local $lAgentArray = GetAgentPtrArray(1)
   For $i = 1 To $lAgentArray[0]
	  If MemoryRead($lAgentArray[$i] + 244, 'word') = Int($aPlayernumber) Then
		 GoToNPC($lAgentArray[$i], $aMyID, $aMe)
		 Return Dialog(0x7F)
	  EndIf
   Next
EndFunc   ;==>GoToNPCbyPlayernumber

;~ Description: Walks to NPC nearest X, Y location and tries to donate faction. Checks luxon faction first.
Func GoLuxons($XLocation, $YLocation, $aMyID = GetMyID(), $aMe = GetAgentPtr($aMyID))
   If GetLuxonFaction() > 12000 Then
	  Update("Need to donate Luxon Faction")
	  RndSleep(Random(1000, 10000, 1))
	  Update("Talking to Luxon Scavenger")
	  GoToNPC(GetNearestAgentPtrToCoords($XLocation, $YLocation), $aMyID, $aMe)
	  Sleep(1000)
	  Do
		 Update("Donating Faction")
		 DonateFaction(1)
		 RndSleep(500)
	  Until GetLuxonFaction() < 5000
	  RndSleep(5000)
   EndIf
EndFunc   ;==>GoLuxons

;~ Description: Walks to NPC nearest X, Y location and tries to donate faction. Checks kurzick faction first.
Func GoKurzick($XLocation, $YLocation, $aMyID = GetMyID(), $aMe = GetAgentPtr($aMyID))
   If GetKurzickFaction() > 5000 Then
	  RndSleep(Random(1000, 10000, 1))
	  Update("Talking to Kurzick Scavenger")
	  MoveTo(21386, 6547, 200, $aMyID, $aMe)
	  GoToNPC(GetNearestAgentPtrToCoords($XLocation, $YLocation), $aMyID, $aMe)
	  Sleep(1000)
	  Do
		 Update("Donating Faction")
		 DonateFaction("k")
		 RndSleep(500)
	  Until GetKurzickFaction() < 5000
	  RndSleep(2000)
   EndIf
EndFunc   ;==>GoKurzick

;~ Description: Talk to priest for bounty/bonus.
;~ $aDialogs = "0x84|0x85|0x86" Or "132|133"
;~ $aBounties = "0x84|0x85" Or "132|133"
Func GrabBounty($aX, $aY, $aDialogs = False, $aBounties = False, $aMyID = GetMyID(), $aMe = GetAgentPtr($aMyID))
   GoToNPCNearestCoords($aX, $aY, $aMyID, $aMe)
   If $aDialogs <> False Then
	  Local $lDialogs = StringSplit(String($aDialogs), "|")
	  For $i = 1 To $lDialogs[0]
		 Dialog($lDialogs[$i])
		 Sleep(125)
	  Next
   EndIf
   If $aBounties <> False Then
	  Local $lBounties = StringSplit(String($aBounties), "|")
	  For $i = 1 To $lBounties[0]
		 Dialog($lBounties[$i])
		 Sleep(125)
	  Next
   EndIf
EndFunc   ;==>GrabBounty

;~ Description: Talks to Grenth in TOA and pays him 1k.
Func GetInUnderworld($aMyID = GetMyID(), $aMe = GetAgentPtr($aMyID))
   Local $lX, $lY
   Local $GrenthSpawn = 0
   Local $lMyID = GetMyID()
   Update("Move To Grenth")
   MoveTo(-4196, 19781, 50, $aMyID, $aMe)
   PingSleep(250)
   UpdateAgentPosByPtr($aMe, $lX, $lY)
   If ComputeDistance($lX, $lY, -4196, 19781) > 200 Then
	  Do
		 If MemoryRead($aMe + 44, 'long') <> $lMyID Then Return False
		 If Not GetIsMoving($aMe) Then
			MoveTo($lX, $lY, 300, $aMyID, $aMe)
			PingSleep(500)
			MoveTo(-4196, 19781, 50, $aMyID, $aMe)
		 EndIf
		 PingSleep(500)
		 UpdateAgentPosByPtr($aMe, $lX, $lY)
	  Until ComputeDistance($lX, $lY, -4196, 19781) <= 150
   EndIf
   PingSleep(250)
   Local $GrenthPtr = GetAgentPtr(83)
   While $GrenthPtr = 0
	  If Mod($GrenthSpawn, 20) = 0 Then Kneel()
	  Sleep(500)
	  $GrenthSpawn += 1
	  $GrenthPtr = GetAgentPtr(83)
   WEnd
   GoNPC($GrenthPtr)
   Sleep(125)
;~    Dialog(0x84) ; no
;~    Sleep(50) ; risk
;~    Dialog(0x85) ; no
;~    Sleep(50) ; fun
   Dialog(0x86)
   Update("Loading Underworld")
   Return WaitMapLoading(72)
EndFunc   ;==>GetInUnderworld
#EndRegion
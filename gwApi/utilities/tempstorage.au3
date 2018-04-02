#include-once

#Region Variables
Global $mBags = 4
Global $mTempStorage[1][2] = [[0, 0]]
Global $mFoundMerch = False
Global $mFoundChest = False
#EndRegion Variables

;~ Decsription: Tries to clear up one slot.
Func TempStorage()
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr
   Local $lType, $lMapState, $lSlot

   $lMapState = GetMapLoading()
   For $i = 1 To 4;(($lMapState = 0) ? (16) : ($mBags))
	  $lBagPtr = GetBagPtr($i)
	  If $lBagPtr = 0 Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $j = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $j, 'ptr')
		 If $lItemPtr = 0 Then Return True ; empty slot
		 $lType = MemoryRead($lItemPtr + 32, 'byte')
		 If $lType = 29 Then ContinueLoop ; kits

		 If $lMapState = 0 Then ; outpost
			If Not $mFoundChest Then Return False
			$lSlot = OpenStorageSlot()
			If IsArray($lSlot) Then
				$mTempStorage[0][0] += 1
				ReDim $mTempStorage[$mTempStorage[0][0] + 1][2]
				$mTempStorage[$mTempStorage[0][0]][0] = $lSlot[0]
				$mTempStorage[$mTempStorage[0][0]][1] = $lSlot[1]
				MoveItem($lItemPtr, $lSlot[0], $lSlot[1])
				Sleep(GetPing() + Random(1000, 1500, 1))
				Return True
			EndIf
		 ElseIf $lMapState = 1 Then ; explorable
			If SalvageUses() < 2 Then Return False
			If MemoryRead($lItemPtr + 75, 'byte') > 1 Then ContinueLoop
			If GetRarity($lItemPtr) <> 2621 Then ContinueLoop ; no white item
			Switch $lType
			   Case 2, 5, 12, 15, 22, 24, 26, 27, 32, 35, 36, 0
				  DropItem($lItemPtr)
				  Sleep(GetPing() + Random(1000, 1500, 1))
				  Return True
			   Case Else
				  ContinueLoop
			EndSwitch
		 EndIf
	  Next
   Next
   Return False
EndFunc   ;==>TempStorage

;~ Description: Moves temporarily relocated item back. --updated
Func RestoreStorage()
   Local $lItemPtr, $lSlot
   For $i = $mTempStorage[0][0] - 1 To 0 Step -1
	  $lItemPtr = GetItemPtrBySlot($mTempStorage[$i][0], $mTempStorage[$i][1])
	  $lSlot = OpenBackpackSlot()
	  If $lSlot = 0 Then Return False
	  ReDim $mTempStorage[$mTempStorage[0][0]][2]
	  $mTempStorage[0][0] -= 1
	  MoveItem($lItemPtr, $lSlot[0], $lSlot[1])
	  Sleep(GetPing() + Random(1000, 1500, 1))
   Next
   If $lSlot = 0 Then Return False
   Return True
EndFunc   ;==>RestoreStorage

;~ Description: Returns empty backpack slot as array.
Func OpenBackpackSlot()
   Local $lBagPtr, $lItemArrayPtr
   For $i = 1 To $mBags
	  $lBagPtr = GetBagPtr($i)
	  If $lBagPtr = 0 Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $j = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 If MemoryRead($lItemArrayPtr + 4 * $j, 'ptr') = 0 Then
			Local $lReturnArray[2] = [$i, $j]
			Return $lReturnArray
		 EndIf
	  Next
   Next
   Return 0
EndFunc   ;==>OpenBackpackSlot

;~ Description: Returns empty storage slot as array.
Func OpenStorageSlot()
   Local $lBagPtr, $lItemArrayPtr
   For $i = 8 To 16
	  $lBagPtr = GetBagPtr($i)
	  If $lBagPtr = 0 Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $j = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 If MemoryRead($lItemArrayPtr + 4 * $j, 'ptr') = 0 Then
			Local $lReturnArray[2] = [$i, $j]
			Return $lReturnArray
		 EndIf
	  Next
   Next
EndFunc   ;==>OpenStorageSlot

;~ Description: Returns bag and slot as array of ModelID, if stack not full (inventory).
;~ @extended contains quantity.
Func FindBackpackStack($aModelID)
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr, $lQuantity
   For $i = 1 To 4
	  $lBagPtr = GetBagPtr($i)
	  If $lBagPtr = 0 Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $j = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $j, 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 44, 'long') = $aModelID Then
			$lQuantity = MemoryRead($lItemPtr + 75, 'byte')
			If $lQuantity < 250 Then
			   Local $lReturnArray[2] = [$i, $j]
			   Return SetExtended($lQuantity, $lReturnArray)
			EndIf
		 EndIf
	  Next
   Next
EndFunc   ;==>FindBackpackStack

;~ Description: Returns bag and slot as array of ModelID, ExtraID, if stack is not full (storage).
;~ @extended contains quantity.
Func FindStorageStack($aModelID, $aExtraID = 0)
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr, $lQuantity
   For $i = 8 To 16
	  $lBagPtr = GetBagPtr($i)
	  If $lBagPtr = 0 Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $j = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $j, 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 44, 'long') = $aModelID Then
			$lQuantity = MemoryRead($lItemPtr + 75, 'byte')
			If $lQuantity < 250 Then
			   Local $lReturnArray[2] = [$i, $j]
			   Return SetExtended($lQuantity, $lReturnArray)
			EndIf
		 EndIf
	  Next
   Next
EndFunc   ;==>FindStorageStack

;~ Description: Checks if modelID is low in inventory and moves then items from storage.
Func GetItemFromStorageIfLow($aModelID, $MinimumAmount = 250)
   If CountItemInBagsByModelID($aModelID) < $MinimumAmount Then
	  MoveItemFromStorageByModelID_($aModelID, $MinimumAmount)
   EndIf
EndFunc   ;==>GetItemFromStorageIfLow

;~ Description: Moves item from storage and onto stack in inventory.
Func MoveItemFromStorageByModelID_($aModelID, $aAmount = 250)
   Local $lCount = CountItemInBagsByModelID($aModelID)
   If $lCount >= $aAmount Then Return True
   Local $lBagPtr, $lItemArrayPtr, $lBackslotPtr, $lItemPtr
   Local $lQuantity, $lTemp, $lMoveCount, $lSlotCount, $lTimer, $lDeadlock, $lQuantityNew
   Local $lRest = $aAmount - $lCount
   Local $lBackpackArray[46][3]
   Local $lReservedSlotCount = 0
   ; Fill $lBackpackArray with possible slots in backpack until no more space needed
   For $i = 1 To 4
	  $lBagPtr = GetBagPtr($i)
	  If $lBagPtr = 0 Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $j = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lBackslotPtr = MemoryRead($lItemArrayPtr + 4 * $j, 'ptr')
		 If $lBackslotPtr = 0 Then
			$lReservedSlotCount += 1
			$lBackpackArray[$lReservedSlotCount][0] = $i
			$lBackpackArray[$lReservedSlotCount][1] = $j + 1
			If $lRest < 250 Then
			   $lBackpackArray[$lReservedSlotCount][2] = $lRest
			Else
			   $lBackpackArray[$lReservedSlotCount][2] = 250
			EndIf
			$lRest -= 250
		 ElseIf MemoryRead($lBackslotPtr + 44, 'long') = $aModelID Then
			$lQuantity = MemoryRead($lBackslotPtr + 75, 'byte')
			If $lQuantity >= 250 Then ContinueLoop ; full stack - ignore
			$lReservedSlotCount += 1
			$lTemp = 250 - $lQuantity ; room left on stack
			If $lRest > $lTemp Then
			   $lMoveCount = $lTemp
			   $lRest -= $lTemp
			Else
			   $lMoveCount = $lRest
			   $lRest = 0
			EndIf
			$lBackpackArray[$lReservedSlotCount][0] = $i
			$lBackpackArray[$lReservedSlotCount][1] = $j + 1
			$lBackpackArray[$lReservedSlotCount][2] = $lMoveCount ; 0 -> empty slot, everything > 0 -> stack
		 EndIf
		 If $lRest <= 0 Then ExitLoop 2
	  Next
   Next
   $lBackpackArray[0][0] = $lReservedSlotCount
   $lSlotCount = 1
   ; Search Storage for stacks and move them to slots defined in $lBackpackArray while updating $lBackpackArray
   For $i = 8 To 16
	  $lBagPtr = GetBagPtr($i)
	  If $lBagPtr = 0 Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $j = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $j, 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 44, 'long') = $aModelID Then
			$lQuantity = MemoryRead($lItemPtr + 75, 'byte')
			$lTimer = TimerInit()
			While $lQuantity > $lBackpackArray[$lSlotCount][2] And $lSlotCount <= $lBackpackArray[0][0]
			   MoveItemEx($lItemPtr, $lBackpackArray[$lSlotCount][0], $lBackpackArray[$lSlotCount][1], $lBackpackArray[$lSlotCount][2])
			   $lDeadlock = TimerInit()
			   Do
				  Sleep(250)
				  $lQuantityNew = MemoryRead($lItemPtr + 75, 'byte')
				  If $lQuantityNew < $lQuantity Then
					 $lBackpackArray[$lSlotCount][2] = 0
					 $lSlotCount += 1
					 ExitLoop
				  EndIf
			   Until TimerDiff($lDeadlock) > 5000
			   $lQuantity = $lQuantityNew
			   If TimerDiff($lTimer) > 30000 Then Return -1 ; error moving
			WEnd
			If $lSlotCount > $lBackpackArray[0][0] Then Return True
			If $lQuantity > 0 And $lQuantity <= $lBackpackArray[$lSlotCount][2] Then
			   MoveItemEx($lItemPtr, $lBackpackArray[$lSlotCount][0], $lBackpackArray[$lSlotCount][1], $lQuantity)
			   $lDeadlock = TimerInit()
			   Do
				  Sleep(250)
				  If MemoryRead($lItemPtr + 12, 'ptr') <> $lBagPtr Then
					 $lBackpackArray[$lSlotCount][2] = $lBackpackArray[$lSlotCount][2] - $lQuantity
					 If $lBackpackArray[$lSlotCount][2] = 0 Then $lSlotCount += 1
					 ExitLoop
				  EndIf
			   Until TimerDiff($lDeadlock) > 5000
			EndIf
			If $lSlotCount > $lBackpackArray[0][0] Then Return True
		 EndIf
	  Next
   Next
EndFunc   ;==>MoveItemFromStorageByModelID_
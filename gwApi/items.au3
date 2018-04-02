#include-once

#Region Ptr
#Region Items
;~ Description: Returns ptr of an item.
Func GetItemPtr($aItemID)
   If $ItemBasePtr = 0 Then $ItemBasePtr = MemoryRead($mBasePtr1840 + 0xB8)
   Return MemoryRead($ItemBasePtr + 0x4 * $aItemID, 'ptr')
EndFunc   ;==>GetItemPtr

;~ Description: Returns Itemptr by Bag- and Slotnumber.
Func GetItemPtrBySlot($aBag, $aSlot)
   If IsPtr($aBag) Then
	  Local $lBagPtr = $aBag
   ElseIf IsDllStruct($aBag) Then
	  Local $lBagPtr = GetBagPtr(DllStructGetData($aBag, 'index') + 1)
   Else
	  If $aBag < 1 Or $aBag > 17 Then Return 0
	  If $aSlot < 1 Or $aSlot > GetMaxSlots($aBag) Then Return 0
	  Local $lBagPtr = GetBagPtr($aBag)
   EndIf
   Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
   Return MemoryRead($lItemArrayPtr + 4 * ($aSlot - 1), 'ptr')
EndFunc   ;==>GetItemPtrBySlot

;~ Description: Returns Itemptr by agentid.
Func GetItemPtrByAgentID($aAgentID)
   Local $lItemArraySize = MemoryRead($mBasePtr1840 + 0xC0)
   Local $lItemPtr, $lItemID, $lAgentID
   For $lItemID = 1 To $lItemArraySize
	  $lItemPtr = GetItemPtr($lItemID)
	  $lAgentID = MemoryRead($lItemPtr + 4, 'long')
	  If $lAgentID = $aAgentID Then Return $lItemPtr
   Next
EndFunc   ;==>GetItemPtrByAgentID

;~ Description: Returns Item ptr via ModelID.
Func GetItemPtrByModelID($aModelID, $aBagsOnly = False)
   Local $lItemArraySize = MemoryRead($mBasePtr1840 + 0xC0)
   Local $lItemPtr, $lItemID
   For $lItemID = 1 To $lItemArraySize
	  $lItemPtr = GetItemPtr($lItemID)
	  If MemoryRead($lItemPtr + 44, 'long') = $aModelID Then
		 If Not $aBagsOnly Then Return $lItemPtr
		 If MemoryRead($lItemPtr + 12, 'ptr') = 0 Then ContinueLoop
		 Return $lItemPtr
	  EndIf
   Next
EndFunc   ;==>GetItemPtrByModelID

;~ Description: Returns agentID of item on the ground with ModelID.
Func GetAgentIDByModelID($aModelID)
   Local $lItemArraySize = MemoryRead($mBasePtr1840 + 0xC0)
   Local $lItemPtr, $lItemID, $lAgentID
   For $lItemID = 1 To $lItemArraySize
	  $lItemPtr = GetItemPtr($lItemID)
	  If MemoryRead($lItemPtr + 44, 'long') = $aModelID Then
		 $lAgentID = MemoryRead($lItemPtr + 4, 'long')
		 If $lAgentID <> 0 Then Return $lAgentID
	  EndIf
   Next
EndFunc

;~ Description: Returns first itemptr in Bags with correct ModelID.
;~ Bags to be searched are stored in $aBagNrArray, with first Element being the amount of bags.
Func GetBagItemPtrByModelID($aModelID, ByRef Const $aBagNumberArray)
   Local $lLastQuantity = 0
   Local $lReturn = 0
   Local $lBagPtr, $lSlots, $lItemArrayPtr, $lItemPtr
   For $i = 1 to $aBagNumberArray[0]
	  $lBagPtr = GetBagPtr($aBagNumberArray[$i])
	  $lSlots = MemoryRead($lBagPtr + 32, 'long')
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To $lSlots - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $slot, 'ptr')
		 If MemoryRead($lItemPtr + 44, 'long') = $aModelID Then Return $lItemPtr
	  Next
   Next
EndFunc   ;==>GetBagItemPtrByModelID
#EndRegion Items

#Region Bags
;~ Description: Returns ptr of an inventory bag.
Func GetBagPtr($aBagNumber)
   If $BagBasePtr = 0 Then $BagBasePtr = MemoryRead($mBasePtr1840 + 0xF8)
   Return MemoryRead($BagBasePtr + 0x4 * $aBagNumber)
EndFunc   ;==>GetBagPtr

;~ Description: Returns array with existing bag's ptrs, first entry is amount of existing bags.
Func GetExistingBagPtrArray()
   Local $lBagArray[18]
   Local $lBagPtr, $lBagCount = 0
   For $i = 1 to 17
	  $lBagPtr = GetBagPtr($i)
	  If $lBagPtr <> 0 Then
		 $lBagCount += 1
		 $lBagArray[$lBagCount] = $lBagPtr
	  EndIf
   Next
   $lBagArray[0] = $lBagCount
   ReDim $lBagArray[$lBagCount+1]
   Return $lBagArray
EndFunc   ;==>GetExistingBagPtrArray
#EndRegion Bags
#EndRegion Ptr

#Region Inventory and Storage
#Region Slots
;~ Description: Returns amount of slots of bag.
Func GetMaxSlots($aBag)
   If IsPtr($aBag) Then
	  Return MemoryRead($aBag + 32, 'long')
   Else
	  Return MemoryRead(GetBagPtr($aBag) + 32, 'long')
   EndIf
EndFunc   ;==>GetMaxSlots

;~ Description: Returns amount of slots available to character.
Func GetMaxTotalSlots()
   Local $SlotCount = 0, $lBagPtr
   For $Bag = 1 to 5
	  $lBagPtr = GetBagPtr($Bag)
	  $SlotCount += MemoryRead($lBagPtr + 32, 'long')
   Next
   For $Bag = 8 to 17
	  $lBagPtr = GetBagPtr($Bag)
	  $SlotCount += MemoryRead($lBagPtr + 32, 'long')
   Next
   Return $SlotCount
EndFunc   ;==>GetMaxTotalSlots

;~ Description: Returns number of free slots in inventory.
Func CountSlots()
   Local $lCount = 0, $lBagPtr
   For $lBag = 1 To 4
	  $lBagPtr = GetBagPtr($lBag)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lCount += MemoryRead($lBagPtr + 32, 'long') - MemoryRead($lBagPtr + 16, 'long')
   Next
   Return $lCount
EndFunc   ;==>CountSlots

;~ Description: Returns number of free slots in storage.
Func CountSlotsChest()
   Local $lCount = 0, $lBagPtr
   For $lBag = 8 To 16
	  $lBagPtr = GetBagPtr($lBag)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lCount += MemoryRead($lBagPtr + 32, 'long') - MemoryRead($lBagPtr + 16, 'long')
   Next
   Return $lCount
EndFunc   ;==>CountSlotsChest
#EndRegion Slots

#Region FindItemInfo
;~ Description: Returns first empty slotnumber found or, if no empty slot is found, returns 0.
Func FindEmptySlot($aBag)
   If IsPtr($aBag) <> 0 Then
	  Local $lBagPtr = $aBag
	  Local $lSlots = MemoryRead($aBag + 32, 'long')
   ElseIf IsDllStruct($aBag) <> 0 Then
	  Local $lBagPtr = GetBagPtr(DllStructGetData($aBag, 'index') + 1)
	  Local $lSlots = DllStructGetData($aBag, 'slots')
   Else
	  Local $lBagPtr = GetBagPtr($aBag)
	  Local $lSlots = MemoryRead($lBagPtr + 32, 'long')
   EndIf
   Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
   Local $lItemPtr
   For $i = 0 To $lSlots - 1
	  $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $i, 'ptr')
	  If $lItemPtr = 0 Then Return $i + 1
   Next
EndFunc   ;==>FindEmptySlot

;~ Description: Returns amount of items in inventory with $aModelID.
Func CountInventoryItem($aModelID)
   Local $lCount = 0, $lBagPtr, $lItemArrayPtr, $lItemPtr
   For $i = 1 To 4
	  $lBagPtr = GetBagPtr($i)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $j = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $j, 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 44, 'long') = $aModelID Then $lCount += MemoryRead($lItemPtr + 75, 'byte')
	  Next
   Next
   Return $lCount
EndFunc   ;==>CountInventoryItem

;~ Description: Returns array with itemIDs of Items in Bags with correct ModelID.
Func GetBagItemIDArrayByModelID($aModelID)
   Local $lRetArr[291][3]
   Local $lCount = 0
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr, $lItemID
   For $bag = 1 to 17
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $slot, 'ptr')
		 If MemoryRead($lItemPtr + 44, 'long') = $aModelID Then
			$lItemID = MemoryRead($lItemPtr, 'long')
			$lRetArr[$lCount][0] = $lItemID
			$lRetArr[$lCount][1] = $bag
			$lRetArr[$lCount][2] = $slot + 1
			$lCount += 1
		 EndIf
	  Next
   Next
   ReDim $lRetArr[$lCount][3]
   Return $lRetArr
EndFunc   ;==>GetBagItemIDArrayByModelID

;~ Description: Returns item ID of salvage kit in inventory.
Func FindSalvageKit($aStart = 1, $aFinish = 16)
   Local $lUses = 101
   Local $lKit = 0
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr, $lValue
   For $bag = $aStart to $aFinish
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 Switch MemoryRead($lItemPtr + 44, 'long')
			Case 2992, 2993
			   $lValue = MemoryRead($lItemPtr + 36, 'short')
			   If $lValue / 2 < $lUses Then
				  $lUses = $lValue / 2
				  $lKit = MemoryRead($lItemPtr, 'long')
			   EndIf
			Case 2991
			   $lValue = MemoryRead($lItemPtr + 36, 'short')
			   If $lValue / 8 < $lUses Then
				  $lUses = $lValue / 8
				  $lKit = MemoryRead($lItemPtr, 'long')
			   EndIf
			Case 5900
			   $lValue = MemoryRead($lItemPtr + 36, 'short')
			   If $lValue / 10 < $lUses Then
				  $lUses = $lValue / 10
				  $lKit = MemoryRead($lItemPtr, 'long')
			   EndIf
		 EndSwitch
	  Next
   Next
   Return $lKit
EndFunc   ;==>FindSalvageKit

;~ Description: Returns amount of salvage uses.
Func SalvageUses($aStart = 1, $aFinish = 16)
   Local $lCount = 0
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr
   For $bag = $aStart to $aFinish
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 Switch MemoryRead($lItemPtr + 44, 'long')
			Case 2992, 2993
			   $lCount += MemoryRead($lItemPtr + 36, 'short') / 2
			Case 2991
			   $lCount += MemoryRead($lItemPtr + 36, 'short') / 8
			Case 5900
			   $lCount += MemoryRead($lItemPtr + 36, 'short') / 10
		 EndSwitch
	  Next
   Next
   Return $lCount
EndFunc   ;==>SalvageUses

;~ Description: Returns item ID of ID kit in inventory.
Func FindIDKit($aStart = 1, $aFinish = 16)
   Local $lUses = 101
   Local $lKit = 0
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr, $lValue
   For $bag = $aStart to $aFinish
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 Switch MemoryRead($lItemPtr + 44, 'long')
			Case 2989
			   $lValue = MemoryRead($lItemPtr + 36, 'short')
			   If $lValue / 2 < $lUses Then
				  $lUses = $lValue / 2
				  $lKit = MemoryRead($lItemPtr, 'long')
			   EndIf
			Case 5899
			   $lValue = MemoryRead($lItemPtr + 36, 'short')
			   If $lValue / 2.5 < $lUses Then
				  $lUses = $lValue / 2.5
				  $lKit = MemoryRead($lItemPtr, 'long')
			   EndIf
		 EndSwitch
	  Next
   Next
   Return $lKit
EndFunc   ;==>FindIDKit

;~ Description: Returns amount of ID kit uses.
Func FindIDKitUses($aStart = 1, $aFinish = 16)
   Local $lUses = 0
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr
   For $bag = $aStart to $aFinish
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 Switch MemoryRead($lItemPtr + 44, 'long')
			Case 2989
			   $lUses += MemoryRead($lItemPtr + 36, 'short') / 2
			Case 5899
			   $lUses += MemoryRead($lItemPtr + 36, 'short') / 2.5
			Case Else
			   ContinueLoop
		 EndSwitch
	  Next
   Next
   Return $lUses
EndFunc   ;==>FindIDKitUses

;~ Description: Returns amount of items of ModelID in inventory.
Func CountItemInBagsByModelID($aItemModelID)
   Local $lCount = 0
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr
   For $bag = 1 To 4
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $slot, 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 44, 'long') = $aItemModelID Then $lCount += MemoryRead($lItemPtr + 75, 'byte')
	  Next
   Next
   Return $lCount
EndFunc   ;==>CountItemInBagsByModelID

;~ Description: Returns amount of items of ModelID in storage.
Func CountItemInStorageByModelID($aItemModelID) ; Bag 6 is Material Storage, which is not included
   Local $lCount = 0
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr
   For $bag = 8 To 16
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $slot, 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 44, 'long') = $aItemModelID Then $lCount += MemoryRead($lItemPtr + 75, 'byte')
	  Next
   Next
   Return $lCount
EndFunc   ;==>CountItemInStorageByModelID

;~ Description: Returns amount of items of ModelID.
Func CountItemTotalByModelID($aItemModelID, $aIncludeMats = True)
   Local $lCount = 0
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr
   If $aIncludeMats Then
	  Local $lBagSearch[15] = [14,1,2,3,4,5,6,8,10,11,12,13,14,15,16]
   Else
	  Local $lBagSearch[14] = [13,1,2,3,4,5,8,10,11,12,13,14,15,16]
   EndIf
   For $i = 1 To $lBagSearch[0]
	  $lBagPtr = GetBagPtr($lBagSearch[$i])
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $slot, 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 44, 'long') = $aItemModelID Then $lCount += MemoryRead($lItemPtr + 75, 'byte')
	  Next
   Next
   Return $lCount
EndFunc   ;==>CountItemTotalByModelID
#EndRegion FindItemInfo

#Region Salvage
;~ Description: Starts a salvaging session of an item.
Func StartSalvage($aItem, $aSalvageKitID = 0)
   If IsPtr($aItem) <> 0 Then
	  Local $lItemID = MemoryRead($aItem, 'long')
   ElseIf IsDllStruct($aItem) <> 0 Then
	  Local $lItemID = DllStructGetData($aItem, 'ID')
   Else
	  Local $lItemID = $aItem
   EndIf
   Local $lSalvageSessionID = MemoryRead($mBasePtr182C + 0x690)
   If $aSalvageKitID = 0 Then
	  Local $lSalvageKitID = FindSalvageKit()
   Else
	  Local $lSalvageKitID = $aSalvageKitID
   EndIf
   ConsoleWrite("$lSalvageKitID = " & $lSalvageKitID & @CRLF)
   If $lSalvageKitID = 0 Then Return False
   DllStructSetData($mSalvage, 2, $lItemID)
   DllStructSetData($mSalvage, 3, $lSalvageKitID)
   DllStructSetData($mSalvage, 4, $lSalvageSessionID)
   If Not Enqueue($mSalvagePtr, 16) Then Return False
   Return SetExtended($lSalvageSessionID, $lSalvageKitID)
EndFunc   ;==>StartSalvage
;~ Description: Salvage the materials out of an item.
Func SalvageMaterials()
   Return SendPacket(0x4, 0x74)
EndFunc   ;==>SalvageMaterials


Func StartSalvageWithPacket($aItem, $aSalvageKitID = 0)
;~ Start Salvage
;~ Size = 16		Header = 113		Value Of Elements = 5
;~ 0x10, 0x71, 0x15, 0x6A, 0x5D

If IsPtr($aItem) <> 0 Then
	Local $lItemID = MemoryRead($aItem, 'long')
Else
	Local $lItemID = $aItem
EndIf

Local $lSalvageSessionID = MemoryRead($mBasePtr182C + 0x690)

If $aSalvageKitID = 0 Then
	  Local $lSalvageKitID = FindSalvageKit()
Else
	  Local $lSalvageKitID = $aSalvageKitID
EndIf

ConsoleWrite("$lSalvageKitID = " & $lSalvageKitID & @CRLF)

If $lSalvageKitID = 0 Then Return False
SendPacket(0x10, 0x71, $lItemID, $lSalvageKitID, $lSalvageSessionID)

EndFunc   ;==>StartSalvage

;~ Description: Salvages a mod out of an item.
;~ ModIndex: 0 -> Insignia, 1 -> Rune for armor upgrades.
Func SalvageMod($aModIndex)
;~ If $aModIndex > 0 Then
	SendPacket(0x8, 0x75, $aModIndex)
;~ 	Sleep(GetPing()+ 250)
;~ EndIf

;~ SendPacket(0x4, 0x73)
EndFunc   ;==>SalvageMod

Func Chancel()
Return SendPacket(0x4, 0x72)
EndFunc
#EndRegion Salvage

#Region ItemActions
;~ Description: Identifies an item.
Func IdentifyItem($aItem, $aIDKit = 0)
   If IsPtr($aItem) <> 0 Then
	  Local $lItemID = MemoryRead($aItem, 'long')
   ElseIf IsDllStruct($aItem) <> 0 Then
	  Local $lItemID = DllStructGetData($aItem, 'ID')
   Else
	  Local $lItemID = $aItem
   EndIf
   If $aIDKit = 0 Then
	  Local $lIDKit = FindIDKit()
   Else
	  Local $lIDKit = $aIDKit
   EndIf
   If $lIDKit = 0 Then Return False
   Local $lTimer = TimerInit()
   Local $lDeadlock
   While GetIsUnIDed($aItem) And TimerDiff($lTimer) < 30000
	  SendPacket(0xC, 0x66, $lIDKit, $lItemID)
	  $lDeadlock = TimerInit()
	  Do
		 Sleep(250)
		 If GetIsIDed($aItem) Then Return True
	  Until TimerDiff($lDeadlock) > 5000
   WEnd
EndFunc   ;==>IdentifyItem

;~ Description: Equips an item.
Func EquipItem($aItem)
   If IsPtr($aItem) <> 0 Then
	  Return SendPacket(0x8, 0x2A, MemoryRead($aItem, 'long'))
   ElseIf IsDllStruct($aItem) <> 0 Then
	  Return SendPacket(0x8, 0x2A, DllStructGetData($aItem, 'ID'))
   Else
	  Return SendPacket(0x8, 0x2A, $aItem)
   EndIf
EndFunc   ;==>EquipItem

;~ Description: Uses an item.
Func UseItem($aItem)
   If IsPtr($aItem) <> 0 Then
	  Return SendPacket(0x8, 0x78, MemoryRead($aItem, 'long'))
   ElseIf IsDllStruct($aItem) <> 0 Then
	  Return SendPacket(0x8, 0x78, DllStructGetData($aItem, 'ID'))
   Else
	  Return SendPacket(0x8, 0x78, $aItem)
   EndIf
EndFunc   ;==>UseItem

;~ Description: Drops an item.
Func DropItem($aItem, $aAmount = 0)
   If IsPtr($aItem) <> 0 Then
	  If $aAmount = 0 Then $aAmount = MemoryRead($aItem + 75, 'byte')
	  Return SendPacket(0xC, 0x26, MemoryRead($aItem, 'long'), $aAmount)
   ElseIf IsDllStruct($aItem) <> 0 Then
	  If $aAmount = 0 Then $aAmount = DllStructGetData($aItem, 'Quantity')
	  Return SendPacket(0xC, 0x26, DllStructGetData($aItem, 'ID'), $aAmount)
   Else
	  If $aAmount = 0 Then $aAmount = MemoryRead(GetItemPtr($aItem) + 75, 'byte')
	  Return SendPacket(0xC, 0x26, $aItem, $aAmount)
   EndIf
EndFunc   ;==>DropItem

;~ Description: Moves an item.
Func MoveItem($aItem, $aBag, $aSlot)
   If IsPtr($aItem) <> 0 Then
	  Local $lItemID = MemoryRead($aItem, 'long')
   ElseIf IsDllStruct($aItem) <> 0 Then
	  Local $lItemID = DllStructGetData($aItem, 'ID')
   Else
	  Local $lItemID = $aItem
   EndIf
   If IsPtr($aBag) <> 0 Then
	  Local $lBagID = MemoryRead($aBag + 8, 'long')
   ElseIf IsDllStruct($aBag) <> 0 Then
	  Local $lBagID = DllStructGetData($aBag, 'ID')
   Else
	  Local $lBagID = MemoryRead(GetBagPtr($aBag) + 8, 'long')
   EndIf
   Return SendPacket(0x10, 0x6C, $lItemID, $lBagID, $aSlot - 1)
EndFunc   ;==>MoveItem

;~ Description: Moves an item, with amount to be moved.
Func MoveItemEx($aItem, $aBag, $aSlot, $aAmount)
   If IsPtr($aItem) <> 0 Then
	  Local $lItemID = MemoryRead($aItem, 'long')
	  Local $lQuantity = MemoryRead($aItem + 75, 'byte')
   ElseIf IsDllStruct($aItem) <> 0 Then
	  Local $lItemID = DllStructGetData($aItem, 'ID')
	  Local $lQuantity = DllStructGetData($aItem, 'Quantity')
   Else
	  Local $lItemID = $aItem
	  Local $lQuantity = MemoryRead(GetItemPtr($aItem) + 75, 'byte')
   EndIf
   If IsPtr($aBag) <> 0 Then
	  Local $lBagID = MemoryRead($aBag + 8, 'long')
   ElseIf IsDllStruct($aBag) <> 0 Then
	  Local $lBagID = DllStructGetData($aBag, 'ID')
   Else
	  Local $lBagID = MemoryRead(GetBagPtr($aBag) + 8, 'long')
   EndIf
   If $lQuantity > $aAmount Then $lQuantity = $aAmount
   Return SendPacket(0x14, 0x6F, $lItemID, $lQuantity, $lBagID, $aSlot - 1)
EndFunc   ;==>MoveItemEx

;~ Description: Unequips item to $abag, $aslot (1-based).
;~ Equipmentslots:	1 -> Mainhand/Two-hand
;~ 			    	2 -> Offhand
;~ 					3 -> Chestpiece
;~ 					4 -> Leggings
;~ 					5 -> Headpiece
;~ 					6 -> Boots
;~ 					7 -> Gloves
Func UnequipItem($aEquipmentSlot, $aBag, $aSlot)
   If IsPtr($aBag) Then
	  Local $lBagID = MemoryRead($aBag + 8, 'long')
   ElseIf IsDllStruct($aBag) Then
	  Local $lBagID = DllStructGetData($aBag, 'ID')
   Else
	  Local $lBagID = MemoryRead(GetBagPtr($aBag) + 8, 'long')
   EndIf
   Return SendPacket(0x10, 0x49, $aEquipmentSlot - 1, $lBagID, $aSlot - 1)
EndFunc   ;==>UnequipItem

;~ Description: Destroys an item.
Func DestroyItem($aItem)
   If IsPtr($aItem) <> 0 Then
	  Return SendPacket(0x8, 0x63, MemoryRead($aItem, 'long'))
   ElseIf IsDllStruct($aItem) <> 0 Then
	  Return SendPacket(0x8, 0x63, DllStructGetData($aItem, 'ID'))
   Else
	  Return SendPacket(0x8, 0x63, $aItem)
   EndIf
EndFunc   ;==>DestroyItem

;~ Description: Accepts unclaimed items after a mission.
Func AcceptAllItems()
   Return SendPacket(0x8, 0x6D, MemoryRead(GetBagPtr(7) + 8, 'long'))
EndFunc   ;==>AcceptAllItems
#EndRegion ItemActions
#EndRegion Inventory and Storage

#Region Merchants
;~ Description: Sells an item.
Func SellItem($aItem, $aQuantity = 0)
   If IsPtr($aItem) <> 0 Then
	  Local $lItemID = MemoryRead($aItem, 'long')
	  Local $lQuantity = MemoryRead($aItem + 75, 'byte')
	  Local $lValue = MemoryRead($aItem + 36, 'short')
   ElseIf IsDllStruct($aItem) <> 0 Then
	  Local $lItemID = DllStructGetData($aItem, 'ID')
	  Local $lQuantity = DllStructGetData($aItem, 'Quantity')
	  Local $lValue = DllStructGetData($aItem, 'Value')
   Else
	  Local $lItemID = $aItem
	  Local $lItemPtr = GetItemPtr($aItem)
	  Local $lQuantity = MemoryRead($lItemPtr + 75, 'byte')
	  Local $lValue = MemoryRead($lItemPtr + 36, 'short')
   EndIf
   If $aQuantity = 0 Or $aQuantity > $lQuantity Then $aQuantity = $lQuantity
   DllStructSetData($mSellItem, 2, $aQuantity * $lValue)
   DllStructSetData($mSellItem, 3, $lItemID)
   Return Enqueue($mSellItemPtr, 12)
EndFunc   ;==>SellItem

#Region BuyItem
;~ Description: Buys an item.
Func BuyItem($aItemRow, $aQuantity, $aValue)
   Local $lMerchantItemsBase = GetMerchantItemsBase()
   If Not $lMerchantItemsBase Then Return
   If $aItemRow < 1 Or $aItemRow > GetMerchantItemsSize() Then Return
   DllStructSetData($mBuyItem, 2, $aQuantity)
   DllStructSetData($mBuyItem, 3, MemoryRead($lMerchantItemsBase + 4 * ($aItemRow - 1)))
   DllStructSetData($mBuyItem, 4, $aQuantity * $aValue)
   Return Enqueue($mBuyItemPtr, 16)
EndFunc   ;==>BuyItem

;~ Description: Internal use for BuyItem()
Func GetMerchantItemsBase()
   Return MemoryRead($mBasePtr182C + 0x24)
EndFunc   ;==>GetMerchantItemsBase

;~ Description: Internal use for BuyItem()
Func GetMerchantItemsSize()
   Return MemoryRead($mBasePtr182C + 0x28)
EndFunc   ;==>GetMerchantItemsSize

;~ Description: Buys an ID kit.
Func BuyIDKit($aAmount = 1)
   Local $lItemIDRow = GetItemRowByModelID(2989)
   If $lItemIDRow = 0 Then Return ; no id kit
   Local $lItemPtr = GetItemPtr($lItemIDRow)
   Local $lValue = MemoryRead($lItemPtr + 36, 'short') * 2
   DllStructSetData($mBuyItem, 2, $aAmount)
   DllStructSetData($mBuyItem, 3, $lItemIDRow)
   DllStructSetData($mBuyItem, 4, $lValue * $aAmount)
   ConsoleWrite($mBuyItemPtr & @CRLF)
   Return SetExtended($lItemPtr, Enqueue($mBuyItemPtr, 16))
EndFunc   ;==>BuyIDKit

;~ Description: Buys a superior ID kit.
Func BuySuperiorIDKit($aAmount = 1)
   Local $lItemIDRow = GetItemRowByModelID(5899)
   If $lItemIDRow = 0 Then Return ; no id kit
   Local $lItemPtr = GetItemPtr($lItemIDRow)
   Local $lValue = MemoryRead($lItemPtr + 36, 'short') * 2
   DllStructSetData($mBuyItem, 2, $aAmount)
   DllStructSetData($mBuyItem, 3, $lItemIDRow)
   DllStructSetData($mBuyItem, 4, $lValue * $aAmount)
   Return SetExtended($lItemPtr, Enqueue($mBuyItemPtr, 16))
EndFunc   ;==>BuySuperiorIDKit

;~ Description: Buys 3 Salvage Kits.
Func BuySalvageKitThree()
   Return BuySalvageKit(3)
EndFunc   ;==>BuySalvageKitThree

;~ Description: Buys 2 Salvage Kits.
Func BuySalvageKitTwo()
   Return BuySalvageKit(2)
EndFunc   ;==>BuySalvageKitTwo

;~ Description: Buys 1 Salvage Kits.
Func BuySalvageKit($aAmount = 1)
   Local $lItemIDRow = GetItemRowByModelID(2992)
   If $lItemIDRow = 0 Then
	  $lItemIDRow = GetItemRowByModelID(2993)
	  If $lItemIDRow = 0 Then Return
   EndIf
   Local $lItemPtr = GetItemPtr($lItemIDRow)
   Local $lValue = MemoryRead($lItemPtr + 36, 'short') * 2
   DllStructSetData($mBuyItem, 2, $aAmount)
   DllStructSetData($mBuyItem, 3, $lItemIDRow)
   DllStructSetData($mBuyItem, 4, $aAmount * $lValue)
   Return SetExtended($lItemPtr, Enqueue($mBuyItemPtr, 16))
EndFunc   ;==>BuySalvageKit
#EndRegion Buy

#Region BuyItemByModelID
;~ Description: Buys an item by modelid instead of row.
Func BuyItemByModelID($aModelID, $aQuantity, $aValue)
   Local $lItemIDRow = GetItemRowByModelID($aModelID)
   DllStructSetData($mBuyItem, 2, $aQuantity)
   DllStructSetData($mBuyItem, 3, $lItemIDRow)
   DllStructSetData($mBuyItem, 4, $aQuantity * $aValue)
   Return Enqueue($mBuyItemPtr, 16)
EndFunc   ;==>BuyItemByModelID

;~ Description: Internal Use CraftItem and BuyItemByModelID.
Func GetItemRowByModelID($aModelID)
   Local $lItemArraySize = MemoryRead($mBasePtr182C + 0x28)
   Local $lMerchantBase = MemoryRead($mBasePtr182C + 0x24)
   Local $lItemID, $lItemPtr
   For $i = 0 To $lItemArraySize - 1
	  $lItemID = MemoryRead($lMerchantBase + 4 * $i)
	  $lItemPtr = GetItemPtr($lItemID)
	  If $lItemPtr = 0 Then ContinueLoop
	  If MemoryRead($lItemPtr + 44, 'long') = $aModelID And MemoryRead($lItemPtr + 64, 'long') = 2 Then
		 Return MemoryRead($lItemPtr, 'long')
	  EndIf
   Next
EndFunc   ;==>GetItemRowByModelID
#EndRegion CraftItemEx & BuyItemByModelID

#Region Trader
;~ Description: Request a quote to buy an item from a trader. Returns true if successful.
Func TraderRequest($aModelID, $aExtraID = -1)
   Local $lItemArraySize = MemoryRead($mBasePtr182C + 0x28)
   Local $lMerchantBase = MemoryRead($mBasePtr182C + 0x24)
   Local $lItemPtr = 0, $lItemID = 0
   Local $lFound = False
   For $i = 0 To $lItemArraySize - 1
	  $lItemID = MemoryRead($lMerchantBase + 4 * $i)
	  $lItemPtr = GetItemPtr($lItemID)
	  If $lItemPtr = 0 Then ContinueLoop
	  If MemoryRead($lItemPtr + 44, 'long') = $aModelID And MemoryRead($lItemPtr + 12, 'ptr') = 0 And MemoryRead($lItemPtr + 4, 'long') = 0 Then
		 ConsoleWrite("Trader request found modelid." & @CRLF)
		 If $aExtraID = -1 Or MemoryRead($lItemPtr + 34, 'short') = $aExtraID Then
			$lFound = True
			ExitLoop
		 EndIf
	  EndIf
   Next
   If Not $lFound Then Return False
   Local $lQuoteID = MemoryRead($mTraderQuoteID)
   DllStructSetData($mRequestQuote, 2, $lItemID)
   If Not Enqueue($mRequestQuotePtr, 8) Then Return False
   Local $lDeadlock = TimerInit()
   Do
	  Sleep(100)
	  If MemoryRead($mTraderQuoteID) <> $lQuoteID Then Return True
   Until TimerDiff($lDeadlock) > GetPing() + 5000
EndFunc   ;==>TraderRequest

;~ Description: Request a quote to buy an item from a trader. Returns true if successful.
Func TraderRequest_($aModelID, $aExtraID = -1)
   Local $lItemArraySize = MemoryRead($mBasePtr1840 + 0xC0)
   Local $lItemPtr = 0
   Local $lFound = False
   Local $lQuoteID = MemoryRead($mTraderQuoteID)
   For $lItemID = 1 To $lItemArraySize
	  $lItemPtr = GetItemPtr($lItemID)
	  If $lItemPtr = 0 Then ContinueLoop
	  If MemoryRead($lItemPtr + 44, 'long') = $aModelID Then
		 ConsoleWrite("Trader request found modelid." & @CRLF)
		 If MemoryRead($lItemPtr + 12, 'ptr') = 0 And MemoryRead($lItemPtr + 4, 'long') = 0 Then
			If $aExtraID = -1 Or MemoryRead($lItemPtr + 34, 'short') = $aExtraID Then
			   $lFound = True
			   ExitLoop
			EndIf
		 EndIf
	  EndIf
   Next
   If Not $lFound Then Return False
   DllStructSetData($mRequestQuote, 2, $lItemID)
   If Not Enqueue($mRequestQuotePtr, 8) Then Return False
   Local $lDeadlock = TimerInit()
   Do
	  Sleep(100)
	  If MemoryRead($mTraderQuoteID) <> $lQuoteID Then Return True
   Until TimerDiff($lDeadlock) > GetPing() + 5000
EndFunc   ;==>TraderRequest

;~ Description: Request a quote to buy a rune from a trader. Returns true if successful.
Func RuneRequestBuy($aModelID, $aModStruct)
   Local $lItemArraySize = MemoryRead($mBasePtr1840 + 0xC0)
   Local $lItemPtr = 0
   Local $lModStruct = 0
   Local $lBuffer = DllStructCreate('ptr;long')
   Local $lFound = False
   Local $lQuoteID = MemoryRead($mTraderQuoteID)
   For $lItemID = 1 To $lItemArraySize
	  $lItemPtr = GetItemPtr($lItemID)
	  If MemoryRead($lItemPtr + 44, 'long') = $aModelID Then
		 If MemoryRead($lItemPtr + 12, 'ptr') <> 0 Then ContinueLoop
		 MemoryReadToStruct($lItemPtr + 16, $lBuffer)
		 $lModStruct = MemoryRead(DllStructGetData($lBuffer, 1), 'byte[' & DllStructGetData($lBuffer, 2) * 4 & ']')
		 If StringInStr($lModStruct, $aModStruct) <> 0 Then
			$lFound = True
			ExitLoop
		 EndIf
	  EndIf
   Next
   If Not $lFound Then Return -1
   DllStructSetData($mRequestQuote, 2, $lItemID)
   If Not Enqueue($mRequestQuotePtr, 8) Then Return False
   Local $lDeadlock = TimerInit()
   Do
	  Sleep(100)
	  If MemoryRead($mTraderQuoteID) <> $lQuoteID Then Return True
   Until TimerDiff($lDeadlock) > GetPing() + 5000
   Return -2
EndFunc   ;==>RuneRequestBuy

;~ Description: Buy the requested item.
Func TraderBuy()
   If Not GetTraderCostID() Or Not GetTraderCostValue() Then Return False
   Return Enqueue($mTraderBuyPtr, 4)
EndFunc   ;==>TraderBuy

;~ Description: Request a quote to sell an item to the trader.
Func TraderRequestSell($aItem)
   If IsPtr($aItem) <> 0 Then
	  Local $lItemID = MemoryRead($aItem, 'long')
   ElseIf IsDllStruct($aItem) <> 0 Then
	  Local $lItemID = DllStructGetData($aItem, 'ID')
   Else
	  Local $lItemID = $aItem
   EndIf
   Local $lFound = False
   Local $lQuoteID = MemoryRead($mTraderQuoteID)
   DllStructSetData($mRequestQuoteSell, 2, $lItemID)
   Enqueue($mRequestQuoteSellPtr, 8)
   Local $lDeadlock = TimerInit()
   Do
	  Sleep(20)
	  $lFound = MemoryRead($mTraderQuoteID) <> $lQuoteID
   Until $lFound Or TimerDiff($lDeadlock) > GetPing() + 5000
   Return $lFound
EndFunc   ;==>TraderRequestSell

;~ Description: ID of the item item being sold.
Func TraderSell()
   If Not GetTraderCostID() Or Not GetTraderCostValue() Then Return False
   Return Enqueue($mTraderSellPtr, 4)
EndFunc   ;==>TraderSell

;~ Description: Returns the item ID of the quoted item.
Func GetTraderCostID()
   Return MemoryRead($mTraderCostID)
EndFunc   ;==>GetTraderCostID

;~ Description: Returns the cost of the requested item.
Func GetTraderCostValue()
   Return MemoryRead($mTraderCostValue)
EndFunc   ;==>GetTraderCostValue
#EndRegion Trader
#EndRegion

#Region PickingUp
;~ Description: Picks up an item, requires AgentID.
Func PickUpItem($aAgentID)
   If IsPtr($aAgentID) <> 0 Then
	  Return SendPacket(0xC, 0x39, MemoryRead($aAgentID + 44, 'long'), 0)
   ElseIf IsDllStruct($aAgentID) <> 0 Then
	  Return SendPacket(0xC, 0x39, DllStructGetData($aAgentID, 'ID'), 0)
   Else
	  Return SendPacket(0xC, 0x39, ConvertID($aAgentID), 0)
   EndIf
EndFunc   ;==>PickUpItem

;~ Description: Picks up loot that has been specified in PickUpList().
Func PickUpLoot($aMinSlots = 2, $aMyID = GetMyID(), $aMe = GetAgentPtr($aMyID))
   Local $lMeX, $lMeY, $lAgentX, $lAgentY
   Local $lSlots = CountSlots()
   Local $lAgentArray = GetSortedItemPtrArray($aMe, 0x400)
   Local $lItemPtr, $lAgentID, $lItemType, $lDistance, $lOwner, $lItemMID
   For $i = 1 To $lAgentArray[0][0]
	  If GetIsDead($aMe) Then Return False ; died, cant pick up items dead
	  If GetMapLoading() <> 1 Then Return True ; not in explorable -> no items to pick up
	  $lAgentID = MemoryRead($lAgentArray[$i][0] + 44, 'long')
	  $lItemPtr = GetItemPtrByAgentID($lAgentID)
	  If $lItemPtr = 0 Then ContinueLoop
	  $lItemType = MemoryRead($lItemPtr + 32, 'byte')
	  If $lItemType = 20 Then ; coins
		 UpdateAgentPosByPtr($lAgentArray[$i][0], $lAgentX, $lAgentY)
		 UpdateAgentPosByPtr($aMe, $lMeX, $lMeY)
		 $lDistance = Sqrt(($lMeX - $lAgentX) ^ 2 + ($lMeY - $lAgentY) ^ 2)
		 PickUpItems($lAgentArray[$i][0], $lAgentID, $lAgentX, $lAgentY, $lDistance, $aMe)
	  EndIf
	  If $lItemType = 6 Then ; quest items / bundles
		 If $mPickUpBundles Then
			UpdateAgentPosByPtr($lAgentArray[$i][0], $lAgentX, $lAgentY)
			UpdateAgentPosByPtr($aMe, $lMeX, $lMeY)
			$lDistance = Sqrt(($lMeX - $lAgentX) ^ 2 + ($lMeY - $lAgentY) ^ 2)
			PickUpItems($lAgentArray[$i][0], $lAgentID, $lAgentX, $lAgentY, $lDistance, $aMe)
		 Else
			ContinueLoop
		 EndIf
	  EndIf
	  If $lSlots < $aMinSlots Then ; inventory is full
		 If $lItemType <> 6 And $lItemType <> 20 Then Return False ; quest items and coins
	  EndIf
	  $lOwner = MemoryRead($lAgentArray[$i][0] + 196, 'long')
	  If $lOwner <> 0 And $lOwner <> $aMyID Then ContinueLoop ; assigned to someone else
	  UpdateAgentPosByPtr($aMe, $lMeX, $lMeY)
	  UpdateAgentPosByPtr($lAgentArray[$i][0], $lAgentX, $lAgentY)
	  $lDistance = Sqrt(($lMeX - $lAgentX) ^ 2 + ($lMeY - $lAgentY) ^ 2)
	  If $lDistance > 2000 Then ContinueLoop ; item is too far away
	  $lItemMID = MemoryRead($lItemPtr + 44, 'long')
	  If $mEventModelID <> 0 Then
		 If $lItemMID = $mEventModelID Then $mEventCount += 1
	  EndIf
	  If Not $mMapPieces Then
		 If $lItemMID = 24629 Or $lItemMID = 24630 Or $lItemMID = 24631 Or $lItemMID = 24632 Then ContinueLoop ; no map pieces please
	  EndIf
	  If $lItemMID = 27977 And Not $mBattlePlans Then ContinueLoop ; no charr battle plans
	  If $lItemMID = 21797 And Not $mMesmerTomes Then ContinueLoop ; no mesmer tomes
	  If $lItemMID = 21799 And Not $mElementalistTomes Then ContinueLoop ; no elementalist tomes
	  If $mPickUpAll Or PickUpList($lItemPtr) Then
		 PickUpItems($lAgentArray[$i][0], $lAgentID, $lAgentX, $lAgentY, $lDistance, $aMe)
	  EndIf
   Next
EndFunc   ;==>PickUpLoot

;~ Description: Returns item ptr array, sorted by distance from player to speed up looting.
Func GetSortedItemPtrArray($aMe = GetAgentPtr(-2), $aType = 0x400)
   Local $lMaxAgents = GetMaxAgents()
   Local $lAgentPtrStruct = DllStructCreate("ptr[" & $lMaxAgents & "]")
   DllCall($mKernelHandle, "int", "ReadProcessMemory", "handle", $mGWProcHandle, "ptr", MemoryRead($mAgentBase), "struct*", $lAgentPtrStruct, "ulong_ptr", $lMaxAgents * 4, "ulong_ptr*", 0)
   Local $lTemp
   Local $lAgentArray[$lMaxAgents + 1][2]
   For $i = 1 To $lMaxAgents
	  $lTemp = DllStructGetData($lAgentPtrStruct, 1, $i)
	  If $lTemp = 0 Then ContinueLoop
	  If MemoryRead($lTemp + 156, 'long') <> $aType Then ContinueLoop
	  $lAgentArray[0][0] += 1
	  $lAgentArray[$lAgentArray[0][0]][0] = $lTemp
	  $lAgentArray[$lAgentArray[0][0]][1] = GetPseudoDistance($aMe, $lTemp)
   Next
   ReDim $lAgentArray[$lAgentArray[0][0] + 1][2]
   If $lAgentArray[0][0] > 2 Then QuickSort2D($lAgentArray, 1, $lAgentArray[0][0], 1)
   Return $lAgentArray
EndFunc

;~ Description: Quicksort by distances, internal use GetSortedItemPtrArray.
Func QuickSort2D(ByRef $aArray, Const ByRef $aStart, Const ByRef $aEnd, Const ByRef $aColumn)
   If $aEnd <= $aStart Then Return
   Local $lTmp
   Local $lLeft = $aStart
   Local $lRight = $aEnd
   Local $lPivot = $aArray[Int(($aStart + $aEnd) / 2)][$aColumn]
   Do
	  If IsNumber($lPivot) Then
		 While ($aArray[$lLeft][$aColumn] - $lPivot) < 0 And IsNumber($aArray[$lLeft][$aColumn])
			$lLeft += 1
		 WEnd
		 While ($aArray[$lRight][$aColumn] - $lPivot) > 0 And IsNumber($aArray[$lRight][$aColumn])
			$lRight -= 1
		 WEnd
	  EndIf
	  If $lLeft <= $lRight Then
		 For $i = 0 To 1
			$lTmp = $aArray[$lLeft][$i]
			$aArray[$lLeft][$i] = $aArray[$lRight][$i]
			$aArray[$lRight][$i] = $lTmp
		 Next
		 $lLeft += 1
		 $lRight -= 1
	  EndIf
   Until $lLeft > $lRight
   QuickSort2D($aArray, $aStart, $lRight, $aColumn)
   QuickSort2D($aArray, $lLeft, $aEnd, $aColumn)
EndFunc

;~ Description: Internal use PickUpLoot().
Func PickUpItems($aPtr, $aAgentID, $aX, $aY, $aDistance, $aMe)
   Local $lBlocked = 0
   If $aDistance > 150 And $aDistance <= 500 Then
	  Move_($aX, $aY)
	  Do
		 If Not GetIsMoving($aMe) Then
			$lBlocked += 1
			Move_($aX, $aY)
		 EndIf
		 Sleep(250)
	  Until GetDistance($aPtr, $aMe) <= 150 Or $lBlocked > 20
   Else
	  MoveTo($aX, $aY)
   EndIf
   Local $lTimer = TimerInit()
   Do
	  PickUpItem($aAgentID)
	  Sleep(500)
	  If GetAgentPtr($aAgentID) <> $aPtr Then Return True
   Until TimerDiff($lTimer) > 3000
EndFunc

;~ Description: Internal use PickUpLoot().
Func PickUpList($aItemPtr)
   Local $lRarity = GetRarity($aItemPtr)
   If $lRarity = 2624 Or $lRarity = 2626 And $mLeecher Then Return False ; leecher present to pick up loot
   If $lRarity = 2627 Then Return $mRarityGreen ; green items
   If $lRarity = 2624 Then Return $mRarityGold ; gold items
   Local $lModelID = MemoryRead($aItemPtr + 44, 'long')
   If $lModelID = 27977 Then Return $mBattlePlans ; charr battle plans
   If $lModelID = 24629 Then Return $mMapPieces ; map top left
   If $lModelID = 24630 Then Return $mMapPieces ; map top right
   If $lModelID = 24631 Then Return $mMapPieces ; map bottom left
   If $lModelID = 24632 Then Return $mMapPieces ; map bottom right
   If $lModelID = 6104 Then Return $mQuestItems ; Quest item: Urn
   If $lModelID = 6102 Then Return $mQuestItems ; Quest item: Spear
   Local $lType = MemoryRead($aItemPtr + 32, 'byte')
   Switch $lType
	  Case 9, 11, 18, 20, 31 ; consumables, materials and z-coins, keys, gold coins, scrolls
		 Return True
	  Case 10 ; dyes
		 Local $lExtraID = MemoryRead($aItemPtr + 34, 'short')
		 If $lExtraID = 10 Or $lExtraID = 12 Then
			Return True ; black and white dye
		 Else
			Return $mDyes
		 EndIf
	  Case 21 ; quest items
		 Return $mQuestItems
   EndSwitch
   Switch $lModelID
	  Case 1953, 1956 to 1975 ; froggys
		 Return True
	  Case 21786 to 21795 ; elite tomes
		 Return $mEliteTomes
	  Case 21796 ;  assassin tomes
		 Return $mTomes
	  Case 21797 ; mesmer tomes
		 Return $mMesmerTomes
	  Case 21798 ; necromancer tomes
		 Return $mTomes
	  Case 21799 ; elementalist tomes
		 Return $mElementalistTomes
	  Case 21800 ; monk tomes
		 Return $mTomes
	  Case 21801 ; warrior tomes
		 Return $mTomes
	  Case 21802 ; ranger tomes
		 Return $mTomes
	  Case 21803 ; dervish tomes
		 Return $mTomes
	  Case 21804 ; ritualist tomes
		 Return $mTomes
	  Case 21805 ; paragon tomes
		 Return $mTomes
	  Case 21127 to 21131 ; gems
		 Return True
	  Case 522, 835, 476, 525, 444, 27047 ; dark remains, feathered scalp, demonic remains, umbral skeletal limb, feathered caromi scalp, glacial stones
		 Return $mSalvageTrophies
	  Case 27033, 27035, 27036, 27050, 27974 ; destroyer core, saurian bone, amphibian tongue, elemental dust, undead bone
		 Return True
	  Case 28434, 18345, 21491, 37765, 30855, 22191, 22190 ; Event items
		 Return True
   EndSwitch
   If GetIsIronItem($lModelID) Then Return True
   Return GetIsRareWeapon($aItemPtr)
EndFunc   ;==>PickUpList
#EndRegion

#Region Itemstats
;~ Description: Returns rarity (name color) of an item.
Func GetRarity($aItem)
   If IsPtr($aItem) <> 0 Then
	  Local $lNameString = MemoryRead($aItem + 56, 'ptr')
   ElseIf IsDllStruct($aItem) <> 0 Then
	  Local $lNameString = DllStructGetData($aItem, 'Namestring')
   Else
	  Local $lNameString = MemoryRead(GetItemPtr($aItem) + 56, 'ptr')
   EndIf
   If $lNameString = 0 Then Return
   Return MemoryRead($lNameString, 'ushort')
EndFunc   ;==>GetRarity

;~ Description: Tests if an item is identified.
Func GetIsIDed($aItem)
   If IsPtr($aItem) <> 0 Then
	  Return BitAND(MemoryRead($aItem + 40, 'short'), 1) > 0
   ElseIf IsDllStruct($aItem) <> 0 Then
	  Return BitAND(DllStructGetData($aItem, 'interaction'), 1) > 0
   Else
	  Return BitAND(MemoryRead(GetItemPtr($aItem) + 40, 'short'), 1) > 0
   EndIf
EndFunc   ;==>GetIsIDed

;~ Descriptions: Tests if an item is unidentfied and can be identified.
Func GetIsUnIDed($aItem)
   If IsPtr($aItem) <> 0 Then
	  Return BitAND(MemoryRead($aItem + 40, 'long'), 8388608) > 0
   ElseIf IsDllStruct($aItem) <> 0 Then
	  Return BitAND(DllStructGetData($aItem, 'interaction'), 8388608) > 0
   Else
	  Return BitAND(MemoryRead(GetItemPtr($aItem) + 40, 'long'), 8388608) > 0
   EndIf
EndFunc   ;==>GetIsUnIDed

;~ Description: Returns true if item has a suffix, prefix or inscription in it that isnt fixed.
Func GetIsUpgraded($lItemPtr)
   Local $lInteraction = MemoryRead($lItemPtr + 40)
   If BitAnd($lInterAction, 68222976) Then Return True
EndFunc

;~ Description: Returns a weapon or shield's minimum required attribute.
Func GetItemReq($aItem)
   Local $lMod = GetModByIdentifier($aItem, "9827")
   Return $lMod[0]
EndFunc   ;==>GetItemReq

;~ Description: Returns a weapon or shield's required attribute.
Func GetItemAttribute($aItem)
   Local $lMod = GetModByIdentifier($aItem, "9827")
   Return $lMod[1]
EndFunc   ;==>GetItemAttribute

;~ Description: Returns an array of the requested mod.
Func GetModByIdentifier($aItem, $aIdentifier)
   Local $lReturn[2]
   Local $lString = StringTrimLeft(GetModStruct($aItem), 2)
   For $i = 0 To StringLen($lString) / 8 - 2
	  If StringMid($lString, 8 * $i + 5, 4) == $aIdentifier Then
		 $lReturn[0] = Int("0x" & StringMid($lString, 8 * $i + 1, 2))
		 $lReturn[1] = Int("0x" & StringMid($lString, 8 * $i + 3, 2))
		 ExitLoop
	  EndIf
   Next
   Return $lReturn
EndFunc   ;==>GetModByIdentifier

;~ Description: Returns modstruct of an item.
Func GetModStruct($aItem)
   If IsPtr($aItem) <> 0 Then
	  Local $lBuffer = DllStructCreate('ptr;long')
	  MemoryReadToStruct($aItem + 16, $lBuffer)
	  If DllStructGetData($lBuffer, 1) <> 0 Then
		 Return MemoryRead(DllStructGetData($lBuffer, 1), 'Byte[' & DllStructGetData($lBuffer, 2) * 4 & ']')
	  EndIf
   ElseIf IsDllStruct($aItem) <> 0 Then
	  Local $lModstruct = DllStructGetData($aItem, 'modstruct')
	  Local $lModSize = DllStructGetData($aItem, 'modstructsize')
	  If $lModstruct <> 0 Then
		 Return MemoryRead($lModstruct, 'Byte[' & $lModSize * 4 & ']')
	  EndIf
   Else
	  Local $lBuffer = DllStructCreate('ptr;long')
	  MemoryReadToStruct(GetItemPtr($aItem) + 16, $lBuffer)
	  If DllStructGetData($lBuffer, 1) <> 0 Then
		 Return MemoryRead(DllStructGetData($lBuffer, 1), 'Byte[' & DllStructGetData($lBuffer, 2) * 4 & ']')
	  EndIf
   EndIf
EndFunc   ;==>GetModStruct

;~ Description: Tests if an item is assigned to you.
Func GetAssignedToMe($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Local $lOwner = MemoryRead($aAgent + 196, 'long')
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Local $lOwner = DllStructGetData($aAgent, 'Owner')
   Else
	  Local $lOwner = MemoryRead(GetAgentPtr($aAgent) + 196, 'long')
   EndIf
   If $lOwner = 0 Or $lOwner = GetMyID() Then
	  Return True
   Else
	  Return False
   EndIf
EndFunc   ;==>GetAssignedToMe

;~ Description: Returns mod's attribute.
Func GetAttributeByMod($aMod)
   Switch $aMod
	  Case "3F" ; $MODSTRUCT_HEADPIECE_DOMINATION_MAGIC
		 Return 3 ; $ATTRIB_DOMINATIONMAGIC
	  Case "40" ; $MODSTRUCT_HEADPIECE_FAST_CASTING
		 Return 1 ; $ATTRIB_FASTCASTING
	  Case "41" ; $MODSTRUCT_HEADPIECE_ILLUSION_MAGIC
		 Return 2 ; $ATTRIB_ILLUSIONMAGIC
	  Case "42" ; $MODSTRUCT_HEADPIECE_INSPIRATION_MAGIC
		 Return 4 ; $ATTRIB_INSPIRATIONMAGIC
	  Case "43" ; $MODSTRUCT_HEADPIECE_BLOOD_MAGIC
		 Return 5 ; $ATTRIB_BLOODMAGIC
	  Case "44" ; $MODSTRUCT_HEADPIECE_CURSES
		 Return 8 ; $ATTRIB_CURSES
	  Case "45" ; $MODSTRUCT_HEADPIECE_DEATH_MAGIC
		 Return 6 ; $ATTRIB_DEATHMAGIC
	  Case "46" ; $MODSTRUCT_HEADPIECE_SOUL_REAPING
		 Return 7 ; $ATTRIB_SOULREAPING
	  Case "47" ; $MODSTRUCT_HEADPIECE_AIR_MAGIC
		 Return 9 ; $ATTRIB_AIRMAGIC
	  Case "48" ; $MODSTRUCT_HEADPIECE_EARTH_MAGIC
		 Return 10 ; $ATTRIB_EARTHMAGIC
	  Case "49" ; $MODSTRUCT_HEADPIECE_ENERGY_STORAGE
		 Return 13 ; $ATTRIB_ENERGYSTORAGE
	  Case "4A" ; $MODSTRUCT_HEADPIECE_FIRE_MAGIC
		 Return 11 ; $ATTRIB_FIREMAGIC
	  Case "4B" ; $MODSTRUCT_HEADPIECE_WATER_MAGIC
		 Return 12 ; $ATTRIB_WATERMAGIC
	  Case "4C" ; $MODSTRUCT_HEADPIECE_DIVINE_FAVOR
		 Return 17 ; $ATTRIB_DIVINEFAVOR
	  Case "4D" ; $MODSTRUCT_HEADPIECE_HEALING_PRAYERS
		 Return 14 ; $ATTRIB_HEALINGPRAYERS
	  Case "4E" ; $MODSTRUCT_HEADPIECE_PROTECTION_PRAYERS
		 Return 16 ; $ATTRIB_PROTECTIONPRAYERS
	  Case "4F" ; $MODSTRUCT_HEADPIECE_SMITING_PRAYERS
		 Return 15 ; $ATTRIB_SMITINGPRAYERS
	  Case "50" ; $MODSTRUCT_HEADPIECE_AXE_MASTERY
		 Return 19 ; $ATTRIB_AXEMASTERY
	  Case "51" ; $MODSTRUCT_HEADPIECE_HAMMER_MASTERY
		 Return 20 ; $ATTRIB_HAMMERMASTERY
	  Case "53" ; $MODSTRUCT_HEADPIECE_SWORDSMANSHIP
		 Return 21 ; $ATTRIB_SWORDSMANSHIP
	  Case "54" ; $MODSTRUCT_HEADPIECE_STRENGTH
		 Return 18 ; $ATTRIB_STRENGTH
	  Case "55" ; $MODSTRUCT_HEADPIECE_TACTICS
		 Return 22 ; $ATTRIB_TACTICS
	  Case "56" ; $MODSTRUCT_HEADPIECE_BEAST_MASTERY
		 Return 23 ; $ATTRIB_BEASTMASTERY
	  Case "57" ; $MODSTRUCT_HEADPIECE_MARKSMANSHIP
		 Return 26 ; $ATTRIB_MARKSMANSHIP
	  Case "58" ; $MODSTRUCT_HEADPIECE_EXPERTISE
		 Return 24 ; $ATTRIB_EXPERTISE
	  Case "59" ; $MODSTRUCT_HEADPIECE_WILDERNESS_SURVIVAL
		 Return 25 ; $ATTRIB_WILDERNESSSURVIVAL
   EndSwitch
EndFunc   ;==>GetAttributeByMod

;~ Description: Returns max dmg of item.
Func GetItemMaxDmg($aItem)
   Local $lModString = GetModStruct($aItem)
   Local $lPos = StringInStr($lModString, "A8A7") ; Weapon Damage
   If $lPos = 0 Then $lPos = StringInStr($lModString, "C867") ; Energy (focus)
   If $lPos = 0 Then $lPos = StringInStr($lModString, "B8A7") ; Armor (shield)
   If $lPos = 0 Then Return 0
   Return Int("0x" & StringMid($lModString, $lPos - 2, 2))
EndFunc   ;==>GetItemMaxDmg

;~ Description: All these salvage into Iron.
Func GetIsIronItem($aItem)
   Local $lItemMID
   If IsPtr($aItem) <> 0 Then
	  $lItemMID = MemoryRead($aItem + 44, 'long')
   ElseIf IsDllStruct($aItem) <> 0 Then
	  $lItemMID = DllStructGetData($aItem, 'ModelID')
   Else
	  $lItemMID = $aItem
   EndIf
   Switch $lItemMID
	  Case 109, 110, 111, 113, 116, 120, 121, 126, 149, 150, 151, 153, 201, 202, 206, 214, 216, 222, 251, 254, 255, 257, 258, 259, 261, 263, 265, 266
		 Return True
	  Case 269, 271, 274, 275, 278, 279, 282, 284, 285, 286, 288, 289, 290, 326, 327, 331, 334, 335, 336, 337, 338, 343, 345, 396, 400, 402, 405, 406
		 Return True
	  Case 407, 408, 412, 418, 419, 421, 1753, 1755, 1757, 1758, 1759, 1765, 1767, 1781, 1785, 1787, 1788, 1790, 1791, 1792, 1793, 1800, 1808, 1810, 1813
		 Return True
	  Case 1815, 1820, 1825, 1827, 1830, 1831, 1832, 1834, 1835, 1837, 1841, 1844, 1850, 1851, 1852, 1857, 1858, 1859, 1860, 1863, 1869, 1871, 1872, 1873
		 Return True
	  Case 1874, 1875, 1876, 1887, 1889, 1892, 1898, 1899, 1901, 1902, 1903, 1904, 1906, 1908, 1910, 1911, 1912, 1913, 1914, 1917, 1928, 1933, 1935, 1937
		 Return True
	  Case 1941, 1944, 1946, 1947, 1954, 2040, 2041, 2042, 2043, 2065, 2072, 2077, 2078, 2104, 2109, 2191, 2200, 2201, 2204, 2211, 2218, 2219, 2220, 2222
		 Return True
	  Case 2224, 2225, 2228, 2231, 2233, 2234, 2251, 2253, 2255, 2403, 2404, 2405, 2406, 2407, 2408, 2411, 2412
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>GetIsIronItem

;~ Description: Returns if rare weapon.
Func GetIsRareWeapon($aItem)
   Local $Attribute = GetItemAttribute($aItem)
   Local $Requirement = GetItemReq($aItem)
   Local $Damage = GetItemMaxDmg($aItem)
   If $Attribute = 21 And $Requirement <= 8 And $Damage = 22 Then ; req8 Swords
	  Return True
   ElseIf $Attribute = 18 And $Requirement <= 8 And $Damage = 16 Then ; req8 Shields
	  Return True
   ElseIf $Attribute = 22 And $Requirement <= 8 And $Damage = 16 Then ; Req8 Shields
	  Return True
   ElseIf $Attribute = 36 And $Requirement <= 8 And $Damage = 16 Then ; Req8 Shields
	  Return True
   ElseIf $Attribute = 37 And $Requirement <= 8 And $Damage = 16 Then ; Req Shields
	  Return True
   EndIf
   Return False
EndFunc   ;==>GetIsRareWeapon
#EndRegion

#Region Gold
;~ Description: Returns amount of gold in storage.
Func GetGoldStorage()
   If $GoldBasePtr = 0 Then $GoldBasePtr = MemoryRead($mBasePtr1840 + 0xF8)
   Return MemoryRead($GoldBasePtr + 0x80)
EndFunc   ;==>GetGoldStorage

;~ Description: Returns amount of gold being carried.
Func GetGoldCharacter()
   If $GoldBasePtr = 0 Then $GoldBasePtr = MemoryRead($mBasePtr1840 + 0xF8)
   Return MemoryRead($GoldBasePtr + 0x7C)
EndFunc   ;==>GetGoldCharacter

;~ Description: Drop gold on the ground.
Func DropGold($aAmount = 0)
   Local $lAmount
   If $aAmount > 0 Then
	  $lAmount = $aAmount
   Else
	  $lAmount = GetGoldCharacter()
   EndIf
   Return SendPacket(0x8, 0x29, $lAmount)
EndFunc   ;==>DropGold

;~ Description: Deposit gold into storage.
Func DepositGold($aAmount = 0)
   Local $lAmount
   Local $lStorage = GetGoldStorage()
   Local $lCharacter = GetGoldCharacter()
   If $aAmount > 0 And $lCharacter >= $aAmount Then
	  $lAmount = $aAmount
   Else
	  $lAmount = $lCharacter
   EndIf
   If $lStorage + $lAmount > 1000000 Then $lAmount = 1000000 - $lStorage
   Return ChangeGold($lCharacter - $lAmount, $lStorage + $lAmount)
EndFunc   ;==>DepositGold

;~ Description: Withdraw gold from storage.
Func WithdrawGold($aAmount = 0)
   Local $lAmount
   Local $lStorage = GetGoldStorage()
   Local $lCharacter = GetGoldCharacter()
   If $aAmount > 0 And $lStorage >= $aAmount Then
	  $lAmount = $aAmount
   Else
	  $lAmount = $lStorage
   EndIf
   If $lCharacter + $lAmount > 100000 Then $lAmount = 100000 - $lCharacter
   Return ChangeGold($lCharacter + $lAmount, $lStorage - $lAmount)
EndFunc   ;==>WithdrawGold

;~ Description: Internal use for moving gold.
Func ChangeGold($aCharacter, $aStorage)
   Local $lResult = SendPacket(0xC, 0x76, $aCharacter, $aStorage)
   Sleep(250)
   Return $lResult
EndFunc   ;==>ChangeGold
#EndRegion
#include-once

;~ Description: Identifies all items in a bag.
Func IdentifyBag($aBag = 1, $aWhites = True, $aGolds = True)
   If IsPtr($aBag) Then
	  Local $lBagPtr = $aBag
	  Local $lSlots = MemoryRead($aBag + 32, 'long')
   ElseIf IsDllStruct($aBag) <> 0 Then
	  Local $lSlots = DllStructGetData($aBag, 'slots')
	  Local $lBagPtr = GetBagPtr(DllStructGetData($aBag, 'index') + 1)
   Else
	  Local $lBagPtr = GetBagPtr($aBag)
	  Local $lSlots = MemoryRead($lBagPtr + 32, 'long')
   EndIf
   If $lBagPtr = 0 Then Return
   Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
   If $aWhites And $aGolds Then
	  Local $lCheckRarity = False
   Else
	  Local $lCheckRarity = True
   EndIf
   Local $lRarity
   For $slot = 0 To $lSlots - 1
	  Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
	  If $lItemPtr = 0 Then ContinueLoop
	  If $lCheckRarity Then $lRarity = GetRarity($lItemPtr)
	  If Not $aWhites And $lRarity = 2621 Then ContinueLoop
	  If Not $aGolds And $lRarity = 2624 Then ContinueLoop
	  IdentifyItem($lItemPtr)
	  Sleep(GetPing())
   Next
   Return True
EndFunc   ;==>IdentifyBag

;~ Description: Identifies all gold items in a bag and drops them.
Func IdentifyBagAndDrop($aBag)
   If IsPtr($aBag) Then
	  Local $lBagPtr = $aBag
	  Local $lSlots = MemoryRead($aBag + 32, 'long')
   ElseIf IsDllStruct($aBag) <> 0 Then
	  Local $lSlots = DllStructGetData($aBag, 'slots')
	  Local $lBagPtr = GetBagPtr(DllStructGetData($aBag, 'index') + 1)
   Else
	  Local $lBagPtr = GetBagPtr($aBag)
	  Local $lSlots = MemoryRead($lBagPtr + 32, 'long')
   EndIf
   If $lBagPtr = 0 Then Return
   Local $lItemPtr
   Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
   For $i = 0 To $lSlots - 1
	  $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $i, 'ptr')
	  If $lItemPtr = 0 Then ContinueLoop
	  If GetRarity($lItemPtr) <> 2624 Then ContinueLoop
	  If FindIDKit() <> 0 Then
		 IdentifyItem($lItemPtr)
		 PingSleep(200)
	  EndIf
	  DropItem($lItemPtr)
	  PingSleep(250)
   Next
EndFunc   ;==>IdentifyBagAndDrop

;~ Description: Drops all gold items on the ground without identifying them first.
Func DropUnIDGolds($aBag)
   If IsPtr($aBag) Then
	  Local $lBagPtr = $aBag
	  Local $lSlots = MemoryRead($aBag + 32, 'long')
   ElseIf IsDllStruct($aBag) <> 0 Then
	  Local $lSlots = DllStructGetData($aBag, 'slots')
	  Local $lBagPtr = GetBagPtr(DllStructGetData($aBag, 'index') + 1)
   Else
	  Local $lBagPtr = GetBagPtr($aBag)
	  Local $lSlots = MemoryRead($lBagPtr + 32, 'long')
   EndIf
   If $lBagPtr = 0 Then Return
   Local $lItemPtr
   Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
   For $i = 0 To $lSlots - 1
	  $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $i, 'ptr')
	  If $lItemPtr = 0 Then ContinueLoop
	  If GetRarity($lItemPtr) <> 2624 Then ContinueLoop
	  If GetIsIDed($lItemPtr) Then ContinueLoop
	  DropItem($lItemPtr)
	  PingSleep(250)
   Next
EndFunc   ;==>DropUnIDGolds

;~ Description: Identifies and Salvages all items in a bag.
Func IdentifyBagAndSalvage($aBag = 1)
   If IsPtr($aBag) <> 0 Then
	  Local $lBagPtr = $aBag
   ElseIf IsDllStruct($aBag) <> 0 Then
	  Local $lBagPtr = GetBagPtr(DllStructGetData($aBag, 'Index') + 1)
   Else
	  Local $lBagPtr = GetBagPtr($aBag)
   EndIf
   If $lBagPtr = 0 Then Return
   Local $lItemPtr, $lItemMID
   Local $lSalvKitID, $lQuantityOld, $lDeadlock
   Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
   For $i = 1 To MemoryRead($lBagPtr + 32, 'long')
	  Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($i - 1), 'ptr')
	  If $lItemPtr = 0 Then ContinueLoop
	  If MemoryRead($lItemPtr + 24, 'ptr') <> 0 Then ContinueLoop ; customized
	  If MemoryRead($lItemPtr + 76, 'byte') <> 0 Then ContinueLoop ; equipped
	  If MemoryRead($lItemPtr + 36, 'short') = 0 Then ContinueLoop ; value 0
	  Local $lItemMID = MemoryRead($lItemPtr + 44, 'long')
	  If GetIsIronItem($lItemMID) Or $lItemMID = 522 Then ; 522 = Dark Remains
		 If GetIsRareWeapon($lItemPtr) Then ContinueLoop
		 If GetIsUnIDed($lItemPtr) Then
			Update("ID bag " & $aBag & " and slot " & $i)
			IdentifyItem($lItemPtr)
		 EndIf
		 Update("Salvage bag " & $aBag & " and slot " & $i)
		 $lSalvKitID = StartSalvage($lItemPtr)
		 $lQuantityOld = MemoryRead($lItemPtr + 75, 'byte')
		 $lDeadlock = TimerInit()
		 If $lQuantityOld > 1 Then
			Do
			   Sleep(250)
			   If MemoryRead($lItemPtr + 75, 'byte') <> $lQuantityOld Then ContinueLoop 2
			Until TimerDiff($lDeadlock) > 5000
		 Else
			Do
			   Sleep(250)
			   If MemoryRead($lItemPtr + 12, 'ptr') = 0 Then ContinueLoop 2
			Until TimerDiff($lDeadlock) > 5000
		 EndIf
		 If GetRarity($lItemPtr) <> 2621 Then
			RndSleep(500)
			Update("Salvage Material Special from bag " & $aBag & " and slot " & $i)
			SalvageMaterials()
		 EndIf
	  EndIf
   Next
   Return True
EndFunc   ;==>IdentifyBagAndSalvage
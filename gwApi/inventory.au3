
#Region Variables
Global $mEmptyBag = 8
Global $mEmptySlot = 0
Global $mStoreGold = False
Global $mStoreMaterials = True
Global $mBlackWhite = True
Global $mMatExchangeGold = 930 ; ModelID of mat that should be bought in case gold storage is full
Global $mSalvageStacks = True
Global $mDustFeatherFiber = 0 ; change to 1 to sell this group of materials
Global $mGraniteIronBone = 0 ; change to 1 to sell this group of materials
Global $mWhiteMantleEmblem = True ; change to false to sell them
Global $mWhiteMantleBadge = True ; change to false to sell them
#EndRegion



;~ Description: Make sure to have enough gold on character, but not too much.
Func MinMaxGold()
   $lGoldCharacter = GetGoldCharacter()
   $lGoldStorage = GetGoldStorage()
   $lGold = $lGoldCharacter + $lGoldStorage
   OpenStorageWindow()
   If $lGoldCharacter < 10000 And $lGoldStorage > 10000 Then
	  WithdrawGold(10000 - $lGoldCharacter)
	  Return 10000
   ElseIf $lGoldCharacter > 50000 And $lGold < 1000000 Then
	  DepositGold($lGoldCharacter - 10000)
	  Return 10000
   Else
	  Return $lGoldCharacter
   EndIf
EndFunc   ;==>MinMaxGold

;~ Description: Buy Ident and Salvage Kits for inventory session.
Func BuyKits($aAmount = 40, $aExpertSalv = True)
   ; identification kits
   $lIDKitUses = FindIDKitUses(1, 4)
   If $lIDKitUses < $aAmount Then
	  $lItemIDRow = GetItemRowByModelID(2989)
	  $lKitUses = 25
	  If $lItemIDRow = 0 Then
		 $lItemIDRow = GetItemRowByModelID(5899)
		 $lKitUses = 100
		 If $lItemIDRow = 0 Then Return ; no id kit
	  EndIf
	  $lBuyAmount = Ceiling(($aAmount - $lIDKITUses) / $lKitUses)
	  Update("Buying ID Kits: " & $lBuyAmount)
	  BuyIdentKit($lItemIDRow, $lBuyAmount)
	  Sleep(250 + GetPing())
   EndIf
   ; salvage kits
   $lSalvKitUses = CheapSalvageUses(1, 4)
   If $lSalvKitUses < $aAmount Then
	  $lItemIDRow = GetItemRowByModelID(2992)
	  $lKitUses = 25
	  If $lItemIDRow = 0 Then
		 $lItemIDRow = GetItemRowByModelID(2993)
		 $lKitUses = 10
		 If $lItemIDRow = 0 Then Return
	  EndIf
	  $lBuyAmount = Ceiling(($aAmount - $lSalvKitUses) / $lKitUses)
	  Update("Buying Salvage Kits: " & $lBuyAmount)
	  BuySalvKit(False, $lItemIDRow, $lBuyAmount)
	  Sleep(250 + GetPing())
   EndIf
   ; expert salvage kits
   If $aExpertSalv Then
	  $lExperSalvKitUses = ExpertSalvageUses(1, 4)
	  If $lExperSalvKitUses < $aAmount Then
		 $lItemIDRow = GetItemRowByModelID(2991)
		 $lKitUses = 25
		 If $lItemIDRow = 0 Then
			$lItemIDRow = GetItemRowByModelID(5900)
			$lKitUses = 100
			If $lItemIDRow = 0 Then Return
		 EndIf
		 $lBuyAmount = Ceiling(($aAmount - $lExperSalvKitUses) / $lKitUses)
		 Update("Buying Expert Salv Kits: " & $lBuyAmount)
		 BuySalvKit(True, $lItemIDRow, $lBuyAmount)
		 Sleep(250 + GetPing())
	  EndIf
   EndIf
EndFunc   ;==>BuyKits

;~ Description: Returns amount of salvage uses.
Func CheapSalvageUses($aStart = 1, $aFinish = 16)
   Local $lCount = 0
   For $bag = $aStart to $aFinish
	  Local $lBagPtr = GetBagPtr($bag)
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 Local $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 If $lItemMID = 2992 Or $lItemMID = 2993 Then $lCount += MemoryRead($lItemPtr + 36, 'short') / 2
	  Next
   Next
   Return $lCount
EndFunc   ;==>SalvageUses

;~ Description: Buys Ident kit.
Func BuyIdentKit($aItemIDRow = 0, $aAmount = 1)
   If $aItemIDRow = 0 Then
	  $lItemIDRow = GetItemRowByModelID(2989)
	  If $lItemIDRow = 0 Then
		 $lItemIDRow = GetItemRowByModelID(5899)
		 If $lItemIDRow = 0 Then Return ; no id kit
	  EndIf
   Else
	  $lItemIDRow = $aItemIDRow
   EndIf
   $lItemPtr = GetItemPtr($lItemIDRow)
   $lValue = MemoryRead($lItemPtr + 36, 'short') * 2
   DllStructSetData($mBuyItem, 2, $aAmount)
   DllStructSetData($mBuyItem, 3, $lItemIDRow)
   DllStructSetData($mBuyItem, 4, $lValue * $aAmount)
   Enqueue($mBuyItemPtr, 16)
   Return $lItemPtr
EndFunc   ;==>BuyIdentKit

;~ Description: Buys salvage kit.
Func BuySalvKit($aExpert = False, $aItemIDRow = 0, $aAmount = 1)
   If $aItemIDRow = 0 Then
	  If $aExpert Then
		 $lItemIDRow = GetItemRowByModelID(2991)
		 If $lItemIDRow = 0 Then
			$lItemIDRow = GetItemRowByModelID(5900)
			If $lItemIDRow = 0 Then Return
		 EndIf
	  Else
		 $lItemIDRow = GetItemRowByModelID(2992)
		 If $lItemIDRow = 0 Then
			$lItemIDRow = GetItemRowByModelID(2993)
			If $lItemIDRow = 0 Then Return
		 EndIf
	  EndIf
   Else
	  $lItemIDRow = $aItemIDRow
   EndIf
   $lItemPtr = GetItemPtr($lItemIDRow)
   $lValue = MemoryRead($lItemPtr + 36, 'short') * 2
   DllStructSetData($mBuyItem, 2, $aAmount)
   DllStructSetData($mBuyItem, 3, $lItemIDRow)
   DllStructSetData($mBuyItem, 4, $aAmount * $lValue)
   Enqueue($mBuyItemPtr, 16)
   Return $lItemPtr
EndFunc   ;==>BuySalvKit

;~ Description: Identify all unident items in inventory.
Func Ident()
   For $bag = 1 to 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  For $slot = 1 to MemoryRead($lBagPtr + 32, 'long')
		 $lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
		 If $lItemPtr = 0 Then ContinueLoop
		 If GetIsUnIDed($lItemPtr) Then
			Update("Identify: " & $bag & ", " & $slot)
			IdentifyItem($lItemPtr)
		 EndIf
	  Next
   Next
EndFunc   ;==>Ident

;~ Description: Store full stacks, unident golds and mods.
Func StoreItems()
   UpdateEmptyStorageSlot($mEmptyBag, $mEmptySlot)
   Update("Empty Spot: " & $mEmptyBag & ", " & $mEmptySlot)
   If $mEmptySlot = 0 Then Return ; no more empty slots found
   OpenStorageWindow()
   For $bag = 1 To 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop ; empty bag slot
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop ; empty slot
		 $lItemID = MemoryRead($lItemPtr, 'long')
		 $lItemType = MemoryRead($lItemPtr + 32, 'byte')
		 $lItemQuantity = MemoryRead($lItemPtr + 75, 'byte')
		 If $lItemType = 11 And $lItemQuantity = 250 And $mStoreMaterials Then ; materials
			Update("Store Materials: " & $bag & ", " & $slot & " -> " & $mEmptyBag & ", " & $mEmptySlot)
			MoveItem($lItemID, $mEmptyBag, $mEmptySlot)
			Do
			   Sleep(250)
			Until MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr') = 0
			UpdateEmptyStorageSlot($mEmptyBag, $mEmptySlot)
			If $mEmptySlot = 0 Then Return
			ContinueLoop
		 EndIf
		 $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 If StackableItems($lItemMID) And $lItemQuantity = 250 Then ; only full stacks
			Update("Store Stack: " & $bag & ", " & $slot & " -> " & $mEmptyBag & ", " & $mEmptySlot)
			MoveItem($lItemID, $mEmptyBag, $mEmptySlot)
			Do
			   Sleep(250)
			Until MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr') = 0
			UpdateEmptyStorageSlot($mEmptyBag, $mEmptySlot)
			If $mEmptySlot = 0 Then Return
			ContinueLoop
		 EndIf
		 If Keepers($lItemMID) Then
			Update("Store Keepers: " & $bag & ", " & $slot & " -> " & $mEmptyBag & ", " & $mEmptySlot)
			MoveItem($lItemID, $mEmptyBag, $mEmptySlot)
			Do
			   Sleep(250)
			Until MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr') = 0
			UpdateEmptyStorageSlot($mEmptyBag, $mEmptySlot)
			If $mEmptySlot = 0 Then Return ; no more empty slots
			ContinueLoop
		 EndIf
		 If $mStoreGold And GetRarity($lItemPtr) = 2624 Then ; store unident golds if possible
			Update("Store Golds: " & $bag & ", " & $slot & " -> " & $mEmptyBag & ", " & $mEmptySlot)
			MoveItem($lItemID, $mEmptyBag, $mEmptySlot)
			Do
			   Sleep(250)
			Until MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr') = 0
			UpdateEmptyStorageSlot($mEmptyBag, $mEmptySlot)
			If $mEmptySlot = 0 Then Return ; no more empty slots
			ContinueLoop
		 EndIf
	  Next
   Next
EndFunc   ;==>StoreItems

;~ Description: Return true of item is a stackable item.
Func StackableItems($aModelID)
   Switch $aModelID
	  ; stackable drops
	  Case 460,474,476,486,504,522,525,811,819,822,835,1610,2994,19185,22751,24629,24630,24631,24632,27033,27035,27044,27046,27047,27052,35123
		 Return True
	  ; tomes
	  Case 21786 to 21805
		 Return True
	  ; alcohol
	  Case 910,2513,5585,6049,6366,6367,6375,15477,19171,22190,24593,28435,30855,31145,31146,35124,36682
		 Return True
	  ; party
	  Case 6376,6368,6369,21809,21810,21813,29436,29543,36683,4730,15837,21490,22192,30626,30630,30638,30642,30646,30648,31020,31141,31142,31144,31172
		 Return True
	  ; sweets
	  Case 15528,15479,19170,21492,21812,22269,22644,22752,28431,28432,28436,31150,35125,36681
		 Return True
	  ; scrolls
	  Case 3256,3746,5594,5595,5611,21233,22279,22280
		 Return True
	  ; DPRemoval
	  Case 6370,21488,21489,22191,35127,26784,28433
		 Return True
	  ; special drops
	  Case 18345,21491,21833,28434,35121
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>StackableItems

;~ Description: Returns next empty slot, start at $aBag, $aSlot. Returns 0 if there's no empty slot in this bag.
Func UpdateEmptySlot(ByRef $aBagNr, ByRef $aSlot)
   If $aBagNr = 0 Then
	  $lBagNr = 1
   Else
	  $lBagNr = $aBagNr
   EndIf
   If $aSlot = 0 Then
	  $lSlot = 1
   Else
	  $lSlot = $aSlot
   EndIf
   $aBagNr = 0
   $aSlot = 0
   For $bag = $lBagNr To 4
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then Return 0 ; no bag
	  For $slot = $lSlot To MemoryRead($lBagPtr + 32, 'long')
		 $lSlotPtr = GetItemPtrBySlot($lBagPtr, $slot)
		 If $lSlotPtr = 0 Then
			$aBagNr = $bag
			$aSlot = $slot
			Return True
		 EndIf
	  Next
	  $lSlot = 1
   Next
EndFunc   ;==>UpdateEmptySlot

;~ Description: Returns next empty slot, start at $aBag, $aSlot. Returns 0 if there's no empty slot in this bag.
Func UpdateEmptyStorageSlot(ByRef $aBagNr, ByRef $aSlot)
   If $aBagNr = 0 Then
	  $lBagNr = 8
   Else
	  $lBagNr = $aBagNr
   EndIf
   If $aSlot = 0 Then
	  $lSlot = 1
   Else
	  $lSlot = $aSlot
   EndIf
   $aBagNr = 0
   $aSlot = 0
   For $bag = $lBagNr To 16
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then Return 0 ; no bag
	  For $slot = $lSlot To 20
		 $lSlotPtr = GetItemPtrBySlot($lBagPtr, $slot)
		 If $lSlotPtr = 0 Then
			$aBagNr = $bag
			$aSlot = $slot
			Return True
		 EndIf
	  Next
	  $lSlot = 1
   Next
EndFunc   ;==>UpdateEmptyStorageSlot

;~ Description: Returns true for all ModelIDs specified.
Func Keepers($aModelID)
   Switch $aModelID
	  ; mods
	  Case 896,908,15554,15551,15552,894,906,897,909,893,905,6323,6331,895,907,15543,15553,15544,15555,15540,15541,15542,17059,19122,19123
		 Return True
	  Case 5551 ; Rune of Superior Vigor
		 Return True
	  Case 460 ; White Mantle Emblem
		 Return $mWhiteMantleEmblem
	  Case 461 ; White Mantle Badge
		 Return $mWhiteMantleBadge
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>Keepers

;~ Description: Salvages all items in all bags.
Func SalvageBags()
   ; Search for ID kit
   Local $lIDKit = FindIDKitPtr(), $lMod
   If $lIDKit = 0 Then
	  Local $lIdentify = False
   Else
	  Local $lIDKitID = MemoryRead($lIDKit, 'long')
	  Local $lIdentify = True
   EndIf
   ; Search for expert salvage kit
   Local $lExpertKit = FindExpertSalvageKit()
   If $lExpertKit = 0 Then
	  Return
   Else
	  $lExpertKitID = MemoryRead($lExpertKit, 'long')
   EndIf
   ; Search for normal salvage kit
   Local $lCheapKit = FindCheapSalvageKit()
   If $lCheapKit = 0 Then
	  Return
   Else
	  $lCheapKitID = MemoryRead($lCheapKit, 'long')
   EndIf
   ; Start processing
   For $bag = 1 To 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  For $slot = 1 To MemoryRead($lBagPtr + 32, 'long') ; slots

		 $lItem = GetItemPtrBySlot($lBagPtr, $slot)
		 If IgnoreItem($lItem) Then ContinueLoop
		 If MemoryRead($lItem + 32, 'byte') = 31 Then ContinueLoop ; scrolls
		 $lQuantity = MemoryRead($lItem + 75, 'byte')
		 If $lQuantity > 1 And Not $mSalvageStacks Then ContinueLoop ; dont process stacks
		 $ItemMID = MemoryRead($lItem + 44, 'long') ; modelID
		 If $ItemMID = 504 Then ContinueLoop ; Decayed Orr Emblems
		 If $ItemMID = 460 Or $ItemMID = 461 Then ContinueLoop ; White Mantle Emblem and Badge
		 If Keepers($ItemMID) Then ContinueLoop ; dont salvage keepers
		 $ItemRarity = GetRarity($lItem)
		 If $ItemRarity = 2624 And GetIsRareWeapon($lItem) Then ContinueLoop ; no salvaging rare weapons

		 ; Identify item if necessary and id kit available
		 If $lIdentify And GetIsUnIDed($lItem) Then
			If MemoryRead($lIDKit + 12, 'ptr') = 0 Then
			   $lIDKit = FindIDKitPtr()
			   If $lIDKit = 0 Then
				  $lIdentify = False
				  ContinueLoop
			   Else
				  $lIDKitID = MemoryRead($lIDKit, 'long')
			   EndIf
			EndIf
			Update("Identify: " & $bag & ", " & $slot)
			IdentifyItem($lItem, $lIDKitID)
			Sleep(250)
			Do
			   Sleep(250)
			Until Not GetIsUnIDed($lItem)
		 EndIf
		 ; salvage white items
		 If $ItemRarity = 2621 Then
			For $i = 1 To $lQuantity
			   If MemoryRead($lCheapKit + 12, 'ptr') = 0 Then
				  $lCheapKit = FindCheapSalvageKit()
				  If $lCheapKit = 0 Then
					 Return -1 ; no more normal salvage kits
				  Else
					 $lCheapKitID = MemoryRead($lCheapKit, 'long')
				  EndIf
			   EndIf
			   Update("Salvaging (white): " & $bag & ", " & $slot)
			   $lQuantityOld = $lQuantity
			   StartSalvage($lItem, $lCheapKitID)
			   Local $lDeadlock = TimerInit()
			   Do
				  Sleep(50)
				  ;$lQuantity = MemoryRead($lItem + 75, 'byte')
			   Until $SalvageState ;$lQuantity <> $lQuantityOld Or MemoryRead($lItem + 12, 'ptr') = 0 Or TimerDiff($lDeadlock) > 2500
			   SalvageOUT()
			Next
		 ; salvage non-whites
		 ElseIf $ItemRarity = 2623 Or $ItemRarity = 2626 Or $ItemRarity = 2624 Then ; blue or purple or gold
			$ItemType = MemoryRead($lItem + 32, 'byte')
			; armor salvage items
			If $ItemType = 0 Then
			   $lMod = Upgrades($lItem)
			   While $lMod > -1
				  If MemoryRead($lExpertKit + 12, 'ptr') = 0 Then
					 $lExpertKit = FindExpertSalvageKit()
					 If $lExpertKit = 0 Then
						Return -1
					 Else
						$lExpertKitID = MemoryRead($lExpertKit, 'long')
					 EndIf
				  EndIf
				  Update("Salvage (" & $lMod & "): " & $bag & ", " & $slot)
				  $lValue = MemoryRead($lExpertKit + 36, 'short')
				  StartSalvage($lItem, $lExpertKitID)
				  Sleep(100)
				  If Not SendPacket(0x8, $CtoGS_MSG_SalvageMod, $lMod) Then ExitLoop 2  ;~ old -> 				  If Not SendPacket(0x8, 0x75, $lMod) Then ExitLoop 2
				  ;Local $lDeadlock = TimerInit()
				  Do
					 Sleep(50)
				  Until $SalvageState ;$lValue <> MemoryRead($lExpertKit + 36, 'short') Or TimerDiff($lDeadlock) > 2500
				  Local $stringSplit = StringSplit($whatWeGetOut, " ")
				  SalvageOUT()
				  $lMod = Upgrades($lItem)
			   WEnd
			; weapons
			ElseIf IsWeapon($ItemType) Then
			   $lMod = WeaponMods($lItem)
			   While $lMod > -1
				  If MemoryRead($lExpertKit + 12, 'ptr') = 0 Then
					 $lExpertKit = FindExpertSalvageKit()
					 If $lExpertKit = 0 Then
						Return -1
					 Else
						$lExpertKitID = MemoryRead($lExpertKit, 'long')
					 EndIf
				  EndIf
				  Update("Salvage (" & $lMod & "): " & $bag & ", " & $slot)
				  $lValue = MemoryRead($lExpertKit + 36, 'short')
				  StartSalvage($lItem, $lExpertKitID)
				  Sleep(100)
				  If Not SendPacket(0x8, $CtoGS_MSG_SalvageMod, $lMod) Then ExitLoop 2  ;~ old -> 				  If Not SendPacket(0x8, 0x75, $lMod) Then ExitLoop 2
				  ;Local $lDeadlock = TimerInit()
				  Do
					 Sleep(50)
				  Until $SalvageState;$lValue <> MemoryRead($lExpertKit + 36, 'short') Or TimerDiff($lDeadlock) > 2500
				  Local $stringSplit = StringSplit($whatWeGetOut, " ")
				  SalvageOUT()
				  $lMod = WeaponMods($lItem)
			   WEnd
			EndIf
			Sleep(500)
			; salvage materials if item not destroyed
			If $ItemRarity <> 2624 And MemoryRead($lItem + 12, 'ptr') <> 0 Then
			   If MemoryRead($lCheapKit + 12, 'ptr') = 0 Then
				  $lCheapKit = FindCheapSalvageKit()
				  If $lCheapKit = 0 Then
					 Return -1 ; no more normal salvage kits
				  Else
					 $lCheapKitID = MemoryRead($lCheapKit, 'long')
				  EndIf
			   EndIf
			   Update("Salvage (Materials): " & $bag & ", " & $slot)
			   StartSalvage($lItem, $lCheapKitID)
			   Sleep(1000 + GetPing())
			   If Not SendPacket(0x4, $CtoGS_MSG_SalvageMaterials) Then ExitLoop  ;~ old -> 			   If Not SendPacket(0x4, 0x74) Then ExitLoop
			   ;Local $lDeadlock = TimerInit()
			   Do
				  Sleep(20)
			   Until $SalvageState; MemoryRead($lItem + 12, 'ptr') = 0 Or TimerDiff($lDeadlock) > 2500
			   SalvageOUT()
			EndIf
		 EndIf
		 Sleep(500)
	  Next
   Next
EndFunc   ;==>SalvageBags

Func SalvageOUT()
Local $stringSplit = StringSplit($whatWeGetOut, " ")
Local $index = _ArraySearch($array_Salvage_Out, $stringSplit[2], 1, 0, 0, 1, 1)
If Not @error And $index <> -1 Then
	$array_Salvage_Out[$index][0] += $stringSplit[1]
Else
	RedDimArray_($array_Salvage_Out, $stringSplit[1], $stringSplit[2])
EndIf
EndFunc

Func RedDimArray_(ByRef $Container, Const ByRef $Parameter1, Const ByRef $Parameter2, $wichColum = 1)
	$Container[0][0] += 1
	ReDim $Container[$Container[0][0] + 1][2]
	$Container[$Container[0][0]][0] = $Parameter1 ; Amount [$i][0]
	$Container[$Container[0][0]][1] = $Parameter2 ; Name [$i][1]
	_ArraySort($Container, 0, 0, 0, $wichColum)
	If @error Then Return False
	Return True
EndFunc   ;==>_RedDimArray


;~ Description: Salvages all items in all bags. Modified for explorable.
Func SalvageBagsExplorable()
   If CountSlots() < 2 Then Return
   Local $lSalvKitUses = 0, $lIDKitUses = 0, $lSalvKitMID
   $lSalvKit = FindSalvKitExplorable($lSalvKitUses)
   If $lSalvKit = 0 Then Return
   $lSalvKitMID = @extended
   For $bag = 1 To 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  For $slot = 1 To MemoryRead($lBagPtr + 32, 'long') ; slots
		 $lItem = GetItemPtrBySlot($lBagPtr, $slot)
		 If IgnoreItem($lItem) Then ContinueLoop
		 If MemoryRead($lItem + 32, 'byte') = 31 Then ContinueLoop ; scrolls
		 If MemoryRead($lItem + 75, 'byte') > 1 Then ContinueLoop ; dont process stacks in explorable
		 $ItemMID = MemoryRead($lItem + 44, 'long') ; modelID
		 If $ItemMID = 504 Then ContinueLoop ; Decayed Orr Emblems
		 If $ItemMID = 460 Or $ItemMID = 461 Then ContinueLoop ; White Mantle Emblem and Badge
		 If Keepers($ItemMID) Then ContinueLoop ; dont salvage keepers
		 $ItemRarity = GetRarity($lItem)
		 If $ItemRarity = 2624 And GetIsRareWeapon($lItem) Then ContinueLoop ; no salvaging rare weapons
		 If GetIsUnIDed($lItem) And $ItemRarity <> 2624 Then
			If $ItemRarity = 2623 Or $ItemRarity = 2626 Then ; only ID blue and purple items in explorable
			   If $lIDKitUses = 0 Then
				  $lIDKit = FindIDKitExplorable($lIDKitUses)
				  If $lIDKitUses = 0 Then ContinueLoop ; ran out of ID kits
			   EndIf
			   $lIDKitValue = MemoryRead($lIDKit + 36, 'short')
			   Update("Identify: " & $bag & ", " & $slot)
			   IdentifyItem($lItem, MemoryRead($lIDKit, 'long'))
			   $lIDKitUses -= 1
			   Sleep(250)
			   Do
				  Sleep(250)
			   Until MemoryRead($lIDKit + 36, 'short') <> $lIDKitValue Or MemoryRead($lIDKit + 12, 'ptr') = 0
			   Sleep(GetPing() + 100)
			EndIf
		 EndIf
		 If MemoryRead($lSalvKit + 12, 'ptr') = 0 Then ; check SalvageKit before salvaging
			$lSalvKit = FindSalvKitExplorable($lSalvKitUses)
			If $lSalvKit = 0 Then Return ; no more salvage kits
			$lSalvKitMID = @extended
		 EndIf
		 If $ItemRarity = 2621 Then ; white
			Update("Salvaging (white): " & $bag & ", " & $slot)
			StartSalvage($lItem, MemoryRead($lSalvKit, 'long'))
			Local $lDeadlock = TimerInit()
			Do
			   Sleep(20)
			Until MemoryRead($lItem + 12, 'ptr') = 0 Or TimerDiff($lDeadlock) > 2500
			$lSalvKitUses -= 1
			Sleep(250 + GetPing())
		 ElseIf $ItemRarity = 2623 Or $ItemRarity = 2626 Then ; blue or purple
			$ItemType = MemoryRead($lItem + 32, 'byte')
			If $ItemType = 0 And Upgrades($lItem) <> 0 Then
			   ContinueLoop
			ElseIf IsWeapon($ItemType) And WeaponMods($lItem) <> 0 Then
			   ContinueLoop
			Else
			   Update("Salvaging (" & $lSalvKitMID & "): " & $bag & ", " & $slot)
			   StartSalvage($lItem, MemoryRead($lSalvKit, 'long'))
			   Sleep(1000 + GetPing())
			   SalvageMaterials()
			   Local $lDeadlock = TimerInit()
			   Do
				  Sleep(20)
			   Until MemoryRead($lItem + 12, 'ptr') = 0 Or TimerDiff($lDeadlock) > 2500
			   $lSalvKitUses -= 1
			   Sleep(250 + GetPing())
			EndIf
		 EndIf
		 Sleep(250)
	  Next
   Next
EndFunc   ;==>SalvageBagsExplorable

;~ Description: Limits bags to inventory to work in explorable, @extended returns ModelID of Kit.
Func FindSalvKitExplorable(ByRef $aUses)
   Local $lUses = 101
   Local $lKit = 0
   Local $lKitMID = 0
   $aUses = 0
   For $bag = 1 to 4
	  Local $lBagPtr = GetBagPtr($bag)
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 Local $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 If $lItemMID = 2992 Or $lItemMID = 2993 Then
			Local $lValue = MemoryRead($lItemPtr + 36, 'short')
			$aUses =  $lValue / 2
			Return SetExtended($lItemMID, $lItemPtr)
		 EndIf
	  Next
   Next
EndFunc   ;==>FindSalvKitExplorable

;~ Description: Limits bags to inventory to work in explorable, @extended returns ModelID of Kit.
Func FindIDKitExplorable(ByRef $aUses)
   Local $lUses = 101
   Local $lKit = 0
   Local $lKitMID = 0
   $aUses = 0
   For $bag = 1 to 4
	  Local $lBagPtr = GetBagPtr($bag)
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 Local $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 Switch $lItemMID
			Case 2989
			   Local $lValue = MemoryRead($lItemPtr + 36, 'short')
			   If $lValue / 2 < $lUses Then
				  $lUses = $lValue / 2
				  $lKit = $lItemPtr
				  $lKitMID = $lItemMID
				  $aUses = $lUses
			   EndIf
			Case 5899
			   Local $lValue = MemoryRead($lItemPtr + 36, 'short')
			   If $lValue / 2.5 < $lUses Then
				  $lUses = $lValue / 2.5
				  $lKit = $lItemPtr
				  $lKitMID = $lItemMID
				  $aUses = $lUses
			   EndIf
			Case Else
			   ContinueLoop
		 EndSwitch
	  Next
   Next
   Return SetExtended($lKitMID, $lKit)
EndFunc   ;==>FindIDKitExplorable

;~ Description: Ignore these items while processing inventory bags.
Func IgnoreItem($aItemPtr)
   If $aItemPtr = 0 Then Return True ; not a valid item
   If MemoryRead($aItemPtr + 24, 'ptr') <> 0 Then Return True ; customized
   If MemoryRead($aItemPtr + 76, 'byte') <> 0 Then Return True ; equipped
   If MemoryRead($aItemPtr + 36, 'short') = 0 Then Return True ; value 0
   If MemoryRead($aItemPtr + 12, 'ptr') = 0 Then Return True ; not in a bag
   Switch MemoryRead($aItemPtr + 32, 'byte')
	  Case 11 ; Materials
		 Return True
	  Case 8 ; Upgrades
		 Return True
	  Case 9 ; Usable
		 Return True
	  Case 10 ; Dyes
		 Return True
	  Case 29 ; Kits
		 Return True
	  Case 34 ; Minipet
		 Return True
	  Case 18 ; Keys
		 Return True
   EndSwitch
EndFunc   ;==>IgnoreItem

;~ Description: Returns item ptr of expert salvage kit in inventory with least uses.
Func FindExpertSalvageKit($aStart = 1, $aFinish = 16)
   Local $lUses = 101
   Local $lKit = 0
   For $bag = $aStart to $aFinish
	  Local $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 Local $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 If $lItemMID = 2991 Or $lItemMID = 5900 Then Return $lItemPtr
		 Switch $lItemMID
			Case 2991
			   Local $lValue = MemoryRead($lItemPtr + 36, 'short')
			   If $lValue / 8 < $lUses Then
				  $lUses = $lValue / 8
				  $lKit = $lItemPtr
			   EndIf
			Case 5900
			   Local $lValue = MemoryRead($lItemPtr + 36, 'short')
			   If $lValue / 10 < $lUses Then
				  $lUses = $lValue / 10
				  $lKit = $lItemPtr
			   EndIf
		 EndSwitch
	  Next
   Next
   Return $lKit
EndFunc   ;==>FindExpertSalvageKit

;~ Description: Returns item ptr of expert salvage kit in inventory with least uses.
Func FindCheapSalvageKit($aStart = 1, $aFinish = 16)
   Local $lUses = 101
   Local $lKit = 0
   For $bag = $aStart to $aFinish
	  Local $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 Local $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 If $lItemMID = 2992 Or $lItemMID = 2993 Then Return $lItemPtr
		 Switch $lItemMID
			Case 2992, 2993
			   Local $lValue = MemoryRead($lItemPtr + 36, 'short')
			   If $lValue / 2 < $lUses Then
				  $lUses = $lValue / 2
				  $lKit = $lItemPtr
			   EndIf
		 EndSwitch
	  Next
   Next
   Return $lKit
EndFunc   ;==>FindExpertSalvageKit

;~ Description: Returns item ptr of ID kit in inventory.
Func FindIDKitPtr($aStart = 1, $aFinish = 16)
   Local $lUses = 101
   Local $lKit = 0
   For $bag = $aStart to $aFinish
	  Local $lBagPtr = GetBagPtr($bag)
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 Local $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 If $lItemMID = 2989 Or $lItemMID = 5899 Then Return $lItemPtr
	  Next
   Next
EndFunc   ;==>FindIDKitPtr

;~ Description: Returns amount of available expert salvage kit uses to salvage mods.
Func ExpertSalvageUses($aStart = 1, $aFinish = 16)
   Local $lCount = 0
   For $bag = $aStart to $aFinish
	  Local $lBagPtr = GetBagPtr($bag)
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 Local $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 Switch $lItemMID
			Case 2991
			   $lCount += MemoryRead($lItemPtr + 36, 'short') / 8
			Case 5900
			   $lCount += MemoryRead($lItemPtr + 36, 'short') / 10
		 EndSwitch
	  Next
   Next
   Return $lCount
EndFunc   ;==>ExpertSalvageUses

;~ Description: Returns true if item is a weapon.
Func IsWeapon($aType)
   Switch $aType
	  Case 2,5,12,15,22,24,26,27,32,35,36
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>IsWeapon

;~ Description: Returns 1 if item contains insignia to keep, 2 if item contains rune to keep.
Func Upgrades($aItemPtr)
$lModStruct = MemoryReadStruct($aItemPtr + 16, 'ptr;long')
$lMod = MemoryRead(DllStructGetData($lModStruct, 1), 'byte[' & DllStructGetData($lModStruct, 2) * 4 & ']')
For $i = 0 To (UBound($Rune_Insigmia) -1)
	If StringInStr($lMod, $Rune_Insigmia[$i][0], 1) <> 0) Then
		ConsoleWrite($lMod & " ==>  " &  @CRLF & $Rune_Insigmia[$i][0] & @CRLF & @CRLF)
		Return $Rune_Insigmia[$i][1]
	EndIf
Next
Return -1
EndFunc   ;==>Upgrades

;~ Description: Returns 2 for inscription, 0 and 1 for weapon mods.
Func WeaponMods($aItemPtr)

Local $lModStruct = MemoryReadStruct($aItemPtr + 16, 'ptr;long')
Local $lMod = MemoryRead(DllStructGetData($lModStruct, 1), 'byte[' & DllStructGetData($lModStruct, 2) * 4 & ']')
Local $lType = MemoryRead($aItemPtr + 32, 'byte')


For $i = 0 To (UBound($Upgrades) -1)
	If (($Upgrades[$i][13] = True) And (StringInStr($lMod, $Upgrades[$i][0], 1) <> 0) And ($lType = $Upgrades[$i][10])) Then
		Local $_array = StringRegExp($lModStruct, '(.{2})(.{2})' & $lMod, $Upgrades[$i][1], 3)
		;_ArrayDisplay($_array, "StringRegExp from WeaponMods ! ")
		If (($Upgrades[$i][11] = 4) And ($_array[0] = $Upgrades[$i][8]) Or ($Upgrades[$i][12] = 2)  And _
		($_array[1] = $Upgrades[$i][9])) Then Return $Upgrades[$i][4];mod Pos
	EndIf
Next

Return -1
EndFunc   ;==>WeaponMods

;~ Description: Sell items.
Func Sell()
   For $bag = 1 to 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  For $slot = 1 to MemoryRead($lBagPtr + 32, 'long')
		 $lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
		 If $lItemPtr = 0 Then ContinueLoop
		 If IgnoreItem($lItemPtr) Then ContinueLoop
		 $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 If Keepers($lItemMID) Then ContinueLoop
		 If StackableItems($lItemMID) Then ContinueLoop
		 If GetRarity($lItemPtr) = 2624 And GetIsRareWeapon($lItemPtr) Then ContinueLoop
		 If GetIsUnIDed($lItemPtr) Then IdentifyItem($lItemPtr)
		 Update("Sell Item: " & $bag & ", " & $slot)
		 SellItem($lItemPtr)
		 Sleep(500)
	  Next
   Next
EndFunc   ;==>Sell

;~ Description: Sell materials.
Func SellMaterials($aRare = False)
   For $bag = 1 to 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  For $slot = 1 to MemoryRead($lBagPtr + 32, 'long')
		 $lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 32, 'byte') <> 11 Then ContinueLoop ; not materials
		 $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 $lMatType = CheckMaterial($lItemMID)
		 If $aRare Then
			If $lMatType = 2 Then
			   For $i = 1 To MemoryRead($lItemPtr + 75, 'byte')
				  TraderRequestSell($lItemPtr)
				  Update("Sell rare materials: " & $bag & ", " & $slot)
				  Sleep(250)
				  TraderSell()
			   Next
			EndIf
		 Else
			If $lMatType = 1 Then
			   For $i = 1 To Floor(MemoryRead($lItemPtr + 75, 'byte') / 10)
				  Update("Sell materials: " & $bag & ", " & $slot)
				  TraderRequestSell($lItemPtr)
				  Sleep(250)
				  TraderSell()
			   Next
			EndIf
		 EndIf
	  Next
   Next
EndFunc   ;==>SellMaterials

;~ Description: Returns 1 for normal materials and 2 for rare materials.
;~ 0 if ModelID is not listed or mat should be ignored.
Func CheckMaterial($aModelID)
   Switch $aModelID
	  Case 954, 925 		; Chitin, Cloth
		 Return 1
	  Case 929, 933, 934	; Dust, Feather, Fibers
		 Return $mDustFeatherFiber
	  Case 955, 948, 921	; Granite, Iron, Bones
		 Return $mGraniteIronBone
	  Case 940, 946, 953	; Scale, Tanned Hide, Wood Plank
		 Return 1
	  Case 928, 926, 927	; Silk, Linen, Damask
		 Return 2
	  Case 931, 932, 923	; Monstrous Eye, Monstrous Fang, Monstrous Claw
		 Return 2
	  Case 922, 950, 949	; Charcoal, Deldrimor, Steel Ingot
		 Return 2
	  Case 951, 952, 956	; Parchment, Vellum, Spiritwood
		 Return 2
	  Case 937, 935, 938	; Ruby, Diamond, Sapphire
		 Return 0
	  Case 936, 945, 930	; Onyx, Obsidian Shard, Ectoplasm
		 Return 0
	  Case 941, 942, 943	; Fur, Leather Square, Elonian Leather Square
		 Return 2
	  Case 944, 939		 	; Vial of Ink, Glass Vial
		 Return 2
	  Case 6532, 6533 		; Amber, Jadeite
		 Return 0
   EndSwitch
EndFunc   ;==>CheckMaterial

;~ Description: Sell runes and insignias.
Func SellUpgrades()
   For $bag = 1 to 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  For $slot = 1 to MemoryRead($lBagPtr + 32, 'long')
		 $lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 32, 'byte') <> 8 Then ContinueLoop ; not an upgrade
		 If IsRuneOrInsignia(MemoryRead($lItemPtr + 44, 'long')) = 0 Then ContinueLoop ; neither rune, nor insignia
		 TraderRequestSell($lItemPtr)
		 Sleep(250)
		 Update("Sell Upgrade: " & $bag & ", " & $slot)
		 TraderSell()
	  Next
   Next
EndFunc   ;==>SellUpgrades

;~ Description: Sell all dyes to Dye Trader except for black and white.
Func SellDyes()
   For $bag = 1 to 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  For $slot = 1 to MemoryRead($lBagPtr + 32, 'long')
		 $lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
		 If $lItemPtr = 0 Then ContinueLoop
		 $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 If $lItemMID <> 146 Then ContinueLoop ; not a dye
		 If $mBlackWhite Then
			$lItemExtraID = MemoryRead($lItemPtr + 34, 'short')
			If $lItemExtraID = 10 Or $lItemExtraID = 12 Then ContinueLoop ; black or white
		 EndIf
		 For $i = 1 To MemoryRead($lItemPtr + 75, 'byte')
			Update("Sell Dye: " & $bag & ", " & $slot)
			TraderRequestSell($lItemPtr)
			Sleep(250)
			TraderSell()
		 Next
	  Next
   Next
EndFunc   ;==>SellDyes

;~ Description: Tries to make room by selling in different order and selling stuff that wasnt expressly forbidden / defined in Junk().
Func ClearInventorySpace($aMapID)
   ; first stage: sell dyes, runes, rare mats, mats, scrolls to try to make room
   If GoToMerchant(GetDyeTrader($aMapID)) <> 0 Then SellDyes()
   If GoToMerchant(GetRuneTrader($aMapID)) <> 0 Then SellUpgrades()
   If GoToMerchant(GetMaterialTrader($aMapID)) <> 0 Then SellMaterials()
   If GoToMerchant(GetScrollTrader($aMapID)) <> 0 Then SellScrolls()
   If GoToMerchant(GetRareMaterialTrader($aMapID)) <> 0 Then SellMaterials(True)
   $lSlots = CountSlots()
   If $lSlots > 3 Then Return True ; enough room to proceed as planned
   ; second stage: try selling identified purple and gold and everything else thats not expressly forbidden
   GoToMerchant(GetMerchant($aMapID))
   For $bag = 1 to 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  For $slot = 1 to MemoryRead($lBagPtr + 32, 'long')
		 $lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 24, 'ptr') <> 0 Then ContinueLoop ; customized
		 If MemoryRead($lItemPtr + 76, 'byte') <> 0 Then ContinueLoop ; equipped
		 If MemoryRead($lItemPtr + 36, 'short') = 0 Then ContinueLoop ; value 0
		 If MemoryRead($lItemPtr + 12, 'ptr') = 0 Then ContinueLoop ; not in a bag
		 $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 If Junk($lItemMID) Then
			Update("Sell Item: " & $bag & ", " & $slot)
			SellItem($lItemPtr)
			Sleep(500)
			$lSlots += 1
			If $lSlots > 3 Then Return True
			ContinueLoop
		 EndIf
		 If Keepers($lItemMID) Then ContinueLoop
		 If StackableItems($lItemMID) Then ContinueLoop
		 $lItemRarity = GetRarity($lItemPtr)
		 If GetIsUnIDed($lItemPtr) Then
			If $lItemRarity = 2624 Or $lItemRarity = 2626 Then ; only gold and purple
			   $lIDKit = FindIDKitPtr()
			   $lIDKitID = MemoryRead($lIDKit, 'long')
			   If $lIDKitID = 0 Then ContinueLoop
			   Update("Identify: " & $bag & ", " & $slot)
			   IdentifyItem($lItemPtr, $lIDKitID)
			   Sleep(250)
			   Do
				  Sleep(250)
			   Until Not GetIsUnIDed($lItemPtr)
			Else
			   ContinueLoop
			EndIf
		 EndIf
		 Switch MemoryRead($lItemPtr + 32, 'byte')
			Case 0
			   If Upgrades($lItemPtr) Then ContinueLoop
			Case 2, 5, 12, 15, 19, 22, 24, 26, 27, 32, 35, 36
			   If $lItemRarity = 2621 Then ContinueLoop ; try to keep whites for salvaging
			   If $mRarityGreen And $lItemRarity = 2627 Then ContinueLoop ; dont sell greens
			   If WeaponMods($lItemPtr) Then ContinueLoop
			Case 4, 7, 13, 16, 19 ; no selling armor pieces
			   ContinueLoop
			Case 11 ; Materials
			   ContinueLoop
			Case 8 ; Upgrades
			   ContinueLoop
			Case 9 ; Usable
			   ContinueLoop
			Case 10 ; Dyes
			   ContinueLoop
			Case 29 ; Kits
			   ContinueLoop
			Case 34 ; Minipet
			   ContinueLoop
			Case 18 ; Keys
			   Switch $lItemMID
				  Case 5962 ; Shiverpeak
					 ContinueLoop
				  Case 5963 ; Darkstone
					 ContinueLoop
				  Case 5961 ; Miners Key
					 ContinueLoop
				  Case 6535 ; Kurzick
					 ContinueLoop
				  Case 6536 ; Stoneroot
					 ContinueLoop
				  Case 6538 ; Luxon
					 ContinueLoop
				  Case 6539 ; Deep Jade
					 ContinueLoop
				  Case 6534 ; Forbidden
					 ContinueLoop
				  Case 15558 ; Vabbian
					 ContinueLoop
				  Case 15556 ; Ancient Elonian
					 ContinueLoop
				  Case 15560 ; Margonite
					 ContinueLoop
				  Case 19174 ; Demonic
					 ContinueLoop
				  Case 5882 ; Phantom
					 ContinueLoop
				  Case 5971 ; Obsidian
					 ContinueLoop
				  Case 22751 ; Lockpick
					 ContinueLoop
			   EndSwitch
		 EndSwitch
		 Update("Sell Item: " & $bag & ", " & $slot)
		 SellItem($lItemPtr)
		 Sleep(500)
		 $lSlots += 1
		 If $lSlots > 3 Then Return True
	  Next
   Next
   Return $lSlots > 3
EndFunc

;~ Description: Contains all modelIDs of items that could be sold if storage space is low. Use with caution.
Func Junk($aModelID)
   Switch $aModelID
	  Case 460 ; White Mantle Emblem
		 Return True
	  Case 461 ; White Mantle Badge
		 Return True
	  Case 504 ; Decayed Orr Emblem
		 Return True
   EndSwitch
EndFunc

;~ Description: Sell all gold rarity scrolls to scroll trader.
Func SellScrolls()
   For $bag = 1 to 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  For $slot = 1 to MemoryRead($lBagPtr + 32, 'long')
		 $lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 32, 'byte') <> 31 Then ContinueLoop ; not a scroll
		 If GetRarity($lItemPtr) <> 2624 Then ContinueLoop ; not a scrolltrader scroll
		 TraderRequestSell($lItemPtr)
		 Sleep(250)
		 Update("Sell Scroll: " & $bag & ", " & $slot)
		 TraderSell()
	  Next
   Next
EndFunc   ;==>SellScrolls

;~ Description: Go to merchant and co, if playernumber wasnt found go to xunlai chest and try again.
Func GoToMerchant($aPlayernumber)
Local $found = False
   ; first try

   $lAgentArray = MemoryReadAgentPtrStruct()
   For $i = 1 To $lAgentArray[0]
	  If MemoryRead($lAgentArray[$i] + 244, 'word') = $aPlayernumber Then
		 GoToNPC($lAgentArray[$i])
		 Sleep(500)
		 Dialog(0x7F)
		 $found = True
		 ExitLoop
	  EndIf
   Next

   If Not $found Then
	   ; merchant wasnt found, next try, but first... go to chest
	   For $i = 1 To $lAgentArray[0]
		  If MemoryRead($lAgentArray[$i] + 244, 'word') = 4991 Then
			 GoToNPC($lAgentArray[$i])
			 ExitLoop
		  EndIf
	   Next
	   ; aaaaand... try again to find merchant
	   $lAgentArray = MemoryReadAgentPtrStruct()
	   For $i = 1 To $lAgentArray[0]
		  If MemoryRead($lAgentArray[$i] + 244, 'word') = $aPlayernumber Then
			 GoToNPC($lAgentArray[$i])
			 Sleep(500)
			 Dialog(0x7F)
			 $found = True
			 ExitLoop
		  EndIf
	   Next
   EndIf

   Return $found
EndFunc   ;==>GoToMerchant

;~ Description: Return merchant depending on MapID.
Func GetMerchant($aMapID)
   Switch $aMapID
	  Case 4, 5, 6, 52, 176, 177, 178, 179 ; proph gh
		 Return 209
	  Case 275, 276, 359, 360, 529, 530, 537, 538 ; factions and nf gh
		 Return 196
	  Case 10, 11, 12, 139, 141, 142, 49, 857
		 Return 2030
	  Case 109, 120, 154
		 Return 1987
	  Case 116, 117, 118, 152, 153, 38
		 Return 1988
	  Case 122, 35
		 Return 2130
	  Case 123, 124
		 Return 2131
	  Case 129, 348, 390
		 Return 3396
	  Case 130, 218, 230, 287, 349, 388
		 Return 3397
	  Case 131, 21, 25, 36
		 Return 2080
	  Case 132, 135, 28, 29, 30, 32, 39, 40
		 Return 2091
	  Case 133, 155, 156, 157, 158, 159, 206, 22, 23, 24
		 Return 2101
	  Case 134, 81
		 Return 2005
	  Case 136, 137, 14, 15, 16, 19, 57, 73
		 Return 1983
	  Case 138
		 Return 1969
	  Case 193, 234, 278, 288, 391
		 Return 3612
	  Case 194, 213, 214, 225, 226, 242, 250, 283, 284, 291, 292
		 Return 3269
	  Case 216, 217, 249, 251
		 Return 3265
	  Case 219, 224, 273, 277, 279, 289, 297, 350, 389
		 Return 3611
	  Case 220, 274, 51
		 Return 3267
	  Case 222, 272, 286, 77
		 Return 3395
	  Case 248
		 Return 1201
	  Case 303
		 Return 3266
	  Case 376, 378, 425, 426, 477, 478
		 Return 5379
	  Case 381, 387, 421, 424, 427, 554
		 Return 5380
	  Case 393, 396, 403, 414, 476
		 Return 5660
	  Case 398, 407, 428, 433, 434, 435
		 Return 5659
	  Case 431
		 Return 4715
	  Case 438, 545
		 Return 5615
	  Case 440, 442, 469, 473, 480, 494, 496
		 Return 5607
	  Case 450, 559
		 Return 4983
	  Case 474, 495
		 Return 5608
	  Case 479, 487, 489, 491, 492, 502, 818
		 Return 4714
	  Case 555
		 Return 4982
	  Case 624
		 Return 6752
	  Case 638
		 Return 6054
	  Case 639, 640
		 Return 6751
	  Case 641
		 Return 6057
	  Case 642
		 Return 6041
	  Case 643, 645, 650
		 Return 6377
	  Case 644
		 Return 6378
	  Case 648
		 Return 6583
	  Case 652
		 Return 6225
	  Case 675
		 Return 6184
	  Case 808
		 Return 7442
	  Case 814
		 Return 104
   EndSwitch
EndFunc   ;==>GetMerchant

;~ Description: Return material trader depending on MapID.
Func GetMaterialTrader($aMapID)
   Switch $aMapID
	  Case 4, 5, 6, 52, 176, 177, 178, 179 ; proph gh
		 Return 204
	  Case 275, 276, 359, 360, 529, 530, 537, 538 ; factions and nf gh
		 Return 191
	  Case 109, 49, 81
		 Return 2011
	  Case 193
		 Return 3618
	  Case 194, 242, 857
		 Return 3279
	  Case 250
		 Return 3280
	  Case 376
		 Return 5385
	  Case 398
		 Return 5665
	  Case 414
		 Return 5668
	  Case 424
		 Return 5386
	  Case 433
		 Return 5666
	  Case 438
		 Return 5618
	  Case 491
		 Return 4720
	  Case 492
		 Return 4721
	  Case 638
		 Return 6757
	  Case 640
		 Return 6758
	  Case 641
		 Return 6059
	  Case 642
		 Return 6044
	  Case 643
		 Return 6383
	  Case 644
		 Return 6384
	  Case 652
		 Return 6227
	  Case 77
		 Return 3409
	  Case 808
		 Return 7446
	  Case 818
		 Return 4723
   EndSwitch
EndFunc   ;==>GetMaterialTrader

;~ Description: Return rare material trader depending on MapID.
Func GetRareMaterialTrader($aMapID)
   Switch $aMapID
	  Case 4, 5, 6, 52, 176, 177, 178, 179 ; proph gh
		 Return 205
	  Case 275, 276, 359, 360, 529, 530, 537, 538 ; factions and nf gh
		 Return 192
	  Case 109
		 Return 1997
	  Case 193
		 Return 3621
	  Case 194, 250, 857
		 Return 3282
	  Case 242
		 Return 3281
	  Case 376
		 Return 5388
	  Case 398, 433
		 Return 5667
	  Case 414
		 Return 5668
	  Case 424
		 Return 5387
	  Case 438
		 Return 5613
	  Case 49
		 Return 2038
	  Case 491, 818
		 Return 4723
	  Case 492
		 Return 4722
	  Case 638
		 Return 6760
	  Case 640
		 Return 6759
	  Case 641
		 Return 6060
	  Case 642
		 Return 6045
	  Case 643
		 Return 6386
	  Case 644
		 Return 6385
	  Case 652
		 Return 6228
	  Case 77
		 Return 3410
	  Case 81
		 Return 2083
   EndSwitch
EndFunc   ;==>GetRareMaterialTrader

;~ Description: Return rune trader depending on MapID.
Func GetRuneTrader($aMapID)
   Switch $aMapID
	  Case 4, 5, 6, 52, 176, 177, 178, 179 ; proph gh
		 Return 203
	  Case 275, 276, 359, 360, 529, 530, 537, 538 ; factions and nf gh
		 Return 190
	  Case 109, 814
		 Return 1999
	  Case 193
		 Return 3624
	  Case 194, 242, 250
		 Return 3285
	  Case 248, 857
		 Return 1975
	  Case 396
		 Return 5672
	  Case 414
		 Return 5671
	  Case 438
		 Return 5620
	  Case 477
		 Return 5390
	  Case 487
		 Return 4726
	  Case 49
		 Return 2039
	  Case 502
		 Return 4727
	  Case 624
		 Return 6764
	  Case 640
		 Return 6763
	  Case 642
		 Return 6046
	  Case 643, 645
		 Return 6389
	  Case 644
		 Return 6390
	  Case 77
		 Return 3415
	  Case 808
		 Return 7450
	  Case 81
		 Return 2085
	  Case 818
		 Return 4705
   EndSwitch
EndFunc   ;==>GetRuneTrader

;~ Description: Return dye trader depending on MapID.
Func GetDyeTrader($aMapID)
   Switch $aMapID
	  Case 4, 5, 6, 52, 176, 177, 178, 179 ; proph gh
		 Return 206
	  Case 275, 276, 359, 360, 529, 530, 537, 538 ; factions and nf gh
		 Return 193
	  Case 109, 49, 81, 857
		 Return 2010
	  Case 193
		 Return 3617
	  Case 194, 242
		 Return 3278
	  Case 250
		 Return 3277
	  Case 286
		 Return 3402
	  Case 381, 477
		 Return 5383
	  Case 403
		 Return 5663
	  Case 414
		 Return 5664
	  Case 640
		 Return 6756
	  Case 642
		 Return 6043
	  Case 644
		 Return 6382
	  Case 77
		 Return 3401
	  Case 812
		 Return 2107
	  Case 818
		 Return 4719
   EndSwitch
EndFunc   ;==>GetDyeTrader

;~ Description: Return scroll trader depending on MapID.
Func GetScrollTrader($aMapID)
   Switch $aMapID
	  Case 4, 5, 6, 52, 176, 177, 178, 179 ; proph gh
		 Return 207
	  Case 275, 276, 359, 360, 529, 530, 537, 538 ; factions and nf gh
		 Return 194
	  Case 109
		 Return 1998
	  Case 193
		 Return 3623
	  Case 194
		 Return 3283
	  Case 287
		 Return 3413
	  Case 396, 414
		 Return 5669
	  Case 426, 857
		 Return 5392
	  Case 442, 480
		 Return 5621
	  Case 49
		 Return 2040
	  Case 624
		 Return 6761
	  Case 638
		 Return 6056
	  Case 639, 640
		 Return 6762
	  Case 643, 644
		 Return 6387
	  Case 645
		 Return 6388
	  Case 77
		 Return 3412
	  Case 808
		 Return 7448
   EndSwitch
EndFunc   ;==>GetScrollTrader

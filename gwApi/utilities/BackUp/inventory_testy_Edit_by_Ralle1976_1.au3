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

#Region GoldManagement
;~ Description: Make sure to have enough gold on character, but not too much.
Func MinMaxGold()
   Local $lGoldCharacter = GetGoldCharacter()
   Local $lGoldStorage = GetGoldStorage()
   Local $lGold = $lGoldCharacter + $lGoldStorage
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

;~ Description: Checks the amount of gold a character holds and withdraws or stores accordingly.
;~ 		$aWithdraw 	-> max amount to be withdrawn from storage
;~ 		$aDeposit 	-> max amount to be deposited to storage
;~ 		$aMinGold 	-> below that gold will be withdrawn from storage
;~ 		$aMaxGold 	-> above MaxGold plus Variance, gold will be stored in storage, if storage not full
Func CheckGold($aWithdraw = 50000, $aDeposit = 50000, $aMinGold = 20000, $aMaxGold = 65000, $aVariance = 10000)
   Local $Gold = GetGoldCharacter()
   Local $Gold_Storage = GetGoldStorage()
   If $Gold > Random($aMaxGold-$aVariance, $aMaxGold+$aVariance) Then
	  If $Gold_Storage = 1000000 Then Return
	  If $Gold_Storage + $aDeposit > 1000000 Then
		 Return DepositGold(1000000 - $Gold_Storage)
	  Else
		 Return DepositGold($aDeposit)
	  EndIf
   ElseIf $Gold < $aMinGold Then
	  If $Gold_Storage = 0 Then Return
	  If $Gold_Storage < $aWithdraw Then
		 Return WithdrawGold($Gold_Storage)
	  Else
		 Return WithdrawGold($aWithdraw)
	  EndIf
   EndIf
EndFunc   ;==>CheckGold
#EndRegion GoldManagement

#Region Kits
;~ Description: Buy Ident and Salvage Kits for inventory session.
Func BuyKits($aAmount = 40, $aExpertSalv = True)
   Local $lItemIDRow, $lKitUses, $lBuyAmount, $lResult
   Local $lIDKitUses, $lSalvKitUses, $lExperSalvKitUses
   Local $lResult = False
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
	  $lResult = BuyIdentKit($lItemIDRow, $lBuyAmount)
	  Sleep(1000 + GetPing())
   EndIf
   ; salvage kits
   $lSalvKitUses = KitUses(1, 4, 0, True, False)
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
	  $lResult = BuySalvKit(False, $lItemIDRow, $lBuyAmount)
	  Sleep(1000 + GetPing())
   EndIf
   ; expert salvage kits
   If $aExpertSalv Then
	  $lExperSalvKitUses = KitUses(1, 4, 0, False, True)
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
		 $lResult = BuySalvKit(True, $lItemIDRow, $lBuyAmount)
		 Sleep(1000 + GetPing())
	  EndIf
   EndIf
   Return $lResult
EndFunc   ;==>BuyKits

;~ Description: Buys Ident kit.
Func BuyIdentKit($aItemIDRow = 0, $aAmount = 1)
   Local $lItemIDRow, $lItemPtr, $lValue
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
   Return SetExtended($lItemPtr, Enqueue($mBuyItemPtr, 16))
EndFunc   ;==>BuyIdentKit

;~ Description: Buys salvage kit.
Func BuySalvKit($aExpert = False, $aItemIDRow = 0, $aAmount = 1)
   Local $lItemIDRow, $lItemPtr, $lValue
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
   Return SetExtended($lItemPtr, Enqueue($mBuyItemPtr, 16))
EndFunc   ;==>BuySalvKit

;~ Description: Finds salvage kit in specified bags and puts ptr to it in $aPtr.
;~ If $aCheapKit is set to True, then loop stops early only if kit with less than 10 uses is found, otherwise least uses kit will be returned.
;~ If only normal kits should be found, set $aNormalOnly = True.
;~ Returns modelID, uses in @extended.
Func FindSalvKitEx(ByRef $aPtr, $aBagStart = 1, $aBagEnd = 4, $aCheapKit = False, $aNormalOnly = False, $aExpertOnly = False)
   If $aBagStart = Default Then $aBagStart = 1
   If $aBagEnd = Default Then $aBagEnd = 4
   If $aCheapKit = Default Then $aCheapKit = False
   If $aNormalOnly = Default Then $aNormalOnly = False
   If $aExpertOnly = Default Then $aExpertOnly = False
   Local $lUses = 250
   Local $lKitMID = 0
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr, $lValue, $lItemMID
   $aPtr = 0 ; delete former value
   For $bag = $aBagStart to $aBagEnd
	  $lBagPtr = GetBagPtr($bag)
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $slot, 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 Switch $lItemMID
			Case 2992, 2993
			   If $aExpertOnly Then ContinueLoop
			   $lValue = MemoryRead($lItemPtr + 36, 'short') / 2
			   If Not $aCheapKit Then
				  $lUses = $lValue
				  $aPtr = $lItemPtr
				  $lKitMID = $lItemMID
				  ExitLoop 2
			   Else
				  If $lValue < $lUses Then
					 $lUses = $lValue
					 $aPtr = $lItemPtr
					 $lKitMID = 2992
				  EndIf
			   EndIf
			Case 2991
			   If $aNormalOnly Then ContinueLoop
			   $lValue = MemoryRead($lItemPtr + 36, 'short') / 8
			   If Not $aCheapKit Then
				  $lUses = $lValue
				  $aPtr = $lItemPtr
				  $lKitMID = 2991
				  ExitLoop 2
			   Else
				  If $lValue < $lUses Then
					 $lUses = $lValue
					 $aPtr = $lItemPtr
					 $lKitMID = 2991
				  EndIf
			   EndIf
			Case 5900
			   If $aNormalOnly Then ContinueLoop
			   $lValue = MemoryRead($lItemPtr + 36, 'short') / 10
			   If Not $aCheapKit Then
				  $lUses = $lValue
				  $aPtr = $lItemPtr
				  $lKitMID = 5900
				  ExitLoop 2
			   Else
				  If $lValue < $lUses Then
					 $lUses = $lValue
					 $aPtr = $lItemPtr
					 $lKitMID = 5900
				  EndIf
			   EndIf
		 EndSwitch
		 If $lUses < 10 Then ExitLoop 2
	  Next
   Next
   Return SetExtended($lUses, $lKitMID)
EndFunc

;~ Description: Finds identification kit in specified bags and puts ptr to it in $aPtr.
;~ If $aCheapKit is set to True, then loop stops early only if kit with less than 10 uses is found, otherwise least uses kit will be returned.
;~ If only normal kits should be found, set $aNormalOnly = True.
;~ Returns modelID, uses in @extended.
Func FindIDKitEx(ByRef $aPtr, $aBagStart = 1, $aBagEnd = 4, $aCheapKit = False, $aNormalOnly = False, $aExpertOnly = False)
   If $aBagStart = Default Then $aBagStart = 1
   If $aBagEnd = Default Then $aBagEnd = 4
   If $aCheapKit = Default Then $aCheapKit = False
   If $aNormalOnly = Default Then $aNormalOnly = False
   If $aExpertOnly = Default Then $aExpertOnly = False
   Local $lUses = 250
   Local $lKitMID = 0
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr, $lValue
   $aPtr = 0 ; delete former value
   For $bag = $aBagStart to $aBagEnd
	  $lBagPtr = GetBagPtr($bag)
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $slot, 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 Switch MemoryRead($lItemPtr + 44, 'long')
			Case 2989
			   If $aExpertOnly Then ContinueLoop
			   $lValue = MemoryRead($lItemPtr + 36, 'short') / 2
			   If Not $aCheapKit Then
				  $lUses = $lValue
				  $aPtr = $lItemPtr
				  $lKitMID = 2989
				  ExitLoop 2
			   Else
				  If $lValue < $lUses Then
					 $lUses = $lValue
					 $aPtr = $lItemPtr
					 $lKitMID = 2989
				  EndIf
			   EndIf
			Case 5899
			   If $aNormalOnly Then ContinueLoop
			   $lValue = MemoryRead($lItemPtr + 36, 'short') / 2.5
			   If Not $aCheapKit Then
				  $lUses = $lValue
				  $aPtr = $lItemPtr
				  $lKitMID = 5899
				  ExitLoop 2
			   Else
				  If $lValue < $lUses Then
					 $lUses = $lValue
					 $aPtr = $lItemPtr
					 $lKitMID = 5899
				  EndIf
			   EndIf
		 EndSwitch
		 If $lUses < 10 Then ExitLoop 2
	  Next
   Next
   Return SetExtended($lUses, $lKitMID)
EndFunc

;~ Description: Returns kit uses left.
;~ $aMode = 0 -> Salvage kits.
;~ $aMode = 1 -> Identification kits.
;~ $aMode everything but 0 or 1: All kits.
Func KitUses($aBagStart = 1, $aBagEnd = 4, $aMode = 0, $aNormalOnly = False, $aExpertOnly = False)
   If $aBagStart = Default Then $aBagStart = 1
   If $aBagEnd = Default Then $aBagEnd = 1
   If $aMode = Default Then $aMode = 0
   If $aNormalOnly = Default Then $aNormalOnly = False
   If $aExpertOnly = Default Then $aExpertOnly = False
   Local $lUses = 0
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr, $lValue
   For $bag = $aBagStart to $aBagEnd
	  $lBagPtr = GetBagPtr($bag)
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $slot, 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 Switch MemoryRead($lItemPtr + 44, 'long')
			Case 2989 ; id kit -> Mode 1
			   If $aExpertOnly Then ContinueLoop
			   If $aMode <> 0 Then $lUses += MemoryRead($lItemPtr + 36, 'short') / 2
			Case 5899 ; id expert kit -> Mode 1
			   If $aNormalOnly Then ContinueLoop
			   If $aMode <> 0 Then $lUses += MemoryRead($lItemPtr + 36, 'short') / 2.5
			Case 2992, 2993 ; salv kits -> Mode 0
			   If $aExpertOnly Then ContinueLoop
			   If $aMode <> 1 Then $lUses += MemoryRead($lItemPtr + 36, 'short') / 2
			Case 2991 ; salv expert kit -> Mode 0
			   If $aNormalOnly Then ContinueLoop
			   If $aMode <> 1 Then $lUses += MemoryRead($lItemPtr + 36, 'short') / 8
			Case 5900 ; salv expert kit -> Mode 0
			   If $aNormalOnly Then ContinueLoop
			   If $aMode <> 1 Then $lUses += MemoryRead($lItemPtr + 36, 'short') / 10
		 EndSwitch
	  Next
   Next
   Return $lUses
EndFunc

;~ Description: Moves kits around so low-use kits come first in inventory. Prevents low kits piling up.
Func SortKits()
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr
   Local $lModelID, $lValue, $lUses
   Local $lTemp, $lSlot, $lDeadlock
   Local $lTempArray[46][6]
   Local $lCount = 0
   For $i = 1 To 4
	  $lBagPtr = GetBagPtr($i)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $j = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $j, 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 32, 'byte') <> 29 Then ContinueLoop ; not a kit
		 $lCount += 1
		 $lModelID = MemoryRead($lItemPtr + 44, 'long')
		 $lValue = MemoryRead($lItemPtr + 36, 'short')
		 Switch $lModelID
			Case 2992, 2993, 2989
			   $lUses = $lValue / 2
			Case 2991
			   $lUses = $lValue / 8
			Case 5900
			   $lUses = $lValue / 10
			Case 5899
			   $lUses = $lValue / 2.5
			Case Else
			   ContinueLoop
		 EndSwitch
		 $lTempArray[$lCount][0] = $lItemPtr
		 $lTempArray[$lCount][1] = $i
		 $lTempArray[$lCount][2] = $j + 1
		 $lTempArray[$lCount][3] = $lModelID
		 $lTempArray[$lCount][4] = $lUses
		 $lTempArray[$lCount][5] = $lItemArrayPtr
	  Next
   Next
   $lTempArray[0][0] = $lCount
   For $i = 1 To $lTempArray[0][0]
	  $lTemp = $i
	  For $j = $i + 1 To $lTempArray[0][0]
		 If $lTempArray[$i][3] = $lTempArray[$j][3] Then
			If $lTempArray[$j][4] < $lTempArray[$lTemp][4] Then $lTemp = $j
		 EndIf
	  Next
	  If $lTemp <> $i Then
		 MoveItemEx($lTempArray[$lTemp][0], $lTempArray[$i][1], $lTempArray[$i][2], 1)
		 $lSlot = $lTempArray[$lCount][2] - 1
		 $lDeadlock = TimerInit()
		 Do
			If TimerDiff($lDeadlock) > 5000 Then Return -1 ; something went really wrong
			Sleep(250)
		 Until MemoryRead($lTempArray[$lTemp][5] + 4 * ($lTempArray[$lTemp][2] - 1), 'ptr') <> $lTempArray[$lTemp][0]
		 $lTempArray[$lTemp][0] = $lTempArray[$i][0]
		 $lTempArray[$lTemp][1] = $lTempArray[$i][1]
		 $lTempArray[$lTemp][2] = $lTempArray[$i][2]
		 $lTempArray[$lTemp][3] = $lTempArray[$i][3]
		 $lTempArray[$lTemp][4] = $lTempArray[$i][4]
		 $lTempArray[$lTemp][5] = $lTempArray[$i][5]
	  EndIf
   Next
   Return True
EndFunc   ;==>SortKits
#EndRegion Kits

#Region MainFunctions
;~ Description: Identify all unident items in inventory.
Func Ident()
   Local $lBagPtr, $lItemPtr, $lItemArrayPtr
   Local $lResult = -1
   For $bag = 1 to 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 If GetIsUnIDed($lItemPtr) Then
			Update("Identify: " & $bag & ", " & $slot + 1)
			$lResult = IdentifyItem($lItemPtr)
		 EndIf
	  Next
   Next
   Return $lResult
EndFunc   ;==>Ident

;~ Description: Store full stacks, unident golds and mods.
Func StoreItems()
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr
   Local $lItemID, $lItemType, $lItemQuantity, $lItemMID
   Local $lDeadlock
   Local $lResult = -1
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
			$lDeadlock = TimerInit()
			Do
			   Sleep(250)
			   If TimerDiff($lDeadlock) > 5000 Then
				  $mEmptyBag = -1
				  Return False
			   EndIf
			Until MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr') = 0
			$lResult = True
			UpdateEmptyStorageSlot($mEmptyBag, $mEmptySlot)
			If $mEmptySlot = 0 Then Return $lResult
			ContinueLoop
		 EndIf

		 $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 If StackableItems($lItemMID) And $lItemQuantity = 250 Then ; only full stacks
			Update("Store Stack: " & $bag & ", " & $slot & " -> " & $mEmptyBag & ", " & $mEmptySlot)
			MoveItem($lItemID, $mEmptyBag, $mEmptySlot)
			$lDeadlock = TimerInit()
			Do
			   Sleep(250)
			   If TimerDiff($lDeadlock) > 5000 Then
				  $mEmptyBag = -1
				  Return False
			   EndIf
			Until MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr') = 0
			$lResult = True
			UpdateEmptyStorageSlot($mEmptyBag, $mEmptySlot)
			If $mEmptySlot = 0 Then Return $lResult
			ContinueLoop
		 EndIf

		 If Keepers($lItemMID) Then
			Update("Store Keepers: " & $bag & ", " & $slot & " -> " & $mEmptyBag & ", " & $mEmptySlot)
			MoveItem($lItemID, $mEmptyBag, $mEmptySlot)
			$lDeadlock = TimerInit()
			Do
			   Sleep(250)
			   If TimerDiff($lDeadlock) > 5000 Then
				  $mEmptyBag = -1
				  Return False
			   EndIf
			Until MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr') = 0
			$lResult = True
			UpdateEmptyStorageSlot($mEmptyBag, $mEmptySlot)
			If $mEmptySlot = 0 Then Return $lResult ; no more empty slots
			ContinueLoop
		 EndIf

		 If $mStoreGold And GetRarity($lItemPtr) = 2624 Then ; store unident golds if possible
			Update("Store Golds: " & $bag & ", " & $slot & " -> " & $mEmptyBag & ", " & $mEmptySlot)
			MoveItem($lItemID, $mEmptyBag, $mEmptySlot)
			$lDeadlock = TimerInit()
			Do
			   Sleep(250)
			   If TimerDiff($lDeadlock) > 5000 Then
				  $mEmptyBag = -1
				  Return False
			   EndIf
			Until MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr') = 0
			$lResult = True
			UpdateEmptyStorageSlot($mEmptyBag, $mEmptySlot)
			If $mEmptySlot = 0 Then Return $lResult ; no more empty slots
			ContinueLoop
		 EndIf
	  Next
   Next
   Return $lResult
EndFunc   ;==>StoreItems

;~ Description: Salvages all items in all bags.
;~ Func SalvageBags()
;~    Local $lIDKit = 0
;~    FindIDKitEx($lIDKit, 1, 16, True)
;~    If $lIDKit = 0 Then
;~ 	  Local $lIdentify = False
;~    Else
;~ 	  Local $lIDKitID = MemoryRead($lIDKit, 'long')
;~ 	  Local $lIdentify = True
;~    EndIf
;~    ; Search for expert salvage kit
;~    Local $lExpertKit = 0
;~    FindSalvKitEx($lExpertKit, 1, 16, True, False, True)
;~    If $lExpertKit = 0 Then
;~ 	  Return 0
;~    Else
;~ 	  Local $lExpertKitID = MemoryRead($lExpertKit, 'long')
;~    EndIf
;~    ; Search for normal salvage kit
;~    Local $lCheapKit = 0
;~    FindSalvKitEx($lCheapKit, 1, 16, True, True)
;~    If $lCheapKit = 0 Then
;~ 	  Return 0
;~    Else
;~ 	  Local $lCheapKitID = MemoryRead($lCheapKit, 'long')
;~    EndIf
;~    ; Start processing
;~    For $bag = 1 To 4 ; inventory only
;~ 	  $lBagPtr = GetBagPtr($bag)
;~ 	  If $lBagPtr = 0 Then ContinueLoop
;~ 	  For $slot = 1 To MemoryRead($lBagPtr + 32, 'long') ; slots
;~ 		 $lItem = GetItemPtrBySlot($lBagPtr, $slot)
;~ 		 If IgnoreItem($lItem) Then ContinueLoop
;~ 		 If MemoryRead($lItem + 32, 'byte') = 31 Then ContinueLoop ; scrolls
;~ 		 $lQuantity = MemoryRead($lItem + 75, 'byte')
;~ 		 If $lQuantity > 1 And Not $mSalvageStacks Then ContinueLoop ; dont process stacks
;~ 		 $ItemMID = MemoryRead($lItem + 44, 'long') ; modelID
;~ 		 If $ItemMID = 504 Then ContinueLoop ; Decayed Orr Emblems
;~ 		 If $ItemMID = 460 Or $ItemMID = 461 Then ContinueLoop ; White Mantle Emblem and Badge
;~ 		 If Keepers($ItemMID) Then ContinueLoop ; dont salvage keepers
;~ 		 $ItemRarity = GetRarity($lItem)
;~ 		 If $ItemRarity = 2624 And GetIsRareWeapon($lItem) Then ContinueLoop ; no salvaging rare weapons
;~ 		 ; Identify item if necessary and id kit available
;~ 		 If $lIdentify And GetIsUnIDed($lItem) Then
;~ 			If MemoryRead($lIDKit + 12, 'ptr') = 0 Then
;~ 			   $lIDKit = FindIDKitPtr()
;~ 			   If $lIDKit = 0 Then
;~ 				  $lIdentify = False
;~ 				  ContinueLoop
;~ 			   Else
;~ 				  $lIDKitID = MemoryRead($lIDKit, 'long')
;~ 			   EndIf
;~ 			EndIf
;~ 			Update("Identify: " & $bag & ", " & $slot)
;~ 			IdentifyItem($lItem, $lIDKitID)
;~ 			Sleep(250)
;~ 			Do
;~ 			   Sleep(250)
;~ 			Until Not GetIsUnIDed($lItem)
;~ 		 EndIf
;~ 		 ; salvage white items
;~ 		 If $ItemRarity = 2621 Then
;~ 			For $i = 1 To $lQuantity
;~ 			   If MemoryRead($lCheapKit + 12, 'ptr') = 0 Then
;~ 				  $lCheapKit = FindCheapSalvageKit()
;~ 				  If $lCheapKit = 0 Then
;~ 					 Return -1 ; no more normal salvage kits
;~ 				  Else
;~ 					 $lCheapKitID = MemoryRead($lCheapKit, 'long')
;~ 				  EndIf
;~ 			   EndIf
;~ 			   Update("Salvaging (white): " & $bag & ", " & $slot)
;~ 			   $lQuantityOld = $lQuantity
;~ 			   StartSalvage($lItem, $lCheapKitID)
;~ 			   Local $lDeadlock = TimerInit()
;~ 			   Do
;~ 				  Sleep(50)
;~ 				  ;$lQuantity = MemoryRead($lItem + 75, 'byte')
;~ 			   Until $SalvageState ;$lQuantity <> $lQuantityOld Or MemoryRead($lItem + 12, 'ptr') = 0 Or TimerDiff($lDeadlock) > 2500
;~ 			   SalvageOUT()
;~ 			Next
;~ 		 ; salvage non-whites
;~ 		 ElseIf $ItemRarity = 2623 Or $ItemRarity = 2626 Or $ItemRarity = 2624 Then ; blue or purple or gold
;~ 			$ItemType = MemoryRead($lItem + 32, 'byte')
;~ 			; armor salvage items
;~ 			If $ItemType = 0 Then
;~ 			   $lMod = Upgrades($lItem)
;~ 			   While $lMod > -1
;~ 				  If MemoryRead($lExpertKit + 12, 'ptr') = 0 Then
;~ 					 $lExpertKit = FindExpertSalvageKit()
;~ 					 If $lExpertKit = 0 Then
;~ 						Return -1
;~ 					 Else
;~ 						$lExpertKitID = MemoryRead($lExpertKit, 'long')
;~ 					 EndIf
;~ 				  EndIf
;~ 				  Update("Salvage (" & $lMod & "): " & $bag & ", " & $slot)
;~ 				  $lValue = MemoryRead($lExpertKit + 36, 'short')
;~ 				  StartSalvage($lItem, $lExpertKitID)
;~ 				  Sleep(100)
;~ 				  If Not SendPacket(0x8, 0x75, $lMod) Then ExitLoop 2
;~ 				  ;Local $lDeadlock = TimerInit()
;~ 				  Do
;~ 					 Sleep(50)
;~ 				  Until $SalvageState ;$lValue <> MemoryRead($lExpertKit + 36, 'short') Or TimerDiff($lDeadlock) > 2500
;~ 				  Local $stringSplit = StringSplit($whatWeGetOut, " ")
;~ 				  SalvageOUT()
;~ 				  $lMod = Upgrades($lItem)
;~ 			   WEnd
;~ 			; weapons
;~ 			ElseIf IsWeapon($ItemType) Then
;~ 			   $lMod = WeaponMods($lItem)
;~ 			   While $lMod > -1
;~ 				  If MemoryRead($lExpertKit + 12, 'ptr') = 0 Then
;~ 					 $lExpertKit = FindExpertSalvageKit()
;~ 					 If $lExpertKit = 0 Then
;~ 						Return -1
;~ 					 Else
;~ 						$lExpertKitID = MemoryRead($lExpertKit, 'long')
;~ 					 EndIf
;~ 				  EndIf
;~ 				  Update("Salvage (" & $lMod & "): " & $bag & ", " & $slot)
;~ 				  $lValue = MemoryRead($lExpertKit + 36, 'short')
;~ 				  StartSalvage($lItem, $lExpertKitID)
;~ 				  Sleep(100)
;~ 				  If Not SendPacket(0x8, 0x75, $lMod) Then ExitLoop 2
;~ 				  ;Local $lDeadlock = TimerInit()
;~ 				  Do
;~ 					 Sleep(50)
;~ 				  Until $SalvageState;$lValue <> MemoryRead($lExpertKit + 36, 'short') Or TimerDiff($lDeadlock) > 2500
;~ 				  SalvageOUT()
;~ 				  $lMod = WeaponMods($lItem)
;~ 			   WEnd
;~ 			EndIf
;~ 			Sleep(500)
;~ 			; salvage materials if item not destroyed
;~ 			If $ItemRarity <> 2624 And MemoryRead($lItem + 12, 'ptr') <> 0 Then
;~ 			   If MemoryRead($lCheapKit + 12, 'ptr') = 0 Then
;~ 				  $lCheapKit = FindCheapSalvageKit()
;~ 				  If $lCheapKit = 0 Then
;~ 					 Return -1 ; no more normal salvage kits
;~ 				  Else
;~ 					 $lCheapKitID = MemoryRead($lCheapKit, 'long')
;~ 				  EndIf
;~ 			   EndIf
;~ 			   Update("Salvage (Materials): " & $bag & ", " & $slot)
;~ 			   StartSalvage($lItem, $lCheapKitID)
;~ 			   Sleep(1000 + GetPing())
;~ 			   If Not SendPacket(0x4, 0x74) Then ExitLoop
;~ 			   ;Local $lDeadlock = TimerInit()
;~ 			   Do
;~ 				  Sleep(20)
;~ 			   Until $SalvageState; MemoryRead($lItem + 12, 'ptr') = 0 Or TimerDiff($lDeadlock) > 2500
;~ 			   SalvageOUT()
;~ 			EndIf
;~ 		 EndIf
;~ 		 Sleep(500)
;~ 	  Next
;~    Next
;~ EndFunc   ;==>SalvageBags

;~ Description: Salvages all items in all bags.
Func SalvageBags()
   ; Search for ID kit
; Search for ID kit
   Local $lIDKit = 0
   FindIDKitEx($lIDKit, 1, 16, True)
   If $lIDKit = 0 Then
	  Local $lIdentify = False
   Else
	  Local $lIDKitID = MemoryRead($lIDKit, 'long')
	  Local $lIdentify = True
   EndIf
   ; Search for expert salvage kit
   Local $lExpertKit = 0
   FindSalvKitEx($lExpertKit, 1, 16, True, False, True)
   If $lExpertKit = 0 Then
	  Return 0
   Else
	  Local $lExpertKitID = MemoryRead($lExpertKit, 'long')
   EndIf
   ; Search for normal salvage kit
   Local $lCheapKit = 0
   FindSalvKitEx($lCheapKit, 1, 16, True, True)
   If $lCheapKit = 0 Then
	  Return 0
   Else
	  Local $lCheapKitID = MemoryRead($lCheapKit, 'long')
   EndIf
   #cs
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
;~ 		 If $ItemRarity = 2624 And GetIsRareWeapon($lItem) Then ContinueLoop ; no salvaging rare weapons
		 ; Identify item if necessary and id kit available
		 If $lIdentify And GetIsUnIDed($lItem) Then
			If MemoryRead($lIDKit + 12, 'ptr') = 0 Then
			   $lIDKit = FindIDKitEx($lIDKit, 1, 16, True)
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
;~ 		 If $ItemRarity = 2621 Then
;~ 			For $i = 1 To $lQuantity
;~ 			   If MemoryRead($lCheapKit + 12, 'ptr') = 0 Then
;~ 				 FindSalvKitEx($lCheapKit, 1, 16, True, True)
;~ 				  If $lCheapKit = 0 Then
;~ 					 Return -1 ; no more normal salvage kits
;~ 				  Else
;~ 					 $lCheapKitID = MemoryRead($lCheapKit, 'long')
;~ 				  EndIf
;~ 			   EndIf
;~ 			   Update("Salvaging (white): " & $bag & ", " & $slot)
;~ 			   $lQuantityOld = $lQuantity
;~ 			   StartSalvage($lItem, $lCheapKitID)
;~ 			   Local $lDeadlock = TimerInit()
;~ 			   Do
;~ 				  Sleep(50)
;~ 				  $lQuantity = MemoryRead($lItem + 75, 'byte')
;~ 			   Until $SalvageState And $lQuantity <> $lQuantityOld Or MemoryRead($lItem + 12, 'ptr') = 0 Or TimerDiff($lDeadlock) > 2500
;~ 			   If $SalvageState Then SalvageOUT()
;~ 			   $SalvageState = False
;~ 			Next
		 ; salvage non-whites
;~ 		 Else
If $ItemRarity = 2623 Or $ItemRarity = 2626 Or $ItemRarity = 2624 Then ; blue or purple or gold
			$ItemType = MemoryRead($lItem + 32, 'byte')
;~ 			; armor salvage items
;~ 			If $ItemType = 0 Then
;~ 			   $lMod = Upgrades($lItem)
;~ 			   While $lMod > -1
;~ 				  If MemoryRead($lExpertKit + 12, 'ptr') = 0 Then
;~ 					 FindSalvKitEx($lExpertKit, 1, 16, True, False, True)
;~ 					 If $lExpertKit = 0 Then
;~ 						Return -1
;~ 					 Else
;~ 						$lExpertKitID = MemoryRead($lExpertKit, 'long')
;~ 					 EndIf
;~ 				  EndIf
;~ 				  Update("Salvage (" & $lMod & "): " & $bag & ", " & $slot)
;~ 				  $lValue = MemoryRead($lExpertKit + 36, 'short')
;~ 				  StartSalvage($lItem, $lExpertKitID)
;~ 				  Sleep(100)
;~ 				  If Not SendPacket(0x8, 0x75, $lMod) Then ExitLoop 2
;~ 				  Local $lDeadlock = TimerInit()
;~ 				  Do
;~ 					 Sleep(50)
;~ 				  Until $SalvageState Or TimerDiff($lDeadlock) > 2500 ;$lValue <> MemoryRead($lExpertKit + 36, 'short')
;~ 				  Local $stringSplit = StringSplit($whatWeGetOut, " ")
;~ 				   If $SalvageState Then SalvageOUT()
;~ 				   $SalvageState = False
;~ 				  $lMod = Upgrades($lItem)
;~ 			   WEnd
			; weapons
			If IsWeapon($ItemType) Then
			   $lMod = WeaponMods($lItem)
			   While $lMod > -1
				If MemoryRead($lExpertKit + 12, 'ptr') = 0 Then
					 FindSalvKitEx($lExpertKit, 1, 16, True, False, True)
					 If $lExpertKit = 0 Then
						Return -1
					 Else
						$lExpertKitID = MemoryRead($lExpertKit, 'long')
					 EndIf
				EndIf
				Update("Salvage (" & $lMod & "): " & $bag & ", " & $slot)
;~ 				  $lValue = MemoryRead($lExpertKit + 36, 'short')
				StartSalvage($lItem, $lExpertKitID)
				Sleep(100)
				If Not SendPacket(0x8, 0x75, $lMod) Then ExitLoop 2
				Local $lDeadlock = TimerInit()
				Do
					 Sleep(50)
				Until $SalvageState Or TimerDiff($lDeadlock) > 2500;$lValue <> MemoryRead($lExpertKit + 36, 'short')
				Local $stringSplit = StringSplit($whatWeGetOut, " ")
				 If $SalvageState Then
					 SalvageOUT()
					$SalvageState = False
				EndIf
				  $lMod = WeaponMods($lItem)
			   WEnd
			EndIf
			Sleep(500)
			; salvage materials if item not destroyed
;~ 			If $ItemRarity <> 2624 And MemoryRead($lItem + 12, 'ptr') <> 0 Then
;~ 			   If MemoryRead($lCheapKit + 12, 'ptr') = 0 Then
;~ 				   FindSalvKitEx($lCheapKit, 1, 16, True, True)
;~ 				  If $lCheapKit = 0 Then
;~ 					 Return -1 ; no more normal salvage kits
;~ 				  Else
;~ 					 $lCheapKitID = MemoryRead($lCheapKit, 'long')
;~ 				  EndIf
;~ 			   EndIf
;~ 			   Update("Salvage (Materials): " & $bag & ", " & $slot)
;~ 			   StartSalvage($lItem, $lCheapKitID)
;~ 			   Sleep(1000 + GetPing())
;~ 			   If Not SendPacket(0x4, 0x74) Then ExitLoop
;~ 			   Local $lDeadlock = TimerInit()
;~ 			   Do
;~ 				  Sleep(20)
;~ 			   Until $SalvageState And  MemoryRead($lItem + 12, 'ptr') = 0 Or TimerDiff($lDeadlock) > 2500
;~ 			   If $SalvageState Then SalvageOUT()
;~ 			   $SalvageState = False
;~ 			EndIf
		 EndIf
		 Sleep(500)
	  Next
   Next
   #CE

EndFunc   ;==>SalvageBags

;~ Func SalvageOUT()
;~ Local $stringSplit = StringSplit($whatWeGetOut, " ")
;~ Local $index = _ArraySearch($array_Salvage_Out, $stringSplit[2], 1, 0, 0, 1, 1)
;~ If Not @error And $index <> -1 Then
;~ 	$array_Salvage_Out[$index][0] += $stringSplit[1]
;~ Else
;~ 	RedDimArray_($array_Salvage_Out, $stringSplit[1], $stringSplit[2])
;~ EndIf
;~ EndFunc

Func SalvageOUT()
	#CS
Local $lDeadlock = TimerInit()
Do
	Sleep(GetPing() + 100)
	If (GetMapLoading() == 2) Then
		If Not DisconnectCheck_() Then Exit ;Bot cant reconnect ...(can set here any bot manager Action to relog Acc back)
		GoToMerchant(GetMerchant(GetMapID()))
	EndIf

Until $SalvageState Or TimerDiff($lDeadlock) >= 35000
$SalvageState = False
ConsoleWrite($whatWeGetOut & @CRLF)
Local $stringSplit = StringSplit($whatWeGetOut, " ")
Local $index = _ArraySearch($array_Salvage_Out, $stringSplit[0] >=  2 ? $whatWeGetOut : $stringSplit[2] , 1, 0, 0, 1, 1)
If Not @error And $index <> -1 Then
	$array_Salvage_Out[$index][0] += $stringSplit[1]
Else
	RedDimArray_($array_Salvage_Out, $stringSplit[1], $stringSplit[2])
EndIf
Sleep(250 + GetPing())
#CE


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
   Local $lSalvKitUses = 0, $lSalvKitMID, $lSalvKit
   Local $lIDKitUses = 0, $lIDKitValue, $lIDKit
   Local $lBagPtr, $lItemArrayPtr, $lItem, $ItemMID, $ItemRarity, $ItemType
   FindSalvKitEx($lSalvKit, 1, 4, True, True)
   If $lSalvKit = 0 Then Return
   $lSalvKitMID = @extended
   For $bag = 1 To 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItem = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If IgnoreItem($lItem) Then ContinueLoop
		 If MemoryRead($lItem + 32, 'byte') = 31 Then ContinueLoop ; scrolls
		 If MemoryRead($lItem + 75, 'byte') > 1 Then ContinueLoop ; dont process stacks in explorable
		 $ItemMID = MemoryRead($lItem + 44, 'long') ; modelID
		 If $ItemMID = 504 Then ContinueLoop ; Decayed Orr Emblems
		 If $ItemMID = 460 Or $ItemMID = 461 Then ContinueLoop ; White Mantle Emblem and Badge
		 If Keepers($ItemMID) Then ContinueLoop ; dont salvage keepers
		 $ItemRarity = GetRarity($lItem)
		 If $ItemRarity = 2624 And GetIsRareWeapon($lItem) Then ContinueLoop ; no salvaging rare weapons
		 If GetIsUnIDed($lItem) Then
			If $ItemRarity = 2623 Or $ItemRarity = 2626 Then ; only ID blue and purple items in explorable
			   If $lIDKitUses = 0 Then
				  FindIDKitEx($lIDKit, 1, 4, True)
				  If $lIDKitUses = 0 Then ContinueLoop ; ran out of ID kits
			   EndIf
			   $lIDKitValue = MemoryRead($lIDKit + 36, 'short')
			   Update("Identify: " & $bag & ", " & $slot + 1)
			   IdentifyItem($lItem, MemoryRead($lIDKit, 'long'))
			   $lIDKitUses -= 1
			   Sleep(250)
			   Local $lDeadlock = TimerInit()
			   Do
				  If TimerDiff($lDeadlock) > 5000 Then ContinueLoop 2 ; ident didnt work
				  Sleep(250)
			   Until MemoryRead($lIDKit + 36, 'short') <> $lIDKitValue Or MemoryRead($lIDKit + 12, 'ptr') = 0
			   Sleep(GetPing() + 250)
			   If GetIsUnIDed($lItem) Then ContinueLoop ; ident didnt work
			EndIf
		 EndIf
		 If MemoryRead($lSalvKit + 12, 'ptr') = 0 Then ; check SalvageKit before salvaging
			FindSalvKitEx($lSalvKit, 1, 4, True, True)
			If $lSalvKit = 0 Then Return 0 ; no more salvage kits
			$lSalvKitMID = @extended
		 EndIf
		 If $ItemRarity = 2621 Then ; white
			Update("Salvaging (white): " & $bag & ", " & $slot + 1)
			Update("Start Salvage: " & $bag & ", " & $slot & " -> " & StartSalvage($lItem, MemoryRead($lSalvKit, 'long')))
			Local $lDeadlock = TimerInit()
			Do
			   Sleep(250)
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
			   Update("Salvaging (" & $lSalvKitMID & "): " & $bag & ", " & $slot + 1)
			   Update("Start Salvage: " & $bag & ", " & $slot + 1 & " -> " & StartSalvage($lItem, MemoryRead($lSalvKit, 'long')))
			   Sleep(1000 + GetPing())
			   If MemoryRead($lItem + 12, 'ptr') <> 0 Then
				  Update("Salvage (Materials): " & $bag & ", " & $slot + 1 & " -> " & SalvageMaterials())
				  Local $lDeadlock = TimerInit()
				  Do
					 Sleep(250)
				  Until MemoryRead($lItem + 12, 'ptr') = 0 Or TimerDiff($lDeadlock) > 2500
				  $lSalvKitUses -= 1
				  Sleep(250 + GetPing())
			   EndIf
			EndIf
		 EndIf
		 Sleep(250)
	  Next
   Next
   Return True
EndFunc   ;==>SalvageBagsExplorable

;~ Description: Sell items.
Func Sell()
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr
   Local $lItemMID
   For $bag = 1 to 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 If IgnoreItem($lItemPtr) Then ContinueLoop
		 $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 If Keepers($lItemMID) Then ContinueLoop
		 If StackableItems($lItemMID) Then ContinueLoop
		 If GetRarity($lItemPtr) = 2624 And GetIsRareWeapon($lItemPtr) Then ContinueLoop
		 If GetIsUnIDed($lItemPtr) Then IdentifyItem($lItemPtr)
		 Update("Sell Item: " & $bag & ", " & $slot + 1)
		 SellItem($lItemPtr)
		 Sleep(500)
	  Next
   Next
EndFunc   ;==>Sell

;~ Description: Sell materials.
Func SellMaterials($aRare = False)
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr
   Local $lItemMID, $lMatType
   For $bag = 1 to 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 32, 'byte') <> 11 Then ContinueLoop ; not materials
		 $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 $lMatType = CheckMaterial($lItemMID)
		 If $aRare Then
			If $lMatType = 2 Then
			   For $i = 1 To MemoryRead($lItemPtr + 75, 'byte')
				  TraderRequestSell($lItemPtr)
				  Update("Sell rare materials: " & $bag & ", " & $slot + 1)
				  Sleep(250)
				  TraderSell()
			   Next
			EndIf
		 Else
			If $lMatType = 1 Then
			   For $i = 1 To Floor(MemoryRead($lItemPtr + 75, 'byte') / 10)
				  Update("Sell materials: " & $bag & ", " & $slot + 1)
				  TraderRequestSell($lItemPtr)
				  Sleep(250)
				  TraderSell()
			   Next
			EndIf
		 EndIf
	  Next
   Next
EndFunc   ;==>SellMaterials

;~ Description: Sell runes and insignias.
Func SellUpgrades()
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr
   For $bag = 1 to 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 32, 'byte') <> 8 Then ContinueLoop ; not an upgrade
		 If IsRuneOrInsignia(MemoryRead($lItemPtr + 44, 'long')) = 0 Then ContinueLoop ; neither rune, nor insignia
		 TraderRequestSell($lItemPtr)
		 Sleep(250)
		 Update("Sell Upgrade: " & $bag & ", " & $slot + 1)
		 TraderSell()
	  Next
   Next
EndFunc   ;==>SellUpgrades

;~ Description: Sell all dyes to Dye Trader except for black and white.
Func SellDyes()
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr
   Local $lItemMID, $lItemExtraID
   For $bag = 1 to 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 If $lItemMID <> 146 Then ContinueLoop ; not a dye
		 If $mBlackWhite Then
			$lItemExtraID = MemoryRead($lItemPtr + 34, 'short')
			If $lItemExtraID = 10 Or $lItemExtraID = 12 Then ContinueLoop ; black or white
		 EndIf
		 For $i = 1 To MemoryRead($lItemPtr + 75, 'byte')
			Update("Sell Dye: " & $bag & ", " & $slot + 1)
			TraderRequestSell($lItemPtr)
			Sleep(250)
			TraderSell()
		 Next
	  Next
   Next
EndFunc   ;==>SellDyes

;~ Description: Sell all gold rarity scrolls to scroll trader.
Func SellScrolls()
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr
   For $bag = 1 to 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
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

;~ Description: Tries to make room by selling in different order and selling stuff that wasnt expressly forbidden / defined in Junk().
Func ClearInventorySpace($aMapID, $aMyID = GetMyID(), $aMe = GetAgentPtr($aMyID))
   ; first stage: sell dyes, runes, rare mats, mats, scrolls to try to make room
   If GoToMerchant(GetDyeTrader($aMapID), $aMyID, $aMe) <> 0 Then SellDyes()
   If GoToMerchant(GetRuneTrader($aMapID), $aMyID, $aMe) <> 0 Then SellUpgrades()
   If GoToMerchant(GetMaterialTrader($aMapID), $aMyID, $aMe) <> 0 Then SellMaterials()
   If GoToMerchant(GetScrollTrader($aMapID), $aMyID, $aMe) <> 0 Then SellScrolls()
   If GoToMerchant(GetRareMaterialTrader($aMapID), $aMyID, $aMe) <> 0 Then SellMaterials(True)
   Local $lSlots = CountSlots()
   If $lSlots > 3 Then Return True ; enough room to proceed as planned
   ; second stage: try selling identified purple and gold and everything else thats not expressly forbidden
   GoToMerchant(GetMerchant($aMapID), $aMyID, $aMe)
   Local $lBagPtr, $lItemArrayPtr, $lItemPtr
   Local $lItemMID, $lItemRarity, $lIDKit, $lIDKitID
   Local $lDeadlock
   For $bag = 1 to 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 1 To MemoryRead($lBagPtr + 32, 'long')
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot + 1), 'ptr')
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
			   FindIDKitEx($lIDKit, 1, 4, True)
			   $lIDKitID = MemoryRead($lIDKit, 'long')
			   If $lIDKitID = 0 Then ContinueLoop
			   Update("Identify: " & $bag & ", " & $slot)
			   IdentifyItem($lItemPtr, $lIDKitID)
			   Sleep(250)
			   $lDeadlock = TimerInit()
			   Do
				  If TimerDiff($lDeadlock) > 5000 Then ContinueLoop 2
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

;~ Description: Moves item from storage and onto stack in inventory.
Func MoveItemFromStorageByModelID($aModelID, $aAmount = 250)
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
EndFunc   ;==>MoveItemFromStorageByModelID

;~ Description: Stacks items in specified bags to make room.
Func CleanUpStacks($aFirst = 1, $aEnd = 4, $aIncludeMatStorage = False)
   Local $lBagPtr, $lItemPtr, $lItemArrayPtr, $lEndThis
   Local $lModelID, $lQuantity, $a, $b, $lToMove
   ; create bagptr array with slots to reduce memoryreads
   Local $lBagPtrArray[$aEnd + 1][2]
   Local $lMaxSlots = 1
   For $i = $aFirst To $aEnd
	  If Not $aIncludeMatStorage And $i = 6 Then ContinueLoop
	  $lBagPtr = GetBagPtr($i)
	  If $lBagPtr = 0 Then
		 $lBagPtrArray[$i][0] = 0
		 $lBagPtrArray[$i][1] = 0
	  Else
		 $lBagPtrArray[$i][0] = $lBagPtr
		 $lBagPtrArray[$i][1] = MemoryRead($lBagPtr + 32, 'long')
		 $lMaxSlots += $lBagPtrArray[$i][1]
	  EndIf
   Next
   ; create array of modelids to stack
   Local $lArray[$lMaxSlots][5]
   Local $lTempArray[$lMaxSlots][4]
   Local $lCount = 0
   Local $lTempCount = 0
   For $i = $aFirst To $aEnd
	  If Not $aIncludeMatStorage And $i = 6 Then ContinueLoop ; ignore mat storage
	  $lBagPtr = $lBagPtrArray[$i][0]
	  If $lBagPtr = 0 Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $j = 0 To $lBagPtrArray[$i][1] - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * $j, 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 $lModelID = MemoryRead($lItemPtr + 44, 'long')
		 If $lModelID = 146 Then ContinueLoop
		 $lQuantity = MemoryRead($lItemPtr + 75, 'byte')
		 If $lQuantity > 1 And $lQuantity < 250 Then ; stack
			$lCount += 1
			$lArray[$lCount][0] = $lItemPtr
			$lArray[$lCount][1] = $i
			$lArray[$lCount][2] = $j + 1
			$lArray[$lCount][3] = $lModelID
			$lArray[$lCount][4] = $lQuantity
		 ElseIf $lQuantity = 1 Then ; not yet a stack?
			If StackableItems($lModelID, 1) Then ; but only if stackable
			   $lCount += 1
			   $lArray[$lCount][0] = $lItemPtr
			   $lArray[$lCount][1] = $i
			   $lArray[$lCount][2] = $j + 1
			   $lArray[$lCount][3] = $lModelID
			   $lArray[$lCount][4] = $lQuantity
			Else ; stragglers
			   $lTempArray[$lTempCount][0] = $lItemPtr
			   $lTempArray[$lTempCount][1] = $i
			   $lTempArray[$lTempCount][2] = $j + 1
			   $lTempArray[$lTempCount][3] = $lModelID
			   $lTempCount += 1
			EndIf
		 EndIf
	  Next
   Next
   $lArray[0][0] = $lCount
   $lBagPtrArray = 0 ; no need for bagptrs anymore
   ; add stragglers
   For $i = 0 To $lTempCount - 1
	  ; check in $lArray
	  For $j = 1 To $lArray[0][0]
		 If $lTempArray[$i][3] = $lArray[$j][3] Then
			$lCount += 1
			$lArray[$lCount][0] = $lTempArray[$i][0]
			$lArray[$lCount][1] = $lTempArray[$i][1]
			$lArray[$lCount][2] = $lTempArray[$i][2]
			$lArray[$lCount][3] = $lTempArray[$i][3]
			$lArray[$lCount][4] = 1
		 EndIf
	  Next
   Next
   $lTempArray = 0
   $lArray[0][0] = $lCount
   ; the actual cleaning up
   For $i = 1 To $lArray[0][0]
	  If $lArray[$i][4] >= 250 Or $lArray[$i][4] <= 0 Then ContinueLoop ; ignore full and empty stacks
	  For $j = 1 To $lArray[0][0]
		 If $j = $i Then ContinueLoop ; obvious
		 If $lArray[$i][3] = $lArray[$j][3] Then ; same modelid
			; switch it up when matstorage, to move TO matstorage and not FROM matstorage
			If $lArray[$j][1] = 6 Then
			   $a = $i ; source
			   $b = $j ; destination
			Else
			   $a = $j ; source
			   $b = $i ; destination
			EndIf
			$lToMove = 250 - $lArray[$b][4] ; destination stack cant get bigger than 250 obviously
			If $lToMove > $lArray[$a][4] Then $lToMove = $lArray[$a][4] ; cant move amounts bigger than source stack
			MoveItemEx($lArray[$a][0], $lArray[$b][1], $lArray[$b][2], $lToMove)
			$lEndThis = False
			For $k = 1 To 20 ; approx 5 seconds
			   Sleep(250)
			   If MemoryRead($lArray[$a][0] + 75, 'byte') <> $lArray[$a][4] Then
				  $lArray[$a][4] = $lArray[$a][4] - $lToMove
				  $lArray[$b][4] = $lArray[$b][4] + $lToMove
				  ExitLoop
			   EndIf
			   If MemoryRead($lArray[$a][0] + 12, 'ptr') = 0 Then ; source stack gone
				  $lArray[$a][4] = 0
				  $lArray[$b][4] = $lArray[$b][4] + $lToMove
				  ExitLoop
			   EndIf
			Next
		 EndIf
	  Next
   Next
   Return True
EndFunc   ;==>CleanUpStacks
#EndRegion MainFunctions

#Region EvaluateItems
;~ Description: Return true of item is a stackable item.
Func StackableItems($aModelID, $aMats = 0)
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
	  ; materials
	  Case 921 to 923, 925 to 946, 948 to 956, 6532, 6533
		 Return $aMats
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>StackableItems

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

;~ Description: Returns true if item is a weapon.
Func IsWeapon($aType)
   Switch $aType
	  Case 2,5,12,15,22,24,26,27,32,35,36
		 Return $aType
   EndSwitch
EndFunc   ;==>IsWeapon

;~ Description: Checks if Itemptr is armor. Returns 0 if not.
Func IsArmor($aType)
   Switch $aType
	  Case 4, 7, 13, 16, 19
		 Return $aType
   EndSwitch
EndFunc   ;==>IsArmor

;~ Description: Returns 1 if item contains insignia to keep, 2 if item contains rune to keep.
Func Upgrades($aItemPtr)
;~    Local $tagModArray = ''
;~    Local $lModStruct = MemoryReadStruct($aItemPtr + 16, 'ptr;DWORD')
;~    Local $lMod = MemoryRead(DllStructGetData($lModStruct, 1), 'byte[' & DllStructGetData($lModStruct, 2) * 4 & ']')
;~ For $i = 1 To DllStructGetData($lModStruct, 2)
;~ 	$tagModArray &= 'BYTE;BYTE;WORD;'
;~ Next




;~    Local $numEnd = (UBound($Rune_Insigmia) -1)
;~    For $i =  0 to $numEnd
;~ 	  If ($Rune_Insigmia[$i][5] == 'True') And (StringInStr($lMod, $Rune_Insigmia[$i][0]) <> 0) Then Return $Rune_Insigmia[$i][1]
;~    Next
;~    Return -1
EndFunc   ;==>Upgrades


Func WeaponMods(Const ByRef $aItemPtr)
;~ Local $lModStruct = MemoryReadStruct($aItemPtr + 0x10, 'ptr;dword')
;~    Local $lMod = MemoryRead(DllStructGetData($lModStruct, 1), 'byte[' & DllStructGetData($lModStruct, 2) * 4 & ']')


;~ Local $1 , $2, $3, $tagModArray, $return
;~ For $i = 1 To DllStructGetData($lModStruct, 2)
;~ 	$tagModArray &= 'BYTE;BYTE;WORD;'
;~ Next

;~ Local $tModArray = MemoryReadToStruct(4 * DllStructGetData($lModStruct, 2), $tagModArray)
;~ For $i = 0 To DllStructGetData($lModStruct, 2) - 1
;~ 	$1 = Hex(DllStructGetData($tModArray,$i * 3 + 3), 4)
;~ 	$2 = DllStructGetData($tModArray,$i * 3 + 1)
;~ 	$3 = DllStructGetData($tModArray,$i * 3 + 2)
;~ 	ConsoleWrite($1 & "  " & $2 & "  " & $3 & @CRLF)
;~ 	$return = CheckModArray($aItemPtr, $1, $2, $3)
;~ Next



;~ Return $return > 0 ? $return : -1
;~ EndFunc   ;==>WeaponMods

;~ Func CheckModArray(Const ByRef $aItemPtr,Const ByRef $1_,Const ByRef $2_,Const ByRef $3_)

;~    Local $numEnd = (UBound($Weapon_Mods) -1)

;~    For $i = 0 To $numEnd
;~ 	If ($Weapon_Mods[$i][13] == 'True') And (MemoryRead($aItemPtr + 32, 'byte') = $Weapon_Mods[$i][10]) Then

;~ 		If (StringInStr($lMod, $Weapon_Mods[$i][0] , 1) <> 0) Then
;~ 			Local $Num_left = StringTrimLeft($Weapon_Mods[$i][1], 2)
;~ 			Local $Num_right = StringTrimRight($Weapon_Mods[$i][1], 2)
;~ 			;Local $_array = StringRegExp($lMod, '(.{2})(.{2})' & $Weapon_Mods[$i][1], 3)

;~ 			;If IsArray($_array) Then
;~ 				_ArrayDisplay($_array, "$_array")
;~ 				If ($Weapon_Mods[$i][11] == 4)  And ($Weapon_Mods[$i][12] == 2) Then
;~ 					If ($_array[0] == $Weapon_Mods[$i][8]) And ($_array[1] == $Weapon_Mods[$i][9]) Then

;~ 						ConsoleWrite($Weapon_Mods[$i][5] & @CRLF)
;~ 						ConsoleWrite($Weapon_Mods[$i][4] & @CRLF & @CRLF)

;~ 						Return $Weapon_Mods[$i][4];mod Pos
;~ 					EndIf
;~ 				ElseIf ($Weapon_Mods[$i][11] == 'False')  And ($Weapon_Mods[$i][12] == 2) Then
;~ 					If ($_array[1] == $Weapon_Mods[$i][9]) Then

;~ 						ConsoleWrite($Weapon_Mods[$i][5] & @CRLF)
;~ 						ConsoleWrite($Weapon_Mods[$i][4] & @CRLF & @CRLF)

;~ 						Return $Weapon_Mods[$i][4];mod Pos
;~ 					EndIf
;~ 				ElseIf ($Weapon_Mods[$i][12] == 'False')  And ($Weapon_Mods[$i][11] == 4) Then
;~ 					If ($_array[0] == $Weapon_Mods[$i][8]) Then

;~ 						ConsoleWrite($Weapon_Mods[$i][5] & @CRLF)
;~ 						ConsoleWrite($Weapon_Mods[$i][4] & @CRLF & @CRLF)

;~ 						Return $Weapon_Mods[$i][4];mod Pos
;~ 					EndIf
;~ 				EndIf

;~ 			;EndIf

;~ 		EndIf
;~ 	EndIf
;~    Next

EndFunc
;~ Description: Returns 1 for Rune, 2 for Insignia, 0 if not found.
Func IsRuneOrInsignia($aModelID)
   Switch $aModelID
	  Case 903, 5558, 5559 ; Warrior Runes
		 Return 1
	  Case 19152 to 19156 ; Warrior Insignias
		 Return 2
	  Case 5560, 5561, 904 ; Ranger Runes
		 Return 1
	  Case 19157 to 19162 ; Ranger Insignias
		 Return 2
	  Case 5556, 5557, 902 ; Monk Runes
		 Return 1
	  Case 19149 to 19151 ; Monk Insignias
		 Return 2
	  Case 5552, 5553, 900 ; Necromancer Runes
		 Return 1
	  Case 19138 to 19143 ; Necromancer Insignias
		 Return 2
	  Case 3612, 5549, 899 ; Mesmer Runes
		 Return 1
	  Case 19128, 19130, 19129 ; Mesmer Insignias
		 Return 2
	  Case 5554, 5555, 901 ; Elementalist Runes
		 Return 1
	  Case 19144 to 19148 ; Elementalist Insignias
		 Return 2
	  Case 6327 to 6329 ; Ritualist Runes
		 Return 1
	  Case 19165 to 19167 ; Ritualist Insignias
		 Return 2
	  Case 6324 to 6326 ; Assassin Runes
		 Return 1
	  Case 19124 to 19127 ; Assassin Insignia
		 Return 2
	  Case 15545 to 15547 ; Dervish Runes
		 Return 1
	  Case 19163 to 19164 ; Dervish Insignias
		 Return 2
	  Case 15548 to 15550 ; Paragon Runes
		 Return 1
	  Case 19168  ; Paragon Insignias
		 Return 2
	  Case 5550, 5551, 898 ; All Profession Runes
		 Return 1
	  Case 19131 to 19137 ; All Profession Insignias
		 Return 2
   EndSwitch
EndFunc   ;==>IsRuneOrInsignia

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

;~ Description: Returns true if aItem is a normal material.
Func GetIsNormalMaterial($aItem)
   If IsPtr($aItem) <> 0 Then
	  Local $lItemMID = MemoryRead($aItem + 44, 'long')
   ElseIf IsDllStruct($aItem) <> 0 Then
	  Local $lItemMID = DllStructGetData($aItem, 'ModelID')
   Else
	  Local $lItemMID = $aItem
   EndIf
   Switch $lItemMID
	  Case 921, 954, 925, 929, 933, 934, 955, 948, 953, 940, 946
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>GetIsNormalMaterial
#EndRegion EvaluateItems

#Region EmptySlots
;~ Description: Returns next empty slot, start at $aBag, $aSlot. Returns 0 if there's no empty slot in this bag.
Func UpdateEmptySlot(ByRef $aBagNr, ByRef $aSlot)
   Local $lBagPtr, $lItemArrayPtr, $lSlotPtr, $lBagNr, $lSlot
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
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lSlotPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lSlotPtr = 0 Then
			$aBagNr = $bag
			$aSlot = $slot + 1
			Return True
		 EndIf
	  Next
	  $lSlot = 1
   Next
   Return True
EndFunc   ;==>UpdateEmptySlot

;~ Description: Returns next empty slot, start at $aBag, $aSlot. Returns 0 if there's no empty slot in this bag.
Func UpdateEmptyStorageSlot(ByRef $aBagNr, ByRef $aSlot)
   Local $lBagPtr, $lItemArrayPtr, $lSlotPtr, $lBagNr, $lSlot
   If $aBagNr < 0 Then
	  $aSlot = 0
	  Return ; no empty storage slots left
   EndIf
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
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 19 To $lSlot - 1 Step -1
		 $lSlotPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lSlotPtr = 0 Then
			$aBagNr = $bag
			$aSlot = $slot + 1
			Return True
		 EndIf
	  Next
	  $lSlot = 1
   Next
   Return True
EndFunc   ;==>UpdateEmptyStorageSlot
#EndRegion

#Region GoToMerchant
;~ Description: Go to merchant and co, if playernumber wasnt found go to xunlai chest and try again.
Func GoToMerchant($aPlayernumber, $aMyID = GetMyID(), $aMe = GetAgentPtr($aMyID))
   ; first try
   Update("Trying to find Merchant.")
   Local $lAgentArray = GetAgentPtrArray()
   For $i = 1 To $lAgentArray[0]
	  If MemoryRead($lAgentArray[$i] + 244, 'word') = $aPlayernumber Then
		 GoToNPC($lAgentArray[$i], $aMyID, $aMe)
		 Sleep(500)
		 Return Dialog(0x7F)
	  EndIf
   Next
   ; merchant wasnt found, next try, but first... go to chest
   Update("No Merchant found, try for chest.")
   For $i = 1 To $lAgentArray[0]
	  If MemoryRead($lAgentArray[$i] + 244, 'word') = 4991 Then
		 GoToNPC($lAgentArray[$i], $aMyID, $aMe)
		 ExitLoop
	  EndIf
   Next
   ; aaaaand... try again to find merchant
   Update("Trying to find Merchant, again.")
   $lAgentArray = GetAgentPtrArray()
   For $i = 1 To $lAgentArray[0]
	  If MemoryRead($lAgentArray[$i] + 244, 'word') = $aPlayernumber Then
		 GoToNPC($lAgentArray[$i], $aMyID, $aMe)
		 Sleep(500)
		 Return Dialog(0x7F)
	  EndIf
   Next
EndFunc   ;==>GoToMerchant

;~ Description: Return merchant depending on MapID.
Func GetMerchant($aMapID)
   Switch $aMapID
	  Case 4, 5, 6, 52, 176, 177, 178, 179 ; proph gh
		 Return 209
	  Case 275, 276, 359, 360, 529, 530, 537, 538 ; factions and nf gh
		 Return 196
	  Case 10, 11, 12, 139, 141, 142, 49, 857
		 Return 2036
	  Case 109, 120, 154
		 Return 1993
	  Case 116, 117, 118, 152, 153, 38
		 Return 1994
	  Case 122, 35
		 Return 2136
	  Case 123, 124
		 Return 2137
	  Case 129, 348, 390
		 Return 3402
	  Case 130, 218, 230, 287, 349, 388
		 Return 3403
	  Case 131, 21, 25, 36
		 Return 2086
	  Case 132, 135, 28, 29, 30, 32, 39, 40
		 Return 2101
	  Case 133, 155, 156, 157, 158, 159, 206, 22, 23, 24
		 Return 2107
	  Case 134, 81
		 Return 2011
	  Case 136, 137, 14, 15, 16, 19, 57, 73
		 Return 1989
	  Case 138
		 Return 1975
	  Case 193, 234, 278, 288, 391
		 Return 3618
	  Case 194, 213, 214, 225, 226, 242, 250, 283, 284, 291, 292
		 Return 3275
	  Case 216, 217, 249, 251
		 Return 3271
	  Case 219, 224, 273, 277, 279, 289, 297, 350, 389
		 Return 3617
	  Case 220, 274, 51
		 Return 3273
	  Case 222, 272, 286, 77
		 Return 3401
	  Case 248
		 Return 1207
	  Case 303
		 Return 3272
	  Case 376, 378, 425, 426, 477, 478
		 Return 5385
	  Case 381, 387, 421, 424, 427, 554
		 Return 5386
	  Case 393, 396, 403, 414, 476
		 Return 5666
	  Case 398, 407, 428, 433, 434, 435
		 Return 5665
	  Case 431
		 Return 4721
	  Case 438, 545
		 Return 5621
	  Case 440, 442, 469, 473, 480, 494, 496
		 Return 5613
	  Case 450, 559
		 Return 4989
	  Case 474, 495
		 Return 5614
	  Case 479, 487, 489, 491, 492, 502, 818
		 Return 4720
	  Case 555
		 Return 4988
	  Case 624
		 Return 6758
	  Case 638
		 Return 6060
	  Case 639, 640
		 Return 6757
	  Case 641
		 Return 6063
	  Case 642
		 Return 6047
	  Case 643, 645, 650
		 Return 6383
	  Case 644
		 Return 6384
	  Case 648
		 Return 6589
	  Case 652
		 Return 6231
	  Case 675
		 Return 6190
	  Case 808
		 Return 7448
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
		 Return 2017
	  Case 193
		 Return 3624
	  Case 194, 242, 857
		 Return 3285
	  Case 250
		 Return 3286
	  Case 376
		 Return 5391
	  Case 398
		 Return 5671
	  Case 414
		 Return 5674
	  Case 424
		 Return 5392
	  Case 433
		 Return 5672
	  Case 438
		 Return 5624
	  Case 491
		 Return 4726
	  Case 492
		 Return 4727
	  Case 638
		 Return 6763
	  Case 640
		 Return 6764
	  Case 641
		 Return 6065
	  Case 642
		 Return 6050
	  Case 643
		 Return 6389
	  Case 644
		 Return 6390
	  Case 652
		 Return 6233
	  Case 77
		 Return 3415
	  Case 808
		 Return 7452
	  Case 818
		 Return 4729
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
		 Return 2003
	  Case 193
		 Return 3627
	  Case 194, 250, 857
		 Return 3288
	  Case 242
		 Return 3287
	  Case 376
		 Return 5394
	  Case 398, 433
		 Return 5673
	  Case 414
		 Return 5674
	  Case 424
		 Return 5393
	  Case 438
		 Return 5619
	  Case 49
		 Return 2044
	  Case 491, 818
		 Return 4729
	  Case 492
		 Return 4728
	  Case 638
		 Return 6766
	  Case 640
		 Return 6765
	  Case 641
		 Return 6066
	  Case 642
		 Return 6051
	  Case 643
		 Return 6392
	  Case 644
		 Return 6391
	  Case 652
		 Return 6234
	  Case 77
		 Return 3416
	  Case 81
		 Return 2089
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
		 Return 2005
	  Case 193
		 Return 3630
	  Case 194, 242, 250
		 Return 3291
	  Case 248, 857
		 Return 1981
	  Case 396
		 Return 5678
	  Case 414
		 Return 5677
	  Case 438
		 Return 5626
	  Case 477
		 Return 5396
	  Case 487
		 Return 4732
	  Case 49
		 Return 2045
	  Case 502
		 Return 4733
	  Case 624
		 Return 6770
	  Case 640
		 Return 6769
	  Case 642
		 Return 6052
	  Case 643, 645
		 Return 6395
	  Case 644
		 Return 6396
	  Case 77
		 Return 3421
	  Case 808
		 Return 7456
	  Case 81
		 Return 2091
	  Case 818
		 Return 4711
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
		 Return 2016
	  Case 193
		 Return 3623
	  Case 194, 242
		 Return 3284
	  Case 250
		 Return 3283
	  Case 286
		 Return 3408
	  Case 381, 477
		 Return 5389
	  Case 403
		 Return 5669
	  Case 414
		 Return 5670
	  Case 640
		 Return 6762
	  Case 642
		 Return 6049
	  Case 644
		 Return 6388
	  Case 77
		 Return 3407
	  Case 812
		 Return 2113
	  Case 818
		 Return 4725
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
		 Return 2004
	  Case 193
		 Return 3629
	  Case 194
		 Return 3289
	  Case 287
		 Return 3419
	  Case 396, 414
		 Return 5675
	  Case 426, 857
		 Return 5398
	  Case 442, 480
		 Return 5627
	  Case 49
		 Return 2046
	  Case 624
		 Return 6767
	  Case 638
		 Return 6062
	  Case 639, 640
		 Return 6768
	  Case 643, 644
		 Return 6393
	  Case 645
		 Return 6394
	  Case 77
		 Return 3418
	  Case 808
		 Return 7454
   EndSwitch
EndFunc   ;==>GetScrollTrader
#EndRegion GoToMerchant


Func DisconnectCheck_()
Opt("SendKeyDelay", 500)
Local $state = False
Static Local $gs_obj = GetValue('PacketLocation')
Local $deadlock = TimerInit()
While MemoryRead($gs_obj ) = 0 ; While Disconnected
    ControlSend($mGWHwnd,'','','{ENTER} {ENTER}') ; Hit enter key until you log back in
    Sleep(Random(5000,10000,1))
    If TimerDiff($deadlock) >= 30000 Then Return $state
WEnd
Opt("SendKeyDelay", 5);5 is default
If Not $state Then $state = True

Return $state
EndFunc
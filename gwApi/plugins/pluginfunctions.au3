#include-once

#cs
   Functions for asm plugins.
   SetPluginVariables() at end of file.
#ce
;Global $mLastPacket
;Global $mLastPacketSize
;_('LastPacketSent/' & 512 * GetValue('PacketLogSize'))
;_('LastPacketSize/4')
;_('LastPacketBase/4')
#CS
Case 'push edi'
	$lOpCode = '57';<---
Case 'mov ebp,esp'
	$lOpCode = '8BEC';<---
Case 'mov edi,dword[ecx]';<-------
	$lOpCode = '368B39'
Case 'mov dword[eax],edi';<------
	$lOpCode = '368938'
Case 'cmp ecx,ebp'
	$lOpCode = '39E9';<----
#CE


#Region DialogLogEx
Global $mLastDialogId = 0

;~ Description: Returns last DialogID in ascii.
Func GetLastDialogId()
   Return MemoryRead($mLastDialogId)
EndFunc   ;==>GetLastDialogId

;~ Description: Last DialogID as hex.
Func GetLastDialogIdHex()
   Local $DialogHex = MemoryRead($mLastDialogId)
   Return "0x" & StringReplace(Hex($DialogHex, 8), StringRegExpReplace(Hex($DialogHex, 8), "[^0].*", ""), "")
EndFunc   ;==>GetLastDialogIdHex

;~ Description: Returns available dialogs of active dialog as a DllStruct, size is in @extended.
Func GetAvailableDialogs()
   Static Local $lSizePtr = 0
   Static Local $lButtonsBase = 0
   If $lSizePtr = 0 Then $lSizePtr = GetValue('LastDialogButtonsSize')
   If $lButtonsBase = 0 Then $lButtonsBase = GetValue('LastDialogButtons')
   Local $lSize = MemoryRead($lSizePtr)
   If $lSize <= 0 Then Return
   Local $lReturn = DllStructCreate('dword[' & $lSize & ']')
   MemoryReadToStruct($lButtonsBase, $lReturn)
   Return SetExtended($lSize, $lReturn)
EndFunc

;~ Description: Returns last dialog sender.
Func GetLastDialogSender()
   Static Local $lDialogSenderPtr = 0
   If $lDialogSenderPtr = 0 Then $lDialogSenderPtr = GetValue('LastDialogSender')
   Return MemoryRead($lDialogSenderPtr)
EndFunc
#EndRegion

#Region MakeAgentArrayEx
Global $mMakeAgentArrayEx = DllStructCreate('ptr;dword;dword')
Global $mMakeAgentArrayExPtr = DllStructGetPtr($mMakeAgentArrayEx)

;~ Description: Pulls only ptrs instead of whole struct from memory, uses internal ASM function.
Func GetAgentPtrArrayASM($aMode = 0, $aType = 0xDB, $aAllegiance = 3)
   If $aMode = Default Then $aMode = 0
   If $aType = Default Then $aType = 0xDB
   If $aAllegiance = Default Then $aAllegiance = 3
   If $aMode = 0 Then
	  $aType = 0
	  $aAllegiance = 0
   EndIf
   Local $lCount
   MemoryWrite($mAgentCopyCount, -1, 'long')
   ConsoleWrite(Ptr(DllStructGetData($mMakeAgentArrayEx, 1)) & Ptr($mAgentCopyCount) & @CRLF)
   DllStructSetData($mMakeAgentArrayEx, 2, $aType)
   DllStructSetData($mMakeAgentArrayEx, 3, $aAllegiance)
   Enqueue($mMakeAgentArrayExPtr, 12)
   Local $lDeadlock = TimerInit()
   Do
	  $lCount = MemoryRead($mAgentCopyCount, 'long')
   Until $lCount >= 0 Or TimerDiff($lDeadlock) > 5000
   If $lCount < 0 Or $lCount > 256 Then $lCount = 0
   Local $lBuffer = DllStructCreate("ptr[" & $lCount & "]")
   DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'handle', $mGWProcHandle, 'ptr', $mAgentCopyBase, 'struct*', $lBuffer, 'ulong_ptr', $lCount * 4, 'ulong_ptr*', 0)
   Local $lReturnArray[$lCount + 1]
   For $i = 1 To $lCount
	  $lReturnArray[$i] = DllStructGetData($lBuffer, 1, $i)
   Next
   $lReturnArray[0] = $lCount
   Return $lReturnArray
EndFunc   ;==>GetAgentPtrArrayASM
#EndRegion

#Region CraftItemEx
Global $mCraftItemEx = DllStructCreate('ptr;dword;dword;ptr;dword;dword')
Global $mCraftItemExPtr = DllStructGetPtr($mCraftItemEx)

;~ Description: Crafts an item. Crafter merchant window has to be opened and mats and gold have to be in inventory/on character.
;~ Return 0: prerequisites not met ($aMatsarray not an array, ItemModelID not part of merchantbase, not enough memory)
;~ Return ModelID: of missing mats -> @extended = amount of missing mats
;~ Return True: function finished -> @extended = 0 if items got crafted, <> 0 if crafting failed
;~ Parameter 1: ModelID of item to be crafted
;~ Parameter 2: Amount of items to craft
;~ Parameter 3: Amount of gold needed to craft one item
;~ Parameter 4: MatsArray[ [Mat1ModelID, Mat1Amount], _
;~ 						   [Mat2ModelID, Mat2Amount], _
;~ 						   [Mat3ModelID, Mat3Amount], _
;~ 						   [MatNModelID, MatNAmount]]
;~ Requires: gwAPI_basics.au3, items.au3
;~ Part of: items.au3
;~ Author: Testytest.
Func CraftItemEx($aModelID, $aQuantity, $aGold, ByRef $aMatsArray)
   Local $lItemIDRow = GetItemRowByModelID($aModelID)
   If $lItemIDRow = 0 Then Return 0 ; modelID not found in merchantbase
   Local $lMatString = ''
   Local $lMatCount = 0
   If IsArray($aMatsArray) = 0 Then Return 0 ; mats are not in an array
   Local $lMatsArraySize = UBound($aMatsArray) - 1
   Local $lCheckQuantity
   For $i = $lMatsArraySize To 0 Step -1
	  $lCheckQuantity = CountItemInBagsByModelID($aMatsArray[$i][0])
	  If $aMatsArray[$i][1] * $aQuantity > $lCheckQuantity Then  ; not enough mats in inventory
		 Return SetExtended($aMatsArray[$i][1] * $aQuantity - $lCheckQuantity, $aMatsArray[$i][0]) ; amount of missing mats in @extended
	  EndIf
   Next
   Local $lCheckGold = GetGoldCharacter()
   For $i = 0 To $lMatsArraySize
	  $lMatString &= GetCraftMatsString($aMatsArray[$i][0], $aQuantity * $aMatsArray[$i][1])
	  $lMatCount += @extended
   Next
   Local $CraftMatsType = 'dword'
   For $i = 1 to $lMatCount - 1
	  $CraftMatsType &= ';dword'
   Next
   Local $CraftMatsBuffer = DllStructCreate($CraftMatsType)
   Local $CraftMatsPointer = DllStructGetPtr($CraftMatsBuffer)
   Local $lSize
   For $i = 1 To $lMatCount
	  $lSize = StringInStr($lMatString, ';')
	  DllStructSetData($CraftMatsBuffer, $i, StringLeft($lMatString, $lSize - 1))
	  $lMatString = StringTrimLeft($lMatString, $lSize)
   Next
   Local $lMemSize = $lMatCount * 4
   Local $lBufferMemory = DllCall($mKernelHandle, 'ptr', 'VirtualAllocEx', 'handle', $mGWProcHandle, 'ptr', 0, 'ulong_ptr', $lMemSize, 'dword', 0x1000, 'dword', 0x40)
   If $lBufferMemory = 0 Then Return 0 ; couldnt allocate enough memory
   Local $lBuffer = DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'int', $mGWProcHandle, 'int', $lBufferMemory[0], 'ptr', $CraftMatsPointer, 'int', $lMemSize, 'int', '')
   If $lBuffer = 0 Then Return 0
   DllStructSetData($mCraftItemEx, 2, $aQuantity)
   DllStructSetData($mCraftItemEx, 3, $lItemIDRow)
   DllStructSetData($mCraftItemEx, 4, $lBufferMemory[0])
   DllStructSetData($mCraftItemEx, 5, $lMatCount)
   DllStructSetData($mCraftItemEx, 6, $aQuantity * $aGold)
   Enqueue($mCraftItemExPtr, 24)
   Local $lCurrentQuantity
   Local $lDeadlock = TimerInit()
   Do
	  Sleep(250)
	  $lCurrentQuantity = CountItemInBagsByModelID($aMatsArray[0][0])
   Until $lCurrentQuantity <> $lCheckQuantity Or $lCheckGold <> GetGoldCharacter() Or TimerDiff($lDeadlock) > 5000
   Local $lRet = DllCall($mKernelHandle, 'ptr', 'VirtualFreeEx', 'handle', $mGWProcHandle, 'ptr', $lBufferMemory[0], 'int', 0, 'dword', 0x8000)
   Return SetExtended($lCheckQuantity - $lCurrentQuantity - $aMatsArray[0][1] * $aQuantity, $lRet <> 0) ; should be zero if items were successfully crafted
EndFunc   ;==>CraftItemEx

;~ Description: Internal use CraftItemEx. Returns item IDs of ModelIDs found in inventory as string, separate by ';'.
;~ Return: String of ItemIDs, separated by ';'
;~ @Extended: Amount of ItemIDs
;~ Parameter 1: ModelID
;~ Parameter 2: Amount needed
;~ Requires: gwAPI_basics.au3, items.au3
;~ Part of: items.au3
;~ Author: Testytest.
Func GetCraftMatsString($aModelID, $aAmount)
   Local $lCount = 0
   Local $lQuantity = 0
   Local $lMatString = ''
   Local $lBagPtr, $lItemArrayPtr, $lSlotPtr
   For $bag = 1 to 4
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop ; no valid bag
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lSlotPtr = MemoryRead($lItemArrayPtr + 4 * $slot, 'ptr')
		 If $lSlotPtr = 0 Then ContinueLoop ; empty slot
		 If MemoryRead($lSlotPtr + 44, 'long') = $aModelID Then
			$lMatString &= MemoryRead($lSlotPtr, 'long') & ';'
			$lCount += 1
			$lQuantity += MemoryRead($lSlotPtr + 75, 'byte')
			If $lQuantity >= $aAmount Then
			   Return SetExtended($lCount, $lMatString)
			EndIf
		 EndIf
	  Next
   Next
EndFunc   ;==>GetCraftMatsString
#EndRegion

#Region Upgrade
Global $mUpgrade = DllStructCreate('ptr;dword;dword;dword;dword')
Global $mUpgradePtr = DllStructGetPtr($mUpgrade)

;~ Description: Upgrades item with upgrade.
;~ UpgradeType -->
;~ 				  For armor: 	0 -> insignia
;~ 								1 -> rune
;~ 				  For weapons: 	0 -> prefix
;~ 							  	1 -> suffix
;~ 							  	2 -> inscription
Func Upgrade($aItemPtr, $aUpgradePtr, $aUpgradeType)
   Local $lItemID = MemoryRead($aItemPtr, 'long')
   Local $lUpgradeID = MemoryRead($aUpgradePtr, 'long')
   If $lItemID = 0 Or $lUpgradeID = 0 Then Return False
   DllStructSetData($mUpgrade, 2, 0)
   DllStructSetData($mUpgrade, 3, $aUpgradeType)
   DllStructSetData($mUpgrade, 4, $lItemID)
   DllStructSetData($mUpgrade, 5, $lUpgradeID)
   Enqueue($mUpgradePtr, 20)
   Sleep(1000 + GetPing())
   Sendpacket(0x4, 0x7C)
   Local $lDeadlock = TimerInit()
   Do
	  Sleep(250)
	  If MemoryRead($aUpgradePtr + 12, 'ptr') = 0 Then Return True
   Until TimerDiff($lDeadlock) > 5000
EndFunc   ;==>Upgrade
#EndRegion

#Region DrunkState
Global $mDrunkState = 0

;~ Description: Returns Drunklevel, starting with next drunklevel-change.
Func GetIsDrunk()
   Return MemoryRead($mDrunkState)
EndFunc
#EndRegion

#Region CollectItem
Global $mCollectItem = DllStructCreate('ptr func;dword IDItemToRecieve;dword CollectedItemAmount;dword IDofItemtoCollect')
Global $mCollectItemPtr = DllStructGetPtr($mCollectItem)

;~ Description: Crafts collector item.
;~ Author: 4D1.
Func CollectItem($aModelIDToGive, $aAmountNeededToGive, $aModelIDToRecieve)
   Local $lItemIDToGive = GetItemPtrByModelID($aModelIDToGive,True)
   If $lItemIDToGive = 0 Then
	  Return
   Else
	  $lItemIDToGive = MemoryRead($lItemIDToGive)
   EndIf
   Local $lItemIDtoRecieve = GetItemRowByModelID($aModelIDToRecieve)
   If $lItemIDtoRecieve = 0 Then Return
   DllStructSetData($mCollectItem, 'IDofItemtoCollect', $lItemIDToGive)
   DllStructSetData($mCollectItem, 'CollectedItemAmount', $aAmountNeededToGive)
   DllStructSetData($mCollectItem, 'IDItemToRecieve', $lItemIDtoRecieve)
   Enqueue($mCollectItemPtr,16)
EndFunc

;~ Description: Crafts multiple collector items.
;~ Author: 4D1.
Func CollectItemEx($aModelIDToGive, $aAmountNeededToGive, $aModelIDToRecieve, $aQuantity)
   Local $lItemPtrToGive = GetItemPtrByModelID($aModelIDToGive, True)
   Local $lItemIDToGive, $lQuantity
   If $lItemPtrToGive = 0 Then
	  Return
   Else
	  $lItemIDToGive = MemoryRead($lItemIDToGive)
   EndIf
   Local $lItemIDtoRecieve = GetItemRowByModelID($aModelIDToRecieve)
   If $lItemIDtoRecieve = 0 Then Return
   DllStructSetData($mCollectItem, 'IDofItemtoCollect', $lItemIDToGive)
   DllStructSetData($mCollectItem, 'CollectedItemAmount', $aAmountNeededToGive)
   DllStructSetData($mCollectItem, 'IDItemToRecieve', $lItemIDtoRecieve)
   For $i = 1 To $aQuantity
	  $lQuantity = MemoryRead($lItemPtrToGive + 75, 'byte')
	  If $lQuantity < $aAmountNeededToGive Then
		 $lItemPtrToGive = GetItemPtrByModelID($aModelIDToGive, True)
		 If $lItemPtrToGive = 0 Then
			Return
		 Else
			$lItemIDToGive = MemoryRead($lItemIDToGive)
			DllStructSetData($mCollectItem, 'IDofItemtoCollect', $lItemIDToGive)
		 EndIf
	  EndIf
	  Enqueue($mCollectItemPtr, 16)
	  Do
		 Sleep(100)
	  Until MemoryRead($lItemPtrToGive + 75, 'byte') < $lQuantity
   Next
EndFunc   ;==>CollectItemEx
#EndRegion

#Region SetPluginVariables
;~ Description: Set variables such as DllStruct at end of InitClient()
Func SetPluginVariables()
   ;; DialogLogEx ;;
   $mLastDialogId = GetValue('LastDialogID')
   ;; MakeAgentArrayEx ;;
   DllStructSetData($mMakeAgentArrayEx, 1, GetValue('CommandMakeAgentArrayEx'))
   $mAgentCopyCount = GetValue('AgentCopyCount')
   $mAgentCopyBase = GetValue('AgentCopyBase')
   ;; CraftItemEx ;;
   DllStructSetData($mCraftItemEx , 1, GetValue('CommandCraftItemEx'))
   ;; Upgrade ;;
   DllStructSetData($mUpgrade, 1, GetValue('CommandUpgrade'))
   ;; DrunkState ;;
   $mDrunkState = GetValue('DrunkState')
   ;; CollectItem ;;
   DllStructSetData($mCollectItem,'func',GetValue('CommandCollectItem'))
EndFunc
#EndRegion
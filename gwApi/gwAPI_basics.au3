#include-once

#Region CommandStructs
; Commands
Local $mPacket = DllStructCreate('ptr;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword')
Local $mPacketPtr = DllStructGetPtr($mPacket)

Local $mAction = DllStructCreate('ptr;dword;dword')
Local $mActionPtr = DllStructGetPtr($mAction)

Local $mUseSkill = DllStructCreate('ptr;dword;dword;dword')
Local $mUseSkillPtr = DllStructGetPtr($mUseSkill)

Local $mMove = DllStructCreate('ptr;float;float;float')
Local $mMovePtr = DllStructGetPtr($mMove)

Local $mChangeTarget = DllStructCreate('ptr;dword')
Local $mChangeTargetPtr = DllStructGetPtr($mChangeTarget)

Local $mToggleLanguage = DllStructCreate('ptr;dword')
Local $mToggleLanguagePtr = DllStructGetPtr($mToggleLanguage)

Local $mUseHeroSkill = DllStructCreate('ptr;dword;dword;dword')
Local $mUseHeroSkillPtr = DllStructGetPtr($mUseHeroSkill)

Local $mUpdateAgentPos = DllStructCreate('ptr;dword;dword;dword;dword;dword;dword')
Local $mUpdateAgentPosPtr = DllStructGetPtr($mUpdateAgentPos)

; Items
Local $mBuyItem = DllStructCreate('ptr;dword;dword;dword')
Local $mBuyItemPtr = DllStructGetPtr($mBuyItem)

Local $mSellItem = DllStructCreate('ptr;dword;dword')
Local $mSellItemPtr = DllStructGetPtr($mSellItem)

Local $mSalvage = DllStructCreate('ptr;dword;dword;dword')
Local $mSalvagePtr = DllStructGetPtr($mSalvage)

Local $mOpenStorage = DllStructCreate('ptr;dword;dword;dword;dword')
Local $mOpenStoragePtr = DllStructGetPtr($mOpenStorage)

Local $mGoNpc = DllStructCreate('ptr;dword;dword')
Local $mGoNpcPtr = DllStructGetPtr($mGoNpc)

; Trader
Local $mTraderBuy = DllStructCreate('ptr')
Local $mTraderBuyPtr = DllStructGetPtr($mTraderBuy)

Local $mTraderSell = DllStructCreate('ptr')
Local $mTraderSellPtr = DllStructGetPtr($mTraderSell)

Local $mRequestQuote = DllStructCreate('ptr;dword')
Local $mRequestQuotePtr = DllStructGetPtr($mRequestQuote)

Local $mRequestQuoteSell = DllStructCreate('ptr;dword')
Local $mRequestQuoteSellPtr = DllStructGetPtr($mRequestQuoteSell)

; Chat
Local $mSendChat = DllStructCreate('ptr;dword')
Local $mSendChatPtr = DllStructGetPtr($mSendChat)

Local $mWriteChat = DllStructCreate('ptr')
Local $mWriteChatPtr = DllStructGetPtr($mWriteChat)

; Attributes
Local $mSetAttributes = DllStructCreate("ptr;dword;dword;dword;dword;dword[16];dword;dword[16]")
Local $mSetAttributesPtr = DllStructGetPtr($mSetAttributes)

; Log
Local $mSkillLogStruct = DllStructCreate('dword;dword;dword;float')
Local $mSkillLogStructPtr = DllStructGetPtr($mSkillLogStruct)

Local $mChatLogStruct = DllStructCreate('dword;wchar[256]')
Local $mChatLogStructPtr = DllStructGetPtr($mChatLogStruct)
#EndRegion CommandStructs

#Region Memory
;~ Description: Open existing local process object.
Func MemoryOpen($aPID)
   $mKernelHandle = DllOpen('kernel32.dll')
   Local $lOpenProcess = DllCall($mKernelHandle, 'int', 'OpenProcess', 'int', 0x1F0FFF, 'int', 1, 'int', $aPID)
   $mGWProcHandle = $lOpenProcess[0]
   Return $lOpenProcess <> 0
EndFunc   ;==>MemoryOpen

;~ Description: Closes process handle opened with MemoryOpen.
Func MemoryClose()
   DllCall($mKernelHandle, 'int', 'CloseHandle', 'int', $mGWProcHandle)
   DllClose($mKernelHandle)
EndFunc   ;==>MemoryClose

;~ Description: Write a binarystring to an address inside opened process.
Func WriteBinary($aBinaryString, $aAddress, $aRestore = True)
   $aBinaryString = BinaryToString('0x' & $aBinaryString)
   Local $lSize = BinaryLen($aBinaryString)
   Local $lData = DllStructCreate('byte[' & $lSize & ']')
   If $aRestore Then
	  MemoryReadToStruct($aAddress, $lData)
	  AddRestoreDict($aAddress, DllStructGetData($lData, 1))
   EndIf
   DllStructSetData($lData, 1, $aBinaryString)
   Local $lRet = DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'handle', $mGWProcHandle, 'ptr', $aAddress, 'ptr', DllStructGetPtr($lData), 'ulong_ptr', DllStructGetSize($lData), 'ulong_ptr*', 0)
   Return SetExtended($lRet[5], $lRet <> 0)
EndFunc   ;==>WriteBinary

;~ Description: Writes data to specified address in opened process.
Func MemoryWrite($aAddress, $aData, $aType = 'dword', $aRestore = False)
   Local $lBuffer = DllStructCreate($aType)
   If $aRestore Then
	  MemoryReadToStruct($aAddress, $lBuffer)
	  AddRestoreDict($aAddress, $lBuffer)
   EndIf
   DllStructSetData($lBuffer, 1, $aData)
   Local $lRet = DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'handle', $mGWProcHandle, 'ptr', $aAddress, 'ptr', DllStructGetPtr($lBuffer), 'ulong_ptr', DllStructGetSize($lBuffer), 'ulong_ptr*', 0)
   Return SetExtended($lRet[5], $lRet <> 0)
EndFunc   ;==>MemoryWrite

;~ Description: Read process memory at specified address.
Func MemoryRead($aAddress, $aType = 'dword')
   Local $lBuffer = DllStructCreate($aType)
   DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'handle', $mGWProcHandle, 'ptr', $aAddress, 'ptr', DllStructGetPtr($lBuffer), 'ulong_ptr', DllStructGetSize($lBuffer), 'ulong_ptr*', 0)
   Return DllStructGetData($lBuffer, 1)
EndFunc   ;==>MemoryRead

;~ Description: Read a chain of pointers.
Func MemoryReadPtr($aAddress, $aOffset, $aType = 'dword')
   Local $lPointerCount = UBound($aOffset) - 2
   Local $lBuffer = DllStructCreate($aType)
   For $i = 0 To $lPointerCount
	  $aAddress += $aOffset[$i]
	  DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'handle', $mGWProcHandle, 'ptr', $aAddress, 'ptr', DllStructGetPtr($lBuffer), 'ulong_ptr', DllStructGetSize($lBuffer), 'ulong_ptr*', 0)
	  $aAddress = DllStructGetData($lBuffer, 1)
	  If $aAddress = 0 Then
		 Local $lData[2] = [0, 0]
		 Return $lData
	  EndIf
   Next
   $aAddress += $aOffset[$lPointerCount + 1]
   $lBuffer = DllStructCreate($aType)
   DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'handle', $mGWProcHandle, 'ptr', $aAddress, 'ptr', DllStructGetPtr($lBuffer), 'ulong_ptr', DllStructGetSize($lBuffer), 'ulong_ptr*', 0)
   Local $lData[2] = [$aAddress, DllStructGetData($lBuffer, 1)]
   Return $lData
EndFunc   ;==>MemoryReadPtr

;~ Description: Same as MemoryReadPtr, but returns memoryread + last $aOffset instead of array.
;~ $aOffset = [0, 0x18, 0x2C, 0] returns memoryread at 0x2C
;~ $aOffset = [0, 0x18, 0x2C] returns memoryread at 0x18 and adds to that memoryread 0x2C
Func MemoryReadPtrChain($aAddress, $aOffset, $aType = 'dword')
   Local $lPointerCount = UBound($aOffset) - 2
   Local $lBuffer = DllStructCreate($aType)
   For $i = 0 To $lPointerCount
	  $aAddress += $aOffset[$i]
	  DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'handle', $mGWProcHandle, 'ptr', $aAddress, 'ptr', DllStructGetPtr($lBuffer), 'ulong_ptr', DllStructGetSize($lBuffer), 'ulong_ptr', 0)
	  $aAddress = DllStructGetData($lBuffer, 1)
	  If $aAddress = 0 Then
		 Local $lData[2] = [0, 0]
		 Return $lData
	  EndIf
   Next
   $aAddress += $aOffset[$lPointerCount + 1]
   Return Ptr($aAddress)
EndFunc   ;==>MemoryReadPtrChain

;~ Description: Converts little endian to big endian and vice versa.
Func SwapEndian($aHex)
   If IsString($aHex) Then
	  $aHex = StringReplace($aHex, '0x', '', 1)
	  Return Hex(Binary(Dec($aHex)))
   Else
	  Return Hex(Binary($aHex))
   EndIf
EndFunc   ;==>SwapEndian

;~ Description: Converts little endian to big endian and vice versa.
Func SwapEndianOld($aHex)
   Return StringMid($aHex, 7, 2) & StringMid($aHex, 5, 2) & StringMid($aHex, 3, 2) & StringMid($aHex, 1, 2)
EndFunc   ;==>SwapEndian

;~ Description: Enqueue a pointer to data to be written to process memory.
Func Enqueue($aPtr, $aSize)
   If MemoryRead($mLoggedIn) <= 0 Then Return False
   Local $lRet = DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'handle', $mGWProcHandle, 'ptr', 256 * $mQueueCounter + $mQueueBase, 'ptr', $aPtr, 'ulong_ptr', $aSize, 'ulong_ptr*', 0)
   If $mQueueCounter = $mQueueSize Then
	  $mQueueCounter = 0
   Else
	  $mQueueCounter = $mQueueCounter + 1
   EndIf
   Return SetExtended($lRet[5], $lRet <> 0)
EndFunc   ;==>Enqueue

;~ Description: Reads consecutive values from memory to buffer struct.
;~ Author: 4D1.
Func MemoryReadStruct($aAddress, $aStruct = 'dword')
   Local $lBuffer = DllStructCreate($aStruct)
   DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'handle', $mGWProcHandle, 'ptr', $aAddress, 'ptr', DllStructGetPtr($lBuffer), 'ulong_ptr', DllStructGetSize($lBuffer), 'ulong_ptr*', 0)
   Return $lBuffer
EndFunc   ;==>MemoryReadStruct

;~ Description: Reads consecutive values from memory into referenced struct.
;~ Returns array if successful: [0] -> boolean
;~    					  		[5] -> bytes read
;~ Author: 4D1.
Func MemoryReadToStruct($aAddress, ByRef $aStructbuffer)
   Return DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'handle', $mGWProcHandle, 'ptr', $aAddress, 'ptr', DllStructGetPtr($aStructbuffer), 'ulong_ptr', DllStructGetSize($aStructbuffer), 'ulong_ptr*', 0)
EndFunc   ;==>MemoryReadStruct

;~ Description: Scans for bytestring, to be used after initialize.
Func ScanForPtr($aByteString, $aOffset = 0, $aLength = 8, $aStartAddr = 0x401000, $aEndAddr = 0x900000)
   Local $lSystemInfoBuffer = DllStructCreate('word;word;dword;ptr;ptr;dword;dword;dword;dword;word;word')
   DllCall($mKernelHandle, 'int', 'GetSystemInfo', 'ptr', DllStructGetPtr($lSystemInfoBuffer))
   Local $lBuffer = DllStructCreate('byte[' & DllStructGetData($lSystemInfoBuffer, 3) & ']')
   For $iAddr = $aStartAddr To $aEndAddr Step DllStructGetData($lSystemInfoBuffer, 3)
	  MemoryReadToStruct($iAddr, $lBuffer)
	  StringRegExp(DllStructGetData($lBuffer, 1), $aByteString, 1, 2)
	  If @error = 0 Then
		 Local $lStringPos = @extended - StringLen($aByteString) - 2
		 Local $lStart = $lStringPos + 2 + $aOffset + $aOffset
		 If $lStart > 0 And $lStart + $aLength <= StringLen(DllStructGetData($lBuffer, 1)) Then
			Return SetExtended(Dec(SwapEndian(StringMid(DllStructGetData($lBuffer, 1), $lStart, $aLength))), _
							   Ptr($iAddr + $aOffset - 1 + ($lStringPos/2)))
		 Else
			Local $lReturn = Ptr($iAddr + $aOffset + ($lStringPos/2))
			Return SetExtended(MemoryRead($lReturn, 'byte[' & $aLength/2 & ']'), $lReturn - 1)
		 EndIf
	  EndIf
   Next
   Return SetError(1, 0, "0x00000000")
EndFunc

;~ Description: Injects dll, no communicator.
;~ Author: 4D1.
Func InjectDll($aDllPath)
   If Not FileExists($aDllPath) Then Return SetError(2, "", False)
   If Not (StringRight($aDllPath, 4) == ".dll") Then Return SetError(3, "", False)

   Local $lDLL_Path = DllStructCreate("char[255]")
   DllCall($mKernelHandle, "DWORD", "GetFullPathNameA", "str", $aDllPath, "DWORD", 255, "ptr", DllStructGetPtr($lDLL_Path), "int", 0)
   If @error Then Return SetError(5, "", False)

   Local $hModule = DllCall($mKernelHandle, "DWORD", "GetModuleHandleA", "str", "kernel32.dll")
   If @error Then Return SetError(7, "", False)

   Local $lpStartAddress = DllCall($mKernelHandle, "DWORD", "GetProcAddress", "DWORD", $hModule[0], "str", "LoadLibraryA")
   If @error Then Return SetError(8, "", False)

   Local $lpParameter = DllCall($mKernelHandle, "DWORD", "VirtualAllocEx", "int", $mGWProcHandle, "int", 0, "ULONG_PTR", DllStructGetSize($lDLL_Path), "DWORD", 0x3000, "int", 4)
   If @error Then Return SetError(9, "", False)

   DllCall("kernel32.dll", "BOOL", "WriteProcessMemory", "int", $mGWProcHandle, "DWORD", $lpParameter[0], "str", DllStructGetData($lDLL_Path, 1), "ULONG_PTR", DllStructGetSize($lDLL_Path), "int", 0)
   If @error Then Return SetError(10, "", False)

   Local $hThread = DllCall($mKernelHandle, "int", "CreateRemoteThread", "DWORD", $mGWProcHandle, "int", 0, "int", 0, "DWORD", $lpStartAddress[0], "DWORD", $lpParameter[0], "int", 0, "int", 0)
   If @error Then Return SetError(11, "", False)

   Return SetError(0, "", True)
EndFunc   ;==>InjectDll
#EndRegion Memory

#Region Initialisation
;~ Description: Searches in $aGW specified client and calls MemoryOpen() on that client.
;~ Injects asm functions, detours etc. into that game client.
Func Initialize($aGW = CharacterSelector(), $aChangeTitle = True, $aUseStringLog = False, $aUseEventSystem = False)
   Local $lWinList
   Local $lCharname = 0
   $mChangeTitle = $aChangeTitle
   $mUseStringLog = $aUseStringLog
   $mUseEventSystem = $aUseEventSystem
   If IsString($aGW) Then ; Charactername
	  $lWinList = WinList("[CLASS:ArenaNet_Dx_Window_Class; REGEXPTITLE:^\D+$]")
	  For $i = 1 To $lWinList[0][0]
		 If StringInStr($lWinList[$i][0], 'Guild Wars Wiki') Then ContinueLoop
		 $mGWHwnd = $lWinList[$i][1]
		 MemoryOpen(WinGetProcess($mGWHwnd))
		 If $mGWProcHandle Then
			If StringRegExp(ScanForCharname(), $aGW) = 1 Then
			   $lCharname = $aGW
			   ExitLoop
			EndIf
		 EndIf
		 MemoryClose()
		 $mGWProcHandle = 0
	  Next
   Else ; Process ID
	  $lWinList = WinList()
	  For $i = 1 To $lWinList[0][0]
		 $mGWHwnd = $lWinList[$i][1]
		 If WinGetProcess($mGWHwnd) = $aGW Then
			MemoryOpen($aGW)
			$lCharname = ScanForCharname()
			ExitLoop
		 EndIf
	  Next
   EndIf
   Return InitClient($lCharname)
EndFunc

;~ Description: Injects asm functions, detours etc. into the game client.
;~ Formerly part of Initialize(). MemoryOpen() has to be called before calling InitiClient(), to get $mGWProcHandle.
;~ Also needed: $mGWHwnd.
Func InitClient($aCharname = '')
   If $mGWProcHandle = 0 Then Return 0 ; MemoryOpen() not successfully called.
   If $mLabelDict = 0 Then CreateLabelDict()
   $mGWTitleOld = WinGetTitle($mGWHwnd)
   If $mUsePlugins Then InitPlugins()
   Scan()
   $mBasePointer = MemoryRead(GetScannedAddress('ScanBasePointer', -3))
   SetValue('BasePointer', $mBasePointer)
   $mAgentBase = MemoryRead(GetScannedAddress('ScanAgentBase', 13))
   SetValue('AgentBase', $mAgentBase)
   $mMaxAgents = $mAgentBase + 8
   SetValue('MaxAgents', $mMaxAgents)
   $mMyID = $mAgentBase - 84
   SetValue('MyID', $mMyID)
   $mMapLoading = $mAgentBase - 240
   $mCurrentTarget = $mAgentBase - 1280
   SetValue('PacketLocation', MemoryRead(GetScannedAddress('ScanBaseOffset', -3)))
   SetValue('StorageFunction', GetScannedAddress('ScanStorage', -7))
   $mPing = MemoryRead(GetScannedAddress('ScanPing', -8))
   $mMapID = MemoryRead(GetScannedAddress('ScanMapID', 71))
   $mLastMapID = MemoryRead(GetScannedAddress('ScanLastMapID', 0x1A))
   $mLoggedIn = Ptr($mMapID - 0x7D4)
   $mLoggedCounter = GetValue('PacketLocation') + 0x14
   $mRegion = MemoryRead(GetScannedAddress('ScanRegion', 8))
   $mLanguage = MemoryRead(GetScannedAddress('ScanLanguage', 8)) + 12
   $mSkillBase = MemoryRead(GetScannedAddress('ScanSkillBase', 9))
   $mSkillTimer = MemoryRead(GetScannedAddress('ScanSkillTimer', -3))
   $mBuildNumber = MemoryRead(GetScannedAddress('ScanBuildNumber', 0x54))
   $mZoomStill = GetScannedAddress("ScanZoomStill", -1)
   $mZoomMoving = GetScannedAddress("ScanZoomMoving", 5)
   $mStorageSessionBase = MemoryRead(GetScannedAddress("ScanStorageSessionIDBase", - 3))
   $mDialogOwnerID = MemoryRead(GetScannedAddress('ScanDialogOwnerID', -0x14))
   Local $lTemp
   $lTemp = GetScannedAddress('ScanEngine', -16)
   SetValue('MainStart', $lTemp)
   SetValue('MainReturn', $lTemp + 5)
   ;; Rendering Mod ;;
   SetValue('RenderingMod', $lTemp + 116)
   SetValue('RenderingModReturn', $lTemp + 132 + 6)
   ;; TargetLog ;;
   $lTemp = GetScannedAddress('ScanTargetLog', 1)
   SetValue('TargetLogStart', $lTemp)
   SetValue('TargetLogReturn', $lTemp + 5)
   ;; SkillLog ;;
   $lTemp = GetScannedAddress('ScanSkillLog', 1)
   SetValue('SkillLogStart', $lTemp)
   SetValue('SkillLogReturn', $lTemp + 5)
   $lTemp = GetScannedAddress('ScanSkillCompleteLog', -4)
   SetValue('SkillCompleteLogStart', $lTemp)
   SetValue('SkillCompleteLogReturn', $lTemp + 5)
   $lTemp = GetScannedAddress('ScanSkillCancelLog', 5)
   SetValue('SkillCancelLogStart', $lTemp)
   SetValue('SkillCancelLogReturn', $lTemp + 6)
   ;; ChatLog ;;
   $lTemp = GetScannedAddress('ScanChatLog', 18)
   SetValue('ChatLogStart', $lTemp)
   SetValue('ChatLogReturn', $lTemp + 6)
   ;; TraderHook ;;
   $lTemp = GetScannedAddress('ScanTraderHook', -7)
   SetValue('TraderHookStart', $lTemp)
   SetValue('TraderHookReturn', $lTemp + 5)
   ;; StringLog ;;
   $lTemp = GetScannedAddress('ScanStringFilter1', -2)
   SetValue('StringFilter1Start', $lTemp)
   SetValue('StringFilter1Return', $lTemp + 5)
   $lTemp = GetScannedAddress('ScanStringFilter2', -2)
   SetValue('StringFilter2Start', $lTemp)
   SetValue('StringFilter2Return', $lTemp + 5)
   SetValue('StringLogStart', GetScannedAddress('ScanStringLog', 35))
   ;; LoadFinished ;;
   SetValue('LoadFinishedStart', GetScannedAddress('ScanLoadFinished', 1))
   SetValue('LoadFinishedReturn', GetScannedAddress('ScanLoadFinished', 6))
   ;; ObstructedHook ;;
   $lTemp = GetScannedAddress('ScanObstructedText', -0x1B)
   SetValue('ObstructedHookStart', $lTemp)
   SetValue('ObstructedHookReturn', $lTemp + 5)
   ;; Misc ;;
   SetValue('PostMessage', MemoryRead(GetScannedAddress('ScanPostMessage', 11)))
   SetValue('Sleep', MemoryRead(MemoryRead(GetValue('ScanSleep') + 8) + 3))
   SetValue('SalvageFunction', MemoryRead(GetValue('ScanSalvageFunction') + 8) - 18)
   SetValue('SalvageGlobal', MemoryRead(MemoryRead(GetValue('ScanSalvageGlobal') + 8) + 1))
   SetValue('MoveFunction', GetScannedAddress('ScanMoveFunction', 1))
   SetValue('UseSkillFunction', GetScannedAddress('ScanUseSkillFunction', 1))
   SetValue('ChangeTargetFunction', GetScannedAddress('ScanChangeTargetFunction', -119))
   SetValue('WriteChatFunction', GetScannedAddress('ScanWriteChatFunction', 1))
   SetValue('SellItemFunction', GetScannedAddress('ScanSellItemFunction', -85))
   SetValue('PacketSendFunction', GetScannedAddress('ScanPacketSendFunction', 1))
   SetValue('ActionBase', MemoryRead(GetScannedAddress('ScanActionBase', -9)))
   SetValue('ActionFunction', GetScannedAddress('ScanActionFunction', -5))
   SetValue('UseHeroSkillFunction', GetScannedAddress('ScanUseHeroSkillFunction', 0x7E7))
   SetValue('BuyItemFunction', GetScannedAddress('ScanBuyItemFunction', 1))
   SetValue('RequestQuoteFunction', GetScannedAddress('ScanRequestQuoteFunction', -2))
   SetValue('TraderFunction', GetScannedAddress('ScanTraderFunction', -71))
   SetValue('ClickToMoveFix', GetScannedAddress("ScanClickToMoveFix", 1))
   SetValue('UpdateAgentPositionFunction', GetScannedAddress('ScanUpdatePositionFunction', -0x95))
   SetValue('GoNpcFunction', GetScannedAddress('ScanGoNpcFunction', -0x9F))
   If $mUsePlugins Then AddPluginSetValues()
   ;; Size ;;
   SetValue('QueueSize', '0x00000010')
   SetValue('SkillLogSize', '0x00000010')
   SetValue('ChatLogSize', '0x00000010')
   SetValue('TargetLogSize', '0x00000200')
   SetValue('StringLogSize', '0x00000200')
   SetValue('CallbackEvent', '0x00000501')
   ModifyMemory()
   ;; Set global variables ;;
   $mQueueCounter = MemoryRead(GetValue('QueueCounter'))
   $mQueueSize = GetValue('QueueSize') - 1
   $mQueueBase = GetValue('QueueBase')
   $mTargetLogBase = GetValue('TargetLogBase')
   $mStringLogBase = GetValue('StringLogBase')
   $mMapIsLoaded = GetValue('MapIsLoaded')
   $mEnsureEnglish = GetValue('EnsureEnglish')
   $mTraderQuoteID = GetValue('TraderQuoteID')
   $mTraderCostID = GetValue('TraderCostID')
   $mTraderCostValue = GetValue('TraderCostValue')
   $mDisableRendering = GetValue('DisableRendering')
   $mAgentMovement = GetAgentMovementPtr()
   $mObstructed = GetValue('ObstructedState')
   $mCinematic = MemoryRead(GetScannedAddress('ScanCinematic', 0x23))

;~    Local $lTemp[4] = [0, 0x18, 0x2C, 0]
;~    $mBasePtr182C = MemoryReadPtrChain($mBasePointer, $lTemp, 'ptr')
;~    Local $lTemp[4] = [0, 0x18, 0x40, 0]
;~    $mBasePtr1840 = MemoryReadPtrChain($mBasePointer, $lTemp, 'ptr')
;~    Local $lTemp[4] = [0, 0x18, 0x4C, 0]
;~    $mBasePtr184C = MemoryReadPtrChain($mBasePointer, $lTemp, 'ptr')
;~    Local $lTemp = 0


   Local $lContextOffsets[3] = [0, 0x18, 0]
   Global $mContextPtr = MemoryReadPtrChain($mBasePointer, $lContextOffsets, 'ptr')

   $mBasePtr182C = MemoryRead($mContextPtr + 0x2C,'ptr')
   $mBasePtr1840 = MemoryRead($mContextPtr + 0x40,'ptr')
   $mBasePtr184C = MemoryRead($mContextPtr + 0x4C,'ptr')







   If $mUseEventSystem Then MemoryWrite(GetValue('CallbackHandle'), $mGUI)
   ;; commands ;;
   DllStructSetData($mPacket, 1, GetValue('CommandPacketSend'))
   DllStructSetData($mUseSkill, 1, GetValue('CommandUseSkill'))
   DllStructSetData($mMove, 1, GetValue('CommandMove'))
   DllStructSetData($mChangeTarget, 1, GetValue('CommandChangeTarget'))
   DllStructSetData($mToggleLanguage, 1, GetValue('CommandToggleLanguage'))
   DllStructSetData($mUseHeroSkill, 1, GetValue('CommandUseHeroSkill'))
   DllStructSetData($mUpdateAgentPos, 1, Getvalue('CommandUpdateAgentPos'))
   ;; Items ;;
   DllStructSetData($mBuyItem, 1, GetValue('CommandBuyItem'))
   DllStructSetData($mSellItem, 1, GetValue('CommandSellItem'))
   DllStructSetData($mSalvage, 1, GetValue('CommandSalvage'))
   DllStructSetData($mAction, 1, GetValue('CommandAction'))
   DllStructSetData($mOpenStorage, 1, GetValue('CommandOpenStorage'))
   ;; Trader ;;
   DllStructSetData($mTraderBuy, 1, GetValue('CommandTraderBuy'))
   DllStructSetData($mTraderSell, 1, GetValue('CommandTraderSell'))
   DllStructSetData($mRequestQuote, 1, GetValue('CommandRequestQuote'))
   DllStructSetData($mRequestQuoteSell, 1, GetValue('CommandRequestQuoteSell'))
   DllStructSetData($mGoNpc, 1, GetValue('CommandGoNpc'))
   ;; Chat ;;
   DllStructSetData($mSendChat, 1, GetValue('CommandSendChat'))
   DllStructSetData($mSendChat, 2, 0x5E)
   DllStructSetData($mWriteChat, 1, GetValue('CommandWriteChat'))
   ;; Attributes ;;
   DllStructSetData($mSetAttributes, 1, GetValue('CommandPacketSend'))
   DllStructSetData($mSetAttributes, 2, 0x90)
   DllStructSetData($mSetAttributes, 3, 9)
   If $mUsePlugins Then SetPluginVariables()
   If $mChangeTitle Then
	  If $aCharname = '' Then
		 WinSetTitle($mGWHwnd, '', 'Guild Wars - ' & GetCharname())
	  Else
		 WinSetTitle($mGWHwnd, '', 'Guild Wars - ' & $aCharname)
	  EndIf
   EndIf
   $mASMString = ''
   $mASMSize = 0
   $mASMCodeOffset = 0
   Return $mGWHwnd
EndFunc   ;==>Initialize

;~ Description: Get Value to Key in $mLabelDict.
Func GetValue($aKey)
   If $mLabelDict.Exists($aKey) Then
	  Return $mLabelDict($aKey)
   Else
	  Return -1
   EndIf
EndFunc   ;==>GetValue

;~ Description: Add Key and Value to $mLabelDict.
Func SetValue($aKey, $aValue)
   $mLabelDict($aKey) = Ptr($aValue)
EndFunc   ;==>SetValue

;~ Description: Creates dictionary object and sets keys to case insensitive.
Func CreateLabelDict()
   $mLabelDict = ObjCreate('Scripting.Dictionary')
   $mLabelDict.CompareMode = 1 ; keys -> case insensitive
EndFunc   ;==>CreateLabelDict

;~ Description: Returns Ptr to Agent Movement struct.
Func GetAgentMovementPtr()
   Static Local $Offset[4] = [0, 0x18, 0x8, 0xE8]
   Return MemoryReadPtr($mBasePointer, $Offset, 'ptr')[1]
EndFunc   ;==>GetAgentMovementPtr

;~ Description: Scans memory for listed patterns.
Func Scan()
   $mASMSize = 0
   $mASMCodeOffset = 0
   $mASMString = ''
   ;; Scan patterns ;;
   _('MainModPtr/4')
   _('ScanBasePointer:')
   AddPattern('85C0750F8BCE')
   _('ScanAgentBase:')
   AddPattern('568BF13BF07204')
   _('ScanEngine:')
   AddPattern('5356DFE0F6C441')
   _('ScanLoadFinished:')
   AddPattern('8B561C8BCF52E8')
   _('ScanPostMessage:')
   AddPattern('6A00680080000051FF15')
   _('ScanTargetLog:')
   AddPattern('5356578BFA894DF4E8')
   _('ScanChangeTargetFunction:')
   AddPattern('33C03BDA0F95C033')
   _('ScanMoveFunction:')
   AddPattern('558BEC83EC2056578BF98D4DF0')
   _('ScanPing:')
   AddPattern('908D41248B49186A30')
   _('ScanMapID:')
   AddPattern('B07F8D55')
   _('ScanLoggedIn:')
   AddPattern('85C07411B807')
   _('ScanRegion:')
   AddPattern('83F9FD7406')
   _('ScanLanguage:')
   AddPattern('C38B75FC8B04B5')
   _('ScanUseSkillFunction:')
   AddPattern('558BEC83EC1053568BD9578BF2895DF0')
   _('ScanChangeTargetFunction:')
   AddPattern('33C03BDA0F95C033')
   _('ScanPacketSendFunction:')
   AddPattern('558BEC83EC2C5356578BF985')
   _('ScanBaseOffset:')
   AddPattern('5633F63BCE740E5633D2')
   _('ScanWriteChatFunction:')
   AddPattern('558BEC5153894DFC8B4D0856578B')
   _('ScanSkillLog:')
   AddPattern('408946105E5B5D')
   _('ScanSkillCompleteLog:')
   AddPattern('741D6A006A40')
   _('ScanSkillCancelLog:')
   AddPattern('85C0741D6A006A42')
   _('ScanChatLog:')
   AddPattern('8B45F48B138B4DEC50')
   _('ScanSellItemFunction:')
   AddPattern('8B4D2085C90F858E')
   _('ScanStringLog:')
   AddPattern('893E8B7D10895E04397E08')
   _('ScanStringFilter1:')
   AddPattern('51568B7508578BF9833E00')
   _('ScanStringFilter2:')
   AddPattern('515356578BF933D28B4F2C')
   _('ScanActionFunction:')
   AddPattern('8B7D0883FF098BF175116876010000')
   _('ScanActionBase:')
   AddPattern('8B4208A80175418B4A08')
   _('ScanSkillBase:')
   AddPattern('8D04B65EC1E00505')
   _('ScanUseHeroSkillFunction:')
   AddPattern('8B782C8B333BB7')
   _('ScanBuyItemFunction:')
   AddPattern('558BEC81ECC000000053568B75085783FE108BFA8BD97614')
   _('ScanRequestQuoteFunction:')
   AddPattern('81EC9C00000053568B')
   _('ScanTraderFunction:')
   AddPattern('8B45188B551085')
   _('ScanTraderHook:')
   AddPattern('8955FC6A008D55F8B9BA')
   _('ScanSleep:')
   AddPattern('5F5E5B741A6860EA0000')
   _('ScanSalvageFunction:')
   AddPattern('8BFA8BD9897DF0895DF4')
   _('ScanSalvageGlobal:')
   AddPattern('8B018B4904A3')
   _('ScanSkillTimer:')
   AddPattern('85c974158bd62bd183fa64')
   _('ScanClickToMoveFix:')
   AddPattern('3DD301000074')
   _('ScanZoomStill:')
   AddPattern('3B448BCB')
   _('ScanZoomMoving:')
   AddPattern('50EB116800803B448BCE')
   _('ScanBuildNumber:')
   AddPattern('8D8500FCFFFF8D')
   _('ScanStorageSessionIDBase:')
   AddPattern('8D14768D14908B4208A80175418B4A0885C9')
   _('ScanStorage:')
   AddPattern('6A00BA12000000E87CCDFFFFBA120000008BCE')
   _('ScanUpdatePositionFunction:')
   AddPattern('8B46043B875401')
   _('ScanObstructedText:')
   AddPattern('8BC88B460C85C0894DEC')
   _('ScanCinematic:')
   AddPattern('568BF15783FE0A8BFA')
   _('ScanGoNpcFunction:')
   AddPattern('558BEC83EC285356578BF28BD9')
   _('ScanLastMapID:')
   AddPattern('7409578D4DAC')
   _('ScanDialogOwnerID:')
   AddPattern('75146A006A018BD38BCF')
   If $mUsePlugins Then AddPluginScans()
   ;; Scan engine ;;
   _('ScanProc:')
   _('pushad')
   _('mov ecx,401000')
   _('mov esi,ScanProc')
   _('ScanLoop:')
   _('inc ecx')
   _('mov al,byte[ecx]')
   _('mov edx,ScanBasePointer')
   ; Inner Loop ;
   _('ScanInnerLoop:')
   _('mov ebx,dword[edx]')
   _('cmp ebx,-1')
   _('jnz ScanContinue')
   _('add edx,50')
   _('cmp edx,esi')
   _('jnz ScanInnerLoop')
   _('cmp ecx,900000')
   _('jnz ScanLoop')
   _('jmp ScanExit')
   ; Continue ;
   _('ScanContinue:')
   _('lea edi,dword[edx+ebx]')
   _('add edi,C')
   _('mov ah,byte[edi]')
   _('cmp al,ah')
   _('jz ScanMatched')
   _('mov dword[edx],0')
   _('add edx,50')
   _('cmp edx,esi')
   _('jnz ScanInnerLoop')
   _('cmp ecx,900000')
   _('jnz ScanLoop')
   _('jmp ScanExit')
   ; Matched ;
   _('ScanMatched:')
   _('inc ebx')
   _('mov edi,dword[edx+4]')
   _('cmp ebx,edi')
   _('jz ScanFound')
   _('mov dword[edx],ebx')
   _('add edx,50')
   _('cmp edx,esi')
   _('jnz ScanInnerLoop')
   _('cmp ecx,900000')
   _('jnz ScanLoop')
   _('jmp ScanExit')
   ; Found ;
   _('ScanFound:')
   _('lea edi,dword[edx+8]')
   _('mov dword[edi],ecx')
   _('mov dword[edx],-1')
   _('add edx,50')
   _('cmp edx,esi')
   _('jnz ScanInnerLoop')
   _('cmp ecx,900000')
   _('jnz ScanLoop')
   ; Exit ;
   _('ScanExit:')
   _('popad')
   _('retn')
   Local $lScanMemory = MemoryRead($mBase, 'ptr')
   If $lScanMemory = 0 Then
	  $mMemory = DllCall($mKernelHandle, 'ptr', 'VirtualAllocEx', 'handle', $mGWProcHandle, 'ptr', 0, 'ulong_ptr', $mASMSize, 'dword', 0x1000, 'dword', 0x40)
	  $mMemory = $mMemory[0]
	  AddRestoreDict($mBase, "0x00000000")
	  MemoryWrite($mBase, $mMemory)
   Else
	  $mMemory = $lScanMemory
   EndIf
   CompleteASMCode()
   If $lScanMemory = 0 Then
	  WriteBinary($mASMString, $mMemory + $mASMCodeOffset)
	  Local $lThread = DllCall($mKernelHandle, 'int', 'CreateRemoteThread', 'int', $mGWProcHandle, 'ptr', 0, 'int', 0, 'int', GetLabelInfo('ScanProc'), 'ptr', 0, 'int', 0, 'int', 0)
	  $lThread = $lThread[0]
	  Local $lResult
	  Do
		 $lResult = DllCall($mKernelHandle, 'int', 'WaitForSingleObject', 'int', $lThread, 'int', 50)
	  Until $lResult[0] <> 258
	  DllCall($mKernelHandle, 'int', 'CloseHandle', 'int', $lThread)
   EndIf
EndFunc   ;==>Scan

;~ Description: Formats and adds pattern-string to $mASMString.
Func AddPattern($aPattern)
   Local $lSize = Int(0.5 * StringLen($aPattern))
   $mASMString &= '00000000' & SwapEndian(Hex($lSize, 8)) & '00000000' & $aPattern
   $mASMSize += $lSize + 12
   For $i = 1 To 68 - $lSize
	  $mASMSize += 1
	  $mASMString &= '00'
   Next
EndFunc   ;==>AddPattern

;~ Description: Returns scanned address +/- offset.
Func GetScannedAddress($aLabel, $aOffset)
   Local $lLabelInfo = GetLabelInfo($aLabel)
   Return MemoryRead($lLabelInfo + 8) - MemoryRead($lLabelInfo + 4) + $aOffset
EndFunc   ;==>GetScannedAddress

;~ Description: Scans game client memory for charname.
Func ScanForCharname($aByteString = '90909066C705', $aStartAddr = 0x401000, $aEndAddr = 0x900000)
   Local $lSystemInfoBuffer = DllStructCreate('word;word;dword;ptr;ptr;dword;dword;dword;dword;word;word')
   DllCall($mKernelHandle, 'int', 'GetSystemInfo', 'ptr', DllStructGetPtr($lSystemInfoBuffer))
   Local $lBuffer = DllStructCreate('byte[' & DllStructGetData($lSystemInfoBuffer, 3) & ']')
   For $iAddr = $aStartAddr To $aEndAddr Step DllStructGetData($lSystemInfoBuffer, 3)
	  MemoryReadToStruct($iAddr, $lBuffer)
	  StringRegExp(DllStructGetData($lBuffer, 1), $aByteString, 1, 2)
	  If @error = 0 Then
		 Local $lStringPos = @extended - StringLen($aByteString) - 2
		 Local $lStart = $lStringPos + 14
		 If $lStart + 8 > StringLen(DllStructGetData($lBuffer, 1)) Then
			$mCharname = MemoryRead($iAddr + 0x6 + ($lStringPos/2), 'ptr')
		 Else
			$mCharname = '0x' & SwapEndian(StringMid(DllStructGetData($lBuffer, 1), $lStart, 8))
		 EndIf
		 Return GetCharname()
	  EndIf
   Next
   Return ''
EndFunc   ;==>ScanForCharname

;~ Description: Gets Winlists of open game client windows.
;~ If there's more than one, a small GUI is opened with a ComboBox to select Charname from.
Func CharacterSelector()
   Local $lWinList = WinList("[CLASS:ArenaNet_Dx_Window_Class; REGEXPTITLE:^\D+$]")
   Switch $lWinList[0][0]
	  Case 0
		 Exit MsgBox(0, "Error", "No Guild Wars Clients were found.")
	  Case 1
		 Return WinGetProcess($lWinList[1][1])
	  Case Else
		 Local $lCharStr = "", $lFirstChar
		 For $winCount = 1 To $lWinList[0][0]
			MemoryOpen(WinGetProcess($lWinList[$winCount][1]))
			$lCharStr &= ScanForCharname()
			If $winCount = 1 Then $lFirstChar = GetCharname()
			If $winCount <> $lWinList[0][0] Then $lCharStr &= "|"
			MemoryClose()
		 Next
		 Local $GUICharSelector = GUICreate("Character Selector", 171, 64, 192, 124)
		 Local $ComboCharSelector = GUICtrlCreateCombo("", 8, 8, 153, 25)
		 Local $ButtonCharSelector = GUICtrlCreateButton("Use This Character", 8, 32, 153, 25)
		 GUICtrlSetData($ComboCharSelector, $lCharStr,$lFirstChar)
		 GUISetState(@SW_SHOW, $GUICharSelector)
		 While 1
			Switch GUIGetMsg()
			   Case $ButtonCharSelector
				  Local $tmp = GUICtrlRead($ComboCharSelector)
				  GUIDelete($GUICharSelector)
				  Return $tmp
			   Case -3
				  Exit
			EndSwitch
			Sleep(25)
		 WEnd
   EndSwitch
EndFunc   ;==>CharacterSelector

;~ Description: Returns a string of charnames, delimeter: '|'.
Func GetLoggedCharnames()
   Local $lWinList = WinList("[CLASS:ArenaNet_Dx_Window_Class; REGEXPTITLE:^\D+$]")
   Local $lCharStr = ''
   Switch $lWinList[0][0]
	  Case 0
		 Exit MsgBox(0, "Error", "No Guild Wars Clients were found.")
	  Case 1
		 MemoryOpen(WinGetProcess($lWinList[1][1]))
		 $lCharStr &= ScanForCharname()
		 $mFirstChar = $lCharStr
		 MemoryClose()
	  Case Else
		 For $winCount = 1 To $lWinList[0][0]
			MemoryOpen(WinGetProcess($lWinList[$winCount][1]))
			$lCharStr &= ScanForCharname()
			If $winCount = 1 Then $mFirstChar = $lCharStr
			If $winCount <> $lWinList[0][0] Then $lCharStr &= "|"
			MemoryClose()
		 Next
   EndSwitch
   Return $lCharStr
EndFunc   ;==>GetLoggedCharnames
#EndRegion Initialisation

#Region Callback
;~ Description: Controls Event System.
Func SetEvent($aSkillActivate = '', $aSkillCancel = '', $aSkillComplete = '', $aChatReceive = '', $aLoadFinished = '')
   If Not $mUseEventSystem Then Return
   If $aSkillActivate <> '' Then
	  WriteDetour('SkillLogStart', 'SkillLogProc')
   Else
	  $mASMString = ''
	  _('inc eax')
	  _('mov dword[esi+10],eax')
	  _('pop esi')
	  WriteBinary($mASMString, GetValue('SkillLogStart'))
   EndIf
   If $aSkillCancel <> '' Then
	  WriteDetour('SkillCancelLogStart', 'SkillCancelLogProc')
   Else
	  $mASMString = ''
	  _('push 0')
	  _('push 42')
	  _('mov ecx,esi')
	  WriteBinary($mASMString, GetValue('SkillCancelLogStart'))
   EndIf
   If $aSkillComplete <> '' Then
	  WriteDetour('SkillCompleteLogStart', 'SkillCompleteLogProc')
   Else
	  $mASMString = ''
	  _('mov eax,dword[edi+4]')
	  _('test eax,eax')
	  WriteBinary($mASMString, GetValue('SkillCompleteLogStart'))
   EndIf
   If $aChatReceive <> '' Then
	  WriteDetour('ChatLogStart', 'ChatLogProc')
   Else
	  $mASMString = ''
	  _('add edi,E')
	  _('cmp eax,B')
	  WriteBinary($mASMString, GetValue('ChatLogStart'))
   EndIf
   $mSkillActivate = $aSkillActivate
   $mSkillCancel = $aSkillCancel
   $mSkillComplete = $aSkillComplete
   $mChatReceive = $aChatReceive
   $mLoadFinished = $aLoadFinished
EndFunc   ;==>SetEvent

;~ Description: Internal use for event system. Calls different event functions.
;~ modified by gigi
Func Event($hwnd, $msg, $wparam, $lparam)
   Switch $lparam
	  Case 0x1
		 DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $wparam, 'ptr', $mSkillLogStructPtr, 'int', 16, 'int', '')
		 Call($mSkillActivate, DllStructGetData($mSkillLogStruct, 1), DllStructGetData($mSkillLogStruct, 2), DllStructGetData($mSkillLogStruct, 3), DllStructGetData($mSkillLogStruct, 4))
	  Case 0x2
		 DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $wparam, 'ptr', $mSkillLogStructPtr, 'int', 16, 'int', '')
		 Call($mSkillCancel, DllStructGetData($mSkillLogStruct, 1), DllStructGetData($mSkillLogStruct, 2), DllStructGetData($mSkillLogStruct, 3))
	  Case 0x3
		 DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $wparam, 'ptr', $mSkillLogStructPtr, 'int', 16, 'int', '')
		 Call($mSkillComplete, DllStructGetData($mSkillLogStruct, 1), DllStructGetData($mSkillLogStruct, 2), DllStructGetData($mSkillLogStruct, 3))
	  Case 0x4
		 DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $wparam, 'ptr', $mChatLogStructPtr, 'int', 512, 'int', '')
		 Local $lMessage = DllStructGetData($mChatLogStruct, 2)
		 Local $lChannel
		 Local $lSender
		 Switch DllStructGetData($mChatLogStruct, 1)
			Case 0
			   $lChannel = "Alliance"
			   $lSender = StringMid($lMessage, 6, StringInStr($lMessage, "</a>") - 6)
			   $lMessage = StringTrimLeft($lMessage, StringInStr($lMessage, "<quote>") + 6)
			Case 3
			   $lChannel = "All"
			   $lSender = StringMid($lMessage, 6, StringInStr($lMessage, "</a>") - 6)
			   $lMessage = StringTrimLeft($lMessage, StringInStr($lMessage, "<quote>") + 6)
			Case 9
			   $lChannel = "Guild"
			   $lSender = StringMid($lMessage, 6, StringInStr($lMessage, "</a>") - 6)
			   $lMessage = StringTrimLeft($lMessage, StringInStr($lMessage, "<quote>") + 6)
			Case 11
			   $lChannel = "Team"
			   $lSender = StringMid($lMessage, 6, StringInStr($lMessage, "</a>") - 6)
			   $lMessage = StringTrimLeft($lMessage, StringInStr($lMessage, "<quote>") + 6)
			Case 12
			   $lChannel = "Trade"
			   $lSender = StringMid($lMessage, 6, StringInStr($lMessage, "</a>") - 6)
			   $lMessage = StringTrimLeft($lMessage, StringInStr($lMessage, "<quote>") + 6)
			Case 10
			   If StringLeft($lMessage, 3) == "-> " Then
				  $lChannel = "Sent"
				  $lSender = StringMid($lMessage, 10, StringInStr($lMessage, "</a>") - 10)
				  $lMessage = StringTrimLeft($lMessage, StringInStr($lMessage, "<quote>") + 6)
			   Else
				  $lChannel = "Global"
				  $lSender = "Guild Wars"
			   EndIf
			Case 13
			   $lChannel = "Advisory"
			   $lSender = "Guild Wars"
			   $lMessage = StringTrimLeft($lMessage, StringInStr($lMessage, "<quote>") + 6)
			Case 14
			   $lChannel = "Whisper"
			   $lSender = StringMid($lMessage, 7, StringInStr($lMessage, "</a>") - 7)
			   $lMessage = StringTrimLeft($lMessage, StringInStr($lMessage, "<quote>") + 6)
			Case Else
			   $lChannel = "Other"
			   $lSender = "Other"
		 EndSwitch
		 Call($mChatReceive, $lChannel, $lSender, $lMessage)
	  Case 0x5
		 ResetPointers()
		 Call($mLoadFinished)
   EndSwitch
EndFunc   ;==>Event
#EndRegion Callback

#Region Modification
;~ Description: Calls ASM functions.
Func ModifyMemory()
   $mASMSize = 0
   $mASMCodeOffset = 0
   $mASMString = ''
   CreateData()
   CreateMain()
   CreateTargetLog()
   CreateSkillLog()
   CreateSkillCancelLog()
   CreateSkillCompleteLog()
   CreateChatLog()
   CreateTraderHook()
   CreateLoadFinished()
   CreateStringLog()
   CreateStringFilter1()
   CreateStringFilter2()
   CreateRenderingMod()
   CreateObstructedHook()
   CreateCommands()
   If $mUsePlugins Then AddPluginASM()
   Local $lModMemory = MemoryRead(MemoryRead($mBase), 'ptr')
   If $lModMemory = 0 Then
	  $mMemory = DllCall($mKernelHandle, 'ptr', 'VirtualAllocEx', 'handle', $mGWProcHandle, 'ptr', 0, 'ulong_ptr', $mASMSize, 'dword', 0x1000, 'dword', 0x40)
	  $mMemory = $mMemory[0]
	  MemoryWrite(MemoryRead($mBase), $mMemory)
	  $mMemoryEnd = Ptr($mMemory + $mASMSize + 40)
   Else
	  $mMemory = $lModMemory
   EndIf
   CompleteASMCode()
   If $lModMemory = 0 Then
	  WriteBinary($mASMString, $mMemory + $mASMCodeOffset)
	  WriteBinary("83F8009090", GetValue('ClickToMoveFix'))
	  MemoryWrite(GetValue('QueuePtr'), GetValue('QueueBase'))
	  MemoryWrite(GetValue('SkillLogPtr'), GetValue('SkillLogBase'))
	  MemoryWrite(GetValue('ChatLogPtr'), GetValue('ChatLogBase'))
	  MemoryWrite(GetValue('StringLogPtr'), GetValue('StringLogBase'))
   EndIf
   WriteDetour('MainStart', 'MainProc')
   WriteDetour('TargetLogStart', 'TargetLogProc')
   WriteDetour('TraderHookStart', 'TraderHookProc')
   WriteDetour('LoadFinishedStart', 'LoadFinishedProc')
   WriteDetour('RenderingMod', 'RenderingModProc')
   WriteDetour('ObstructedHookStart', 'ObstructedHookProc')
   If $mUseStringLog Then
	  WriteDetour('StringLogStart', 'StringLogProc')
	  WriteDetour('StringFilter1Start', 'StringFilter1Proc')
	  WriteDetour('StringFilter2Start', 'StringFilter2Proc')
   EndIf
   If $mUsePlugins Then AddPluginDetours()
EndFunc   ;==>ModifyMemory

;~ Description: Writes a jump 'from'-'to' to process memory.
Func WriteDetour($aFrom, $aTo)
   Local $lFrom = GetLabelInfo($aFrom)
   WriteBinary('E9' & SwapEndian(Hex(GetLabelInfo($aTo) - $lFrom - 5)), $lFrom)
EndFunc   ;==>WriteDetour

;~ Description: Add Key and Value to $mRestoreDict.
Func AddRestoreDict($aKey, $aItem)
   If IsDllStruct($aItem) Then
	  Local $lBuffer = DllStructCreate('byte[' & DllStructGetSize($aItem) & ']', DllStructGetPtr($aItem))
	  $aItem = DllStructGetData($lBuffer, 1)
   EndIf
   If $aItem == '' Then Return
   If $mRestoreDict = 0 Then CreateRestoreDict()
   $mRestoreDict($aKey) = $aItem
EndFunc

;~ Description: Restore data saved in $mRestoreDict.
Func RestoreDetour()
   While GetMapLoading() = 2
	  Sleep(1000)
   WEnd
   If $mRestoreDict.Item($mBase) = "0x00000000" Then
	  Local $lItem, $lSize, $lTemp
	  Local $lStr = "Restoring data: " & @CRLF
	  For $i In $mRestoreDict.Keys
		 $lItem = $mRestoreDict.Item($i)
		 If StringLeft($lItem, 2) == '0x' Then $lItem = StringTrimLeft($lItem, 2)
		 $lSize = 0.5 * StringLen($lItem)
		 $lTemp = MemoryRead(Ptr($i), 'byte[' & $lSize & ']')
		 WriteBinary($lItem, $i, False)
		 $lStr &= Ptr($i) & ': ' & $lItem & ' | ' & $lTemp & ' -> ' & MemoryRead(Ptr($i), 'byte[' & $lSize & ']') & @CRLF
	  Next
	  WinSetTitle($mGWHwnd, '', $mGWTitleOld)
	  DllCall($mKernelHandle, 'int', 'VirtualFreeEx', 'handle', $mGWProcHandle, 'ptr', $mMemory, 'int', 0, 'dword', 0x8000)
   ElseIf $mUsePlugins Then
	  $lStr = "Client was already injected. Only restoring Dialoghook."
	  WinSetTitle($mGWHwnd, '', $mGWTitleOld)
	  WriteBinary('558BEC8B41', GetLabelInfo('DialogLogStart'))
   EndIf
   Consolewrite($lStr & @CRLF)
EndFunc

;~ Description: Creates dictionary object and sets keys to case insensitive. Internal use RestoreDetour.
Func CreateRestoreDict()
   $mRestoreDict = ObjCreate('Scripting.Dictionary')
   $mRestoreDict.CompareMode = 1 ; keys -> case insensitive
EndFunc   ;==>CreateLabelDict

;~ Description: ASM variables.
Func CreateData()
   _('CallbackHandle/4')
   _('QueueCounter/4')
   _('SkillLogCounter/4')
   _('ChatLogCounter/4')
   _('ChatLogLastMsg/4')
   _('MapIsLoaded/4')
   _('NextStringType/4')
   _('EnsureEnglish/4')
   _('TraderQuoteID/4')
   _('TraderCostID/4')
   _('TraderCostValue/4')
   _('DisableRendering/4')
   _('QueueBase/' & 256 * GetValue('QueueSize'))
   _('TargetLogBase/' & 4 * GetValue('TargetLogSize'))
   _('SkillLogBase/' & 16 * GetValue('SkillLogSize'))
   _('StringLogBase/' & 256 * GetValue('StringLogSize'))
   _('ChatLogBase/' & 512 * GetValue('ChatLogSize'))
   _('ObstructedState/4')
   If $mUsePlugins Then AddPluginData()
EndFunc   ;==>CreateData

;~ Description: ASM function. Internal use only.
Func CreateMain()
   _('MainProc:')
   _('pushad')
   _('mov eax,dword[EnsureEnglish]')
   _('test eax,eax')
   _('jz MainMain')

   _('mov ecx,dword[BasePointer]')
   _('mov ecx,dword[ecx+18]')
   _('mov ecx,dword[ecx+18]')
   _('mov ecx,dword[ecx+194]')
   _('mov al,byte[ecx+4f]')
   _('cmp al,f')
   _('ja MainMain')
   _('mov ecx,dword[ecx+4c]')
   _('mov al,byte[ecx+3f]')
   _('cmp al,f')
   _('ja MainMain')
   _('mov eax,dword[ecx+40]')
   _('test eax,eax')
   _('jz MainMain')

   _('mov ecx,dword[ActionBase]')
   _('mov ecx,dword[ecx+170]')
   _('mov ecx,dword[ecx+20]')
   _('mov ecx,dword[ecx]')
   _('push 0')
   _('push 0')
   _('push bb')
   _('mov edx,esp')
   _('push 0')
   _('push edx')
   _('push 18')
   _('call ActionFunction')
   _('pop eax')
   _('pop ebx')
   _('pop ecx')

   _('MainMain:')
   _('mov eax,dword[QueueCounter]')
   _('mov ecx,eax')
   _('shl eax,8')
   _('add eax,QueueBase')
   _('mov ebx,dword[eax]')
   _('test ebx,ebx')
   _('jz MainExit')

   _('push ecx')
   _('mov dword[eax],0')
   _('jmp ebx')

   _('CommandReturn:')
   _('pop eax')
   _('inc eax')
   _('cmp eax,QueueSize')
   _('jnz MainSkipReset')
   _('xor eax,eax')
   _('MainSkipReset:')
   _('mov dword[QueueCounter],eax')

   _('MainExit:')
   _('popad')
   _('mov ebp,esp')
   _('sub esp,14')
   _('ljmp MainReturn')
EndFunc   ;==>CreateMain

;~ Description: ASM function. Internal use only.
Func CreateTargetLog()
   _('TargetLogProc:')
   _('cmp ecx,4')
   _('jz TargetLogMain')
   _('cmp ecx,32')
   _('jz TargetLogMain')
   _('cmp ecx,3C')
   _('jz TargetLogMain')
   _('jmp TargetLogExit')

   _('TargetLogMain:')
   _('pushad')
   _('mov ecx,dword[ebp+8]')
   _('test ecx,ecx')
   _('jnz TargetLogStore')
   _('mov ecx,edx')

   _('TargetLogStore:')
   _('lea eax,dword[edx*4+TargetLogBase]')
   _('mov dword[eax],ecx')
   _('popad')

   _('TargetLogExit:')
   _('push ebx')
   _('push esi')
   _('push edi')
   _('mov edi,edx')
   _('ljmp TargetLogReturn')
EndFunc   ;==>CreateTargetLog

;~ Description: ASM function. Internal use only.
Func CreateSkillLog()
   _('SkillLogProc:')
   _('pushad')
   _('mov eax,dword[SkillLogCounter]')
   _('push eax')
   _('shl eax,4')
   _('add eax,SkillLogBase')
   _('mov ecx,dword[edi]')
   _('mov dword[eax],ecx')
   _('mov ecx,dword[ecx*4+TargetLogBase]')
   _('mov dword[eax+4],ecx')
   _('mov ecx,dword[edi+4]')
   _('mov dword[eax+8],ecx')
   _('mov ecx,dword[edi+8]')
   _('mov dword[eax+c],ecx')
   _('push 1')
   _('push eax')
   _('push CallbackEvent')
   _('push dword[CallbackHandle]')
   _('call dword[PostMessage]')
   _('pop eax')
   _('inc eax')
   _('cmp eax,SkillLogSize')
   _('jnz SkillLogSkipReset')
   _('xor eax,eax')

   _('SkillLogSkipReset:')
   _('mov dword[SkillLogCounter],eax')
   _('popad')
   _('inc eax')
   _('mov dword[esi+10],eax')
   _('pop esi')
   _('ljmp SkillLogReturn')
EndFunc   ;==>CreateSkillLog

;~ Description: ASM function. Internal use only.
Func CreateSkillCancelLog()
   _('SkillCancelLogProc:')
   _('pushad')
   _('mov eax,dword[SkillLogCounter]')
   _('push eax')
   _('shl eax,4')
   _('add eax,SkillLogBase')
   _('mov ecx,dword[edi]')
   _('mov dword[eax],ecx')
   _('mov ecx,dword[ecx*4+TargetLogBase]')
   _('mov dword[eax+4],ecx')
   _('mov ecx,dword[edi+4]')
   _('mov dword[eax+8],ecx')
   _('push 2')
   _('push eax')
   _('push CallbackEvent')
   _('push dword[CallbackHandle]')
   _('call dword[PostMessage]')
   _('pop eax')
   _('inc eax')
   _('cmp eax,SkillLogSize')
   _('jnz SkillCancelLogSkipReset')
   _('xor eax,eax')

   _('SkillCancelLogSkipReset:')
   _('mov dword[SkillLogCounter],eax')
   _('popad')
   _('push 0')
   _('push 42')
   _('mov ecx,esi')
   _('ljmp SkillCancelLogReturn')
EndFunc   ;==>CreateSkillCancelLog

;~ Description: ASM function. Internal use only.
Func CreateSkillCompleteLog()
   _('SkillCompleteLogProc:')
   _('pushad')
   _('mov eax,dword[SkillLogCounter]')
   _('push eax')
   _('shl eax,4')
   _('add eax,SkillLogBase')
   _('mov ecx,dword[edi]')
   _('mov dword[eax],ecx')
   _('mov ecx,dword[ecx*4+TargetLogBase]')
   _('mov dword[eax+4],ecx')
   _('mov ecx,dword[edi+4]')
   _('mov dword[eax+8],ecx')
   _('push 3')
   _('push eax')
   _('push CallbackEvent')
   _('push dword[CallbackHandle]')
   _('call dword[PostMessage]')
   _('pop eax')
   _('inc eax')
   _('cmp eax,SkillLogSize')
   _('jnz SkillCompleteLogSkipReset')
   _('xor eax,eax')

   _('SkillCompleteLogSkipReset:')
   _('mov dword[SkillLogCounter],eax')
   _('popad')
   _('mov eax,dword[edi+4]')
   _('test eax,eax')
   _('ljmp SkillCompleteLogReturn')
EndFunc   ;==>CreateSkillCompleteLog

;~ Description: ASM function. Internal use only.
Func CreateChatLog()
   _('ChatLogProc:')
   _('pushad')
   _('mov ecx,dword[esp+1F4]')
   _('mov ebx,eax')
   _('mov eax,dword[ChatLogCounter]')
   _('push eax')
   _('shl eax,9')
   _('add eax,ChatLogBase')
   _('mov dword[eax],ebx')
   _('mov edi,eax')
   _('add eax,4')
   _('xor ebx,ebx')

   _('ChatLogCopyLoop:')
   _('mov dx,word[ecx]')
   _('mov word[eax],dx')
   _('add ecx,2')
   _('add eax,2')
   _('inc ebx')
   _('cmp ebx,FF')
   _('jz ChatLogCopyExit')
   _('test dx,dx')
   _('jnz ChatLogCopyLoop')

   _('ChatLogCopyExit:')
   _('push 4')
   _('push edi')
   _('push CallbackEvent')
   _('push dword[CallbackHandle]')
   _('call dword[PostMessage]')
   _('pop eax')
   _('inc eax')
   _('cmp eax,ChatLogSize')
   _('jnz ChatLogSkipReset')
   _('xor eax,eax')
   _('ChatLogSkipReset:')
   _('mov dword[ChatLogCounter],eax')
   _('popad')

   _('ChatLogExit:')
   _('add edi,E')
   _('cmp eax,B')
   _('ljmp ChatLogReturn')
EndFunc   ;==>CreateChatLog

;~ Description: ASM function. Internal use only.
Func CreateTraderHook()
   _('TraderHookProc:')
   _('mov dword[TraderCostID],ecx')
   _('mov dword[TraderCostValue],edx')
   _('push eax')
   _('mov eax,dword[TraderQuoteID]')
   _('inc eax')
   _('cmp eax,200')
   _('jnz TraderSkipReset')
   _('xor eax,eax')
   _('TraderSkipReset:')
   _('mov dword[TraderQuoteID],eax')
   _('pop eax')
   _('mov ebp,esp')
   _('sub esp,8')
   _('ljmp TraderHookReturn')
EndFunc   ;==>CreateTraderHook

;~ Description: ASM function. Internal use only.
Func CreateLoadFinished()
   _('LoadFinishedProc:')
   _('pushad')
   _('mov eax,1')
   _('mov dword[MapIsLoaded],eax')
   _('xor ebx,ebx')
   _('mov eax,StringLogBase')

   _('LoadClearStringsLoop:')
   _('mov dword[eax],0')
   _('inc ebx')
   _('add eax,100')
   _('cmp ebx,StringLogSize')
   _('jnz LoadClearStringsLoop')

   _('xor ebx,ebx')
   _('mov eax,TargetLogBase')
   _('LoadClearTargetsLoop:')
   _('mov dword[eax],0')
   _('inc ebx')
   _('add eax,4')
   _('cmp ebx,TargetLogSize')
   _('jnz LoadClearTargetsLoop')

   _('push 5')
   _('push 0')
   _('push CallbackEvent')
   _('push dword[CallbackHandle]')
   _('call dword[PostMessage]')
   _('popad')
   _('mov edx,dword[esi+1C]')
   _('mov ecx,edi')
   _('ljmp LoadFinishedReturn')
EndFunc   ;==>CreateLoadFinished

;~ Description: ASM function. Internal use only.
Func CreateStringLog()
   _('StringLogProc:')
   _('pushad')
   _('mov eax,dword[NextStringType]')
   _('test eax,eax')
   _('jz StringLogExit')

   _('cmp eax,1')
   _('jnz StringLogFilter2')
   _('mov eax,dword[ebp+37c]')
   _('jmp StringLogRangeCheck')

   _('StringLogFilter2:')
   _('cmp eax,2')
   _('jnz StringLogExit')
   _('mov eax,dword[ebp+338]')

   _('StringLogRangeCheck:')
   _('mov dword[NextStringType],0')
   _('cmp eax,0')
   _('jbe StringLogExit')
   _('cmp eax,StringLogSize')
   _('jae StringLogExit')

   _('shl eax,8')
   _('add eax,StringLogBase')
   _('xor ebx,ebx')

   _('StringLogCopyLoop:')
   _('mov dx,word[ecx]')
   _('mov word[eax],dx')
   _('add ecx,2')
   _('add eax,2')
   _('inc ebx')
   _('cmp ebx,80')
   _('jz StringLogExit')
   _('test dx,dx')
   _('jnz StringLogCopyLoop')

   _('StringLogExit:')
   _('popad')
   _('mov esp,ebp')
   _('pop ebp')
   _('retn 10')
EndFunc   ;==>CreateStringLog

;~ Description: ASM function. Internal use only.
Func CreateStringFilter1()
   _('StringFilter1Proc:')
   _('mov dword[NextStringType],1')
   _('push ebp')
   _('mov ebp,esp')
   _('push ecx')
   _('push esi')
   _('ljmp StringFilter1Return')
EndFunc   ;==>CreateStringFilter1

;~ Description: ASM function. Internal use only.
Func CreateStringFilter2()
   _('StringFilter2Proc:')
   _('mov dword[NextStringType],2')
   _('push ebp')
   _('mov ebp,esp')
   _('push ecx')
   _('push esi')
   _('ljmp StringFilter2Return')
EndFunc   ;==>CreateStringFilter2

Func CreateObstructedHook()
   _('ObstructedHookProc:')
   _('mov eax,dword[ecx]')
   _('cmp eax,8AB')
   _('jnz ObstructedHookEnd')
   _('mov dword[ObstructedState],eax')
   _('ObstructedHookEnd:')
   _('mov ebp,esp')
   _('sub esp,18')
   _('ljmp ObstructedHookReturn')
EndFunc

;~ Description: ASM function. Internal use only.
Func CreateRenderingMod()
   _('RenderingModProc:')
   _('cmp dword[DisableRendering],1')
   _('jz RenderingModSkipCompare')
   _('cmp eax,ebx')
   _('ljne RenderingModReturn')

   _('RenderingModSkipCompare:')
   $mASMSize += 17
   $mASMString &= StringTrimLeft(MemoryRead(GetValue("RenderingMod") + 4, "byte[17]"), 2)
   _('cmp dword[DisableRendering],1')
   _('jz DisableRenderingProc')
   _('retn')

   _('DisableRenderingProc:')
   _('push 1')
   _('call dword[Sleep]')
   _('retn')
EndFunc   ;==>CreateRenderingMod

;~ Description: ASM functions as strings, each line calls conversion function _(). Internal use only.
Func CreateCommands()
   #Region Commands
   ; PacketSend ;
   _('CommandPacketSend:')
   _('mov ecx,dword[PacketLocation]')
   _('lea edx,dword[eax+8]')
   _('push edx')
   _('mov edx,dword[eax+4]')
   _('mov eax,ecx')
   _('call PacketSendFunction')
   _('ljmp CommandReturn')
   ; Action ;
   _('CommandAction:')
   _('mov ecx,dword[ActionBase]')
   _('mov ecx,dword[ecx+250]')
   _('mov ecx,dword[ecx+10]')
   _('mov ecx,dword[ecx]')
   _('push 0')
   _('push 0')
   _('push dword[eax+4]')
   _('mov edx,esp')
   _('push 0')
   _('push edx')
   _('push dword[eax+8]')
   _('call ActionFunction')
   _('pop eax')
   _('pop ebx')
   _('pop ecx')
   _('ljmp CommandReturn')
   ; UseSkill ;
   _('CommandUseSkill:')
   _('mov ecx,dword[MyID]')
   _('mov edx,dword[eax+C]')
   _('push edx')
   _('mov edx,dword[eax+4]')
   _('dec edx')
   _('push dword[eax+8]')
   _('call UseSkillFunction')
   _('ljmp CommandReturn')
   ; Move ;
   _('CommandMove:')
   _('lea ecx,dword[eax+4]')
   _('call MoveFunction')
   _('ljmp CommandReturn')
   ; ChangeTarget ;
   _('CommandChangeTarget:')
   _('mov ecx,dword[eax+4]')
   _('xor edx,edx')
   _('call ChangeTargetFunction')
   _('ljmp CommandReturn')
   ; ToggleLanguage ;
   _('CommandToggleLanguage:')
   _('mov ecx,dword[ActionBase]')
   _('mov ecx,dword[ecx+170]')
   _('mov ecx,dword[ecx+20]')
   _('mov ecx,dword[ecx]')
   _('push 0')
   _('push 0')
   _('push bb')
   _('mov edx,esp')
   _('push 0')
   _('push edx')
   _('push dword[eax+4]')
   _('call ActionFunction')
   _('pop eax')
   _('pop ebx')
   _('pop ecx')
   _('ljmp CommandReturn')
   ; UseHeroSkill ;
   _('CommandUseHeroSkill:')
   _('mov ecx,dword[eax+4]')
   _('mov edx,dword[eax+c]')
   _('mov eax,dword[eax+8]')
   _('push eax')
   _('call UseHeroSkillFunction')
   _('ljmp CommandReturn')
   ; UpdateAgentPos ;
   _('CommandUpdateAgentPos:')
   _('add eax,4')
   _('mov ecx,eax')
   _('call UpdateAgentPositionFunction')
   _('ljmp CommandReturn')
   ; Go NPC ;
   _('CommandGoNpc:')
   _('mov ecx,dword[eax+4]')
   _('mov edx,dword[eax+8]')
   _('call GoNpcFunction')
   _('ljmp CommandReturn')
   #EndRegion Commands

   #Region Items
   ; Buy ;
   _('CommandBuyItem:')
   _('add eax,4')
   _('push eax')
   _('add eax,4')
   _('push eax')
   _('push 1')
   _('push 0')
   _('push 0')
   _('push 0')
   _('push 0')
   _('mov ecx,1')
   _('mov edx,dword[eax+4]')
   _('call BuyItemFunction')
   _('ljmp CommandReturn')
   ; Sell ;
   _('CommandSellItem:')
   _('push 0')
   _('push 0')
   _('push 0')
   _('push dword[eax+4]')
   _('push 0')
   _('add eax,8')
   _('push eax')
   _('push 1')
   _('mov ecx,b')
   _('xor edx,edx')
   _('call SellItemFunction')
   _('ljmp CommandReturn')
   ; Salvage ;
   _('CommandSalvage:')
   _('mov ebx,SalvageGlobal')
   _('mov ecx,dword[eax+4]')
   _('mov dword[ebx],ecx')
   _('push ecx')
   _('mov ecx,dword[eax+8]')
   _('add ebx,4')
   _('mov dword[ebx],ecx')
   _('mov edx,dword[eax+c]')
   _('mov dword[ebx],ecx')
   _('call SalvageFunction')
   _('ljmp CommandReturn')
   ; OpenStorage ;
   _('CommandOpenStorage:')
   _('pushad')
   _('add eax,4')
   _('mov ecx,dword[eax]')
   _('add eax,4')
   _('mov edx,eax')
   _('call StorageFunction')
   _('popad')
   #EndRegion Items

   #Region Trader
   ; Buy ;
   _('CommandTraderBuy:')
   _('push 0')
   _('push TraderCostID')
   _('push 1')
   _('push 0')
   _('push 0')
   _('push 0')
   _('push 0')
   _('mov ecx,c')
   _('mov edx,dword[TraderCostValue]')
   _('call TraderFunction')
   _('mov dword[TraderCostID],0')
   _('mov dword[TraderCostValue],0')
   _('ljmp CommandReturn')
   ; Sell ;
   _('CommandTraderSell:')
   _('push 0')
   _('push 0')
   _('push 0')
   _('push dword[TraderCostValue]')
   _('push 0')
   _('push TraderCostID')
   _('push 1')
   _('mov ecx,d')
   _('xor edx,edx')
   _('call TraderFunction')
   _('mov dword[TraderCostID],0')
   _('mov dword[TraderCostValue],0')
   _('ljmp CommandReturn')
   ; QuoteBuy ;
   _('CommandRequestQuote:')
   _('mov dword[TraderCostID],0')
   _('mov dword[TraderCostValue],0')
   _('add eax,4')
   _('push eax')
   _('push 1')
   _('push 0')
   _('push 0')
   _('push 0')
   _('push 0')
   _('mov ecx,c')
   _('xor edx,edx')
   _('call RequestQuoteFunction')
   _('ljmp CommandReturn')
   ; QuoteSell ;
   _('CommandRequestQuoteSell:')
   _('mov dword[TraderCostID],0')
   _('mov dword[TraderCostValue],0')
   _('push 0')
   _('push 0')
   _('push 0')
   _('add eax,4')
   _('push eax')
   _('push 1')
   _('push 0')
   _('mov ecx,d')
   _('xor edx,edx')
   _('call RequestQuoteFunction')
   _('ljmp CommandReturn')
   #EndRegion Trader

   #Region Chat
   ; Send ;
   _('CommandSendChat:')
   _('mov ecx,dword[PacketLocation]')
   _('add eax,4')
   _('push eax')
   _('mov edx,11c')
   _('mov eax,ecx')
   _('call PacketSendFunction')
   _('ljmp CommandReturn')
   ; Write ;
   _('CommandWriteChat:')
   _('add eax,4')
   _('mov edx,eax')
   _('xor ecx,ecx')
   _('add eax,28')
   _('push eax')
   _('call WriteChatFunction')
   _('ljmp CommandReturn')
   #EndRegion Chat
EndFunc   ;==>CreateCommands
#EndRegion Modification

#Region Assembler
;~ Description: Converts ASM commands to opcodes and updates global variables.
Func _($aASM)
   ;quick and dirty x86assembler unit:
   ;relative values stringregexp
   ;static values hardcoded
   Local $lBuffer
   Local $lOpCode = ''
   Local $lMnemonic = StringLeft($aASM, StringInStr($aASM, ' ') - 1)
   Select
	  Case $lMnemonic = "" ; variables and single word opcodes
		 Select
			Case StringRight($aASM, 1) = ':'
			   SetValue('Label_' & StringLeft($aASM, StringLen($aASM) - 1), $mASMSize)
			Case StringInStr($aASM, '/') > 0
			   SetValue('Label_' & StringLeft($aASM, StringInStr($aASM, '/') - 1), $mASMSize)
			   Local $lOffset = StringRight($aASM, StringLen($aASM) - StringInStr($aASM, '/'))
			   $mASMSize += $lOffset
			   $mASMCodeOffset += $lOffset
			Case $aASM = 'pushad' ; push all
			   $lOpCode = '60'
			Case $aASM = 'popad' ; pop all
			   $lOpCode = '61'
			Case $aASM = 'nop'
			   $lOpCode = '90'
			Case $aASM = 'retn'
			   $lOpCode = 'C3'
			Case $aASM = 'clc'
			   $lOpCode = 'F8'
		 EndSelect
	  Case $lMnemonic = "nop" ; nop
		 If StringLeft($aASM, 5) = 'nop x' Then
			$lBuffer = Int(Number(StringTrimLeft($aASM, 5)))
			$mASMSize += $lBuffer
			For $i = 1 To $lBuffer
			   $mASMString &= '90'
			Next
		 EndIf
	  Case StringLeft($lMnemonic, 2) = "lj" Or StringLeft($lMnemonic, 1) = "j" ; jump
		 Local $lStringLeft5 = StringLeft($aASM, 5)
		 Local $lStringLeft4 = StringLeft($aASM, 4)
		 Local $lStringLeft3 = StringLeft($aASM, 3)
		 Select
			Case $lStringLeft5 = 'ljmp '
			   $mASMSize += 5
			   $mASMString &= 'E9{' & StringRight($aASM, StringLen($aASM) - 5) & '}'
			Case $lStringLeft5 = 'ljne '
			   $mASMSize += 6
			   $mASMString &= '0F85{' & StringRight($aASM, StringLen($aASM) - 5) & '}'
			Case $lStringLeft4 = 'jmp ' And StringLen($aASM) > 7
			   $mASMSize += 2
			   $mASMString &= 'EB(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
			Case $lStringLeft4 = 'jae '
			   $mASMSize += 2
			   $mASMString &= '73(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
			Case $lStringLeft4 = 'jnz '
			   $mASMSize += 2
			   $mASMString &= '75(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
			Case $lStringLeft4 = 'jbe '
			   $mASMSize += 2
			   $mASMString &= '76(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
			Case $lStringLeft4 = 'jge '
			   $mASMSize += 2
			   $mASMString &= '7D(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
			Case $lStringLeft4 = 'jle '
			   $mASMSize += 2
			   $mASMString &= '7E(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
			Case $lStringLeft3 = 'ja '
			   $mASMSize += 2
			   $mASMString &= '77(' & StringRight($aASM, StringLen($aASM) - 3) & ')'
			Case $lStringLeft3 = 'jl '
			   $mASMSize += 2
			   $mASMString &= '7C(' & StringRight($aASM, StringLen($aASM) - 3) & ')'
			Case $lStringLeft3 = 'jz '
			   $mASMSize += 2
			   $mASMString &= '74(' & StringRight($aASM, StringLen($aASM) - 3) & ')'
			; hardcoded
			Case $aASM = 'jmp ebx'
			   $lOpCode = 'FFE3'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "mov" ; mov
		 Select
			; mov eax,dword[EnsureEnglish]
			Case StringRegExp($aASM, 'mov eax,dword[[][a-z,A-Z]{4,}[]]')
			   $mASMSize += 5
			   $mASMString &= 'A1[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
			Case StringRegExp($aASM, 'mov ecx,dword[[][a-z,A-Z]{4,}[]]')
			   $mASMSize += 6
			   $mASMString &= '8B0D[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
			Case StringRegExp($aASM, 'mov edx,dword[[][a-z,A-Z]{4,}[]]')
			   $mASMSize += 6
			   $mASMString &= '8B15[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
			Case StringRegExp($aASM, 'mov ebx,dword[[][a-z,A-Z]{4,}[]]')
			   $mASMSize += 6
			   $mASMString &= '8B1D[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
			Case StringRegExp($aASM, 'mov esi,dword[[][a-z,A-Z]{4,}[]]')
			   $mASMSize += 6
			   $mASMString &= '8B35[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
			Case StringRegExp($aASM, 'mov edi,dword[[][a-z,A-Z]{4,}[]]')
			   $mASMSize += 6
			   $mASMString &= '8B3D[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
			; mov eax,TargetLogBase
			Case StringRegExp($aASM, 'mov eax,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			   $mASMSize += 5
			   $mASMString &= 'B8[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
			Case StringRegExp($aASM, 'mov edx,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			   $mASMSize += 5
			   $mASMString &= 'BA[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
			Case StringRegExp($aASM, 'mov ebx,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			   $mASMSize += 5
			   $mASMString &= 'BB[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
			Case StringRegExp($aASM, 'mov esi,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			   $mASMSize += 5
			   $mASMString &= 'BE[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
			Case StringRegExp($aASM, 'mov edi,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			   $mASMSize += 5
			   $mASMString &= 'BF[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
			; mov ecx,dword[ecx*4+TargetLogBase]
			Case StringRegExp($aASM, 'mov eax,dword[[]ecx[*]4[+][a-z,A-Z]{4,}[]]')
			   $mASMSize += 7
			   $mASMString &= '8B048D[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
			Case StringRegExp($aASM, 'mov ecx,dword[[]ecx[*]4[+][a-z,A-Z]{4,}[]]')
			   $mASMSize += 7
			   $mASMString &= '8B0C8D[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
			; mov eax,dword[ebp+8]
			Case StringRegExp($aASM, 'mov (eax|ecx|edx|ebx|esp|ebp|esi|edi),dword[[](ebp|esp)[+][-[:xdigit:]]{1,8}[]]')
			   Local $lASM = ''
			   Local $lBuffer = StringMid($aASM, 19, StringLen($aASM) - 19)
			   $lBuffer = ASMNumber($lBuffer, True)
			   If @extended Then
				  $mASMSize += 4
				  Local $lStart = 4
			   Else
				  $mASMSize += 7
				  Local $lStart = 8
			   EndIf
			   Switch StringMid($aASM, 5, 3)
				  Case 'eax'
					 $lASM &= Hex($lStart, 1) & '5'
				  Case 'ecx'
					 $lASM &= Hex($lStart, 1) & 'D'
				  Case 'edx'
					 $lASM &= Hex($lStart + 1, 1) & '5'
				  Case 'ebx'
					 $lASM &= Hex($lStart + 1, 1) & 'D'
				  Case 'esp'
					 $lASM &= Hex($lStart + 2, 1) & '5'
				  Case 'ebp'
					 $lASM &= Hex($lStart + 2, 1) & 'D'
				  Case 'esi'
					 $lASM &= Hex($lStart + 3, 1) & '5'
				  Case 'edi'
					 $lASM &= Hex($lStart + 3, 1) & 'D'
				  EndSwitch
			   If StringMid($aASM, 15, 3) = 'esp' Then
				  $mASMSize += 1
				  $lASM = Hex(Dec($lASM) - 1, 2) & '24'
			   EndIf
			   $mASMString &= '3E8B' & $lASM & $lBuffer
			; mov eax,dword[ecx+8]
			Case StringRegExp($aASM, 'mov (eax|ecx|edx|ebx|esp|ebp|esi|edi),dword[[](eax|ecx|edx|ebx|esi|edi)[+][-[:xdigit:]]{1,8}[]]')
			   Local $lASM = ''
			   Local $lBuffer = StringMid($aASM, 19, StringLen($aASM) - 19)
			   $lBuffer = ASMNumber($lBuffer, True)
			   If @extended Then
				  $mASMSize += 3
				  Local $lStart = 4
			   Else
				  $mASMSize += 6
				  Local $lStart = 8
			   EndIf
			   Switch StringMid($aASM, 5, 3)
				  Case 'eax'
					 $lASM &= Hex($lStart, 1) & '0'
				  Case 'ecx'
					 $lASM &= Hex($lStart, 1) & '8'
				  Case 'edx'
					 $lASM &= Hex($lStart + 1, 1) & '0'
				  Case 'ebx'
					 $lASM &= Hex($lStart + 1, 1) & '8'
				  Case 'esp'
					 $lASM &= Hex($lStart + 2, 1) & '0'
				  Case 'ebp'
					 $lASM &= Hex($lStart + 2, 1) & '8'
				  Case 'esi'
					 $lASM &= Hex($lStart + 3, 1) & '0'
				  Case 'edi'
					 $lASM &= Hex($lStart + 3, 1) & '8'
			   EndSwitch
			   $mASMString &= '8B' & ASMOperand(StringMid($aASM, 15, 3), $lASM) & $lBuffer
			; mov ebx,dword[edx]
			Case StringRegExp($aASM, 'mov (eax|ecx|edx|ebx|esp|ebp|esi|edi),dword[[](eax|ecx|edx|ebx|esp|ebp|esi|edi)[]]')
			   $mASMSize += 2
			   Switch StringMid($aASM, 5, 3)
				  Case 'eax'
					 $lBuffer = '00'
				  Case 'ecx'
					 $lBuffer = '08'
				  Case 'edx'
					 $lBuffer = '10'
				  Case 'ebx'
					 $lBuffer = '18'
				  Case 'esp'
					 $lBuffer = '20'
				  Case 'ebp'
					 $lBuffer = '28'
				  Case 'esi'
					 $lBuffer = '30'
				  Case 'edi'
					 $lBuffer = '38'
				  EndSwitch
			   $mASMSTring &= '8B' & ASMOperand(StringMid($aASM, 15, 3), $lBuffer, True)
			; mov eax,14
			Case StringRegExp($aASM, 'mov eax,[-[:xdigit:]]{1,8}\z')
			   $mASMSize += 5
			   $mASMString &= 'B8' & ASMNumber(StringMid($aASM, 9))
			Case StringRegExp($aASM, 'mov ebx,[-[:xdigit:]]{1,8}\z')
			   $mASMSize += 5
			   $mASMString &= 'BB' & ASMNumber(StringMid($aASM, 9))
			Case StringRegExp($aASM, 'mov ecx,[-[:xdigit:]]{1,8}\z')
			   $mASMSize += 5
			   $mASMString &= 'B9' & ASMNumber(StringMid($aASM, 9))
			Case StringRegExp($aASM, 'mov edx,[-[:xdigit:]]{1,8}\z')
			   $mASMSize += 5
			   $mASMString &= 'BA' & ASMNumber(StringMid($aASM, 9))
			; mov eax,ecx
			Case StringRegExp($aASM, 'mov (eax|ecx|edx|ebx|esp|ebp|esi|edi),(eax|ecx|edx|ebx|esp|ebp|esi|edi)')
			   $mASMSize += 2
			   Switch StringMid($aASM, 5, 3)
				  Case 'eax'
					 $lBuffer = 'C0'
				  Case 'ecx'
					 $lBuffer = 'C8'
				  Case 'edx'
					 $lBuffer = 'D0'
				  Case 'ebx'
					 $lBuffer = 'D8'
				  Case 'esp'
					 $lBuffer = 'E0'
				  Case 'ebp'
					 $lBuffer = 'E8'
				  Case 'esi'
					 $lBuffer = 'F0'
				  Case 'edi'
					 $lBuffer = 'F8'
				  EndSwitch
			   $mASMString &= '8B' & ASMOperand(StringMid($aASM, 9, 3), $lBuffer)
			; mov dword[TraderCostID],ecx
			Case StringRegExp($aASM, 'mov dword[[][a-z,A-Z]{4,}[]],ecx')
			   $mASMSize += 6
			   $mASMString &= '890D[' & StringMid($aASM, 11, StringLen($aASM) - 15) & ']'
			Case StringRegExp($aASM, 'mov dword[[][a-z,A-Z]{4,}[]],edx')
			   $mASMSize += 6
			   $mASMString &= '8915[' & StringMid($aASM, 11, StringLen($aASM) - 15) & ']'
			Case StringRegExp($aASM, 'mov dword[[][a-z,A-Z]{4,}[]],eax')
			   $mASMSize += 5
			   $mASMString &= 'A3[' & StringMid($aASM, 11, StringLen($aASM) - 15) & ']'
			; mov dword[NextStringType],2
			Case StringRegExp($aASM, 'mov dword\[[a-z,A-Z]{4,}\],[-[:xdigit:]]{1,8}\z')
			   $lBuffer = StringInStr($aASM, ",")
			   $mASMSize += 10
			   $mASMString &= 'C705[' & StringMid($aASM, 11, $lBuffer - 12) & ']' & ASMNumber(StringMid($aASM, $lBuffer + 1))
			; mov dword[edi],-1
			Case StringRegExp($aASM, 'mov dword[[](eax|ecx|edx|ebx|esp|ebp|esi|edi)[]],[-[:xdigit:]]{1,8}\z')
			   $mASMSize += 6
			   $mASMString &= 'C7' & ASMOperand(StringMid($aASM, 11, 3), '00', True) & _
							  ASMNumber(StringMid($aASM, 16, StringLen($aASM) - 15))
			; mov dword[eax+C],ecx
			Case StringRegExp($aASM, 'mov dword[[][abcdeipsx]{3}[-+[:xdigit:]]{2,9}[]],[abcdeipsx]{3}\z')
			   If StringMid($aASM, 14, 1) <> '+' Then
				  $lBuffer = BitNOT('0x' & StringMid($aASM, 15, StringInStr($aASM, ']') - 15)) + 1
			   Else
				  $lBuffer = StringMid($aASM, 15, StringInStr($aASM, ']') - 15)
			   EndIf
			   $lBuffer = ASMNumber($lBuffer, True)
			   If @extended Then
				  $mASMSize += 3
				  Local $lStart = 4
			   Else
				  $mASMSize += 6
				  Local $lStart = 8
			   EndIf
			   Local $lASM = ''
			   Switch StringMid($aASM, StringLen($aASM) - 2, 3)
				  Case 'eax'
					 $lASM = Hex($lStart, 1) & '0'
				  Case 'ecx'
					 $lASM = Hex($lStart, 1) & '8'
				  Case 'edx'
					 $lASM = Hex($lStart + 1, 1) & '0'
				  Case 'ebx'
					 $lASM = Hex($lStart + 1, 1) & '8'
				  Case 'esp'
					 $lASM = Hex($lStart + 2, 1) & '0'
				  Case 'ebp'
					 $lASM = Hex($lStart + 2, 1) & '8'
				  Case 'esi'
					 $lASM = Hex($lStart + 3, 1) & '0'
				  Case 'edi'
					 $lASM = Hex($lStart + 3, 1) & '8'
			   EndSwitch
			   $mASMString &= '89' & ASMOperand(StringMid($aASM, 11, 3), $lASM, True) &  $lBuffer
			; mov dword[eax],ecx
			Case StringRegExp($aASM, 'mov dword[[][abcdeipsx]{3}[]],[abcdeipsx]{3}\z')
			   $mASMSize += 2
			   $lBuffer = ''
			   Switch StringMid($aASM, StringLen($aASM) - 2, 3)
				  Case 'eax'
					 $lBuffer = '00'
				  Case 'ecx'
					 $lBuffer = '08'
				  Case 'edx'
					 $lBuffer = '10'
				  Case 'ebx'
					 $lBuffer = '18'
				  Case 'esp'
					 $lBuffer = '20'
				  Case 'ebp'
					 $lBuffer = '28'
				  Case 'esi'
					 $lBuffer = '30'
				  Case 'edi'
					 $lBuffer = '38'
			   EndSwitch
			   $mASMString &= '89' & ASMOperand(StringMid($aASM, 11, 3), $lBuffer, True)
			; hardcoded
			Case $aASM = 'mov al,byte[ecx+4f]'
			   $lOpCode = '8A414F'
			Case $aASM = 'mov al,byte[ecx+3f]'
			   $lOpCode = '8A413F'
			Case $aASM = 'mov al,byte[ebx]'
			   $lOpCode = '8A03'
			Case $aASM = 'mov al,byte[ecx]'
			   $lOpCode = '8A01'
			Case $aASM = 'mov ah,byte[edi]'
			   $lOpCode = '8A27'
			Case $aASM = 'mov dx,word[ecx]'
			   $lOpCode = '668B11'
			Case $aASM = 'mov dx,word[edx]'
			   $lOpCode = '668B12'
			Case $aASM = 'mov word[eax],dx'
			   $lOpCode = '668910'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "cmp" ; cmp
		 Select
			; cmp ebx,dword[MaxAgents]
			Case StringRegExp($aASM, 'cmp (eax|ecx|edx|ebx|esp|ebp|esi|edi),dword\[[a-z,A-Z]{4,}\]')
			   $lBuffer = ''
			   $mASMSize += 6
			   Switch StringMid($aASM, 5, 3)
				  Case 'eax'
					 $lBuffer = '05'
				  Case 'ecx'
					 $lBuffer = '0D'
				  Case 'edx'
					 $lBuffer = '15'
				  Case 'ebx'
					 $lBuffer = '1D'
				  Case 'esp'
					 $lBuffer = '25'
				  Case 'ebp'
					 $lBuffer = '2D'
				  Case 'esi'
					 $lBuffer = '35'
				  Case 'edi'
					 $lBuffer = '3D'
			   EndSwitch
			   $mASMString &= '3B' & $lBuffer & '[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
			; cmp edi,dword[esi]
			Case StringRegExp($aASM, 'cmp (eax|ecx|edx|ebx|esp|ebp|esi|edi),dword\[(eax|ecx|edx|ebx|esp|ebp|esi|edi)\]\z')
			   Local $lBuffer = StringMid($aASM, 15, 3)
			   If $lBuffer = 'ebp' Or $lBuffer = 'esp' Then
				  $mASMString &= '3E3B'
				  $mASMSize += 3
			   Else
				  $mASMString &= '3B'
				  $mASMSize += 2
			   EndIf
			   Switch StringMid($aASM, 5, 3)
				  Case 'eax'
					 $mASMString &= ASMOperand($lBuffer, '00', True, 64)
				  Case 'ecx'
					 $mASMString &= ASMOperand($lBuffer, '08', True, 64)
				  Case 'edx'
					 $mASMString &= ASMOperand($lBuffer, '10', True, 64)
				  Case 'ebx'
					 $mASMString &= ASMOperand($lBuffer, '18', True, 64)
				  Case 'esp'
					 $mASMString &= ASMOperand($lBuffer, '20', True, 64)
				  Case 'ebp'
					 $mASMString &= ASMOperand($lBuffer, '28', True, 64)
				  Case 'esi'
					 $mASMString &= ASMOperand($lBuffer, '30', True, 64)
				  Case 'edi'
					 $mASMString &= ASMOperand($lBuffer, '38', True, 64)
			   EndSwitch
			; cmp edi,dword[exi+4]
			Case StringRegExp($aASM, 'cmp (eax|ecx|edx|ebx|esp|ebp|esi|edi),dword\[(eax|ecx|edx|ebx|esp|ebp|esi|edi)[+-][[:xdigit:]]')
			   If StringMid($aASM, 18, 1) <> '+' Then
				  $lBuffer = BitNOT('0x' & StringMid($aASM, 19, StringLen($aASM) - 19)) + 1
			   Else
				  $lBuffer = StringMid($aASM, 19, StringLen($aASM) - 19)
			   EndIf
			   $lBuffer = ASMNumber($lBuffer, True)
			   If @extended Then
				  $mASMSize += 3
				  Local $lStart = 4
			   Else
				  $mASMSize += 6
				  Local $lStart = 8
			   EndIf
			   Switch StringMid($aASM, 15, 3)
				  Case 'ebp', 'esp'
					 Local $lASM = '3E3B'
					 $mASMSize += 1
				  Case Else
					 Local $lASM = '3B'
			   EndSwitch
			   Local $lASMOpcode = ''
			   Switch StringMid($aASM, 5, 3)
				  Case 'eax'
					 $lASMOpcode = Hex($lStart, 1) & '0'
				  Case 'ecx'
					 $lASMOpcode = Hex($lStart, 1) & '8'
				  Case 'edx'
					 $lASMOpcode = Hex($lStart + 1, 1) & '0'
				  Case 'ebx'
					 $lASMOpcode = Hex($lStart + 1, 1) & '8'
				  Case 'esp'
					 $lASMOpcode = Hex($lStart + 2, 1) & '0'
				  Case 'ebp'
					 $lASMOpcode = Hex($lStart + 2, 1) & '8'
				  Case 'esi'
					 $lASMOpcode = Hex($lStart + 3, 1) & '0'
				  Case 'edi'
					 $lASMOpcode = Hex($lStart + 3, 1) & '8'
			   EndSwitch
			   $mASMString &= $lASM & ASMOperand(StringMid($aASM, 15, 3), $lASMOpcode, True) &  $lBuffer
			; cmp dword[DisableRendering],1
			Case StringRegExp($aASM, 'cmp dword[[][a-z,A-Z]{4,}[]],[-[:xdigit:]]')
			   Local $lStart = StringInStr($aASM, ',')
			   If StringMid($aASM, $lStart + 1, 1) = '-' Then
				  $lBuffer = BitNOT('0x' & StringMid($aASM, $lStart + 2)) + 1
			   Else
				  $lBuffer = StringMid($aASM, $lStart + 1)
			   EndIf
			   $lBuffer = ASMNumber($lBuffer, True)
			   If @extended Then
				  $mASMSize += 7
				  $mASMString &= '833D[' & StringMid($aASM, 11, StringInStr($aASM, ",") - 12) & ']' & $lBuffer
			   Else
				  $mASMSize += 10
				  $mASMString &= '813D[' & StringMid($aASM, 11, StringInStr($aASM, ",") - 12) & ']' & $lBuffer
			   EndIf
			; cmp eax,TargetLogBase
			Case StringRegExp($aASM, 'cmp (eax|ecx|edx|ebx|esp|ebp|esi|edi),[a-z,A-Z]{4,}\z')
			   $lBuffer = ''
			   Switch StringMid($aASM, 5, 3)
				  Case 'eax'
					 $mASMSize += 5
					 $lBuffer = '3D'
				  Case 'ecx'
					 $mASMSize += 6
					 $lBuffer = '81F9'
				  Case 'edx'
					 $mASMSize += 6
					 $lBuffer = '81FA'
				  Case 'ebx'
					 $mASMSize += 6
					 $lBuffer = '81FB'
				  Case 'esp'
					 $mASMSize += 6
					 $lBuffer = '81FC'
				  Case 'ebp'
					 $mASMSize += 6
					 $lBuffer = '81FD'
				  Case 'esi'
					 $mASMSize += 6
					 $lBuffer = '81FE'
				  Case 'edi'
					 $mASMSize += 6
					 $lBuffer = '81FF'
			   EndSwitch
			   $mASMString &= $lBuffer & '[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
			; cmp ebx,14
		 Case StringRegExp($aASM, 'cmp (eax|ecx|edx|ebx|esp|ebp|esi|edi),[-[:xdigit:]]{1,}\z')
			   Local $lStart = StringInStr($aASM, ',')
			   If StringMid($aASM, $lStart + 1, 1) = '-' Then
				  $lBuffer = BitNOT('0x' & StringMid($aASM, $lStart + 2)) + 1
			   Else
				  $lBuffer = StringMid($aASM, $lStart + 1)
			   EndIf
			   $lBuffer = ASMNumber($lBuffer, True)
			   If @extended Then
				  $mASMSize += 3
				  $mASMString &= '83' & ASMOperand(StringMid($aASM, 5, 3), 'F8') & $lBuffer
			   Else
				  $mASMSize += 6
				  $mASMString &= '81' & ASMOperand(StringMid($aASM, 5, 3), 'F8') & $lBuffer
			   EndIf
			; cmp eax,ecx
			Case StringRegExp($aASM, 'cmp (eax|ecx|edx|ebx|esp|ebp|esi|edi),(eax|ecx|edx|ebx|esp|ebp|esi|edi)\z')
			   $lBuffer = ''
			   $mASMSize += 2
			   Switch StringMid($aASM, 9, 3)
				  Case 'eax'
					 $mASMString &= '39' & ASMOperand(StringMid($aASM, 5, 3), 'C0')
				  Case 'ecx'
					 $mASMString &= '39' & ASMOperand(StringMid($aASM, 5, 3), 'C8')
				  Case 'edx'
					 $mASMString &= '39' & ASMOperand(StringMid($aASM, 5, 3), 'D0')
				  Case 'ebx'
					 $mASMString &= '39' & ASMOperand(StringMid($aASM, 5, 3), 'D8')
				  Case 'esp'
					 $mASMString &= '39' & ASMOperand(StringMid($aASM, 5, 3), 'E0')
				  Case 'ebp'
					 $mASMString &= '39' & ASMOperand(StringMid($aASM, 5, 3), 'E8')
				  Case 'esi'
					 $mASMString &= '39' & ASMOperand(StringMid($aASM, 5, 3), 'F0')
				  Case 'edi'
					 $mASMString &= '39' & ASMOperand(StringMid($aASM, 5, 3), 'F8')
			   EndSwitch
			; hardcoded
			Case $aASM = 'cmp word[edx],0'
			   $lOpCode = '66833A00'
			Case $aASM = 'cmp al,ah'
			   $lOpCode = '3AC4'
			Case $aASM = 'cmp al,f'
			   $lOpCode = '3C0F'
			Case $aASM = 'cmp cl,byte[esi+1B1]'
			   $lOpCode = '3A8EB1010000'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "lea" ; lea
		 Select
			; lea eax,dword[ecx*8+TargetLogBase]
			Case StringRegExp($aASM, 'lea eax,dword[[]ecx[*]8[+][a-z,A-Z]{4,}[]]')
			   $mASMSize += 7
			   $mASMString &= '8D04CD[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
			; lea eax,dword[ecx*4+TargetLogBase]
			Case StringRegExp($aASM, 'lea eax,dword[[]edx[*]4[+][a-z,A-Z]{4,}[]]')
			   $mASMSize += 7
			   $mASMString &= '8D0495[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
			; lea ebx,dword[eax*4+TargetLogBase]
			Case StringRegExp($aASM, 'lea ebx,dword[[]eax[*]4[+][a-z,A-Z]{4,}[]]')
			   $mASMSize += 7
			   $mASMString &= '8D1C85[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
			; hardcoded
			Case $aASM = 'lea eax,dword[eax+18]'
			   $lOpCode = '8D4018'
			Case $aASM = 'lea ecx,dword[eax+4]'
			   $lOpCode = '8D4804'
			Case $aASM = 'lea ecx,dword[eax+180]'
			   $lOpCode = '8D8880010000'
			Case $aASM = 'lea edx,dword[eax+4]'
			   $lOpCode = '8D5004'
			Case $aASM = 'lea edx,dword[eax+8]'
			   $lOpCode = '8D5008'
			Case $aASM = 'lea esi,dword[esi+ebx*4]'
			   $lOpCode = '8D349E'
			Case $aASM = 'lea edi,dword[edx+ebx]'
			   $lOpCode = '8D3C1A'
			Case $aASM = 'lea edi,dword[edx+8]'
			   $lOpCode = '8D7A08'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "add" ; add
		 Select
			; add eax, TargetLogBase
			Case StringRegExp($aASM, 'add eax,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			   $mASMSize += 5
			   $mASMString &= '05[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
			; add eax,14
			Case StringRegExp($aASM, 'add eax,[-[:xdigit:]]{1,8}\z')
			   $lBuffer = ASMNumber(StringMid($aASM, 9), True)
			   If @extended Then
				  $mASMSize += 3
				  $mASMString &= '83C0' & $lBuffer
			   Else
				  $mASMSize += 5
				  $mASMString &= '05' & $lBuffer
			   EndIf
			Case StringRegExp($aASM, 'add ecx,[-[:xdigit:]]{1,8}\z')
			   $lBuffer = ASMNumber(StringMid($aASM, 9), True)
			   If @extended Then
				  $mASMSize += 3
				  $mASMString &= '83C1' & $lBuffer
			   Else
				  $mASMSize += 6
				  $mASMString &= '81C1' & $lBuffer
			   EndIf
			Case StringRegExp($aASM, 'add edx,[-[:xdigit:]]{1,8}\z')
			   $lBuffer = ASMNumber(StringMid($aASM, 9), True)
			   If @extended Then
				  $mASMSize += 3
				  $mASMString &= '83C2' & $lBuffer
			   Else
				  $mASMSize += 6
				  $mASMString &= '81C2' & $lBuffer
			   EndIf
			Case StringRegExp($aASM, 'add ebx,[-[:xdigit:]]{1,8}\z')
			   $lBuffer = ASMNumber(StringMid($aASM, 9), True)
			   If @extended Then
				  $mASMSize += 3
				  $mASMString &= '83C3' & $lBuffer
			   Else
				  $mASMSize += 6
				  $mASMString &= '81C3' & $lBuffer
			   EndIf
			Case StringRegExp($aASM, 'add edi,[-[:xdigit:]]{1,8}\z')
			   $lBuffer = ASMNumber(StringMid($aASM, 9), True)
			   If @extended Then
				  $mASMSize += 3
				  $mASMString &= '83C7' & $lBuffer
			   Else
				  $mASMSize += 6
				  $mASMString &= '81C7' & $lBuffer
			   EndIf
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "fstp" ; fstp
		 ; fstp dword[EnsureEnglish]
		 If StringRegExp($aASM, 'fstp dword[[][a-z,A-Z]{4,}[]]') Then
			$mASMSize += 6
			$mASMString &= 'D91D[' & StringMid($aASM, 12, StringLen($aASM) - 12) & ']'
		 Else
			MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			Exit
		 EndIf
	  Case $lMnemonic = "push" ; push
		 Select
			; push dword[EnsureEnglish]
			Case StringRegExp($aASM, 'push dword[[][a-z,A-Z]{4,}[]]')
			   $mASMSize += 6
			   $mASMString &= 'FF35[' & StringMid($aASM, 12, StringLen($aASM) - 12) & ']'
			; push CallbackEvent
			Case StringRegExp($aASM, 'push [a-z,A-Z]{4,}\z')
			   $mASMSize += 5
			   $mASMString &= '68[' & StringMid($aASM, 6, StringLen($aASM) - 5) & ']'
			; push 14
			Case StringRegExp($aASM, 'push [-[:xdigit:]]{1,8}\z')
			   $lBuffer = ASMNumber(StringMid($aASM, 6), True)
			   If @extended Then
				  $mASMSize += 2
				  $mASMString &= '6A' & $lBuffer
			   Else
				  $mASMSize += 5
				  $mASMString &= '68' & $lBuffer
			   EndIf
			; hardcoded
			Case $aASM = 'push eax'
			   $lOpCode = '50'
			Case $aASM = 'push ecx'
			   $lOpCode = '51'
			Case $aASM = 'push edx'
			   $lOpCode = '52'
			Case $aASM = 'push ebx'
			   $lOpCode = '53'
			Case $aASM = 'push ebp'
			   $lOpCode = '55'
			Case $aASM = 'push esi'
			   $lOpCode = '56'
			Case $aASM = 'push edi'
			   $lOpCode = '57'
			Case $aASM = 'push dword[eax+4]'
			   $lOpCode = 'FF7004'
			Case $aASM = 'push dword[eax+8]'
				  $lOpCode = 'FF7008'
			Case $aASM = 'push dword[eax+c]'
			   $lOpCode = 'FF700C'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "pop" ; pop
		 ; hardcoded
		 Select
			Case $aASM = 'pop eax'
			   $lOpCode = '58'
			Case $aASM = 'pop ebx'
			   $lOpCode = '5B'
			Case $aASM = 'pop edx'
			   $lOpCode = '5A'
			Case $aASM = 'pop ecx'
			   $lOpCode = '59'
			Case $aASM = 'pop esi'
			   $lOpCode = '5E'
			Case $aASM = 'pop edi'
			   $lOpCode = '5F'
			Case $aASM = 'pop ebp'
			   $lOpCode = '5D'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "call" ; call
		 Select
			; call dword[EnsureEnglish]
			Case StringRegExp($aASM, 'call dword[[][a-z,A-Z]{4,}[]]')
			   $mASMSize += 6
			   $mASMString &= 'FF15[' & StringMid($aASM, 12, StringLen($aASM) - 12) & ']'
			; call ActionFunction
			Case StringLeft($aASM, 5) = 'call ' And StringLen($aASM) > 8
			   $mASMSize += 5
			   $mASMString &= 'E8{' & StringMid($aASM, 6, StringLen($aASM) - 5) & '}'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "test"
		 Switch $aAsm
			Case $aASM = 'test eax,eax'
			   $lOpCode = '85C0'
			Case $aASM = 'test ecx,ecx'
			   $lOpCode = '85C9'
			Case $aASM = 'test ebx,ebx'
			   $lOpCode = '85DB'
			Case $aASM = 'test esi,esi'
			   $lOpCode = '85F6'
			Case $aASM = 'test dx,dx'
			   $lOpCode = '6685D2'
			Case $aASM = 'test al,al'
			   $lOpCode = '84C0'
			Case $aASM = 'test al,1'
			   $lOpCode = 'A801'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSwitch
	  Case $lMnemonic = "inc"
		 Select
			; inc dword[EnsureEnglish]
			Case StringRegExp($aASM, 'inc dword\[[a-zA-Z]{4,}\]')
			   $mASMSize += 6
			   $mASMString &= 'FF05[' & StringMid($aASM, 11, StringLen($aASM) - 11) & ']'
			Case $aASM = 'inc eax'
			   $lOpCode = '40'
			Case $aASM = 'inc ecx'
			   $lOpCode = '41'
			Case $aASM = 'inc edx'
			   $lOpCode = '42'
			Case $aASM = 'inc ebx'
			   $lOpCode = '43'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "dec"
		 Switch $aAsm
			Case $aASM = 'dec edx'
			   $lOpCode = '4A'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSwitch
	  Case $lMnemonic = "xor"
		 Switch $aAsm
			Case $aASM = 'xor eax,eax'
			   $lOpCode = '33C0'
			Case $aASM = 'xor ecx,ecx'
			   $lOpCode = '33C9'
			Case $aASM = 'xor edx,edx'
			   $lOpCode = '33D2'
			Case $aASM = 'xor ebx,ebx'
			   $lOpCode = '33DB'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSwitch
	  Case $lMnemonic = "sub"
		 Select
			Case StringRegExp($aASM, 'sub [abcdeipsx]{3},[-[:xdigit:]]{1,8}\z')
			   $lBuffer = ASMNumber(StringMid($aASM, 9, StringLen($aASM) - 8), True)
			   If @extended Then
				  $mASMSize += 3
			   Else
				  $mASMSize += 6
			   EndIf
			   $mASMString &= '83' & ASMOperand(StringMid($aASM, 5, 3), 'E8', False) & $lBuffer
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "shl"
		 Switch $aAsm
			Case $aASM = 'shl eax,4'
			   $lOpCode = 'C1E004'
			Case $aASM = 'shl eax,6'
			   $lOpCode = 'C1E006'
			Case $aASM = 'shl eax,7'
			   $lOpCode = 'C1E007'
			Case $aASM = 'shl eax,8'
			   $lOpCode = 'C1E008'
			Case $aASM = 'shl eax,8'
			   $lOpCode = 'C1E008'
			Case $aASM = 'shl eax,9'
			   $lOpCode = 'C1E009'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSwitch
	  Case $lMnemonic = "retn"
		 If $aASM = 'retn 10' Then $lOpCode = 'C21000'
	  Case $aASM = 'repe movsb'
		 $lOpCode = 'F3A4'
	  Case Else
		 MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
		 Exit
   EndSelect
   If $lOpCode <> '' Then
	  $mASMSize += 0.5 * StringLen($lOpCode)
	  $mASMString &= $lOpCode
   EndIf
EndFunc   ;==>_

;~ Description: Completes formatting of ASM code. Internal use only.
Func CompleteASMCode()
   Local $lInExpression = False
   Local $lExpression
   Local $lTempASM = $mASMString
   Local $lCurrentOffset = Dec(Hex($mMemory)) + $mASMCodeOffset
   Local $lToken
   For $i In $mLabelDict.Keys
	  If StringLeft($i, 6) = 'Label_' Then
		 $mLabelDict.Item($i) = $mMemory + $mLabelDict.Item($i)
		 $mLabelDict.Key($i) = StringTrimLeft($i, 6)
	  EndIf
   Next
   $mASMString = ''
   For $i = 1 To StringLen($lTempASM)
	  $lToken = StringMid($lTempASM, $i, 1)
	  Switch $lToken
		 Case '(', '[', '{'
			$lInExpression = True
		 Case ')'
			$mASMString &= Hex(GetLabelInfo($lExpression) - Int($lCurrentOffset) - 1, 2)
			$lCurrentOffset += 1
			$lInExpression = False
			$lExpression = ''
		 Case ']'
			$mASMString &= SwapEndian(Hex(GetLabelInfo($lExpression), 8))
			$lCurrentOffset += 4
			$lInExpression = False
			$lExpression = ''
		 Case '}'
			$mASMString &= SwapEndian(Hex(GetLabelInfo($lExpression) - Int($lCurrentOffset) - 4, 8))
			$lCurrentOffset += 4
			$lInExpression = False
			$lExpression = ''
		 Case Else
			If $lInExpression Then
			   $lExpression &= $lToken
			Else
			   $mASMString &= $lToken
			   $lCurrentOffset += 0.5
			EndIf
	  EndSwitch
   Next
EndFunc   ;==>CompleteASMCode

;~ Description: Returns GetValue($aLabel) and exits, if label cant be found.
Func GetLabelInfo($aLabel)
   Local $lValue = GetValue($aLabel)
   If $lValue = -1 Then Exit MsgBox(0, 'Label', 'Label: ' & $aLabel & ' not provided')
   Return $lValue
EndFunc   ;==>GetLabelInfo

;~ Description: Converts hexadecimal to ASM.
Func ASMNumber($aNumber, $aSmall = False)
   If $aNumber >= 0 Then
	  $aNumber = Dec($aNumber)
   EndIf
   If $aSmall And $aNumber <= 127 And $aNumber >= -128 Then
	  Return SetExtended(1, Hex($aNumber, 2))
   Else
	  Return SetExtended(0, SwapEndian(Hex($aNumber, 8)))
   EndIf
EndFunc   ;==>ASMNumber

;~ Descripion: Increases opcode-part according to opcode basis value.
Func ASMOperand($aSearchString, $aOpcodeString, $aESP = False, $aEBP = 0)
   Switch $aSearchString
	  Case 'eax'
		 Return $aOpcodeString
	  Case 'ecx'
		 Return Hex(Dec($aOpcodeString) + 1, 2)
	  Case 'edx'
		 Return Hex(Dec($aOpcodeString) + 2, 2)
	  Case 'ebx'
		 Return Hex(Dec($aOpcodeString) + 3, 2)
	  Case 'esp'
		 If $aESP Then
			$mASMSize += 1
			Return Hex(Dec($aOpcodeString) + 4, 2) & '24'
		 EndIf
		 Return Hex(Dec($aOpcodeString) + 4, 2)
	  Case 'ebp'
		 If $aEBP > 0 Then
			$mASMSize += 1
			Return Hex(Dec($aOpcodeString) + 5 + $aEBP, 2) & '00'
		 EndIf
		 Return Hex(Dec($aOpcodeString) + 5, 2)
	  Case 'esi'
		 Return Hex(Dec($aOpcodeString) + 6, 2)
	  Case 'edi'
		 Return Hex(Dec($aOpcodeString) + 7, 2)
   EndSwitch
EndFunc
#EndRegion Assembler

#Region Conversion
;~ Description: Converts float to integer.
Func FloatToInt($nFloat)
   Local $tFloat = DllStructCreate("float")
   Local $tInt = DllStructCreate("int", DllStructGetPtr($tFloat))
   DllStructSetData($tFloat, 1, $nFloat)
   Return DllStructGetData($tInt, 1)
EndFunc   ;==>FloatToInt
#EndRegion

#Region Misc
;~ Description: Prepares data to be used to call Guild War's packet send function.
Func SendPacket($aSize, $aHeader, $aParam1 = 0, $aParam2 = 0, $aParam3 = 0, $aParam4 = 0, $aParam5 = 0, $aParam6 = 0, $aParam7 = 0, $aParam8 = 0, $aParam9 = 0, $aParam10 = 0)
   DllStructSetData($mPacket, 2, $aSize)
   DllStructSetData($mPacket, 3, $aHeader)
   DllStructSetData($mPacket, 4, $aParam1)
   DllStructSetData($mPacket, 5, $aParam2)
   DllStructSetData($mPacket, 6, $aParam3)
   DllStructSetData($mPacket, 7, $aParam4)
   DllStructSetData($mPacket, 8, $aParam5)
   DllStructSetData($mPacket, 9, $aParam6)
   DllStructSetData($mPacket, 10, $aParam7)
   DllStructSetData($mPacket, 11, $aParam8)
   DllStructSetData($mPacket, 12, $aParam9)
   DllStructSetData($mPacket, 13, $aParam10)
   Return Enqueue($mPacketPtr, 52)
EndFunc   ;==>SendPacket

;~ Description: Call CommandAction.
Func PerformAction($aAction, $aFlag)
   DllStructSetData($mAction, 2, $aAction)
   DllStructSetData($mAction, 3, $aFlag)
   Return Enqueue($mActionPtr, 12)
EndFunc   ;==>PerformAction

;~ Description: Returns current ping.
Func GetPing()
   Return MemoryRead($mPing)
EndFunc   ;==>GetPing

;~ Description: Get name of currently logged in character.
Func GetCharname()
   Return MemoryRead($mCharname, 'wchar[30]')
EndFunc   ;==>GetCharname

;~ Description: Returns logged in or not.
Func GetLoggedIn()
   Return MemoryRead($mLoggedCounter) > 0
EndFunc   ;==>GetLoggedIn

;~ Description: Returns currently used language as number, same as GetLanguage().
Func GetDisplayLanguage()
   Static Local $lLanguagePtr = 0
   If $lLanguagePtr = 0 Then
	  Local $lOffset[6] = [0, 0x18, 0x18, 0x194, 0x4C, 0x40]
	  $lLanguagePtr = MemoryReadPtrChain($mBasePointer, $lOffset, 'ptr')
   EndIf
   Return MemoryRead($lLanguagePtr)
EndFunc   ;==>GetDisplayLanguage

;~ Description: Returns the game client's build number.
Func GetBuildNumber()
   Return $mBuildNumber
EndFunc   ;==>GetBuildNumber

;~ Description: Sleep a random amount of time.
Func RndSleep($aAmount, $aRandom = 0.05)
   Local $lRandom = $aAmount * $aRandom
   Sleep(Random($aAmount - $lRandom, $aAmount + $lRandom))
EndFunc   ;==>RndSleep

;~ Description: Sleep a period of time, plus or minus a tolerance
Func TolSleep($aAmount = 150, $aTolerance = 50)
   Sleep(Random($aAmount - $aTolerance, $aAmount + $aTolerance))
EndFunc   ;==>TolSleep

;~ Description: Sleeps time plus your ping.
Func PingSleep($Time = 1000)
   Sleep(GetPing() + $Time)
EndFunc   ;==>PingSleep

;~ Description: Window Handle to game client, variable set during initialize.
Func GetWindowHandle()
   Return $mGWHwnd
EndFunc   ;==>GetWindowHandle

;~ Description: Computes distance between two sets of coordinates.
Func ComputeDistance($aX1, $aY1, $aX2, $aY2)
   Return Sqrt(($aX1 - $aX2) ^ 2 + ($aY1 - $aY2) ^ 2)
EndFunc   ;==>ComputeDistance

;~ Description: Same as ComputeDistance, but without Sqrt.
Func ComputePseudoDistance($aX1, $aY1, $aX2, $aY2)
   Return ($aX1 - $aX2) ^ 2 + ($aY1 - $aY2) ^ 2
EndFunc   ;==>ComputeDistance

;~ Description: Opens storage window, only in outpost its possible to change content of chest.
Func OpenStorageWindow()
   Local $lID = StorageSessionID()
   DllStructSetData($mOpenStorage, 2, $lID)
   DllStructSetData($mOpenStorage, 3, 0)
   DllStructSetData($mOpenStorage, 4, 1)
   DllStructSetData($mOpenStorage, 5, 2)
   Return Enqueue($mOpenStoragePtr, 20)
EndFunc   ;==>OpenStorageWindow

;~ Description: Gets current storage session ID.
Func StorageSessionID()
   Local $lOffset[5] = [0, 0x118, 0x10, 0, 0x14]
   Local $lReturn = MemoryReadPtr($mStorageSessionBase, $lOffset)
   Return $lReturn[1]
EndFunc   ;==>StorageSessionID

;~ Description: Checks if game client got disconnected and attempts to reconnect.
Func Disconnected()
   If MemoryRead($MyPtr + 44, 'long') <> $MyID Then
	  If SetPointers() Then Return False
   EndIf
   If MemoryRead($mLoggedCounter) <> 0 Then Return False ; not disconnected at all
   Local $lEnabledRendering = False
   If Not $mRendering Then
	  EnableRendering(False)
	  $lEnabledRendering = True
   EndIf
   Local $lTimer = 0
   Local $lDeadlock = TimerInit()
   Do
	  $lTimer = TimerInit()
	  ControlSend(GetWindowHandle(), "", "", "{Enter}")
	  Do
		 Sleep(1000) ; no rush
		 If MemoryRead($mLoggedCounter) <> 0 Then ; we made it back ingame hopefully
			If SetPointers() Then
			   If $lEnabledRendering = False Then DisableRendering()
			   Return True ; really made it back
			EndIf
			ConsoleWrite("Couldnt retrieve $MyPtr." & @CRLF)
			ExitLoop 2 ; client probably crashed, exit script
		 EndIf
	  Until TimerDiff($lTimer) > 10000
   Until TimerDiff($lDeadlock) > 120000
   ConsoleWrite("Exiting script." & @CRLF)
   EnableRendering()
   RestoreDetour()
   Exit
EndFunc   ;==>Disconnected

;~ Description: Tries to get correct $MyID and $MyPtr and resets essential pointer variables to zero.
;~ Called in WaitMapLoading() and Disconnected().
Func SetPointers()
   Local $lDeadlock = TimerInit()
   Do
	  Do
		 If TimerDiff($lDeadlock) > 15000 Then Return False
		 Sleep(1000)
		 $MyID = MemoryRead($mMyID)
	  Until $MyID > 0
	  $MyPtr = GetAgentPtr($MyID)
   Until $MyID = MemoryRead($MyPtr + 44, 'long')
   $TitlesPtr = 0
   $HeroPtr1 = 0
   $HeroPtr2 = 0
   $HeroPtr3 = 0
   $HeroPtr4 = 0
   $ItemBasePtr = 0
   $BagBasePtr = 0
   $GoldBasePtr = 0
   $PartySizePtr = 0
   $QuestBasePtr = 0
   $SkillbarBasePtr = 0
   $BuffBasePtr = 0
   Return True
EndFunc

;~ Description: Reset essential variables to zero. Used in event().
;~ If eventsystem is disabled, this has to be called manually after each loading screen.
Func ResetPointers()
   ConsoleWrite("ResetPointers." & @CRLF)
   $TitlesPtr = 0
   $HeroPtr1 = 0
   $HeroPtr2 = 0
   $HeroPtr3 = 0
   $HeroPtr4 = 0
   $ItemBasePtr = 0
   $BagBasePtr = 0
   $GoldBasePtr = 0
   $PartySizePtr = 0
   $QuestBasePtr = 0
   $SkillbarBasePtr = 0
   $BuffBasePtr = 0
EndFunc
#EndRegion
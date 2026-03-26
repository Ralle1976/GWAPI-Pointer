
#include-once

#Region InitializePlugins
;~ Description: Reads data from plugin files and stores them for use during initialize.
Func InitPlugins()
   ; create filelist
   Local $lFileListArray = CreatePluginList(StringRegExpReplace(@ScriptDir, '[\\/]+$', '') & '\gwAPI\plugins\')
   If Not IsArray($lFileListArray) Then
	  $mUsePlugins = False
	  Return
   EndIf
   ; read line and evaluate -> dismiss empty lines, section headers
   Local $lSize = 0
   Local $lTempArray = 0
   For $iFileName In $lFileListArray
	  $lTempArray = IniReadSection($iFileName, 'CreateASM')
	  If @error = 0 Then
		 PluginArrayCombine($mAsmArray, $lTempArray)
		 $mAsmArray[0][0] += $lTempArray[0][0]
	  EndIf
	  $lTempArray = IniReadSection($iFileName, 'CreateData')
	  If @error = 0 Then
		 PluginArrayCombine($mDataArray, $lTempArray)
		 $mDataArray[0][0] += $lTempArray[0][0]
	  EndIf
	  $lTempArray = IniReadSection($iFileName, 'CreateDetours')
	  If @error = 0 Then
		 PluginArrayCombine($mDetoursArray, $lTempArray)
		 $mDetoursArray[0][0] += $lTempArray[0][0]
	  EndIf
	  $lTempArray = IniReadSection($iFileName, 'CreateScans')
	  If @error = 0 Then
		 PluginArrayCombine($mScansArray, $lTempArray)
		 $mScansArray[0][0] += $lTempArray[0][0]
	  EndIf
	  $lTempArray = IniReadSection($iFileName, 'SetValues')
	  If @error = 0 Then
		 PluginArrayCombine($mSetValuesArray, $lTempArray)
		 $mSetValuesArray[0][0] += $lTempArray[0][0]
	  EndIf
   Next
   Return True
EndFunc   ;==>InitPlugins

;~ Description: Creates filelist array of plugins in plugins folder.
Func CreatePluginList($aFilePath)
   Local $lReturn = ''
   Local $lFileName = ''
   Local $lPath = StringRegExpReplace($aFilePath, '[\\/]+$', '') & '\'
   If Not FileExists($lPath) Then
	  ConsoleWrite("FileExists." & StringRegExpReplace($aFilePath, '[\\/]+$', '') & '\' & @CRLF)
	  Return
   EndIf
   Local $lSearchHandle = FileFindFirstFile($lPath & '*.gwplasm')
   If @error Then
	  ConsoleWrite("Error." & @CRLF)
	  Return
   EndIf
   While 1
	  $lFileName = FileFindNextFile($lSearchHandle)
	  If @error Then ExitLoop
	  If @extended = 1 Then ContinueLoop ; no clue why there's folders in there
	  $lReturn &= $lPath & $lFileName & '|'
   WEnd
   FileClose($lSearchHandle)
   Return StringRegExp($lReturn, '(.+?)\|', 3)
EndFunc   ;==>CreatePluginList

;~ Description: Simple function to concatenate two 2D arrays.
Func PluginArrayCombine(ByRef $aBasisArray, Const ByRef $aAddArray)
   ReDim $aBasisArray[$aBasisArray[0][0] + $aAddArray[0][0] + 1][2]
   For $i = 1 To $aAddArray[0][0]
	  For $j = 0 To 1
		 $aBasisArray[$aBasisArray[0][0] + $i][$j] = $aAddArray[$i][$j]
	  Next
   Next
EndFunc   ;==>PluginArrayCombine

;~ Description: Adds ASM section to ModifyMemory.
Func AddPluginASM()
   For $i = 1 To $mAsmArray[0][0]
	  _($mAsmArray[$i][1])
 	  ConsoleWrite("('" & $mAsmArray[$i][1] & "')" & @CRLF)
   Next
EndFunc

;~ Description: Adds ASM Variables to CreateData.
Func AddPluginData()
   For $i = 1 To $mDataArray[0][0]
	  _($mDataArray[$i][1])
 	  ConsoleWrite("('" & $mDataArray[$i][1] & "')" & @CRLF)
   Next
EndFunc

;~ Description: Adds Detours to InitClient.
Func AddPluginDetours()
   For $i = 1 To $mDetoursArray[0][0]
 	  ConsoleWrite("WriteDetour('" & $mDetoursArray[$i][0] & "', '" & $mDetoursArray[$i][1] & "')" & @CRLF)
	  WriteDetour($mDetoursArray[$i][0], $mDetoursArray[$i][1])
   Next
EndFunc

;~ Description: Adds Scans to ScanEngine.
Func AddPluginScans()
   For $i = 1 To $mScansArray[0][0]
 	  ConsoleWrite("_('" & $mScansArray[$i][0] & ':' & "')" & @CRLF)
	  _($mScansArray[$i][0] & ':')
 	  ConsoleWrite("AddPattern('" & $mScansArray[$i][1] & "')" & @CRLF)
	  AddPattern($mScansArray[$i][1])
   Next
EndFunc

;~ Description: Adds scan values to LabelDict, via SetValue().
Func AddPluginSetValues()
   If $mSetValuesArray[0][0] < 4 Then Return
   Local $lScannedAddress, $lName, $lOffsetString, $lSign
   Local $lOldScan = ''
   Local $lCount = 0
   Do
	  $lCount += 1
	  $lName = $mSetValuesArray[$lCount][1]
	  $lCount += 1
	  If $mSetValuesArray[$lCount][1] <> $lOldScan Then
		 $lOldScan = $mSetValuesArray[$lCount][1]
		 $lCount += 1
		 $lOffsetString = $mSetValuesArray[$lCount][1]
		 $lSign = StringLeft($lOffsetString, 1)
		 If $lSign <> '-' Then
			$lSign = ''
		 Else
			$lOffsetString = StringTrimLeft($lOffsetString, 1)
		 EndIf
		 $lScannedAddress = GetScannedAddress($lOldScan, $lSign & Number($lOffsetString))
 		 ConsoleWrite("GetScannedAddress('" & $lOldScan & "', " & $lSign & Number($lOffsetString) & ")" & @CRLF)
		 $lCount += 1
		 If Number($mSetValuesArray[$lCount][1]) <> 0 Then
 			ConsoleWrite("MemoryRead(" & $lScannedAddress & ")" & @CRLF)
			$lScannedAddress = MemoryRead($lScannedAddress)
		 EndIf
	  Else
		 $lCount += 2
	  EndIf
	  $lCount += 1
 	  ConsoleWrite("SetValue('" & $lName & "', " & Ptr($lScannedAddress + Number($mSetValuesArray[$lCount][1])) & ")" & @CRLF)
	  SetValue($lName, Ptr($lScannedAddress + Number($mSetValuesArray[$lCount][1])))
   Until $lCount >= $mSetValuesArray[0][0]
EndFunc
#EndRegion

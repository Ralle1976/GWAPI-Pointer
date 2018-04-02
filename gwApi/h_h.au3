#include-once

#Region PartyCommands
;~ Description: Adds a hero to the party.
Func AddHero($aHeroId)
   Return SendPacket(0x8, 0x17, $aHeroId)
EndFunc   ;==>AddHero

;~ Description: Kicks a hero from the party.
Func KickHero($aHeroId)
   Return SendPacket(0x8, 0x18, $aHeroId)
EndFunc   ;==>KickHero

;~ Description: Kicks all heroes from the party.
Func KickAllHeroes()
   Return SendPacket(0x8, 0x18, 0x26)
EndFunc   ;==>KickAllHeroes

;~ Description: Add a henchman to the party.
Func AddNpc($aNpcId)
   Return SendPacket(0x8, 0x99, $aNpcId)
EndFunc   ;==>AddNpc

;~ Description: Kick a henchman from the party.
Func KickNpc($aNpcId)
   Return SendPacket(0x8, 0xA2, $aNpcId)
EndFunc   ;==>KickNpc

;~ Description: Place a hero's position flag.
Func CommandHero($aHeroNumber, $aX, $aY, $aHeroID = GetHeroID($aHeroNumber))
   Return SendPacket(0x14, 0x13, $aHeroID, FloatToInt($aX), FloatToInt($aY), 0)
EndFunc   ;==>CommandHero

;~ Description: Clear the position flag from a hero.
Func CancelHero($aHeroNumber, $aAgentID = GetHeroID($aHeroNumber))
   Return SendPacket(0x14, 0x13, $aAgentID, 0x7F800000, 0x7F800000, 0)
EndFunc   ;==>CancelHero

;~ Description: Place the full-party position flag.
Func CommandAll($aX, $aY)
   Return SendPacket(0x10, 0x14, FloatToInt($aX), FloatToInt($aY), 0)
EndFunc   ;==>CommandAll

;~ Description: Clear the full-party position flag.
Func CancelAll()
   Return SendPacket(0x10, 0x14, 0x7F800000, 0x7F800000, 0)
EndFunc   ;==>CancelAll

;~ Description: Clear all hero flags.
;~ Full-party position flag and hero's 1-3 position flags.
Func ClearPartyCommands()
   Return PerformAction(0xDB, 0x18)
EndFunc   ;==>ClearPartyCommands

;~ Description: Lock a hero onto a target.
Func LockHeroTarget($aHeroNumber, $aAgentID = 0, $aHeroID = GetHeroID($aHeroNumber)) ;$aAgentID=0 Cancels Lock
   Return SendPacket(0xC, 0xF, $aHeroID, $aAgentID)
EndFunc   ;==>LockHeroTarget

;~ Description: Change a hero's aggression level.
Func SetHeroAggression($aHeroNumber, $aAggression, $aHeroID = GetHeroID($aHeroNumber)) ;0=Fight, 1=Guard, 2=Avoid
   Return SendPacket(0xC, 0xE, $aHeroID, $aAggression)
EndFunc   ;==>SetHeroAggression
#EndRegion

#Region Hero Skillbar Interaction
;~ Description: Disable a skill on a hero's skill bar.
Func DisableHeroSkillSlot($aHeroNumber, $aSkillSlot, $aPtr = GetSkillbarPtr($aHeroNumber), $aHeroID = GetHeroID($aHeroNumber))
   Local $lDeadlock = TimerInit()
   While Not GetIsHeroSkillSlotDisabled($aHeroNumber, $aSkillSlot, $aPtr)
	  ChangeHeroSkillSlotState($aHeroNumber, $aSkillSlot, $aHeroID)
	  Sleep(500)
	  If TimerDiff($lDeadlock) > 5000 Then Return False
   WEnd
   Return True
EndFunc   ;==>DisableHeroSkillSlot

;~ Description: Enable a skill on a hero's skill bar.
Func EnableHeroSkillSlot($aHeroNumber, $aSkillSlot, $aPtr = GetSkillbarPtr($aHeroNumber), $aHeroID = GetHeroID($aHeroNumber))
   Local $lDeadlock = TimerInit()
   While GetIsHeroSkillSlotDisabled($aHeroNumber, $aSkillSlot, $aPtr)
	  ChangeHeroSkillSlotState($aHeroNumber, $aSkillSlot, $aHeroID)
	  Sleep(500)
	  If TimerDiff($lDeadlock) > 5000 Then Return False
   WEnd
   Return True
EndFunc   ;==>EnableHeroSkillSlot

;~ Description: Internal use for enabling or disabling hero skills
Func ChangeHeroSkillSlotState($aHeroNumber, $aSkillSlot, $aHeroID = GetHeroID($aHeroNumber))
   Return SendPacket(0xC, 0x12, $aHeroID, $aSkillSlot - 1)
EndFunc   ;==>ChangeHeroSkillSlotState

;~ Description: Tests if a hero's skill slot is disabled.
Func GetIsHeroSkillSlotDisabled($aHeroNumber, $aSkillSlot, $aPtr = GetSkillbarPtr($aHeroNumber))
   Local $lDisabled = MemoryRead($aPtr + 164, 'dword')
   If $aSkillSlot > 1 Then
	  Local $lBitMask = 2 ^ ($aSkillSlot - 1)
   Else
	  Local $lBitMask = 1
   EndIf
   Return BitAND($lBitMask, $lDisabled) > 0
EndFunc   ;==>GetIsHeroSkillSlotDisabled

;~ Description: Order a hero to use a skill.
Func UseHeroSkill($aHero, $aSkillSlot, $aTarget = -2)
   If IsPtr($aTarget) <> 0 Then
	  Local $lTargetID = MemoryRead($aTarget + 44, 'long')
   ElseIf IsDllStruct($aTarget) <> 0 Then
	  Local $lTargetID = DllStructGetData($aTarget, 'ID')
   Else
	  Local $lTargetID = ConvertID($aTarget)
   EndIf
   DllStructSetData($mUseHeroSkill, 2, GetHeroID($aHero))
   DllStructSetData($mUseHeroSkill, 3, $lTargetID)
   DllStructSetData($mUseHeroSkill, 4, $aSkillSlot - 1)
   Return Enqueue($mUseHeroSkillPtr, 16)
EndFunc   ;==>UseHeroSkill
#EndRegion

#Region Information
#cs
Herostruct1 -> $lOffset[5] = [0, 0x18, 0x4C, 0x54, 0x24], $mBasePointer
   size: 0x18
   long: HeroID
   byte[4]: unknown
   long: HeroNameID
   byte[8]: unknown
   long: level

Herostruct2 -> $lOffset[5] = [0, 0x18, 0x2C, 0x6BC, 0], $mBasePointer
   size: 0x14
   long: HeroID
   long: Primary
   long: Secondary
   byte[8]: unknown
#ce

;~ Description: Returns number of heroes you control.
Func GetHeroCount()
   If $HeroPtr1 = 0 Then $HeroPtr1 = MemoryRead($mBasePtr184C + 0x54, 'ptr')
   Return MemoryRead($HeroPtr1 + 0x2C)
EndFunc   ;==>GetHeroCount

;~ Description: Returns agent ID of a hero.
Func GetHeroID($aHeroNumber)
   If $aHeroNumber = 0 Then Return GetMyID()
   If $HeroPtr1 = 0 Then $HeroPtr1 = MemoryRead($mBasePtr184C + 0x54, 'ptr')
   If $HeroPtr2 = 0 Then $HeroPtr2 = MemoryRead($HeroPtr1 + 0x24, 'ptr')
   Return MemoryRead($HeroPtr2 + 0x18 * ($aHeroNumber - 1))
EndFunc   ;==>GetHeroID

;~ Description: Returns hero number by hero ID.
Func GetHeroNumberByHeroID($aHeroID)
   If $aHeroID < 0 Then $aHeroID = ConvertID($aHeroID)
   If $HeroPtr1 = 0 Then $HeroPtr1 = MemoryRead($mBasePtr184C + 0x54, 'ptr')
   If $HeroPtr2 = 0 Then $HeroPtr2 = MemoryRead($HeroPtr1 + 0x24, 'ptr')
   For $i = 1 To MemoryRead($HeroPtr1 + 0x2C)
	  If MemoryRead($HeroPtr2 + 0x18 * ($i - 1)) = $aHeroID Then Return $i
   Next
EndFunc   ;==>GetHeroNumberByHeroID

;~ Description: Returns HeroNameID of hero in group.
Func GetHeroNameID($aHeroNumber)
   If $aHeroNumber = 0 Then Return 0
   If $HeroPtr1 = 0 Then $HeroPtr1 = MemoryRead($mBasePtr184C + 0x54, 'ptr')
   If $HeroPtr2 = 0 Then $HeroPtr2 = MemoryRead($HeroPtr1 + 0x24, 'ptr')
   Local $lHeroNameID = MemoryRead($HeroPtr2 + 0x18 * ($aHeroNumber - 1) + 8)
   If $lHeroNameID < 1 Or $lHeroNameID > 36 Then Return 0
   Return $lHeroNameID
EndFunc   ;==>GetHeroNameID

;~ Description: Returns my profession when passed 0 ; GetHeroProfession(0)
;~ Returns hero's profession ID (when it can't be found by other means)
Func GetHeroProfession($aHeroNumber, $aSecondary = False, $aHeroID = GetHeroID($aHeroNumber))
   If $HeroPtr3 = 0 Then $HeroPtr3 = MemoryRead($mBasePtr182C + 0x6BC)
   Local $lTemp = 0, $lBuffer, $lExtended
   For $i = 0 To GetHeroCount()
	  $lBuffer = MemoryRead($HeroPtr3 + $lTemp)
	  If $lBuffer = $aHeroID Then
		 $lTemp += 4
		 If Not $aSecondary Then
			Return MemoryRead($HeroPtr3 + $lTemp)
		 Else
			$lExtended = MemoryRead($HeroPtr3 + $lTemp)
			$lTemp += 4
			Return SetExtended($lExtended, MemoryRead($HeroPtr3 + $lTemp))
		 EndIf
	  EndIf
	  $lTemp += 0x14
   Next
EndFunc   ;==>GetHeroProfession

;~ Description: Returns all hero equipment pointers in an array.
Func GetHeroEquipBagPtrArray()
   If $HeroPtr4 = 0 Then $HeroPtr4 = MemoryRead($mBasePtr1840 + 0x24, 'ptr')
   Local $lCount = 0, $lTemp
   Local $lHeroCount = GetHeroCount()
   Local $lReturn[$lHeroCount + 1]
   For $i = 0 To 100
	  $lTemp = MemoryRead($HeroPtr4 + 0x34 + $i * 4, 'ptr')
	  If MemoryRead(MemoryRead($lTemp + 20, 'ptr') + 68, 'ptr') <> $lTemp Then ContinueLoop
	  $lCount += 1
	  $lReturn[$lCount] = $lTemp
	  If $lCount = $lHeroCount Then ExitLoop
   Next
   $lReturn[0] = $lCount
   Return $lReturn
EndFunc   ;==>GetHeroEquipBagPtrArray
#EndRegion
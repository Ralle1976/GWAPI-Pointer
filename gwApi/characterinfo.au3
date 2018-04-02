#include-once

#Region Titles
;~ Description: Returns Hero title progress.
Func GetHeroTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x4)
EndFunc   ;==>GetHeroTitle

;~ Description: Returns Gladiator title progress.
Func GetGladiatorTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x7C)
EndFunc   ;==>GetGladiatorTitle

;~ Description: Returns Kurzick title progress.
Func GetKurzickTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0xCC)
EndFunc   ;==>GetKurzickTitle

;~ Description: Returns Luxon title progress.
Func GetLuxonTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0xF4)
EndFunc   ;==>GetLuxonTitle

;~ Description: Returns drunkard title progress.
Func GetDrunkardTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x11C)
EndFunc   ;==>GetDrunkardTitle

;~ Description: Returns survivor title progress.
Func GetSurvivorTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x16C)
EndFunc   ;==>GetSurvivorTitle

;~ Description: Returns max titles
Func GetMaxTitles()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x194)
EndFunc   ;==>GetMaxTitles

;~ Description: Returns lucky title progress.
Func GetLuckyTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x25C)
EndFunc   ;==>GetLuckyTitle

;~ Description: Returns unlucky title progress.
Func GetUnluckyTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x284)
EndFunc   ;==>GetUnluckyTitle

;~ Description: Returns Sunspear title progress.
Func GetSunspearTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x2AC)
EndFunc   ;==>GetSunspearTitle

;~ Description: Returns Lightbringer title progress.
Func GetLightbringerTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x324)
EndFunc   ;==>GetLightbringerTitle

;~ Description: Returns Commander title progress.
Func GetCommanderTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x374)
EndFunc   ;==>GetCommanderTitle

;~ Description: Returns Gamer title progress.
Func GetGamerTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x39C)
EndFunc   ;==>GetGamerTitle

;~ Description: Returns Legendary Guardian title progress.
Func GetLegendaryGuardianTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x4DC)
EndFunc   ;==>GetLegendaryGuardianTitle

;~ Description: Returns sweets title progress.
Func GetSweetTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x554)
EndFunc   ;==>GetSweetTitle

;~ Description: Returns Asura title progress.
Func GetAsuraTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x5F4)
EndFunc   ;==>GetAsuraTitle

;~ Description: Returns Deldrimor title progress.
Func GetDeldrimorTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x61C)
EndFunc   ;==>GetDeldrimorTitle

;~ Description: Returns Vanguard title progress.
Func GetVanguardTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x644)
EndFunc   ;==>GetVanguardTitle

;~ Description: Returns Norn title progress.
Func GetNornTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x66C)
EndFunc   ;==>GetNornTitle

;~ Description: Returns mastery of the north title progress.
Func GetNorthMasteryTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x694)
EndFunc   ;==>GetNorthMasteryTitle

;~ Description: Returns party title progress.
Func GetPartyTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x6BC)
EndFunc   ;==>GetPartyTitle

;~ Description: Returns Zaishen title progress.
Func GetZaishenTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x6E4)
EndFunc   ;==>GetZaishenTitle

;~ Description: Returns treasure hunter title progress.
Func GetTreasureTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x70C)
EndFunc   ;==>GetTreasureTitle

;~ Description: Returns wisdom title progress.
Func GetWisdomTitle()
   If $TitlesPtr = 0 Then $TitlesPtr = MemoryRead($mBasePtr182C + 0x81C)
   Return MemoryRead($TitlesPtr + 0x734)
EndFunc   ;==>GetWisdomTitle

#Region SetTitle
;~ Description:	Set the currently displayed title.
;~ Author: Skaldish
;~ No Title			= 0x00
;~ Spearmarshall 	= 0x11
;~ Lightbringer 	= 0x14
;~ Asuran 			= 0x26
;~ Dwarven 			= 0x27
;~ Ebon Vanguard 	= 0x28
;~ Norn 			= 0x29
Func SetDisplayedTitle($aTitle = 0)
   If $aTitle Then
	  Return SendPacket(0x8, 0x51, $aTitle)
   Else
	  Return SendPacket(0x4, 0x52)
   EndIf
EndFunc   ;==>SetDisplayedTitle
#EndRegion
#EndRegion Titles

#Region Misc
;~ Description: Returns current amount of skillpoints.
Func GetSkillpoints()
   Return MemoryRead($mBasePtr182C + 0x7A8)
EndFunc   ;==>GetSkillpoints

;~ Description: Returns amount of experience.
Func GetExperience()
   Return MemoryRead($mBasePtr182C + 0x740)
EndFunc   ;==>GetExperience

;~ Description: Returns current morale.
Func GetMorale($aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   Static Local $lIndex = 0
   If $lIndex = 0 Then $lIndex = MemoryRead($mBasePtr182C + 0x638)
   Static Local $lMoraleBasePtr = 0
   If $lMoraleBasePtr = 0 Then $lMoraleBasePtr = MemoryRead($mBasePtr182C + 0x62C)
   Local $lTemp = MemoryRead($lMoraleBasePtr + 8 + 0xC * BitAND($aHeroID, $lIndex), 'ptr')
   Return MemoryRead($lTemp + 0x18, 'long') - 100
EndFunc   ;==>GetMorale
#EndRegion


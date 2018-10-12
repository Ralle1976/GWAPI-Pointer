
#include-once

#Region Donate
;~ Description: Donate Kurzick or Luxon faction.
Func DonateFaction($aFaction)
   If StringLeft($aFaction, 1) = 'k' Then
	  Return SendPacket(0x10, $CtoGS_MSG_DonateFaction, 0, 0, 5000)  ;~ old -> 	  Return SendPacket(0x10, 0x2F, 0, 0, 5000)
   Else
	  Return SendPacket(0x10, $CtoGS_MSG_DonateFaction, 0, 1, 5000)  ;~ old -> 	  Return SendPacket(0x10, 0x2F, 0, 1, 5000)
   EndIf
EndFunc   ;==>DonateFaction
#EndRegion

#Region Kurzick
;~ Description: Returns current Kurzick faction.
Func GetKurzickFaction()
   Return MemoryRead($mBasePtr182C + 0x748)
EndFunc   ;==>GetKurzickFaction

;~ Description: Returns max Kurzick faction.
Func GetMaxKurzickFaction()
   Return MemoryRead($mBasePtr182C + 0x7B8)
EndFunc   ;==>GetMaxKurzickFaction
#EndRegion

#Region Luxon
;~ Description: Returns current Luxon faction.
Func GetLuxonFaction()
   Return MemoryRead($mBasePtr182C + 0x758)
EndFunc   ;==>GetLuxonFaction

;~ Description: Returns max Luxon faction.
Func GetMaxLuxonFaction()
   Return MemoryRead($mBasePtr182C + 0x7BC)
EndFunc   ;==>GetMaxLuxonFaction
#EndRegion

#Region Imperial
;~ Description: Returns current Imperial faction.
Func GetImperialFaction()
   Return MemoryRead($mBasePtr182C + 0x76C)
EndFunc   ;==>GetImperialFaction

;~ Description: Returns max Imperial faction.
Func GetMaxImperialFaction()
   Return MemoryRead($mBasePtr182C + 0x7C4)
EndFunc   ;==>GetMaxImperialFaction
#EndRegion

#Region Balth
;~ Description: Returns current Balthazar faction.
Func GetBalthazarFaction()
   Return MemoryRead($mBasePtr182C + 0x798)
EndFunc   ;==>GetBalthazarFaction

;~ Description: Returns max Balthazar faction.
Func GetMaxBalthazarFaction()
   Return MemoryRead($mBasePtr182C + 0x7C0)
EndFunc   ;==>GetMaxBalthazarFaction
#EndRegion

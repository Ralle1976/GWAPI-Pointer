
#include-once

#Region Party Window
#Region Invite
;~ Description: Invite a player to the party.
Func InvitePlayer($aPlayerName)
   SendChat('invite ' & $aPlayerName, '/')
EndFunc   ;==>InvitePlayer

;~ Func InvitePlayer($aPlayerName)
;~ Static $mInvitePlayer = DllStructCreate('ptr;dword;dword;wchar[20]')
;~ Static $mInvitePlayerPtr = Null

;~ If ($mInvitePlayerPtr = Null) then
;~ 	DllStructSetData($mInvitePlayer,1,GetValue('CommandPacketSend'))
;~ 	DllStructSetData($mInvitePlayer,2,0x2C)
;~ 	DllStructSetData($mInvitePlayer,3,0x9B)
;~ EndIf

;~ 	DllStructSetData($mInvitePlayer,4,$aPlayerName)
;~ EndFunc   ;==>InvitePlayer

;~ Description: Invites player by playernumber.
Func InvitePlayerByPlayerNumber($lPlayerNumber)
   Return SendPacket(0x8, $CtoGS_MSG_InvitePlayer, $lPlayerNumber)
EndFunc   ;==>InvitePlayerByPlayerNumber

;~ Description: Invites player by AgentID.
Func InvitePlayerByID($aAgentID)
   If IsPtr($aAgentID) Then
	  Local $lAgentPlayerNumber = MemoryRead($aAgentID + 244, 'word')
   ElseIf IsDllStruct($aAgentID) <> 0 Then
	  Local $lAgentPlayerNumber = DllStructGetData($aAgentID, 'Playernumber')
   Else
	  Local $lAgentPlayerNumber = MemoryRead(GetAgentPtr($aAgentID) + 244, 'word')
   EndIf
   If $lAgentPlayerNumber <> 0 Then Return SendPacket(0x8, $CtoGS_MSG_InvitePlayer, $lAgentPlayerNumber)
EndFunc   ;==>InvitePlayerByID

;~ Description: Invite current target.
Func InviteTarget()
   Local $lpNUM = MemoryRead(GetAgentPtr(-1) + 244, 'word')
   Return SendPacket(0x8, $CtoGS_MSG_InvitePlayer, $lpNUM)
EndFunc   ;==>InviteTarget

;~ Description: Accepts pending invite.
Func AcceptInvite()
   Return SendPacket(0x8, $CtoGS_MSG_AcceptPartyRequest)
EndFunc   ;==>AcceptInvite
#EndRegion

#Region Leave/Kick
;~ Description: Leave your party.
Func LeaveGroup($aKickHeroes = True)
   If $aKickHeroes Then SendPacket(0x8, 0x1E, 0x26)  ;~ old ->    If $aKickHeroes Then SendPacket(0x8, 0x18, 0x26)
   Return SendPacket(0x4, $CtoGS_MSG_LeaveParty)  ;~ old ->    Return SendPacket(0x4, 0x9C)
EndFunc   ;==>LeaveGroup
#EndRegion

#Region Misc
;~ Description: Switches to/from Hard Mode.
Func SwitchMode($aMode)
   Return SendPacket(0x8, $CtoGS_MSG_SwitchMode, $aMode)
EndFunc   ;==>SwitchMode
#EndRegion
#EndRegion

#Region Information
;~ Description: Returns partysize.
Func GetPartySize()
   If $HeroPtr1 = 0 Then $HeroPtr1 = MemoryRead($mBasePtr184C + 0x54, 'ptr')
   If $PartySizePtr = 0 Then $PartySizePtr = MemoryRead($mBasePtr184C + 0x64, 'ptr')
   Local $lParty1 = MemoryRead($PartySizePtr + 0x24, 'long') ; henchmen
   Local $lParty2 = MemoryRead($PartySizePtr + 0x34, 'long') ; heroes
   Local $lParty3 = MemoryRead($HeroPtr1 + 0xC, 'long') ; player
   Local $lReturn = $lParty1 + $lParty2 + $lParty3
   If $lReturn > 12 or $lReturn < 1 Then $lReturn = 8
   Return $lReturn
EndFunc   ;==>GetPartySize

;~ Description: Returns max partysize.
;~ Works only in OUTPOST or TOWN.
Func GetMaxPartySize($aMapID)
   Switch $aMapID
	  Case 293 to 296, 721, 368, 188, 467, 497
		 Return 1
	  Case 163 to 166
		 Return 2
	  Case 28 to 30, 32, 36, 39, 40, 81, 131, 135, 148, 189, 214, 242, 249, 251, 281, 282
		 Return 4
	  Case 431, 449, 479, 491, 502, 544, 555, 795, 796, 811, 815, 816, 818 to 820, 855, 856
		 Return 4
	  Case 10 to 12, 14 to 16, 19, 21, 25, 38, 49, 55, 57, 73, 109, 116, 117 to 119
		 Return 6
	  Case 132 to 134, 136, 137, 139 to 142, 152, 153, 154, 213, 250, 385, 808, 809, 810
		 Return 6
	  Case 266, 307
		 Return 12
	  Case Else
		 Return 8
   EndSwitch
EndFunc   ;==>GetMaxPartySize

;~ Description: Returns true if party is defeated/party has resigned.
;~ Func GetIsPartyDefeated()
;~    Return MemoryRead($mBasePtr184C + 0x14) = 160
;~ EndFunc
#EndRegion

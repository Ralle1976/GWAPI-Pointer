
#include-once

#Region Ptr
;~ Description: Returns questptr by questid.
Func GetQuestPtrByID($aQuestID)
   If $aQuestID = 0 Then Return MemoryRead($mBasePtr182C + 0x528, 'ptr')
   If $QuestBasePtr = 0 Then $QuestBasePtr = MemoryRead($mBasePtr182C + 0x52C, 'ptr')
   Local $lQuestPtr = 0
   Local $lQuestID = 0
   Local $lQuestLogSize = MemoryRead($mBasePtr182C + 0x534, 'ptr')
   For $i = 0 To $lQuestLogSize
	  $lQuestID = MemoryRead($QuestBasePtr + 0x34 * $i, 'long')
	  If $lQuestID = $aQuestID Then Return Ptr($QuestBasePtr + 0x34 * $i)
   Next
EndFunc   ;==>GetQuestPtrByID

;~ Description: Returns questptr by number of quest in questlog.
Func GetQuestPtrByLogNumber($aLogNumber)
   If $QuestBasePtr = 0 Then $QuestBasePtr = MemoryRead($mBasePtr182C + 0x52C, 'ptr')
   Return Ptr($QuestBasePtr + 0x34 * ($aLogNumber - 1))
EndFunc   ;==>GetQuestPtrByLogNumber
#EndRegion Ptr

#Region Dialogs
;~ Description: Accept a quest from an NPC.
Func AcceptQuest($aQuestID)
   Return SendPacket(0x8, $CtoGS_MSG_AbandonQuest, '0x008' & Hex($aQuestID, 3) & '01')
EndFunc   ;==>AcceptQuest

;~ Description: Accept the reward for a quest.
Func QuestReward($aQuestID)
   Return SendPacket(0x8, $CtoGS_MSG_AbandonQuest, '0x008' & Hex($aQuestID, 3) & '07')
EndFunc   ;==>QuestReward

;~ Description: Abandon a quest.
Func AbandonQuest($aQuestID)
   Return SendPacket(0x8, $CtoGS_MSG_AbandonQuest, $aQuestID)
EndFunc   ;==>AbandonQuest
#EndRegion

#Region QuestState
;~ Description: Request quest data.
Func UpdateQuest($aQuestID)
   ToggleQuestWindow()
   ToggleQuestWindow()
EndFunc   ;==>UpdateQuest
#EndRegion

#include-once

Local const $CtoGS_MSG_Disconnect = 0x9;
Local const $CtoGS_MSG_RequestItems = 0x97;
Local const $CtoGS_MSG_RequestSpawn = 0x8D;
Local const $CtoGS_MSG_RequestAgents = 0x96;

Local const $CtoGS_MSG_CallTarget = 0x28;					X
Local const $CtoGS_MSG_GoNPC = 0x3F;						X
Local const $CtoGS_MSG_GoGadget = 0x57;						X
Local const $CtoGS_MSG_GoPlayer = 0x39;						X

Local const $CtoGS_MSG_PickUpItem = 0x45;

Local const $CtoGS_MSG_Attack = 0x2C;						X
Local const $CtoGS_MSG_CancelAction = 0x2E;					X

Local const $CtoGS_MSG_OpenChest = 0x59;

Local const $CtoGS_MSG_DropBuff = 0x2F;						X
Local const $CtoGS_MSG_DropItem = 0x32;						X

Local const $CtoGS_MSG_DropGold = 0x35;

Local const $CtoGS_MSG_EquipItem = 0x36;					X

Local const $CtoGS_MSG_DonateFaction = 0x3B;				X
Local const $CtoGS_MSG_Dialog = 0x41;
Local const $CtoGS_MSG_MouseMove = 0x44;
Local const $CtoGS_MSG_UseSkill = 0x4C;
Local const $CtoGS_MSG_CallSkill = 0x2A;

Local const $CtoGS_MSG_SetSkillbarSkill = 0x61;				X

Local const $CtoGS_MSG_ChangeSecondary = 0x47;
Local const $CtoGS_MSG_SetAttributes = 0x10;

Local const $CtoGS_MSG_LoadSkillbar = 0x62;					X

Local const $CtoGS_MSG_RequestQuote = 0x52;
Local const $CtoGS_MSG_TransactItem = 0x53;
Local const $CtoGS_MSG_TransactTrade = 0x50;


;~ <CtoGS> Size: 0x10  Header: 0x7C
;~ 7C 00 00 00   2E 00 00 00   15 01 00 00   D2 00 00 00
;~ ---------------------------------
;~ 0x00  Header         => 124
;~ 0x04  Integer        => 46                float => 0.000000
;~ 0x08  Integer        => 277               float => 0.000000
;~ 0x0C  Integer        => 210               float => 0.000000
Local const $CtoGS_MSG_StartSalvage = 0x7C;					X


;~ <CtoGS> Size: 0x4  Header: 0x7F
;~ 7F 00 00 00
;~ ---------------------------------
;~ 0x00  Header         => 127

;~ ---------------------------------
Local const $CtoGS_MSG_SalvageMaterials = 0x7F;				X

;~ <CtoGS> Size: 0x4  Header: 0x7E
;~ 7E 00 00 00
;~ ---------------------------------
;~ 0x00  Header         => 126

;~ ---------------------------------
Local const $CtoGS_MSG_FinishSalvageMaterials = 0x7E;		X

Local const $CtoGS_MSG_SalvageMod = 0x80;					X

Local const $CtoGS_MSG_IdentifyItem = 0x71;					X



Local const $CtoGS_MSG_SplitStack = 0x7A;						X

Local const $CtoGS_MSG_MoveItem = 0x77;						X



Local const $CtoGS_MSG_AcceptAllItems = 0x78;				X
Local const $CtoGS_MSG_UseItem = 0x83;						X

Local const $CtoGS_MSG_StartTrade = 0x4F;					X

Local const $CtoGS_MSG_AcknowledgeTrade = 0x0;

Local const $CtoGS_MSG_AcceptTrade = 0x7;					X

Local const $CtoGS_MSG_CancelTrade = 0x1;
Local const $CtoGS_MSG_AddItemTrade = 0x2;
Local const $CtoGS_MSG_RemoveItemTrade = 0x5;

Local const $CtoGS_MSG_ChangeOffer = 0x6;					X
Local const $CtoGS_MSG_SubmitOffer = 0x3;					X

Local const $CtoGS_MSG_AddNpc = 0xA5;							X
Local const $CtoGS_MSG_KickNpc = 0xAE;							X

Local const $CtoGS_MSG_InvitePlayer = 0xA6;						X

Local const $CtoGS_MSG_InvitePlayerByName = 0xA7;
Local const $CtoGS_MSG_KickPlayer = 0xAF;
Local const $CtoGS_MSG_AcceptPartyRequest = 0xA4;
Local const $CtoGS_MSG_DenyPartyRequest = 0xA2;

Local const $CtoGS_MSG_EnterChallenge = 0xAB;					X
Local const $CtoGS_MSG_ReturnToOutpost = 0xAD;					X

Local const $CtoGS_MSG_AbandonQuest = 0x12;
Local const $CtoGS_MSG_ActivateQuest = 0x13;
Local const $CtoGS_MSG_RequestQuest = 0x16;

Local const $CtoGS_MSG_SetHeroAggression = 0x17;				X
Local const $CtoGS_MSG_LockHeroTarget = 0x18;					X
Local const $CtoGS_MSG_ChangeHeroSkillSlotState = 0x1C;			X
Local const $CtoGS_MSG_CommandHero = 0x1E;						X
Local const $CtoGS_MSG_CommandAll = 0x1F;						X
Local const $CtoGS_MSG_AddHero = 0x23;							X
Local const $CtoGS_MSG_KickHero = 0x24;							X
Local const $CtoGS_MSG_TravelGH = 0xB6;							X
Local const $CtoGS_MSG_LeaveGH = 0xB8;							X
Local const $CtoGS_MSG_TravelTo = 0xB7;							X

Local const $CtoGS_MSG_SendChat = 0x69;

Local const $CtoGS_MSG_SetDisplayedTitle = 0x5D;				X
Local const $CtoGS_MSG_RemoveDisplayedTitle = 0x5E;				X
Local const $CtoGS_MSG_SkipCinematic = 0x68;					X

Local const $CtoGS_MSG_UnlockSkillByTome = 0x72;

Local const $CtoGS_MSG_DeleteItem = 0x6E;						X


Local const $CtoGS_MSG_ChangeGold = 0x81;

Local const $CtoGS_MSG_SwitchMode = 0xA1;						X
Local const $CtoGS_MSG_LeaveParty = 0xA8;						X

Local const $CtoGS_MSG_SwapWeapon = 0x38;
Local const $CtoGS_MSG_Tick = 0xB5;
Local const $CtoGS_MSG_DrawMap = 0x31;
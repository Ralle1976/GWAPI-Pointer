#cs
   Pointer-based GWA².

   Author gwAPI 2.5: Testytest.
#ce

#include-once
#RequireAdmin

;~ Opt("MustDeclareVars", 1)

#Region Declarations gwAPI_basics
Global $mKernelHandle
Global $mGWProcHandle
Global $mGWHwnd
Global $mGWTitleOld = 'Guild Wars'
Global $mMemory
Global $mMemoryEnd = 0
Global $mLabelDict = 0
Global $mRestoreDict = 0
Global $mBase = 0x00DE0000
Global $mASMString, $mASMSize, $mASMCodeOffset
Global $mGUI = GUICreate('EventGUI'), $mSkillActivate, $mSkillCancel, $mSkillComplete, $mChatReceive, $mLoadFinished
GUIRegisterMsg(0x501, 'Event')
Global $mQueueCounter, $mQueueSize, $mQueueBase
Global $mTargetLogBase
Global $mStringLogBase
Global $mSkillBase
Global $mEnsureEnglish
Global $mMyID
Global $mCurrentTarget
Global $mAgentBase
Global $mBasePointer
Global $mBasePtr182C
Global $mBasePtr1840
Global $mBasePtr184C
Global $mRegion
Global $mLanguage
Global $mPing
Global $mCharname
Global $mMapID
Global $mLastMapID
Global $mMaxAgents
Global $mMapLoading
Global $mMapIsLoaded
Global $mLoggedIn
Global $mLoggedCounter
Global $mTraderQuoteID, $mTraderCostID, $mTraderCostValue
Global $mSkillTimer
Global $mBuildNumber
Global $mZoomStill, $mZoomMoving
Global $mDisableRendering
Global $mAgentCopyCount
Global $mAgentCopyBase
Global $mChangeTitle = True
Global $mUseStringLog
Global $mUseEventSystem
Global $mStorageSessionBase
Global $mRendering = False
Global $GWPID = -1
Global $mAgentMovement
Global $mFirstChar = ''
Global $mSleepAfterPort = 2000
Global $mObstructed
Global $mCinematic
Global $mDialogOwnerID = 0

#EndRegion Declarations

#Region Reusable pointers until next loading screen
Global $MyID = 0
Global $MyPtr = 0
Global $MySkillbar = 0
Global $TitlesPtr = 0
Global $HeroPtr1 = 0
Global $HeroPtr2 = 0
Global $HeroPtr3 = 0
Global $HeroPtr4 = 0
Global $ItemBasePtr = 0
Global $BagBasePtr = 0
Global $GoldBasePtr = 0
Global $PartySizePtr = 0
Global $QuestBasePtr = 0
Global $SkillbarBasePtr = 0
Global $BuffBasePtr = 0
#EndRegion

#Region PluginManager
Global $mUsePlugins = False
Global $mAsmArray[1][2] = [[0, 0]]
Global $mDataArray[1][2] = [[0, 0]]
Global $mDetoursArray[1][2] = [[0, 0]]
Global $mScansArray[1][2] = [[0, 0]]
Global $mSetValuesArray[1][2] = [[0, 0]]
#EndRegion

#Region UpdateWorld Variables
Global $mLowestAlly
Global $mLowestAllyHP
Global $mHighestAlly
Global $mHighestAllyHP
Global $mLowestOtherAlly
Global $mLowestOtherAllyHP
Global $mLowestEnemy
Global $mLowestEnemyHP
Global $mClosestEnemy
Global $mAverageTeamHP
Global $NumberOfFoesInAttackRange = 0
Global $NumberOfFoesInSpellRange = 0
Global $BestAOETarget
Global $HexedAlly
Global $ConditionedAlly
Global $EnemyHexed
Global $EnemyNonHexed
Global $EnemyConditioned
Global $EnemyNonConditioned
Global $EnemyNonEnchanted
Global $EnemyEnchanted
Global $EnemyHealer
Global $LowHPEnemy
Global $EnemyAttacker = 0
Global $mTeam[2] = [0, 0] ;Array of living members
Global $mTeamOthers[1] ;Array of living members other than self
Global $mTeamDead[1] ;Array of dead teammates
Global $mSpirits[1] ;Array of your spirits
Global $mMinions[1] ;Array of your minions
Global $mDazed = False
Global $mBlind = False
Global $mSkillHardCounter = False
Global $mSkillSoftCounter = 0
Global $mAttackHardCounter = False
Global $mAttackSoftCounter = 0
Global $mAllySpellHardCounter = False
Global $mEnemySpellHardCounter = False
Global $mSpellSoftCounter = 0
Global $mBlocking = False
Global $mClosestEnemy
Global $mClosestEnemyDist
Global $mEffects
Global $mEnergy
Global $HurtTimer = TimerInit()
#EndRegion

#Region SmartCast Variables
#Region CacheSkill
Global $mSkillPriorityRating[9][3]
Global $mSkillbarCache[9] = [False]
Global $mSkillbarCacheStruct[9] = [False]
Global $mSkillbarCacheEnergyReq[9] = [False]
Global $mSkillbar
Global $mSkillbarPtr
Global $mSkillbarCacheArray[9][11]
Global $mSkillbarCachePtr[9] = [False]
Global $IsHealingSpell[9] = [False]
Global $IsYMLAD[9] = [False]
Global $IsInterrupt[9] = [False]
Global $YMLADSlot = 0
Global $IsSummonSpell[9] = [False]
Global $IsSoulTwistingSpell[9] = [False]
Global $IsSelfCastingSpell[9] = [False]
Global $IsWeaponSpell[9] = [False]
Global $SkillDamageAmount[9] = [False]
Global $SkillAdrenalineReq[9] = [False]
#EndRegion
#EndRegion

#Region GUI
Global $boolRun = False
Global $Resigned = False
Global $UpdateText
Global $FirstRun = True
Global $OldGuiText = ''
Global $WriteIGChat = True
#EndRegion

#Region Misc Variables
Global $mMaxPartySize = 12
Global $mPartyArray[13]
Global $SkipCinematic = False
Global $GHPassKeyBuffer = DllStructCreate('dword;dword;dword;dword')

#Region PickUp
Global $mBattlePlans = False ; excluded from $mPickUpAll, set to true if you want to pick them up
Global $mMapPieces = False ; excluded from $mPickUpAll, set to true if you want to pick them up
Global $mTomes = True
Global $mEliteTomes = True
Global $mMesmerTomes = False
Global $mElementalistTomes = False
Global $mQuestItems = False
Global $mDyes = False
Global $mSalvageTrophies = True
Global $mRarityGold = True
Global $mRarityGreen = False
Global $mEventModelID = 0
Global $mEventCount = 0
Global $mPickUpAll = False
Global $mLeecher = False
Global $mPickUpBundles = True
#EndRegion PickUp
#EndRegion

;~ Description: Data arrays, remove commentation if you need them.
;~ #include "gwAPI\array_questnames.au3"
;~ #include "gwAPI\array_skill_small.au3"
;~ #include "gwAPI\array_skillnames.au3"
;~ #include "gwAPI\array_skills_big.au3"
;~ #include "gwAPI\array_skills_pvp.au3"

;~ Description: Global constants.
#include "gwAPI\constants.au3"

;~ Description: Mainfile, Initialisation etc.
#include "gwAPI\gwAPI_basics.au3"

;~ Description: Pluginmanager and functions for ASM plugins.
#include "gwAPI\plugin.au3"
#include "gwAPI\plugins\pluginfunctions.au3"

;~ Description: GetMapID, GetMapLoading etc.
#include "gwAPI\map.au3"

;~ Description: Move, MoveTo, MoveAggroing, GoToAgent and its variations, as well as travelto etc.
#include "gwAPI\movement.au3"

;~ Description: All functions that mainly involve agents.
#include "gwAPI\agents.au3"

;~ Description: Functions to process inventory between runs.
;~ #include "gwAPI\utilities\inventory_testy_Edit_by_Ralle1976.au3"
#include "gwAPI\utilities\inventory_Edit_by_Ralle.au3"
;~ #include "gwAPI\inventory.au3"

#include "gwAPI\utilities\tempstorage.au3"

;~ Description: All functions that mainly involve items.
#include "gwAPI\items.au3"

;~ Description: Party formation etc functions.
#include "gwAPI\party.au3"

;~ Description: Smartcast function.
#include "gwAPI\smartcast.au3"

;~ Description: Updateworld()
#include "gwAPI\UpdateWorld.au3"

;~ Description: All functions involving heroes and henchmen.
#include "gwAPI\h_h.au3"

;~ Description: Functions involving kurzick, luxon, balth and imperial faction.
#include "gwAPI\faction.au3"

;~ Description: Write, send etc chat functions, including functions like kneel.
#include "gwAPI\chat.au3"

;~ Description: All functions needed to access character information, doesnt include faction.
#include "gwAPI\characterinfo.au3"

;~ Description: Functions for manipulation client interface, includes disable/enable rendering.
#include "gwAPI\client_interface.au3"

;~ Description: Functions involving skills, skilltemplates, attributes or professions.
#include "gwAPI\skills.au3"

;~ Description: Quest functions.
#include "gwAPI\quest.au3"
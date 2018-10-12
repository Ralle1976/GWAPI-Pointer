# GWAPI-Pointer

An AutoIt API to interface with the Guild Wars client.

All credit goes to GameRevision members.


## Getting Started

### Prerequisites

- [Git](https://git-scm.com/)

- [AutoIt v3](https://www.autoitscript.com/site/autoit/downloads/)

### Download

```
git clone https://github.com/Ralle1976/GWAPI-Pointer.git
```

## Usage

### Pick up items



```
#include "gwApi.au3"

#Region Globals
Global $playerId
Global $playerPtr
Global $playerX
Global $playerY
#EndRegion Globals

Initialize(CharacterSelector(), True, True, False)

main()

Func main()
  PickStuffUp()
EndFunc

Func PickStuffUp()
	Local $AgArray = MemoryReadAgentPtrStruct(1, 0x400)
	Local $lagentX, $lagentX

	For $i = 1 To $AgArray[0]
		Local $itemptr = GetItemPtrByAgent($AgArray[$i])
    
		UpdatePlayer()
		UpdateAgentPosByPtr($AgArray[$i],$lagentX,$lagentY)
    Local dist = ComputeDistance($lagentX, $lagentY, $playerX, $playerY)
    
		PickUpItems($AgArray[$i], MemoryRead($AgArray[$i] + 44, 'dword'), $lagentX, $lagentX, dist, $playerPtr)
	Next
EndFunc

Func UpdatePlayer()
	$playerId = GetMyID()
	$playerPtr = GetAgentPtr($playerId)
  UpdateAgentPosByPtr($playerPtr, $playerX, $playerY)
EndFunc

```





















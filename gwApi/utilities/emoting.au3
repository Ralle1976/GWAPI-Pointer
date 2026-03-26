54
#include-once

;~ Description: Randomly emotes 6 different emotes (dance, clap, excited, drum, flute and violin)
Func Emoting()
   Switch (Random(1, 6, 1))
	  Case 1
		 Return Dance()
	  Case 2
		 Return Clap()
	  Case 3
		 Return Excited()
	  Case 4
		 Return Drum()
	  Case 5
		 Return Flute()
	  Case 6
		 Return Violin()
	EndSwitch
EndFunc   ;==>Emoting

;~ Description: Dance emote.
Func Dance()
   Return SendChat('dance', '/')
EndFunc   ;==>Dance

;~ Description: Clap emote.
Func Clap()
   Return SendChat('clap', '/')
EndFunc   ;==>Clap

;~ Description: Excited emote.
Func Excited()
   Return SendChat('excited', '/')
EndFunc   ;==>Excited

;~ Description: Drum emote.
Func Drum()
   Return SendChat('drum', '/')
EndFunc   ;==>Drum

;~ Description: Flute emote.
Func Flute()
   Return SendChat('flute', '/')
EndFunc   ;==>Flute

;~ Description: Violin emote.
Func Violin()
   Return SendChat('violin', '/')
EndFunc   ;==>Violin

;~ Description: Jump emote.
Func Jump()
   Return SendChat('jump', '/')
EndFunc   ;==>Jump

; Text Screen Capture TSR module.

MOV WORD BX, [CEInDOS_Offset]    ; Skips text screen capture if either the critical error or InDOS flag are set.
MOV WORD ES, [CEInDOS_Segment]   ;
ES                               ;
CMP BYTE [BX - 0x01], 0x00       ;
JNE Done                         ;
ES                               ;
CMP BYTE [BX], 0x00              ;
JNE Done                         ;

IN AL, 0x60             ; Skips text screen capture unless the F11 or F12 key is being pressed.
CMP AL, 0x57            ;
JE EndKeyCheck          ;
   CMP AL, 0x58            ;
   JNE Done                ;
EndKeyCheck:

MOV [KeyStroke], AL     ; Saves the keystroke.

WaitForKeyUp:
   IN AL, 0x60     ; Waits for the key to be released.
   TEST AL, 0x80   ;
JZ WaitForKeyUp

CMP BYTE [Busy], 0x00   ; Checks whether a text screen capture is already in progress.
JNE Done                ;

MOV BYTE [Busy], 0x01   ; Sets the flag indicating a text screen capture is in progress.

%INCLUDE "ScrnInfo.asm"   ; Includes the screen information code file.

CMP BYTE [TextScreenFlag], 0x01   ; Skips screen capturing for graphics modes.
JNE Done                          ;

CMP BYTE [KeyStroke], 0x58   ; Checks whether the F12 (append) key has been pressed.
JE NoFileDeletion            ;
   MOV AH, 0x41                 ;
   LEA DX, OutputFile           ;
   INT 0x21                     ;
NoFileDeletion:

%INCLUDE "FileIO.asm"     ; Includes the File I/O code file.

CMP BYTE [KeyStroke], 0x58   ; Checks whether the F12 (append) key has been pressed.
JNE NoAppend                 ;
   MOV AX, 0x4202               ;
   XOR CX, CX                   ;
   XOR DX, DX                   ;
   INT 0x21                     ;
NoAppend:

%INCLUDE "Capture.asm"   ; Includes the Capture code file.

MOV AH, 0x3E          ; Closes the output file.
INT 21h               ;
JMP SHORT Done        ;

Address DW 0x0000
Busy DB 0x00
CEInDOS_Offset DW 0x0000
CEInDOS_Segment DW 0x0000
CharacterCount DW 0x0000
ColumnCount DW 0x0000
KeyStroke DB 0x00
ScreenPage DW 0x0000
TextScreenFlag DB 0x00

Done:
MOV BYTE [Busy], 0x00   ; Clears the flag indicating a text screen capture is progress.

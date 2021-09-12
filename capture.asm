; Text Screen Capture Capture module.

PUSH WORD 0x0040      ; Retrieves the shift keys' status.
POP ES                ;
ES                    ;
MOV AX, [0x17]        ;
AND WORD AX, 0x0003   ;

PUSH DS      ; Saves the current data segment.
POP ES       ;

PUSH WORD [ScreenPage]   ; Retrieves the current screen page's segment.
POP DS                   ;

XOR DX, DX   ; Sets the offset of the first character on the screen.

CMP AX, 0x0000      ; Gives the command to capture without line breaks if one of the shift keys is being pressed.
JNE NoLineCapture   ;

ES                      ; Sets the characters per line remaining to the current number columns.
MOV SI, [ColumnCount]   ;

LineCapture:
   MOV AH, 0x40       ; Writes the current character to the output file.
   MOV CX, 0x0001     ;
   INT 0x21           ;
   JC Done            ;
   
   DEC SI             ; Skips adding a line break if the end of the current line has not yet been reached.
   CMP SI, 0x0000     ;
   JNE ReadNext       ;

   ES                      ; Sets the characters per line remaining to the current number columns.
   MOV SI, [ColumnCount]   ;

   PUSH DS            ; Writes a line break to the output file. 
   PUSH DX            ;   
   MOV AH, 0x40       ;
   MOV CX, 0x0001     ;
   PUSH ES            ;
   POP DS             ;
   LEA DX, LineBreak  ;
   INT 0x21           ;
   JC Done            ;
   POP DX             ;
   POP DS             ;

   ReadNext:
   ES                         ; Checks whether the last character on the screen has been reached.
   CMP DX, [CharacterCount]   ;
   JAE CaptureFinished        ;

   ADD DX, 0x0002        ; Moves to the next character on the screen.
JMP SHORT LineCapture    ;

LineBreak DB 0x0D

NoLineCapture:
   MOV AH, 0x40       ; Writes the current character to the output file.
   MOV CX, 0x0001     ;
   INT 0x21           ;
   JC Done            ;

   ES                         ; Checks whether the last character on the screen has been reached.
   CMP DX, [CharacterCount]   ;
   JAE CaptureFinished        ;

   ADD DX, 0x0002        ; Moves to the next character on the screen.
JMP SHORT NoLineCapture

CaptureFinished:

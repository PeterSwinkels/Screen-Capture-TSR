; Text Screen Capture Screen Information Module.

MOV AH, 0x0F                  ; Checks whether a text based screen mode is currently active.
INT 0x10                      ;
CMP AL, 0x03                  ;
   JBE IsTextScreen                     ;
      MOV BYTE [TextScreenFlag], 0x00   ;
      JMP SHORT GetColumnCount          ; 
   IsTextScreen:                        ;   
      MOV BYTE [TextScreenFlag], 0x01   ;

GetColumnCount:         ; Checks the number of screen columns.
CMP AH, 0x50            ;
   JNE Columns40                          ;
      MOV WORD [CharacterCount], 0x0FA0   ;
      MOV WORD [ColumnCount], 0x0050      ;
      JMP SHORT EndOfColumnCheck   ;
   Columns40:                      ;
      MOV WORD [CharacterCount], 0x03E8   ;
      MOV WORD [ColumnCount], 0x0028      ;
EndOfColumnCheck:         ;

MOV BL, BH              ; Calculates the current screen page's segment address.
XOR BH, BH              ;
MOV AX, 0x0100          ;
MUL BX                  ;
MOV BX, 0xB800          ;
ADD BX, AX              ;
MOV [ScreenPage], BX    ;

; Text Screen Capture File I/O module.

MOV AX, 0x3D01                  ; Opens the output file for writing.
LEA DX, OutputFile              ;
INT 0x21                        ;
JNC EndOfFileIO                 ;
   CALL NEAR CreateOutputFile   ;
JMP SHORT EndOfFileIO           ;

CreateOutputFile:       ; Creates the output file.
   MOV AH, 0x3C            ;
   XOR CX, CX              ;
   LEA DX, OutputFile      ;
   INT 0x21                ;
   JC EndOfFileIO          ;
RETN                    ;

OutputFile DB "Capture.txt", 0x00

EndOfFileIO:            ; Retrieves the filehandle.
MOV BX, AX              ;


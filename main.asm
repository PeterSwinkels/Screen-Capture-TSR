; Text Screen Capture TSR for MS-DOS - By: Peter Swinkels, ***2021***

ALIGN 0x01, DB 0x90     ; Defines alignment.
BITS 16                 ; Defines the segment size used by this program.
ORG 0x0100              ; Indicates that all relative pointers to data are moved forward by 0x0100 bytes.

REDIRECTED_FROM EQU 0x08  ; Defines the interrupt to be redirected.
REDIRECTED_TO EQU 0xFF    ; Defines the redirected interrupt's new vector.

JMP NEAR Main             ; Jumps to the main entry point.

TSR:
PUSHA                     ; Saves the registers.
PUSH DS                   ;
PUSH ES                   ;

PUSH CS                   ; Restores the data segment register.
POP DS                    ;

%INCLUDE "Tsr.asm"        ; Includes the TSR's code file.

POP ES                    ; Restores the registers.
POP DS                    ;
POPA                      ;

INT REDIRECTED_TO         ; Calls the redirected interrupt.

IRET                      ; Returns.
EndTSR:

Main:
MOV AH, 0x09              ; Displays the TSR "start" message.
MOV DX, TSR_Start_Msg     ;
INT 0x21                  ;

MOV AH, 0x35              ; Checks whether this TSR is already active by checking for a redirected interrupt.
MOV AL, REDIRECTED_TO     ;
INT 0x21                  ;
MOV AX, ES                ;
CMP AX, 0x0000            ;
JNE IsActive              ;
    CMP BX, 0x0000        ;
    JNE IsActive          ;

MOV AH, 0x34                ; Retrieves the address of the critical error and InDOS flags.
INT 0x21                    ;
MOV [CEInDOS_Offset], BX    ;
MOV [CEInDOS_Segment], ES   ;

MOV AH, 0x35              ; Retrieves vector the vector for the interrupt to be redirected.
MOV AL, REDIRECTED_FROM   ;
INT 0x21                  ;

MOV DX, BX                ; Places the retrieved vector at another interrupt.
PUSH ES                   ;
POP DS                    ;
MOV AH, 0x25              ;
MOV AL, REDIRECTED_TO     ;
INT 0x21                  ;

PUSH CS                   ; Sets this TSR's interrupt vector.
POP DS                    ;
MOV DX, TSR               ;
MOV AH, 0x25              ;
MOV AL, REDIRECTED_FROM   ;
INT 0x21                  ;

MOV AH, 0x09              ; Displays the TSR "activated" message.
MOV DX, TSR_Activated_Msg ;
INT 0x21                  ;

MOV AX, 0x3100            ; Terminates and stays resident.
MOV DX, EndTSR            ;
ADD DX, 0x0F              ;
SHR DX, 0x04              ;
INT 0x21                  ;

IsActive:                 ; 
MOV AH, 0x09              ; Displays the TSR "already active" message.
MOV DX, TSR_Activate_Msg  ;
INT 0x21                  ;

MOV AH, 0x4C              ; Quits if the TSR is already active.
INT 0x21                  ;

TSR_Activate_Msg DB "Already active!", 0x0D, 0x0A, "$"
TSR_Activated_Msg DB "Activated.", 0x0D, 0x0A, "$"
TSR_Start_Msg DB "Text Screen Capture TSR for MS-DOS v1.03 - by: Peter Swinkels, ***2021***"
DB 0x0D, 0x0A
DB "F11 = Capture   F12 = Append   Shift = No line breaks"
DB 0x0D, 0x0A
DB "$"

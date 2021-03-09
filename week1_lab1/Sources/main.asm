;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data

; variable/data section

 ifdef _HCS12_SERIALMON
            ORG $3FFF - (RAMEnd - RAMStart)
 else
            ORG RAMStart
 endif
 ; Insert here your data definition.
Counter     DS.W 1
FiboRes     DS.W 1


; code section
            ORG   ROMStart


Entry:
_Startup:
            ; remap the RAM &amp; EEPROM here. See EB386.pdf
 ifdef _HCS12_SERIALMON
            ; set registers at $0000
            CLR   $11                  ; INITRG= $0
            ; set ram to end at $3FFF
            LDAB  #$39
            STAB  $10                  ; INITRM= $39

            ; set eeprom to end at $0FFF
            LDAA  #$9
            STAA  $12                  ; INITEE= $9


            LDS   #$3FFF+1        ; See EB386.pdf, initialize the stack pointer
 else
            LDS   #RAMEnd+1       ; initialize the stack pointer
 endif

            CLI                     ; enable interrupts

            ; This is our first program
            ; 02/03/21
            
Start_here:

          LDS   #RAMEnd+1       ; initialize the stack pointer


;**** you may want to write your own equates here *****

          ldaa    #$FF
          staa    DDRB    ; Configure PORTB as output
          staa    DDRJ   ; Port J as output to enable LED
          ldaa    #00    ; need to write 0 to J0
          staa    PTJ    ; to enable LEDs
          
start:    ldaa    #1	; load accumulator with value for port B
          staa    PORTB	; write value to LED bank
          bsr     delay	; delay for 1 second
          clr     PORTB	; now turn the LED(s) off
          bsr     delay	; delay for 1 second
          bra     start	; loop back to beginning


delay:
          ; <your code goes here>
          ;     
          LDX #60000
          LOOP:
          LDA #100
          LOP:
          NOP
          DBNE A, LOP
          DBNE X, LOOP
        
          
          rts		; return from subroutine

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
          ORG   $FFFE
          DC.W  Entry           ; Reset Vector

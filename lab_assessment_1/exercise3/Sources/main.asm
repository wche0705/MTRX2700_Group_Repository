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
WORD FCB $4D,$65,$6D,$6F,$72,$79,$0A,$0D,$00
READ RMB 80

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
mainLoop: 

  ;bsr task1
  bsr task2
    

task1: LDX #WORD    ; loads word pointer into X register
    
    
    
    
    task1_LOOP:
    LDAA 1,X+     ; loads value at X into accumulator A & increment
    CMPA #$00      ; comparing value in A to 0 
    BEQ delay      ; branch if 0 is reached (null character)
    
    bsr loadSCI1
    bra task1_LOOP
    

task2: LDX #READ
    
    bsr readSCI1
    
relay: LDX #READ

relay_LOOP:
    LDAA 1,X+     ; loads value at X into accumulator A & increment
    CMPA #$00      ; comparing value in A to 0 
    BEQ delay      ; branch if 0 is reached (null character)
    
    bsr loadSCI1
    bra relay_LOOP

loadSCI1:
    MOVB #$00, SCI1BDH
    MOVB #156, SCI1BDL
    MOVB #$00, SCI1CR1
    MOVB #$08, SCI1CR2
    brclr SCI1SR1,mSCI1SR1_TDRE,*    ; waits for TDRE to be set
    staa SCI1DRL           ; outputs the character
    rts
    
    

readSCI1: 
    MOVB #00, SCI1BDH
    MOVB #156, SCI1BDL
    MOVB #mSCI1CR2_RE, SCI1CR2
    brclr SCI1SR1, mSCI1SR1_RDRF,*
    LDAA SCI1DRL
    STAA 1,X+
    CMPA #$D
    BEQ complete_string
    bra readSCI1
    
complete_string:
    LDAA #$A    
    STAA 1,X+
    LDAA #00
    STAA 1,X+
    bra relay

delay:
   
    LDX #60000
LOOP1:
    LDAA #100
LOOP2:
    NOP
    DBNE A, LOOP2
    DBNE X, LOOP1
        
          
    bra mainLoop

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector

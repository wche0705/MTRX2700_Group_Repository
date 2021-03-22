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

            ORG RAMStart
; Insert here your data definition.

string_length    DS.B  1     ; one byte to store the string length

fullstop_count   DS.B  1     ; one byte to store the string length

test_count       DS.B  1     ; one byte to store the count of the test_character

current_count    DS.B  1     ; one byte to store the count of the test_character

spc_count        DS.B  1     ; one byte to store the count of the test_character

input_string     FCC   "this IS a String. a. B" ; make a string in memory
                 FCB  $00
output_string1   DS.B  48     ; allocate 256 bytes at the address output_string
                 FCB  $00
output_string2   DS.B  48     ; allocate 256 bytes at the address output_string
                 FCB  $00
output_string3   DS.B  48     ; allocate 256 bytes at the address output_string
                 FCB  $00
output_string4   DS.B  48     ; allocate 256 bytes at the address output_string
                 FCB  $00




; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
mainLoop:
            LDAA  #0
            STAA  test_count      ;to show current task

            LDAA  #0
            STAA  current_count   ;to count the number of array in the string
            
            LDAA  #1
            STAA  spc_count       ;to detect spaces
            
            LDAA  #0
            STAA  fullstop_count  ;to detect fullstop
                                    
            LDAA  #0              
            STAA  string_length   ;store the input string length
            
            
                                                  
            LDX   #input_string   ;load input string into x


;find the length of the string          
  find_length:    
            LDAB  1, x+
            INC   string_length
            CMPB  $00
            BEQ   loop
            BRA   find_length

;start by case 1, making the string in lower cases
loop:           
            BRA   string1

;printing the other task cases            
loop2:
            
            LDAA  #0              ;reset count so it can be used by the other task
            STAA  current_count
            INC   test_count      ;add one after each task complete so to get to the next one
            LDAA  test_count
            CMPA  #1
            BEQ   string2
            CMPA  #2
            BEQ   string3
            CMPA  #3
            BEQ   string4
            CMPA  #4
            BEQ   mainLoop
            
            
            
;lower cases for all letters            
  string1:  
            LDX   #input_string        ;load input string to x
            LDY   #output_string1      ;store the changes in output string1
            BRA   find_char
            
    all_lower: 
                CMPB  #$61             ;check if it's lower case. The first lower case is 'a'
                                       ;starts with 61
                LBLT   make_lower      ;else make it lower case              
                LBRA   skipUpdate      ;dont update if it is in lower case

                

;upper cases for all letters                
 string2:
            LDX   #input_string        ;load input string to x
            LDY   #output_string2      ;store the changes in output string1
            BRA   find_char           
            
    all_upper: 
                CMPB  #$61             ;check if it's lower case. The first lower case is 'a'
                                       ;starts with 61             
                LBGE   make_upper       ;update if it is in lower case
                LBRA   skipUpdate       ;dont update if it is in upper case                

;Capitalise the first letter of each word
string3:
            LDX   #input_string 
            LDY   #output_string3
            BRA   find_char 
            
                    
    Cap_first:    
            DEC   spc_count             ;initialise count
            CMPB  #$61                  ;check if it's lower case. The first lower case is 'a'
            LBGE   make_upper           ;update if it is in lower case
            LBRA   skipUpdate           ;dont update if it is in upper case                  


;Capitalise the first letter of the string and after a fullstop            
string4:
            LDX   #input_string 
            LDY   #output_string4
            BRA   find_char                 
                    
    Cap_fullstop:
            DEC   spc_count             ;initialise count
            DEC   fullstop_count        ;initialise count
            CMPB  #$61                  ;check if it's lower case. The first lower case is 'a'
            LBGE   make_upper           ;update if it is in lower case
            LBRA   skipUpdate           ;dont update if it is in upper case                                  
                               
;determine if it is a letter
find_char:  
            INC   current_count         ;count the current location of the string  
            LDAA  current_count
            CMPA  string_length         ;if it is at the end of the string, start the next task
            BEQ   loop2
           
            LDAB  1, x+
            
            LDAA  test_count            
            
            CMPA  #02
            BEQ   case3
            
            CMPA  #03
            BEQ   case4
            
            BRA   find_char1
            
case3: 
            LDAA  current_count     ;load current state and if is the first letter,
            CMPA  #01               ;capitalise it
            BEQ   Cap_first         
            
            LDAA  spc_count         ;if the letter is after a space, capitalise it
            CMPA  #00
            BGT   Cap_first
            BRA   next
           
  next:            
            CMPB  #$20              ;determine if it is a space
            BEQ   flag_spc          
            
            LDAA  test_count        ;for the forth task, capitalise after a fullstop 
            CMPA  #03               ;and a space
            BEQ   Cap_fullstop      ;if full stop and space flags are both present, capitalise it
            BRA   find_char1
  flag_spc:   
            INC   spc_count         ;add one to indecate that space has being found
            LDAA  spc_count
            CMPA  #00
            BGT   skip

case4:
            LDAA  current_count     ;load current state and if is the first letter,
            CMPA  #01               ;capitalise it
            BEQ   Cap_first 
            
            LDAA  fullstop_count    ;determine if there is a fullstop being detected before
            CMPA  #00
            BGT   next              ;check if there is space detected
            BRA   next1             

  next1:            
            CMPB  #$2E              ;check if it is a fullstop
            BEQ   flag_fullstop     ;add one if it is
            BRA   find_char1        ;print it out

  flag_fullstop:
            INC   fullstop_count
            LDAA  fullstop_count
            CMPA  #00
            BGT   skip          
                       
;determine if it is a letter               
find_char1:            
            CMPB  #$41              ;from scii chart, first letter A starts with 41
            BGE   distribute        ;knowning that it is a letter, determine if it is 
                                    ;upper or lower case.

skip:
            BRA   skipUpdate       ;if it is not a letter, dont change

            
distribute:          
            LDAA  test_count 
            CMPA  #00
            LBEQ   all_lower      ;make lower case
            CMPA  #01
            LBEQ   all_upper      ;make upper case
            CMPA  #02
            LBEQ   all_lower      ;make lower case      
            CMPA  #03
            LBEQ   all_lower      ;else make it lower case
      

;making letters to lower casing   
make_lower: 
            ADDB  #$20              ;upper case is 20 apart from it's corresponding
                                    ;lower case 
            STAB  0,y               ;store into output
            INY
            DECA
            LBNE find_char 


;making letters to upper casing
make_upper:
            SUBB  #$20              ;lower case is 20 apart from it's corresponding
                                    ;uper case 
            STAB  0,y               ;store into output
            INY
            LBNE find_char 
            


;skip any update and just print it out
skipUpdate:                                    
            STAB  0,y
            INY
            LBNE find_char   

        
            

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
    RETSYS MACRO
    MOV AX, 4C00H 
    INT 21H
    ENDM
DATA SEGMENT
SCORE_SPACE DB 241,0,241 DUP(0)
INSTRUCTION1 DB "pls input score with space $"  

INSTRUCTION2 DB 10,13,"total number is $"
INSTRUCTION3 DB 10,13,"the highest number is $"
INSTRUCTION4 DB 10,13,"the lowerest number is $"
INSTRUCTION5 DB 10,13,"the result of bubble sort is",10,13,"$"   
INSTRUCTION6 DB 10,13,"the magnitude of the interval [90,99] is  $"
INSTRUCTION7 DB 10,13,"the magnitude of the interval [80,89] is  $"
INSTRUCTION8 DB 10,13,"the magnitude of the interval [70,79] is  $"
INSTRUCTION9 DB 10,13,"the magnitude of the interval [60,69] is  $" 
INSTRUCTION10 DB 10,13,"the magnitude of the interval [0,59] is  $"
PKEY DB 10,13,"press any key...$"
SCORE DB 80 DUP(0)    

MAX DB 0              
MIN DB 0              
TOTAL DB 0            
90_99 DB 0            
80_89 DB 0            
70_79 DB 0            
60_69 DB 0            
0_59  DB 0            
CRLF DB 10,13,10,13,'$'     
ENDS

STACK SEGMENT
DW 128 DUP(0)
ENDS

CODE SEGMENT
START:
MOV AX, DATA
MOV DS, AX
MOV ES, AX

LEA DX, INSTRUCTION1 
MOV AH, 9
INT 21H

LEA DX,SCORE_SPACE 
MOV AH,10
INT 21H

LEA SI,SCORE_SPACE  
LEA DI,SCORE
CALL BINARY_BCD

LEA SI,SCORE       
MOV CX,BX
CALL BUBBLE_SORT    

LEA DX, CRLF       
MOV AH, 9
INT 21H              

LEA DI,MAX          
MOV AL,[SI+BX-1]   
MOV [DI],AL         
LEA DI,MIN          
MOV AL,[SI]   
MOV [DI],AL          
LEA DI,TOTAL        
MOV AL,BL   
MOV [DI],AL
                     
LEA DX,INSTRUCTION2 
MOV AH,9
INT 21H   
LEA DI,TOTAL
CALL INTERVAL_OUTPUT

LEA DX,INSTRUCTION3 
MOV AH,9
INT 21H             
LEA SI,MAX
MOV CX,1
CALL BCD_BINARY_OUTPUT
                   
LEA DX,INSTRUCTION4 
MOV AH,9
INT 21H             
LEA SI,MIN
MOV CX,1
CALL BCD_BINARY_OUTPUT
                    
LEA DX,INSTRUCTION5 

MOV AH,9
INT 21H
LEA SI,SCORE        
MOV CX,0
MOV CL,TOTAL
CALL BCD_BINARY_OUTPUT

LEA SI,SCORE         

MOV CX,0
MOV CL,TOTAL
CALL INTERVAL_CALCULATION 
                    
LEA DX, PKEY    
MOV AH, 9
INT 21H 

MOV AH, 1
INT 21H
RETSYS
BINARY_BCD PROC 
    
    PUSH AX         
    MOV CX,0
    MOV AX,0
    MOV AL,[SI+1]
    INC AL
    MOV CL,3
    DIV CL
    MOV CX,AX
    MOV BX,CX
DEFORM:        
    MOV AX, 0
    MOV AH, [SI+2]
    SUB AH,30H
    MOV AL, [SI+3]
    SUB AL,30H
    ROR AH,4
    ROL AX,4
    ROR AL,4
    MOV [DI],AL
    INC DI
    ADD SI,3
    LOOP DEFORM
    POP AX
    RET
BINARY_BCD ENDP

BUBBLE_SORT PROC         
    PUSH BP
    MOV BP, SP 
    MOV BX,0
    MOV DX, CX 
    DEC DX 
OUTER_LOOP:
    MOV AX,DX
    SUB AX,BX 
    MOV CX,0 
    CMP BX, DX 
    JB INNER_LOOP
    JA EXIT
INNER_LOOP:
    CMP CX,AX 
    JAE EXIT_INNER
    PUSH AX
    PUSH BX
    PUSH DX
    MOV BX,CX
    MOV AX,0
    MOV AL, [SI+BX] 
    MOV DL, [SI+BX+1]
    CMP AL, DL
    JBE NO_SWAP 
    
    XCHG AL, [SI+BX+1] 
    MOV [SI+BX], AL
    
NO_SWAP:    
    INC CX
    POP DX 
    POP BX
    POP AX
    
    JMP INNER_LOOP 
EXIT_INNER:
    INC BX
    JMP OUTER_LOOP
EXIT:
    POP BP
       RET
BUBBLE_SORT ENDP

BCD_BINARY_OUTPUT PROC 
    PUSH AX 
    PUSH BX
    MOV AX,0 
    MOV BX,0   
    
    OUTPUT:
        MOV BL, [SI]
        MOV AL, BL
        AND BL, 0X0F 
        AND AL, 0XF0  
        SHR AL, 4     
        ADD AL, 30H  
        ADD BL, 30H   
        MOV DL,AL
        MOV AH，2    
        INT 21H      
        MOV DL,BL    
        MOV AH,2  
        INT 21H      
        MOV DL,32
        MOV AH,2
        INT 21H     
        INC SI
    LOOP OUTPUT 
    
    POP AX 
    POP BX      
           RET
BCD_BINARY_OUTPUT ENDP  

INTERVAL_CALCULATION PROC   
PUSH AX
PUSH BX        
    MOV AX,0
    MOV BX,0 
    MOV AX,SI
    ADD AX,CX
CALCULATION:   
    CMP SI,AX  
    JAE EXIT_CALCULATION
    MOV BL,[SI]
    CMP BL,10010000B
    JAE PLUS_90
    JB  CMP_80
PLUS_90:            
    LEA DI,90_99
    INC [DI] 
    INC SI   
    JMP CALCULATION
CMP_80:
    CMP BL,10000000B
    JAE PLUS_80
    JB  CMP_70
PLUS_80:
    LEA DI,80_89
    INC [DI]
    INC SI
    JMP CALCULATION
CMP_70: 
    CMP BL,01110000B
    JAE PLUS_70
    JB  CMP_60
PLUS_70:
    LEA DI,70_79
    INC [DI]
    INC SI
    JMP CALCULATION  
CMP_60: 
    CMP BL,01100000B
    JAE PLUS_60
    JB  CMP_0
PLUS_60:
    LEA DI,60_69
    INC [DI]
    INC SI
    JMP CALCULATION 
CMP_0:
    CMP BL,0
    JAE PLUS_0
PLUS_0:
    LEA DI,0_59
    INC [DI]
    INC SI
    JMP CALCULATION
EXIT_CALCULATION: 
    LEA DX,INSTRUCTION6
    MOV AH,9
    INT 21H 
    LEA DI,90_99
    CALL INTERVAL_OUTPUT
    LEA DX,INSTRUCTION7
    MOV AH,9
    INT 21H  
    LEA DI,80_89
    CALL INTERVAL_OUTPUT
    LEA DX,INSTRUCTION8
    MOV AH,9
    INT 21H   
    LEA DI,70_79
    CALL INTERVAL_OUTPUT
    LEA DX,INSTRUCTION9
    MOV AH,9
    INT 21H  
    LEA DI,60_69
    CALL INTERVAL_OUTPUT
    LEA DX,INSTRUCTION10
    MOV AH,9
    INT 21H
    LEA DI,0_59
    CALL INTERVAL_OUTPUT
POP AX
POP BX    
    RET     
INTERVAL_CALCULATION ENDP

INTERVAL_OUTPUT PROC      

    PUSH AX           
    PUSH BX
    PUSH CX
        MOV AX,0     
        MOV AL,[DI]
        MOV CL,10     

        DIV CL
        MOV DL,AL
        ADD DL,30H
        MOV CH,AH
        MOV AH,02H
        INT 21H       
        MOV DL,CH
        ADD DL,30H
        MOV AH,02
        INT 21H

    POP CX
    POP BX
    POP AX
        RET
INTERVAL_OUTPUT ENDP
ENDS
END START

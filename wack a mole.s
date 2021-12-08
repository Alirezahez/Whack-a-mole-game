; Author of Whack-A-Mole - Alireza Hezaryan
; SID: 200412032
; ENSE 352 Final project
; December 6th, 2021
; #Don't panic :) 
;;; Directives
		PRESERVE8
		THUMB 

;; For the addresses you can see the prot A and B 

;;PortA
GPIOA_CRL   EQU 0x40010800 ;PA0~PA7  
GPIOA_ODR	EQU	0x4001080C ;Output Data 
	
;;PortB
GPIOB_CRL	EQU 0x40010C00
GPIOB_IDR	EQU 0x40010C08
GPIOB_ODR	EQU 0x40010C0C
	
; constant for clock;
RCC_APB2ENR EQU 0x40021018
	
	
;Time Constant are presented as follow: 
LED_Delay EQU 90000; initial game State 
PreGameDelay EQU 587545; Pre-game wait time after initiated
ReactTimeDelay EQU 565754; Reaction Time delay time to platy each mole 
Lose_idle EQU 604345; Delay for losing sequence
WinningSignalTime EQU 1200000; Loop time for winning signal
LosingSignalTime EQU 1200000; loop timw for loosing singnal


            AREA    RESET, Data, READONLY
            EXPORT  __Vectors
;The DCD directive allocates one or more words of memory, aligned on four-byte boundaries, 
;and defines the initial runtime contents of the memory.
; Vector Table Mapped to Address 0 at Reset, Linker requires __Vectors to be exported
__Vectors	DCD		0x20002000	; when stack is empty => stack pointer value 
            DCD		Reset_Handler	; reset vector
			
			ALIGN
;My program, Linker requires Reset_Handler and it must be exported				
		
            AREA    MYCODE, CODE, READONLY
			ENTRY
			EXPORT	Reset_Handler 

Reset_Handler PROC
	ALIGN
	LDR R2, =GPIOB_ODR
	LDR R3, = GPIOB_ODR
 	BL GPIO_CLK;   setting up  the clock
	BL GPIO_Enable;  
	BL waitingForPlayer    ;use case 2 Waiting for Player
	BL normalGamePlay    ;use case 3 Normal Game Play
	BL Whack_Moles
	BL UC4    ;End Success. The user has won the game
	BL UC5    ;End Failure. The user has lost the game
	
	ENDP
;Enable CLK
	ALIGN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This subroutine is where the clocks will be enabled and the ports 
;;; will be configured
;;;  
;;; Require:
;;;   R0: Register where data will be manipulated and stored
;;;	  R1: port enables
;;;   
;;;  
;;; Promisse:
;;;   Enables clocks of Ports A and B and configures them as outputs
;;;   and inputs. All inputs are already configured by default on reset
;;;   but they were configured just to be safe. Also all outputs are being 
;;;   configured as push-pull
;;;   
;;;
;;; Modifies:
;;;   This function will modify the low registers, although 
;;;   those can be reset after the function ends
;;;
;;;
;;;
GPIO_CLK PROC
	LDR R0, =RCC_APB2ENR; Address for Clock
	LDR R1, = 0xC;00001100 Port Enables
	STR R1, [R0]
	BX LR
	ENDP
;Enable 
GPIO_Enable PROC  
	LDR R5, =GPIOA_CRL ; Enable Port 0,1,4
	LDR R1, = 0x44434433
	STR R1, [R5]
	LDR R6, =GPIOB_CRL
	LDR R1, = 0x44444443; Enable Port B
	STR R1, [R6]
	BX LR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This subroutine consists of a loop where the user must press a button
;;; in order to proceed with the game. The state of the buttons is checked
;;; throughout the loop, and it is made the assumption that when the user 
;;; presses one button it is held down pressed for at least half a second.
;;;  
;;; Require:
;;;   R4: GPIOB_IDR
;;;  
;;;
;;; Promisse:
;;;  Creates a loop where LEDs will blink in a pattern as to
;;;  indicate that the system is waiting for user input   
;;;
;;;
;;;
;;;	
;User case 2
waitingForPlayer	
	LDR R4, =GPIOB_IDR;  Load R4 to PortB  
	LDR R9,[R4]; Set default input
	LDR R8, = 0
	B LED1
	
;**********************************************************************	
;LED main functions ***************************************************
;**********************************************************************
LED1
	LDR R1, =0x0; Turn Off
	STR R1,[R2]
	LDR R1, =0x1;PA0 Turn On
	STR R1,[R2]	
	LDR R7,= LED_Delay
	B LED1_Delay
LED2
	LDR R1, =0x0; PA_0 OFF
	STR R1,[R2]
	LDR R1, =0x2; PA_1 ON
	STR R1,[R2]
	LDR R7,= LED_Delay
	B LED2_Delay	
LED3
	LDR R1, =0x0; PA1 Off
	STR R1,[R2]
	LDR R2, =GPIOA_ODR
	LDR R1, =0x10; PA4 On
	STR R1,[R2]
	LDR R7,= LED_Delay
	B LED3_Delay
LED4
	LDR R2, =GPIOA_ODR
	LDR R1, =0x0;  
	STR R1,[R2]
	LDR R2, =GPIOB_ODR
	LDR R1, =0x1; 
	STR R1,[R2]
	LDR R7,= LED_Delay
	B LED4_Delay
LED3_Back
	LDR R2, =GPIOB_ODR
	LDR R1, =0x0; 
	STR R1,[R2]
	LDR R2, =GPIOA_ODR
	LDR R1, =0x10; 
	STR R1,[R2]
	LDR R7,= LED_Delay
	B LED3_Delay_Back	
LED2_Back
	LDR R2, =GPIOA_ODR
	LDR R1, =0x0; PA_4 OFF
	STR R1,[R2]
	LDR R2, =GPIOA_ODR
	LDR R1, =0x2; PA_1 ON
	STR R1,[R2]
	LDR R7,= LED_Delay
	B LED2_Delay_Sub
	

;**********************************************************************	
;LED sub functions ****************************************************
;**********************************************************************

LED1_Sub
	LDR R9,[R4]
	LDR R1, = 0xFFC6; BlackPB
	CMP R9, R1
	BNE LED1_I
	BX LR
LED2_Sub
	LDR R9,[R4]
	LDR R1, = 0xFF96; REDPB
	CMP R9, R1
	BNE LED2_I
	BX LR
LED3_Sub    
	LDR R9,[R4]	
	LDR R1, = 0xFED6;  
	CMP R9, R1
	BNE LED3_Sub_I
	BX LR	
LED4_Sub
	LDR R9,[R4]
	LDR R1, = 0xFDD7
	CMP R9, R1
	BNE LED4_Sub_I
	BX LR	
LED3_Back_Sub
	LDR R9,[R4]	
	LDR R1, = 0xFED6; 
	CMP R9, R1
	BNE LED3_Back_Sub_I
	BX LR; 
LED2_Back_Sub
	LDR R9,[R4]
	LDR R1, = 0xFF96 
	CMP R9, R1
	BNE LED2_Back_Sub_I
	BX LR 
	
	
;**********************************************************************	
;LED sub functions ****************************************************
;**********************************************************************

LED1_I
	LDR R1, = 0xFF96; REDPB
	CMP R9, R1
	BNE LED1_II
	BX LR
	
LED1_II
	LDR R1, = 0xFED6; GREENPB
	CMP R9, R1
	BNE LED1_III
	BX LR
	
LED1_III
	LDR R1, = 0xFDD6; BLUEPB
	CMP R9, R1
	BNE LED1_Delay
	BX LR
	
LED2_I
	LDR R1, = 0xFFC6; BLACKPB
	CMP R9, R1
	BNE LED2_II
	BX LR
LED2_II
	LDR R1, = 0xFED6; GREENPB
	CMP R9, R1
	BNE LED2_III
	BX LR
LED2_III
	LDR R1, = 0xFDD6; BLUEPB
	CMP R9, R1
	BNE LED2_Delay
	BX LR
	
LED3_Sub_I
	LDR R1, = 0xFFC6;  
	CMP R9, R1
	BNE LED3_Sub_II
	BX LR
	
LED3_Sub_II
	LDR R1, = 0xFF96;  
	CMP R9, R1
	BNE LED3_Sub_III
	BX LR
	
LED3_Sub_III
	LDR R1, = 0xFDD6;  
	CMP R9, R1
	BNE LED3_Delay
	BX LR

LED4_Sub_I
	LDR R1, = 0xFFC7; 
	CMP R9, R1
	BNE LED4_Sub_II
	BX LR
	
LED4_Sub_II
	LDR R1, = 0xFF97; 
	CMP R9, R1
	BNE LED4_Sub_III
	BX LR
	
LED4_Sub_III
	LDR R1, = 0xFED7;  
	CMP R9, R1
	BNE LED4_Delay
	BX LR
	
LED3_Back_Sub_I
	LDR R1, = 0xFFC6; 
	CMP R9, R1
	BNE LED3_Back_Sub_II
	BX LR
	
LED3_Back_Sub_II
	LDR R1, = 0xFF96;  
	CMP R9, R1
	BNE LED3_Back_Sub_III
	BX LR
	
LED3_Back_Sub_III
	LDR R1, = 0xFDD6; 
	CMP R9, R1
	BNE LED3_Delay_Back
	BX LR

LED2_Back_Sub_I
	LDR R1, = 0xFFC6;  
	CMP R9, R1
	BNE LED2_Back_Sub_II
	BX LR
	
LED2_Back_Sub_II
	LDR R1, = 0xFDD6; 
	CMP R9, R1
	BNE LED2_Back_Sub_III
	BX LR
	
LED2_Back_Sub_III
	LDR R1, = 0xFED6; 
	CMP R9, R1
	BNE LED2_Delay_Sub
	BX LR
	
;**********************************************************************	
; Here are the LED dalays *********************************************
;**********************************************************************	


LED1_Delay
	SUBS R7, R7, #1;  
	CMP R7, #0   
	BNE LED1_Sub; 
	BEQ LED2
LED2_Delay
	SUBS R7, R7, #1;  
	CMP R7, #0   
	BNE LED2_Sub ; 
	BEQ LED3	
LED2_Delay_Sub
	SUBS R7, R7, #1;  
	CMP R7, #0   
	BNE LED2_Back_Sub; 
	BEQ LED1
LED3_Delay
	SUBS R7, R7, #1;  
	CMP R7, #0   
	BNE LED3_Sub; 
	BEQ LED4
LED4_Delay
	SUBS R7, R7, #1;  
	CMP R7, #0   
	BNE LED4_Sub;
	BEQ LED3_Back	
LED3_Delay_Back
	SUBS R7, R7, #1;  
	CMP R7, #0   
	BNE LED3_Back_Sub; 
	BEQ LED2_Back	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This is where the normal gameplay will take place. 
;;; 
;;; a prime number randomizer is gneratting the required pattern to paly the game. 
;;; 
;;;  
;;; Require:
;;;   R0: PreGameDelay
;;;	  R1: 0x0;
;;;   R2: GPIOA_ODR
;;;   R3: GPIOB_ODR
;;;   R5: Read button states
;;;   R7: ReactTimeDelay
;;;
;;; Promisse:
;;; Simulates wack-a-mole game by turning on random LEDs and monitoring button states   
;;;
;;; Modifies:
;;;   This function will modify R0, R1 and R11, all other registers can be 
;;;   reset/reused once subroutine ends
;;;
;;;
;;;	
;normalGamePlay
normalGamePlay PROC
Whack_Moles	
	LDR R0, = PreGameDelay;
	LDR R7, = ReactTimeDelay;
	LDR R1, = 0x0;
	LDR R2, = GPIOA_ODR;
	LDR R3, = GPIOB_ODR;
	LDR R8, = 7; 7 Rounds --The number of times that the player can whack moles to win a round
	LDR R5, = 0
	PUSH{R5}
	BL OFFLEDS

YOUWIN
	BL UC4

BlackMole
	LDR  R1, =0x1; Black Mole
	STR  R1, [R2]; Mole pops--Black Button	
	LDR  R5, = 0 
	PUSH {R5}
BlackMole_WAIT
	PUSH {R5}
	LDR R1, [R4]; R
	LDR R6, = 0xFFC6; Black
	CMP R1, R6;
	BEQ OFFLEDS
	LDR R6, = 0xFF96; RED
	CMP R1, R6
	BEQ Tryagain	
	LDR R6, = 0xFED6; GREEN
	CMP R1, R6
	BEQ Tryagain
	LDR R6, = 0xFDD6; BLUE
	CMP R1, R6
	BEQ Tryagain	
	POP{R5}
	ADD R5, #1
	CMP R5, R7
	BNE BlackMole_WAIT
	B  Tryagain
RedMole
	LDR  R1, =0x2; RED Mole
	STR  R1, [R2]; Mole pops--Red button
	LDR  R5, = 0 
	PUSH {R5}
RedMole_Waiting
	PUSH {R5}
	LDR R1, [R4]; R4: GPIOB_IDR	
	LDR R6, = 0xFF96; RED
	CMP R1, R6;
	BEQ OFFLEDS	
	LDR R6, = 0xFDD6; BLUE
	CMP R1, R6
	BEQ Tryagain
	LDR R6, = 0xFED6; GREEN
	CMP R1, R6
	BEQ Tryagain
	LDR R6, = 0xFFC6; Black
	CMP R1, R6
	BEQ Tryagain
	POP{R5}
	ADD R5, #1
	CMP R5, R7
	BNE RedMole_Waiting
	B Tryagain
GreenMole
	LDR  R1, =0x10; Green Mole
	STR  R1, [R2]; Mole pops--Green button
	LDR  R5, = 0 
	PUSH {R5}
GreenMole_Waiting
	PUSH {R5}
	LDR R1, [R4]; R4: GPIOB_IDR	
	LDR R6, = 0xFED6; 
	CMP R1, R6;
	BEQ OFFLEDS	
	LDR R6, = 0xFDD6; BLUE
	CMP R1, R6
	BEQ Tryagain
	LDR R6, = 0xFF96;  
	CMP R1, R6
	BEQ Tryagain
	LDR R6, = 0xFFC6;  
	CMP R1, R6
	BEQ Tryagain
	POP{R5}
	ADD R5, #1
	CMP R5, R7
	BNE GreenMole_Waiting
	B Tryagain
BlueMole
	LDR  R1, =0x1; Blue Mole
	STR  R1, [R3]; Mole pops--Blue Button
	LDR  R5, = 0 
	PUSH {R5}
BlueMole_Waiting
	PUSH {R5}
	LDR R1, [R4]; R4: GPIOB_IDR
	LDR R6, = 0xFDD7; BLUE
	CMP R1, R6;
	BEQ OFFLEDS
	LDR R6, = 0xFF96; RED
	CMP R1, R6
	BEQ Tryagain
	LDR R6, = 0xFED6; GREEN
	CMP R1, R6
	BEQ Tryagain
	LDR R6, = 0xFFC6; Black
	CMP R1, R6
	BEQ Tryagain
	POP{R5}
	ADD R5, #1
	CMP R5, R7
	BNE BlueMole_Waiting
	B  Tryagain
Tryagain ; Restart UC4
	BL UC5
	ENDP
  
OFFLEDS;  
	LDR R6, =0x2
	LDR R1, =0x0
	STR R1, [R2];  
	STR R1, [R3];  
	ADD R5, #1;
	CMP R5, R0;
	BNE OFFLEDS
	B normalGamePlay_Loop
	
normalGamePlay_Loop
	POP{R5}
	SUBS R8, #1
	CMP R8, #0
	BEQ YOUWIN
	BNE Random
	
;randomNumGen

;		LDR R6, = 0x19660D
;		LDR R5, = 0x3C6EF35F
;		MUL R4, R4, R6
;		ADD R4, R4, R7
;		MOV R8, R4
;		LSR R8, R8, #30
;		 
;		CMP R8, #0x0
;		BEQ BlackMole; 
;		
;		CMP R8, #0x1
;		BEQ GreenMole; 
;		
;		CMP R8, #0x2
;		BEQ BlueMole; 
;		
;		CMP R8, #0x3
;		BEQ RedMole; 
	
Random; Prime Number Randomizer
	UDIV R5, R6; 
	CMP R5, #5
	BEQ BlackMole;  
	CMP R5, #0
	BEQ GreenMole;  
	CMP R5, #3
	BEQ BlueMole; 
	CMP R5, #2
	BEQ RedMole; 
	BNE Random


;Usercase 4	 End Success. The user has won the game
UC4 PROC  
	
	BL GAMEWIN 
;Usercase 5	End Failure. The user has lost the game
UC5 PROC
	LDR R11, = Lose_idle
	
	BL GameOver

GAMEWIN 
	
	LDR R12, = WinningSignalTime  

anotherLoop   ;loop for winning signal and restart the game
	
	LDR R7, = 0;
	LDR R10, = 1;  
	LDR R2, =GPIOA_ODR
	LDR R3, = GPIOB_ODR
	LDR R1, =0x0
	STR R1, [R2]; LED OFF
	STR R1, [R3]; LED OFF
	LDR R1,  = 0x13;open PA 0,1,4
	STR R1,[R2]
	LDR R1, = 0x1  ;open PB0
	STR R1, [R3]
	CMP R7, R10 ;
	SUBS R12, R12, #1
	CMP R12, #0
	BNE anotherLoop
	B waitingForPlayer
	
GameOver
	LDR R12, = LosingSignalTime;
looseLoop  ;loop for loosing signal and restart the game
 
	LDR R10, = Lose_idle; Rese first
	ADD R7, R7, #1; Start counting 
	LDR R2, =GPIOA_ODR
	LDR R3, = GPIOB_ODR
	LDR R8, =0x0
	STR R8, [R2];  
	STR R8, [R3]
	CMP R7, #40; 
	BNE Losewaiting1
	SUBS R12, R12, #1
	CMP R12, #0
	BNE looseLoop
	B waitingForPlayer

GameOver_LED_ON
	LDR R11, = Lose_idle; Reset for Losewaiting1
	LDR R1,  = 0x13;-->PA_0
	STR R1,[R2]
	LDR R1, = 0x1
	STR R1, [R3]
	B Losewaiting2
Losewaiting1
	SUBS R11, R11, #1 
	CMP R11, #0  
	BNE Losewaiting1   
	BEQ GameOver_LED_ON    
Losewaiting2
	SUBS R10, R10, #1  
	CMP R10, #0
	BNE Losewaiting2
	;;BEQ GameOver
	SUBS R12, R12, #1
	CMP R12, #0
	BNE looseLoop
	B waitingForPlayer
	ALIGN
	END
;;ProficiencyLevel 
;   LDR R5

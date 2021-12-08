# Whack-a-mole-game
Whack-a-mole is basically a game in which there are holes on a surface and randomly,  the mice(or any animal for instance) pops out constantly from unpredictable holes in an uncertain pattern.  The player has to hit the mole by hammering it using different hammers so it goes away,in this way, the moles  keep popping out from various holes speedily at uncertain holes. Our goal as a player would be to whack as   many moles as possible so that none(least) remains popping out on the surface. 

Demo 

You can see a Demo of the project via this link:
https://youtu.be/WXZU4MgGGlg




######################################################################################
1. What the game is?

$ Whack-a-mole is basically a game in which there are holes on a surface and randomly,
 the mice(or any animal for instance) pops out constantly from unpredictable holes in an uncertain pattern.
 The player has to hit the mole by hammering it using different hammers so it goes away,in this way, the moles
 keep popping out from various holes speedily at uncertain holes. Our goal as a player would be to whack as 
 many moles as possible so that none(least) remains popping out on the surface.

######################################################################################
2. How to play

$ To play the whack-A-mole that I have created, the user must hit the reset button in order to go
into  the Waiting phase that has a sequence of leds going off in a sequencial pattern.
The pattern that I chose to do was having my leds flash right to left in 90000 speed timing. The user must press
any of the 4 coloured buttons(red, black, blue, green) on the main board in order to proceed to the
next phase, which is the game phase.

In the game phase, all of the leds are shut off with a slight delay before anything happens. Once the
delay(approximately a second or two) is done, the first random LED comes on. The user must then push
the assigned button for the LED to turn off and proceed further along in the game. I have implemented
up to 7 rounds currently.

If the player is able to press all of the corresponding pushbuttons in time and properly,
the player has won the game sending themselves to the End Success phase. In this phase all LEDs 
turn on and and show that you have won the game and loops to the waiting status.

If the player is unable to press all of the corresponding pushbuttons in time and/or properly, the
game will to go into the End Failure phase which flashes the LEDs blinking very fast showing that you lost
the game. And the game is ready to reset and be played another round.

######################################################################################
3. Any information about problems encountered, features you failed to implement, extra features
you implemented beyond the basic requirements, possible future expansion, etc.

$ Problems encountered for myself was trying to be more organized and be consistant with naming my functions
and  procedures. I had to start from the scatch 2 times since I confused myself with What I wrote at the end. I would 
definitly use comments explanning stuff. 
$ Some of my hardwares had problems that I tried different code on it and did not work. I had to check all my wires,
buttons and then I realized the problem was my breadboard, It was not working and the amount of time it took me to 
realize this was considerably high that I started questioning my whole field and mental status for it :)
$Another probem was that whatever I did the looseLoop coundn't work and I set it in a way that the player has to
reset after loosing to play again.


$$ Features I failed to implement:

$ Unfortunately due to time constraint I could not implement the player proficiency level and showing the user 
what round they are playing. I tried to implement it but encountered some errors and did not have enough time to debug
so I got rid of that part.
$ The player has to reset the game after loosing and my looseLoop does not work in the way I want to.


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


######################################################################################
4.How the user can adjust the game parameters, including:
(a) PrelimWait: at the beginning of a cycle, the time to wait before lighting a LED
(b) ReactTime, the time allowed for the user to press the correct button to avoid terminating
the game.
(c) The number of cycles in a game: NumCycles
(d) values of WinningSignalTime and LosingSignalTime.

$$$
a) All you need to do is change the time in      

          PreGameDelay EQU 587545; Pre-game wait time after initiated*
	  
 in the code and set it as you wish it be played.

b) All you need to do is change the time in   

         ReactTimeDelay EQU 565754; Reaction Time delay time to platy each mole
	 
in the code and set it as you wish it be played.

c) All you need to do is change the R8 velue in the below code:

*Whack_Moles	
	LDR R0, = PreGameDelay;
	LDR R7, = ReactTimeDelay;
	LDR R1, = 0x0;
	LDR R2, = GPIOA_ODR;
	LDR R3, = GPIOB_ODR;
	LDR R8, = 7;  7 Rounds --The number of times that the player can whack moles to win a round
	LDR R5, = 0
	PUSH{R5}
	BL OFFLEDS
*

d) All you need to do is change the time in   
            
              WinningSignalTime EQU 1200000; Loop time for winning signal
              LosingSignalTime EQU 1200000; loop timw for loosing singnal

in the code and set it as you wish it be played.

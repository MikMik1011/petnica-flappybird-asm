PLAYERCLR:	equ %00001000 ;color of the player/bird
PIPECLR:	equ %01110000 ;color of the pipe


	
	org		32768 ; place game in the middle of the memory
	ld		hl, 22912 ; 22912 = 22528 + 12*32
	ld 		(hl), PLAYERCLR ;color the first block
	inc 	hl	;go to next one
	ld 		(hl), PLAYERCLR	;color the second block
	ld		bc, 31 ;put difference from second block first row to first block second row
	add 	hl, bc
	ld 		(hl), PLAYERCLR ;color the first block
	inc 	hl	;go to next one
	ld 		(hl), PLAYERCLR	;color the second block
	ret 




HEIGHT:	defb	12	;height of the player
SCORE:	defb	0	;players score

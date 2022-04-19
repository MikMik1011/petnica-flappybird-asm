PLAYERCLR:	equ %00001000 ;color of the player/bird
PIPECLR:	equ %01110000 ;color of the pipe


	
	org		32768 ; place game in the middle of the memory


	call drawPlayer
	call drawPipe
	call movePipes
	call movePipes
	call movePipes
	call movePipes

;--------------------------------------------------------------------------------
; routine for drawing player/bird
drawPlayer:
	ld		hl, 22915 ; 22915 = 22528 + 12*32 + 3
	ld 		(hl), PLAYERCLR ;color the first block
	inc 	hl	;go to next one
	ld 		(hl), PLAYERCLR	;color the second block
	ld		bc, 31 ;put difference from second block first row to first block second row
	add 	hl, bc
	ld 		(hl), PLAYERCLR ;color the first block
	inc 	hl	;go to next one
	ld 		(hl), PLAYERCLR	;color the second block
	ret

;--------------------------------------------------------------------------------
; routine for drawing pipe
drawPipe:
	ld		hl, 22558 ; 22558 = 22528 + 30
	ld		bc, 31 ; number of space blocks between pipes
	ld 		a, 22 ; number of rows on the screen
	call drawPipeLoop
	ret

drawPipeLoop:
	;halt 
	ld 		(hl), PIPECLR ;color the first block
	inc 	hl	;go to next one
	ld 		(hl), PIPECLR	;color the second block
	add 	hl, bc ; go to next row
	dec 	a ; decrement number of rows
	jp 		nz, drawPipeLoop ; repeat
	ret

;-----------------------------------------------
; routine for moving pipe blocks
movePipes:
	ld 		hl, 22528 ; first block
	ld 		bc, 704 ; amount of blocks to move
	call movePipesLoop

movePipesLoop:
	
	ld 		d, h ;save the address so we can move the pipe later
	ld 		e, l ;save the address so we can move the pipe later
	inc 	hl	;go to next one
	ld 		a, (hl) ;get the block color
	cp 		PIPECLR ;compare with the pipe color
	jp 		nz, decreaseMovePipesCounter ;if it's not the pipe color, go to the next block
	ld 		a, l ; save the value of l in a so we can do and operation later
	and 	%00011111 ; mask the value of the position of pipe to check if it is in first block in a row
	jp 		z, deletePipe ;if it's in the first block, delete it
	ld 		a, (hl) ; move the pipe info to accumulator so we can move it to the previous block
	ld 		(de), a ; move the pipe from accumulator to previous block
	ld 		(hl), %00111000 ; reset current block
	call 	decreaseMovePipesCounter ;if there are blocks to move, go to the next block
	ret  
	

deletePipe:
	ld 		(hl), %00111000 ;delete the pipe
	jp 		decreaseMovePipesCounter ;go to the next block

decreaseMovePipesCounter:
	dec 	bc
	jp 		nz, movePipesLoop ;if there are blocks to move, go to the next block
	ret 
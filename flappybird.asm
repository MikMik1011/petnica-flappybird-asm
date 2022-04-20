PLAYERCLR:	equ %00001000
PIPECLR: 	equ %01110000
BGCLR:		equ %00111000	
PIPEOPENSIZE	equ 7
PIPEDISTANCE	equ 13
SPACEPORT	equ $7FFE
JUMPDIST 	equ 5
FALLINT 	equ 3
	
	org 32768

main:

	ld	hl, (COORDS)	;address of the first block
	call 	drawPlayer
	call 	drawPipe

	call 	infinitelooptest


	
	ret 

infinitelooptest:
	call	shiftScreen
	call 	playerJump
	call 	scanSpaceDown
	call 	scanSpaceReleased
	ld 	a, (PADA)
	dec 	a
	call 	z, playerfall
	ld 	(PADA), a
	halt
	halt
	halt
	dec	d
	call	z, drawPipe
	
	jp	infinitelooptest
	ret
	;-------------------------------------
; player draw routine
; usage: pass address of the first player block, it will handle the rest 
drawPlayer:
	ld 	(hl), PLAYERCLR		; color the block
	ret 
;----------------------------------------


;------------------------------------------
; pipe draw routine
; it draws the pipe in the last 2 columns
drawPipe:
	ld	hl, $581F 	; last block in first row

	call Generaterandom	; generate a random size of first pipe part
	and	%00001111	; check if it is larger than 16
	jp	z, drawPipe	; if so, jump to start of the function
	ld 	b, a 		; copy size of first part from accumulator to loop counter
	ld 	c, a 		; save size of first part to c because it will be needed later

	ld	a, PIPECLR	; set color to pipe color
	call 	drawPipeRowLoop	; draw first part

	ld	a, BGCLR	; set color to background color (invisible)
	ld 	b, PIPEOPENSIZE ; set amount of needed blocks to size of opening
	call 	drawPipeRowLoop	; draw the hole/opening

	ld 	a, 24		; load total row size to accumulator
	sub 	c		; subtract the size of the first opening
	sub 	PIPEOPENSIZE	; also subtract the size of the opening
	ld 	b, a		; set the remainder as the amount of remaining blocks for drawing second part of pipe
	ld 	a, PIPECLR	; set color to pipe color
	call 	drawPipeRowLoop	; draw the second part

	ld 	d, PIPEDISTANCE	; reset the pipe drawing thing
	ret 

drawPipeRowLoop:
	ld 	(hl), a 	; paint it in pipe color
	ld 	de, 32 		; load number of blocks needed to get below the first block
	add 	hl, de 		; jump to the block below the first block
	djnz	drawPipeRowLoop	; loop until all needed rows are drawn
	ret 
;------------------------

;------------------------
; screen shift routine
shiftScreen:
	ld 	hl, (OLDCOORDS)
	ld 	(hl), BGCLR 	; make player invisible to hide its move
	ld 	hl, $5801 	; load block which needs to be moved in the row
	ld 	c, 24 		; number of rows
	call	shiftScreenWholeLoop
	ld 	hl, (COORDS)
	ld 	a, (hl)
	cp 	PIPECLR
	jp 	z, 0
	ld 	(hl), PLAYERCLR ; make player visible again
	ret 

shiftScreenWholeLoop:
	ld 	b, 31 		; load number of blocks in a row - 1
	call	shiftScreenRowLoop
	dec	c
	jp	nz, shiftScreenWholeLoop
	ret

shiftScreenRowLoop:
	ld 	a, (hl)		; move the pipe info to accumulator so we can move it to the block left
	dec	hl		; go one block left
	ld 	(hl), a		; move the pipe from accumulator to the block left
	inc	hl
	inc	hl 		; move 2 blocks to the right
	djnz shiftScreenRowLoop
	dec	hl		; go to last block in the row
	ld	(hl), BGCLR	; paint the block with the background color
	inc 	hl
	inc 	hl

	ret 

playerJump:
	ld 	a, (TOJUMP) 	; load remaining jumps
	cp 	0		; compare them with zero
	call 	nz, movePlayerUp
	ret 

movePlayerUp:
	dec 	a 		; decrease the number of remaining jumps
	ld 	(TOJUMP), a	; save it to TOJUMP var
	ld 	bc, (COORDS)	; load player coords to registry a
	ld 	(OLDCOORDS), bc ; remember old coords in OLDCOORDS var
	ld 	a, 32
	call 	govno
	ld 	(COORDS), bc 	; set new coords to COORDS var
	ret 

govno:
	dec bc
	dec a 
	jp nz, govno
	ret 

playerfall:

	ld 	bc, (COORDS)
	ld 	a, 32
	call 	novogovno
	ld 	(COORDS), bc
	ld 	a, FALLINT
	ret

novogovno:
	inc bc
	dec a 
	jp nz, novogovno
	ret 
	
scanSpaceDown:
	ld 	a, (SPACEPRESSED) ; check variable that shows if the key is pressed
	cp 	0		  ; compare it with 0
	jp 	z, scanSpacePressed ; if it really isn't pressed, scan keyboard, else just return
	ret

scanSpacePressed:
	ld	bc, SPACEPORT	; load space port adress
	in	a, (c)		; i have no idea what this really does but it gets key states i guess
	bit 	0, a		; check if space is pressed by checking its bit (SPACE RSHIFT M N B = 0 1 2 3 4)
	call	z, addPlayerJump; if is pressed then make player jump (NEEDS TO BE IMPLEMENTED)
	ret

scanSpaceReleased:
	ld	bc, SPACEPORT	; load space port adress
	in	a, (c)		; i have no idea what this really does but it gets key states i guess
	bit 	0, a		; check if space is pressed by checking its bit (SPACE RSHIFT M N B = 0 1 2 3 4)
	call	nz, setSpaceUp	; if is pressed then make player jump (NEEDS TO BE IMPLEMENTED)
	ret

setSpaceUp:
	ld 	a, 0
	ld 	(SPACEPRESSED), a ; set the variable that shows if the key is pressed to 1
	ret 

;-----------------------------------------------
addPlayerJump:
	ld 	a, 1
	ld 	(SPACEPRESSED), a
	ld 	a, (TOJUMP)
	add 	a, JUMPDIST ; add jump distance to remaining jumps variable
	ld 	(TOJUMP), a
	ret



;===============================================================================
; lib_random.asm
; Originally appeared as a post by Patrik Rak on WoSF.
;
; generateRandom - generates random number
; seedRandom - seeds random number generator
;===============================================================================

; ------------------------------------------------------------------------------ 
; Generates random number.
;
; Input: 
;   NONE
; Output: 
;   A  - generated random number
; ------------------------------------------------------------------------------ 

generateRandom:

	push	hl
	push	de
	
_rnd:	ld	hl,0xA280   ; xz -> yw
	ld	de,0xC0DE   ; yw -> zt

	ld	(_rnd+1),de ; x = y, z = w
	ld 	a,e         ; w = w ^ ( w << 3 )
	add	a,a
	add	a,a
	add	a,a
	xor	e
	ld	e,a
	ld	a,h         ; t = x ^ (x << 1)
	add	a,a
	xor	h
	ld	d,a
	rra                 ; t = t ^ (t >> 1) ^ w
	xor	d
	xor	e
	ld	h,l         ; y = z
	ld	l,a         ; w = t
	ld	(_rnd+4),hl

	pop	de
	pop	hl
	ret
		
; ------------------------------------------------------------------------------ 
; Seeds random number generator with R register. Not originally posted by
; Patrik Rak, added later by Ivan Glisin to provide different initial values. 
;
; Input: 
;   NONE
; Output: 
;   NONE
; ------------------------------------------------------------------------------ 

seedRandom:

	push	af
	ld	a,r
	ld	(_rnd+4),a
	pop	af
	ret

TEST: 	defb $69, $69, $69 ; split program from data, mainly for debugging
OLDCOORDS: 	defw $5962
COORDS:		defw $5962
TOJUMP:		defb 0 ;80FE
SPACEPRESSED: 	defb 0
PADA:		defb 10
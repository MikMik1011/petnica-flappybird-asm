PLAYERCLR:	equ %00001000 ;color of the player/bird
PIPECLR:	equ %01110000 ;color of the pipe


	
	org		32768 ; place game in the middle of the memory

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



drawPipe:
	; ovde ide ona petlja za crtanje pipe-a i njihovih blokova 
	ld		hl, 22558 ; 22558 = 22528 + 30
	ld		bc, 31 ; number of space blocks between pipes
	ld 		a, 24 ; number of columns on the screen

drawPipeLoop:
	ld 		(hl), PIPECLR ;color the first block
	inc 	hl	;go to next one
	ld 		(hl), PIPECLR	;color the second block
	add 	hl, bc
	dec 	a
	jr 		nz, drawPipeLoop
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


HEIGHT:	defb	12	;height of the player
SCORE:	defb	0	;players score

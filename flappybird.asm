PLAYERCLR:	equ %00001000
PIPECLR: 	equ %01110000
BGCLR:		equ %00111000	
	
	org 32768

main:
	ld	hl, $5962	;address of the first block
	call 	drawPlayer
	call 	drawWholePipe
	call 	shiftScreen
	halt
	call 	shiftScreen
	halt
	call 	shiftScreen
	halt
	call 	shiftScreen
	halt
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
drawWholePipe:
	ld	hl, $581E 	; 2nd last block in first row
	ld 	b, 22 		; number of rows
	call drawPipeRowLoop	
	ret 

drawPipeRowLoop:
	ld 	(hl), PIPECLR 	; paint it in pipe color
	ld 	de, 32 		; load number of blocks needed to get below the first block
	add 	hl, de 		; jump to the block below the first block
	djnz 	drawPipeRowLoop ; loop until whole pipe has been drawn
	ret 
;------------------------

;------------------------
; screen shift routine
shiftScreen:
	ld 	hl, $5801 	; load block which needs to be moved in the row
	ld 	c, 24 		; number of rows
	call	shiftScreenWholeLoop
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

	ret 

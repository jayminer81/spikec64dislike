.include	"init.asm"
; init stuff done, fixing basic-start of the program, setting up the color-ram, screen-ram, initializes sprites and so on...

restart:		; if player dies, the game returns here to initialize everything back to "the start"
	lda	#$07
	sta	ground_counter	; timer used for redrawing the ground-tiles
	lda	#$00
	sta $02
	lda	#$30
	sta $03		; start of level is at $3000
	lda	#$00
	sta	death

; reset all variables in ram $4000-....
	ldx	#$17
	lda	#$00
@loop:
	sta	$4000, x
	dex
	bne	@loop

	lda	#$00
	sta $d020	; set border color to black

	lda	#$02
	jsr	song		; init goat-tracker song

	jsr setupspritesfortitle

	ldx	#$28
@loop2:
	lda	bottomtext, x
	sta	$07c0, x
	dex
	txa
	bpl	@loop2

	lda	#$01
	sta	ontitlescreen

waitfire:
	lda wait_interrupt	; wait for interrupt to finish
	bne	waitfire
	lda	$dc00	; read joystick in port 2
	eor	#%11111111	; invert what was read
	and #%00011111	; mask off bits not related to the joystick
	beq waitfire		; if the value we have now is not zero, the joystick has been pressed and we have movement

	lda	#$00
	sta	ontitlescreen

	ldx	#$28
@loop:
	lda	#$00
	sta	$07c0, x
	dex
	txa
	bpl	@loop

	jsr setupspritesforgameplay

	lda	#$00
	jsr	song		; init goat-tracker song

; --- MAIN LOOP STARTS HERE ---

lock:
	lda wait_interrupt	; wait for interrupt to finish
	bne	lock
	lda	#$01
	sta	wait_interrupt

; check to see if player has collided with a spike

	lda	death
	beq	playerisalive		; if death = 0 then continue game, else wait for $20 frames and then restart
	lda	#$01
	jsr song

	jsr hiscorecheck
	ldx	#$50
playerisdead:
	lda wait_interrupt
	bne	playerisdead
	lda	#$01
	sta	wait_interrupt
	dex
	bne	playerisdead
	jmp restart

playerisalive:
	lda	$dc00	; read joystick in port 2
	eor	#%11111111	; invert what was read
	and #%00011111	; mask off bits not related to the joystick
	bne movement		; if the value we have now is not zero, the joystick has been pressed and we have movement
	lda	moveanyway
	bne	movement
	lda	#$00
	sta	firecombo
	jmp nomovement	; otherwise we skip all movement stuff

movement:
	lda	#$00
	sta	moveanyway
	dec	ground_counter
	dec	ground_counter
	dec	ground_counter	; count down the counter used for updating the ground-tiles, counts from 7 to 0
	bpl	dontresetcounter
	lda	ground_counter
	clc
	adc	#$08
	sta	ground_counter

dontresetcounter: 
	lda	ground_counter
	asl
	asl
	asl
	tay			; multiply the counter by 8 (each tile is 8 bytes) and transfer it back to X register
	ldx	#$f8		
charupdateloop:
	lda brick+$100, y
	sta	$2200-$f8, x
	lda brick+$140, y
	sta	$2208-$f8, x
	lda brick+$180, y
	sta	$2210-$f8, x
	lda brick+$1c0, y
	sta	$2218-$f8, x
	iny
	inx
	bne charupdateloop

	jsr	movemonsters		; this subroutine is in monster.asm

nomovement:
	ldy player_sine
	lda	sintable, y
	clc
	adc #$7d
	sta $d001
	sta $d003
	inc player_sine
	lda	player_sine
	cmp #$4a
	bne noresetsine
	lda	#$00
	sta player_sine
noresetsine:
	jsr checkcollision
	jsr checkscore

	lda	combotimer
	beq @slem
	jmp lock
@slem:
	jmp lock

irq:
	jsr	song+3
	lda	ontitlescreen
	beq	donotupdatebottomtext
	inc	counter
	bne	donotupdatebottomtext
	jsr	updatebottomtext
donotupdatebottomtext:
	dec combotimer
	lda	combotimer
	bpl	noneedtoresetscoreadd
	lda	#$00
	sta	scoreadd
	sta	combotimer
noneedtoresetscoreadd:
	lda	#$00
	sta	wait_interrupt
	asl	$d019	; acknowledge the interrupt
	jmp	$ea81

.include "monster.asm"
.include "score.asm"
.include "data.asm"

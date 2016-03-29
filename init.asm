.DEFINE	ground_counter	$4000
.DEFINE	player_sine		$4001
.DEFINE	wait_interrupt	$4002
.DEFINE	player_col_x		$4003
.DEFINE	player_col_y		$4004
.DEFINE	monster_col_x		$4005
.DEFINE	monster_col_y		$4006
.DEFINE	death			$4007
.DEFINE	score0bcd		$4008
.DEFINE	score1bcd		$4009
.DEFINE	score2bcd		$400a
.DEFINE	score3bcd		$400b
.DEFINE	scoreadd			$400c
.DEFINE	firecombo		$400d
.DEFINE combotimerl		$400e
.DEFINE combotimerr		$400f
.DEFINE	combotimer		$4010
.DEFINE	moveanyway		$4011
.DEFINE	combotemp		$4012
.DEFINE combochar0		$4013
.DEFINE combochar1		$4014
.DEFINE combochar2		$4015
.DEFINE combochar3		$4016
.DEFINE combochar4		$4017
.DEFINE	hiscore0bcd		$4018
.DEFINE	hiscore1bcd		$4019
.DEFINE	hiscore2bcd		$401a
.DEFINE	hiscore3bcd		$401b
.DEFINE counter			$401c
.DEFINE	textshow			$401d
.DEFINE	ontitlescreen		$401e

.DEFINE left 			#$6d


.byte $01,$08
.org $0801
	.byte $0c,$08,$d0,$07,$9e,$20,$32,$30,$36,$34,$00,$00,$00,$00,$00	; SYS 2064 in "Basic-Code" 

	lda	#%00011011
	sta	$d011
	lda #%00011000
	sta	$d016	; set up the screen - hires character mode

	lda	#$00
	sta	$d020	; set border color to black
	sta	$d021	; set background color to black

	lda #$18
	sta $d018	; set up the screen memory, screen ram at $400, character ram at $2000

; --- INTERRUPT INITIALIZATION ---

	sei			; disable interrupts
	lda #$7f
	sta $dc0d
	sta $dd0d	; disable all interrupts

	lda	#$01
	sta	$d01a	; set to use raster interrupts

	lda #<irq
	ldx	#>irq
	sta	$0314
	stx $0315	; store adress to jump to when an interrupt occurs

	ldy	#$f0
	sty	$d012	; trigger interrupt on line $f0

	lda	$dc0d
	lda	$dd0d
	asl $d019	; clear and acknowledge interrupts

	cli			; re-enable interrupts

; --- fill screen ---
; $0400 - $07ff = screen ram (name table), $d800 - $dbff = color ram (attribute table)

	ldx	#$00
loop2:
	lda	map,x
	sta	$0400, x
	lda	map+$100,x
	sta $0500, x
	lda	map+$200,x
	sta $0600, x
	lda	map+$300,x
	sta $0700, x
	inx
	bne	loop2

; --- load colors onto screen ---
; $d800 - $dbff = color ram

	ldx	#$00
loop3:
	ldy	$400, x
	lda color, y
	sta	$d800, x
	ldy	$500, x
	lda color, y
	sta	$d900, x
	ldy	$600, x
	lda color, y
	sta	$da00, x
	ldy	$700, x
	lda color, y
	sta	$db00, x
	dex
	bne loop3

; set up colors for the game background

	lda	#$0e		; light blue
	sta $d022 
	lda	#$0d		; light green
	sta $d023 

	jmp restart

setupspritesfortitle:
	lda	#%00000000	; set all sprites to to hires
	sta	$d01c
	lda	#%11111111	; enable all sprites
	sta $d015

	lda	#$98			; set up sprites for displaying title text
	sta	$7f8
	lda	#$99
	sta	$7f9
	lda	#$9a
	sta	$7fa
	lda	#$9b
	sta	$7fb
	lda	#$9c
	sta	$7fc
	lda	#$9d
	sta	$7fd
	lda	#$9e
	sta	$7fe
	lda	#$9f
	sta	$7ff

	lda	#%10000000
	sta	$d010		; set msb for rightmost sprite

	lda	left
	sta	$d000
	lda	left+$18
	sta $d002
	lda	left+$30
	sta $d004
	lda	left+$48
	sta $d006
	lda	left+$60
	sta $d008
	lda	left+$78
	sta $d00a
	lda	left+$90
	sta $d00c
	lda	$10
	sta $d00e

	lda	#$80
	sta	$d001
	sta	$d003
	sta	$d005
	sta	$d007
	sta	$d009
	sta	$d00b
	sta	$d00d
	sta	$d00f

	lda	#$01		; white outline 
	sta $d027	; on all sprites
	sta $d028
	sta $d029
	sta $d02a
	sta $d02b
	sta $d02c
	sta $d02d
	sta $d02e
	sta $d02f
rts

setupspritesforgameplay:

	lda	#%10101010	; set one sprite to multicolor and one to hires (the overlay)
	sta	$d01c
	lda	#%11111111	; enable all sprites
	sta $d015

	lda	#$95			; set up correct graphics for main sprite
	sta	$7f8
	lda	#$94
	sta	$7f9

	lda	#$97			; set up correct graphics for spikes
	sta	$7fa
	sta	$7fc
	sta	$7fe
	lda	#$96
	sta	$7fb
	sta	$7fd
	sta	$7ff

; set up initial values for X position of main sprite

	lda	#$40
	sta	$d000
	sta $d002

; set up colors for the sprites

	lda	#$0f		; light grey
	sta $d025	; universal sprite-color #1
	lda	#$01		; white
	sta $d026	; universal sprite-color #2

	lda	#$0b		; dark grey outline 
	sta $d027	; on the player sprite
	lda	#$00		; black outline
	sta $d029	; used on the rest
	sta $d02b
	sta $d02d

	lda	#$0c
	sta $d028	; middle grey color on player sprite

; set up initial values for X and Y position for all sprites

	lda	#$7f
	sta $d004
	sta $d006
	lda #$ff
	sta $d008
	sta $d00a
	lda	#$7f
	sta $d00c
	sta $d00e

	lda #$ff
	sta	$d005
	sta	$d007
	sta	$d009
	sta	$d00b
	sta	$d00d
	sta	$d00f

	lda	#%11000000
	sta $d010

rts 

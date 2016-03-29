bounding_box	= 18
sprite_size	= 16

movemonsters:
; move monster 0
	lda	$d004
	sec
	sbc	#$03
	sta	$d004
	sta	$d006
	cmp #$ff
	beq	updateofmsb_monster0
	cmp #$fe
	beq	updateofmsb_monster0
	cmp #$fd
	beq	updateofmsb_monster0
	jmp noupdateofmsb_monster0
updateofmsb_monster0:
	lda	$d010
	eor	#%00001100
	sta	$d010
	and	#%00001100
	beq	noupdateofmsb_monster0
	lda	#$80
	sta	$d004
	sta	$d006
	ldy #$00
	lda	($02), y
	sta	$d005
	sta	$d007
	lsr
	lsr
	lsr
	clc
	adc #$01
	sta	$d02a
	inc $02
	bne	noupdateofmsb_monster0
	inc $03
noupdateofmsb_monster0:

; move monster 1
	lda	$d008
	sec
	sbc	#$03
	sta	$d008
	sta	$d00a
	cmp #$ff
	beq	updateofmsb_monster1
	cmp #$fe
	beq	updateofmsb_monster1
	cmp #$fd
	beq	updateofmsb_monster1
	jmp noupdateofmsb_monster1
updateofmsb_monster1:
	lda	$d010
	eor	#%00110000
	sta	$d010
	and	#%00110000
	beq	noupdateofmsb_monster1
	lda	#$80
	sta	$d008
	sta	$d00a
	ldy #$00
	lda	($02), y
	sta	$d009
	sta	$d00b
	lsr
	lsr
	lsr
	clc
	adc #$01
	sta	$d02c
	inc $02
	bne	noupdateofmsb_monster1
	inc $03

noupdateofmsb_monster1:

; move monster 2
	lda	$d00c
	sec
	sbc	#$03
	sta	$d00c
	sta	$d00e
	cmp #$ff
	beq	updateofmsb_monster2
	cmp #$fe
	beq	updateofmsb_monster2
	cmp #$fd
	beq	updateofmsb_monster2
	jmp noupdateofmsb_monster2
updateofmsb_monster2:
	lda	$d010
	eor	#%11000000
	sta	$d010
	and	#%11000000
	beq	noupdateofmsb_monster2
	lda	#$80
	sta	$d00c
	sta	$d00e
	ldy #$00
	lda	($02), y
	sta	$d00d
	sta	$d00f
	lsr
	lsr
	lsr
	clc
	adc #$01
	sta	$d02e
	inc $02
	bne	noupdateofmsb_monster2
	inc $03
noupdateofmsb_monster2:
rts 

checkcollision:
	lda	$d000
	sec
	sbc #(bounding_box/2 - sprite_size/2)
	sta player_col_x

	lda $d001
	sec
	sbc #(bounding_box/2 - sprite_size/2)
	sta player_col_y

checkmonster0:
	lda	$d010
	and	#%00001100
	bne	checkmonster1

	lda	$d004
	clc
	adc #sprite_size/2
	sta monster_col_x

	lda $d005
	clc		
	adc #sprite_size/2
	sta monster_col_y

	jsr	docheck

checkmonster1:
	lda	$d010
	and	#%00110000
	bne	checkmonster2

	lda	$d008
	clc
	adc #sprite_size/2
	sta monster_col_x

	lda $d009
	clc		
	adc #sprite_size/2
	sta monster_col_y

	jsr	docheck

checkmonster2:
	lda	$d010
	and	#%11000000
	bne	colcheckdone

	lda	$d00c
	clc
	adc #sprite_size/2
	sta monster_col_x

	lda $d00d
	clc		
	adc #sprite_size/2
	sta monster_col_y

	jsr	docheck
colcheckdone:
rts

docheck:

	; if monster_col_x < sprite_col_x, no collision
	lda monster_col_x
	cmp player_col_x
	bmi no_col_on_this_monster

	; if monster_col_y < sprite_col_y, no collision
	lda monster_col_y
	cmp player_col_y
	bmi no_col_on_this_monster

	; if monster_col_x > sprite_col_x + bounding_box_size, no collision
	lda player_col_x
	clc
	adc #bounding_box
	cmp monster_col_x
	bmi no_col_on_this_monster

	; if monster_col_y > sprite_col_y + bounding_box_size, no collision
	lda player_col_y
	clc
	adc #bounding_box
	cmp monster_col_y
	bmi no_col_on_this_monster

	; collision
	lda	#$02
	sta	$d020
	lda	#$01
	sta	death
	no_col_on_this_monster:
rts


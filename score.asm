checkscore:
	lda	$d010
	and #%00001100
	bne checkpassedmonster1
	lda	$d004
	cmp #$40
	beq	passedmonster0
	cmp #$3f
	beq	passedmonster0
	cmp #$3e
	beq	passedmonster0
	jmp checkpassedmonster1
passedmonster0:
	lda	$d005
	cmp	#$ff
	beq	checkpassedmonster1
	inc firecombo
	lda	firecombo
	cmp	#$05
	bne	@notatcombomax
	lda	#$04
	sta firecombo
@notatcombomax:
	jsr increasescore

checkpassedmonster1:
	lda	$d010
	and #%00110000
	bne checkpassedmonster2
	lda	$d008
	cmp #$40
	beq	passedmonster1
	cmp #$3f
	beq	passedmonster1
	cmp #$3e
	beq	passedmonster1
	jmp checkpassedmonster2
passedmonster1:
	lda	$d009
	cmp	#$ff
	beq	checkpassedmonster2
	inc firecombo
	lda	firecombo
	cmp	#$05
	bne	@notatcombomax
	lda	#$04
	sta firecombo
@notatcombomax:
	jsr increasescore

checkpassedmonster2:
	lda	$d010
	and #%11000000
	bne checkscoredone
	lda	$d00c
	cmp #$40
	beq	passedmonster2
	cmp #$3f
	beq	passedmonster2
	cmp #$3e
	beq	passedmonster2
	jmp checkscoredone
passedmonster2:
	lda	$d00d
	cmp	#$ff
	beq	checkscoredone
	inc firecombo
	lda	firecombo
	cmp	#$05
	bne	@notatcombomax
	lda	#$04
	sta firecombo
@notatcombomax:
	jsr increasescore

checkscoredone:		; --- Render the score on screen ---
	lda	score0bcd
	lsr
	lsr
	lsr
	lsr
	clc
	adc #$44
	sta	$0447
	lda	score0bcd
	and	#%00001111
	clc
	adc #$44
	sta	$0448

	lda	score1bcd
	lsr
	lsr
	lsr
	lsr
	clc
	adc #$44
	sta	$0449
	lda	score1bcd
	and	#%00001111
	clc
	adc #$44
	sta	$044a

	lda	score2bcd
	lsr
	lsr
	lsr
	lsr
	clc
	adc #$44
	sta	$044b
	lda	score2bcd
	and	#%00001111
	clc
	adc #$44
	sta	$044c

	lda	score3bcd
	lsr
	lsr
	lsr
	lsr
	clc
	adc #$44
	sta	$044d
	lda	score3bcd
	and	#%00001111
	clc
	adc #$44
	sta	$044e

	jsr	figureoutcombochars
	jsr	rendercombometer
rts

figureoutcombochars:
	lda	combotimer
	lsr
	sta	combotemp
	cmp #$04
	bpl @combochar0isfull
	sta	combochar0
	lda	#$00
	sta	combochar1
	sta	combochar2
	sta	combochar3
	sta	combochar4
rts

@combochar0isfull:
	lda	#$04
	sta	combochar0
	lda	combotemp
	cmp #$08
	bpl @combochar1isfull
	sec
	sbc	#$04
	sta	combochar1
	lda	#$00
	sta	combochar2
	sta	combochar3
	sta	combochar4
rts

@combochar1isfull:
	lda	#$04
	sta	combochar1
	lda	combotemp
	cmp #$0c
	bpl @combochar2isfull
	sec
	sbc	#$08
	sta	combochar2
	lda	#$00
	sta	combochar3
	sta	combochar4
rts

@combochar2isfull:
	lda	#$04
	sta	combochar2
	lda	combotemp
	cmp #$10
	bpl @combochar3isfull
	sec
	sbc	#$0c
	sta	combochar3
	lda	#$00
	sta	combochar4
rts

@combochar3isfull:
	lda	#$04
	sta	combochar3
	lda	combotemp
	cmp #$14
	bpl @allarefull
	sec
	sbc	#$10
	sta	combochar4
rts

@allarefull:
	lda	#$04
	sta	combochar4
rts

rendercombometer:
	ldy	#$0
@loop:
	lda	combochar0, y
	sta	$43c, y
	iny
	cpy	#$05
	bne @loop
rts

increasescore:
	lda	#$01
	sta	moveanyway
	lda	#$48
	sta combotimer

	sed
	lda	scoreadd
	clc
	adc	#$01
	bcc scoreaddlowerthan99
	lda	#$99
scoreaddlowerthan99:
	sta	scoreadd
	cld

	ldx	firecombo
	sed
increaseloop:
	lda	score3bcd
	clc
	adc scoreadd
	sta	score3bcd
	bcc	donotincrementmore
	lda	score2bcd
	clc
	adc #$01
	sta	score2bcd
	bcc donotincrementmore
	lda	score1bcd
	clc
	adc #$01
	sta	score1bcd
	bcc donotincrementmore
	lda	score0bcd
	clc
	adc #$01
	sta	score0bcd
	bcc donotincrementmore
	lda	#$99
	sta	score0bcd
	sta	score1bcd
	sta	score2bcd
	sta	score3bcd

donotincrementmore:
	dex
	bne	increaseloop
	cld
	jmp	checkscoredone

; ----------- HI SCORE CHECKER ------------

hiscorecheck:
	lda	hiscore0bcd
	cmp	score0bcd
	bmi	hiscore
	beq	possiblehiscore
	jmp nohiscore

possiblehiscore:
	lda	hiscore1bcd
	cmp	score1bcd
	bmi	hiscore
	beq	possiblehiscore2
	jmp nohiscore

possiblehiscore2:
	lda	hiscore2bcd
	cmp	score2bcd
	bmi	hiscore
	beq	possiblehiscore3
	jmp nohiscore

possiblehiscore3:
	lda	hiscore3bcd
	cmp	score3bcd
	bmi	hiscore
	jmp nohiscore

hiscore:
	lda	score0bcd
	sta	hiscore0bcd
	lda	score1bcd
	sta	hiscore1bcd
	lda	score2bcd
	sta	hiscore2bcd
	lda	score3bcd
	sta	hiscore3bcd

	lda	hiscore0bcd
	lsr
	lsr
	lsr
	lsr
	clc
	adc #$44
	sta	$042e
	lda	hiscore0bcd
	and	#%00001111
	clc
	adc #$44
	sta	$042f

	lda	hiscore1bcd
	lsr
	lsr
	lsr
	lsr
	clc
	adc #$44
	sta	$0430
	lda	hiscore1bcd
	and	#%00001111
	clc
	adc #$44
	sta	$0431

	lda	hiscore2bcd
	lsr
	lsr
	lsr
	lsr
	clc
	adc #$44
	sta	$0432
	lda	hiscore2bcd
	and	#%00001111
	clc
	adc #$44
	sta	$0433

	lda	hiscore3bcd
	lsr
	lsr
	lsr
	lsr
	clc
	adc #$44
	sta	$0434
	lda	hiscore3bcd
	and	#%00001111
	clc
	adc #$44
	sta	$0435

nohiscore:
rts	

updatebottomtext:
	lda	textshow
	cmp	#$00
	beq	shownames
	cmp #$02
	beq	showhttp
increasetextshow:
	inc textshow
	lda	textshow
	cmp	#$04
	bne	@done
	lda	#$00
	sta	textshow

@done:
rts 


shownames:
	ldx	#$28
@loop:
	lda	bottomtext, x
	sta	$07c0, x
	dex
	txa
	bpl	@loop
	jmp	increasetextshow

showhttp:
	ldx	#$28
@loop:
	lda	bottomtext+$28, x
	sta	$07c0, x
	dex
	txa
	bpl	@loop
	jmp	increasetextshow

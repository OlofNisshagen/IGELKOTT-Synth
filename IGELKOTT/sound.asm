UPDATE_OSCILLATORS:
	push r16
    in r16, SREG
    push r16
	push r23

	clr r23

	rcall UPDATE_ENVELOPE_TICK
	rcall OUTPUT_AUDIO

	sts OCR1AL, r23
	
	pop r23
	pop r16
    out SREG, r16
    pop r16
	reti

UPDATE_ENVELOPE_TICK:
	lds r16, ENVELOPE_TICK
	dec r16
	sts ENVELOPE_TICK, r16
	brne UPDATE_TICK_EXIT
	sti ENVELOPE_TICK, ENVELOPE_PRESCALER
UPDATE_TICK_EXIT:
	ret

OUTPUT_AUDIO:
	push YL
	push YH
	push r16
	push r18

	loady OSCILLATOR_0
	ldi r16, VOICES_AMOUNT
	lds r18, OSCILLATORS_ACTIVE

OUTPUT_LOOP:
	sbrc r18, 0
	rcall PLAY_NOTE
	addiy OSCILLATOR_SIZE
	lsr r18
	dec r16
	brne OUTPUT_LOOP
	
	pop r18
	pop r16
	pop YH
	pop YL
	ret

PLAY_NOTE:
	push r16
	push r17
	push r18
	push r19
	push r20

	rcall UPDATE_ACCUMULATOR
	rcall ADSR

	lds r17, MASTER_VOLUME
	mul r17, r20
	mov r17, r1
	lsr r17
	lsr r17

	rcall WAVE

PLAY_NOTE_EXIT:
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
	ret
	
UPDATE_ACCUMULATOR:
	ldd r16, y+0 ;step low
    ldd r17, y+1 ;step high
    ldd r18, y+2 ;acc low
    ldd r19, y+3 ;acc high
    add r18, r16
    adc r19, r17
	std y+2, r18            
    std y+3, r19
	ret

ADSR:
	push r21
	push ZL
	push ZH
	ldd r16, y+4
	ldd r18, y+5			 ;acc
	ldd r20, y+6			 ;envelope volume

	;lij ADSR_TABLE, r16
	ldi ZL, low(ADSR_TABLE)
	ldi ZH, high(ADSR_TABLE)
	addz r16
	ijmp
ADSR_TABLE:
	rjmp ATTACK
	rjmp DECAY
	rjmp SUBSTAIN
	rjmp RELEASE
	rjmp CLEAR_OSCILLATOR
	
ATTACK:
	lds r17, ENVELOPE_ATTACK ;step
	tst r17
	breq ATTACK_INSTANT
	com r17
	lds r21, ENVELOPE_TICK
	cpi r21, ENVELOPE_PRESCALER
	brne ADSR_ACC
	add r18, r17
	brcc ADSR_ACC
	inc r20
	std y+6, r20
	cpi r20, $FF
	breq NEXT_PHASE
	rjmp ADSR_ACC
ATTACK_INSTANT:
	ldi r20, $FF
	std y+6, r20
	rjmp NEXT_PHASE
	
DECAY:
	lds r17, ENVELOPE_DECAY ;step
	tst r17
	breq DECAY_INSTANT
	com r17
	lds r21, ENVELOPE_TICK
	cpi r21, ENVELOPE_PRESCALER
	brne ADSR_ACC
	add r18, r17
	brcc ADSR_ACC
	dec r20
	std y+6, r20
	lds r21, ENVELOPE_SUBSTAIN
	cp r20, r21
	breq NEXT_PHASE
	rjmp ADSR_ACC
DECAY_INSTANT:
	lds r20, ENVELOPE_SUBSTAIN
	std y+6, r20
	rjmp NEXT_PHASE
	
SUBSTAIN:
	rjmp ADSR_ACC
	
RELEASE:
	lds r17, ENVELOPE_RELEASE ;step
	tst r17
	breq RELEASE_INSTANT
	com r17
	lds r21, ENVELOPE_TICK
	cpi r21, ENVELOPE_PRESCALER
	brne ADSR_ACC
	add r18, r17
	brcc ADSR_ACC
	dec r20
	std y+6, r20
	tst r20
	breq NEXT_PHASE
	rjmp ADSR_ACC
RELEASE_INSTANT:
	clr r20
	std y+6, r20
	rjmp NEXT_PHASE

NEXT_PHASE:
	inc r16
	std y+4, r16
	clr r18
ADSR_ACC:
	std y+5, r18
	pop ZH
	pop ZL
	pop r21
	ret

WAVE:
	push ZL
	push ZH
	lds r16, WAVEFORM
	;lij WAVE_TABLE, r16

	ldi ZL, low(WAVE_TABLE)
	ldi ZH, high(WAVE_TABLE)
	addz r16
	ijmp
WAVE_TABLE:
	rjmp SINE_WAVE
	rjmp SQUARE_WAVE
	rjmp SAWTOOTH_WAVE
	rjmp TRIANGLE_WAVE

SINE_WAVE:
	push ZL
	push ZH
	loadz SINE_TABLE
	addz r19
	lpm r16, Z
	mul r16, r17
	add r23, r1
	pop ZH
	pop ZL
	rjmp WAVE_EXIT

SQUARE_WAVE:
	sbrc r19, 7
	add r23, r17
	rjmp WAVE_EXIT

SAWTOOTH_WAVE:
	mul r19, r17    ; Scale by volume
    add r23, r1     ; Add high byte to mixer
	rjmp WAVE_EXIT

TRIANGLE_WAVE:
	push r19
    sbrc r19, 7     ; Is it the second half of the wave?
    com r19         ; If bit 7 is set, invert the value (creates the "down" slope)
    lsl r19         ; Multiply by 2 to keep the amplitude full (0-255)
    mul r19, r17    ; Scale by volume
    add r23, r1     ; Add high byte to mixer
	pop r19
	rjmp WAVE_EXIT

WAVE_EXIT:
	pop ZH
	pop ZL
	ret
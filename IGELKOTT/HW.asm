HW:
	sbi DDRB, 1

	clr r16
	out DDRD, r16

	ldi r16, $FF
	out PORTD, r16
    
    ; Timer 1
    ldi r16, (1<<COM1A1) | (1<<WGM10)
    sts TCCR1A, r16
    ldi r16, (1<<WGM12) | (1<<CS10)
    sts TCCR1B, r16

    ;Timer 2
    ldi r16, (1<<WGM21)
    sts TCCR2A, r16
	ldi r16, (1<<CS21) 
    sts TCCR2B, r16
    ldi r16, 31
    sts OCR2A, r16

    ldi r16, (1<<OCIE2A)
    sts TIMSK2, r16

	clr r2

	ret
HW:
	sbi DDRB, 1

	ldi r16, 0b00000100
	out DDRD, r16

	ldi r16, 0b11111000
	out PORTD, r16
    
    ; Timer 1
	ldi r16, (1<<COM1A1) | (1<<WGM10)
	sts TCCR1A, r16
	ldi r16, (1<<WGM12) | (1<<CS10)
	sts TCCR1B, r16
   
    ;Timer 2
	;ldi r16, (1<<WGM21)
	;sts TCCR2A, r16
	;ldi r16, (1<<CS21)
	;sts TCCR2B, r16

	sti TCCR2A, 1<<WGM21
	sti TCCR2B, 1<<CS21

	
    sti OCR2A, 31
    
	sti TIMSK2, 1<<OCIE2A

	clr r2

	ret
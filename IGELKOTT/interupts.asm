.org 0x0000
    rjmp COLD
.org 0x000E             ; Adressen för Timer 2 Compare Match A (ATmega328P)
    rjmp TIMER_2

INITIALIZE_INTERUPTS:
;TIMER1
	ldi r16, (1<<COM1A1) | (1<<WGM10)
	sts TCCR1A, r16
	ldi r16, (1<<WGM12) | (1<<CS10)
	sts TCCR1B, r16
   
;TIMER2
	sti TCCR2A, 1<<WGM21
	sti TCCR2B, 1<<CS21

    sti OCR2A, 31
	sti TIMSK2, 1<<OCIE2A
	ret

TIMER_2:
	push r16
    in r16, SREG
    push r16

	rcall UPDATE_OSCILLATORS
	sti DEBOUNCE_FLAG, $FF

	pop r16
    out SREG, r16
    pop r16
	reti
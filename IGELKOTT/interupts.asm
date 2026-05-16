.org 0x0000
    rjmp COLD
.org 0x000E             ; Adressen för Timer 2 Compare Match A (ATmega328P)
    rjmp TIMER_2

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
.include "resources.asm"
.include "interupts.asm"
.include "hw.asm"
.include "sound_lib.asm"
.include "sound.asm"
.include "keys.asm"


COLD:
	ldi r16, LOW(RAMEND)
	out SPL, r16
	ldi r16, HIGH(RAMEND)
	out SPH, r16

	rcall INITIALIZE_HARDWARE
	rcall INITIALIZE_INTERUPTS
	rcall CLEAR_OSCILLATORS
	rcall INITIALIZE_VALUES
	rcall INITIALIZE_KEYS
	sei
	rjmp MAIN

INITIALIZE_HARDWARE:
	sbi DDRB, 1
	ldi r16, 0b00000100
	out DDRD, r16
	ldi r16, 0b11111000
	out PORTD, r16
	clr r2
	ret

MAIN:
	lds r16, DEBOUNCE_FLAG
	cpse r16, r2
	rcall CHECK_KEYS
	rcall LIGHT

	rjmp MAIN

LIGHT:
	lds r16, KEYS_PRESSED
	tst r16
	breq TURN_OFF
	
TURN_ON:
	sbi PORTD, 2
	ret

TURN_OFF:
	cbi PORTD, 2
	ret
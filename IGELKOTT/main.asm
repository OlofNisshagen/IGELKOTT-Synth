.org 0x0000
    rjmp COLD
.org 0x000E             ; Adressen för Timer 2 Compare Match A (ATmega328P)
    rjmp UPDATE_OSCILLATORS

.include "resources.asm"
.include "hw.asm"
.include "keys.asm"
.include "sound_lib.asm"
.include "sound.asm"

COLD:
	ldi r16, LOW(RAMEND)
	out SPL, r16
	ldi r16, HIGH(RAMEND)
	out SPH, r16

	rcall HW
	rcall CLEAR_OSCILLATORS
	rcall INITIALIZE_VALUES
	rcall INITIALIZE_KEYS

WARM:
	note 330
	note 440

	sei

MAIN:
	;rcall CHECK_KEYS
	rcall UPDATE_OSCILLATORS
	rjmp MAIN

.equ F_ISR = 62500
.equ ACC_MAX = 65536

.equ OSCILLATOR_SIZE = 9
.equ VOICES_AMOUNT = 2

.equ ENVELOPE_PRESCALER = 8

.macro NOTE ;@0 = Frek (16)
	ldi r16, low((@0 * ACC_MAX) / F_ISR)
	ldi r17, high((@0 * ACC_MAX) / F_ISR)
	rcall FIND_OSCILLATOR
.endmacro

.dseg
	MASTER_VOLUME:		.byte	1
	WAVEFORM:			.byte	1

	ENVELOPE_TICK:		.byte	1
	ENVELOPE_ATTACK:	.byte	1
	ENVELOPE_DECAY:		.byte	1
	ENVELOPE_SUBSTAIN:	.byte	1
	ENVELOPE_RELEASE:	.byte	1

	OSCILLATORS_ACTIVE:	.byte	1
	OSCILLATOR_0:		.byte	OSCILLATOR_SIZE
	OSCILLATOR_1:		.byte	OSCILLATOR_SIZE
	OSCILLATOR_2:		.byte	OSCILLATOR_SIZE
	OSCILLATOR_3:		.byte	OSCILLATOR_SIZE

.cseg
INITIALIZE_VALUES:
	sti MASTER_VOLUME, 255
	sti WAVEFORM, 2
	sti ENVELOPE_ATTACK, 100
	sti ENVELOPE_DECAY, 100
	sti ENVELOPE_SUBSTAIN, 128
	sti ENVELOPE_RELEASE, 200
	ret

CLEAR_OSCILLATORS:
	push r16
	push YL
	push YH
	loady OSCILLATOR_0
	ldi r16, VOICES_AMOUNT
CLEAR_OSCILLATORS_LOOP:
	rcall CLEAR_OSCILLATOR
	addiy OSCILLATOR_SIZE
	dec r16
	brne CLEAR_OSCILLATORS_LOOP
	sts OSCILLATORS_ACTIVE, r2
	pop YH
	pop YL
	pop r16
	ret

CLEAR_OSCILLATOR:
	std y+0, r2
	std y+1, r2
	std y+2, r2
	std y+3, r2
	std y+4, r2
	std y+5, r2
	std y+6, r2
	std y+7, r2
	std y+8, r2
	ret

FIND_OSCILLATOR:
	lds r18, OSCILLATORS_ACTIVE
	ldi r19, VOICES_AMOUNT
FIND_OSCILLATOR_LOOP:
	sbrs r18, 0
	rjmp FOUND
	lsr r18
	dec r19
	brne FIND_OSCILLATOR_LOOP
VOICE_STEALING:
	push YL
	push YH
	loady OSCILLATOR_0
	addiy 8

	clr r19		;vilken oscillator som levt längst
	clr r20		;hur längre den längsta oscillatorn levt
	clr r21		;current oscillator

	ldi r18, VOICES_AMOUNT ;looplängd
VOICE_STEALING_LOOP:
	ld r21, Y
	cp r21, r20
	brlo VOICE_STEALING_CONT
	mov r20, r21

	ldi r21, VOICES_AMOUNT
	sub r21, r18
	mov r19, r21
VOICE_STEALING_CONT:
	addiy OSCILLATOR_SIZE
	dec r18
	brne VOICE_STEALING_LOOP
VOICE_STEALING_EXIT:
	ldi r20, OSCILLATOR_SIZE
	mul r19, r20
	loadx OSCILLATOR_0
	addx r0
	rcall ADD_TO_OSCILLATOR
	rcall INCREMENT_OSCILLATORS_DURATION
	pop YH
	pop YL
	ret

FOUND:
	ldi r18, VOICES_AMOUNT
	sub r18, r19
	ldi r20, OSCILLATOR_SIZE
	mul r18, r20
	loadx OSCILLATOR_0
	addx r0
	rcall ADD_TO_OSCILLATOR
	rcall INCREMENT_OSCILLATORS_DURATION
	rcall ACTIVATE_OSCILLATOR
	ret

ADD_TO_OSCILLATOR:
	st X+, r16	;Step low
	st X+, r17	;Step high
	st X+, r2	;Acc low
	st X+, r2	;Acc high
	st X+, r2	;Phase State
	st X+, r2	;Phase Acc
	st X+, r2	;Envelope Level
	st X+, r2	;Key Index
	st X+, r2	;Duration
	ret

INCREMENT_OSCILLATORS_DURATION:
	loady OSCILLATOR_0
	addiy 8
	ldi r18, VOICES_AMOUNT
INCREMENT_OSCILLATORS_LOOP:
	ld r16, y
	inc r16
	std y+8, r16
	addiy OSCILLATOR_SIZE
	dec r18
	brne INCREMENT_OSCILLATORS_LOOP
INCREMENT_OSCILLATORS_EXIT:
	ret

ACTIVATE_OSCILLATOR:
	push r18
	lds r16, OSCILLATORS_ACTIVE
	ldi r17, 1
	tst r18
	breq ACTIVATE_OSCILLATOR_EXIT
ACTIVATE_OSCILLATOR_LOOP:
	lsl r17
	dec r18
	brne ACTIVATE_OSCILLATOR_LOOP
ACTIVATE_OSCILLATOR_EXIT:
	or r16, r17
	sts OSCILLATORS_ACTIVE, r16
	pop r18
	ret

DEACTIVATE_OSCILLATOR:
	push r18
	lds r16, OSCILLATORS_ACTIVE
	ldi r17, 1
	tst r18
	breq DEACTIVATE_OSCILLATOR_EXIT
DEACTIVATE_OSCILLATOR_LOOP:
	lsl r17
	dec r18
	brne DEACTIVATE_OSCILLATOR_LOOP
DEACTIVATE_OSCILLATOR_EXIT:
	and r16, r17
	sts OSCILLATORS_ACTIVE, r16
	pop r18
	ret

SINE_TABLE:
	.db 128, 131, 134, 137, 140, 143, 146, 149, 152, 156, 159, 162, 165, 168, 171, 174
	.db 177, 179, 182, 185, 188, 191, 193, 196, 199, 201, 204, 206, 209, 211, 213, 216
	.db 218, 220, 222, 224, 226, 228, 230, 232, 234, 236, 237, 239, 240, 242, 243, 245
	.db 246, 247, 248, 249, 250, 251, 252, 252, 253, 254, 254, 255, 255, 255, 255, 255
	.db 255, 255, 255, 255, 255, 255, 254, 254, 253, 252, 252, 251, 250, 249, 248, 247
	.db 246, 245, 243, 242, 240, 239, 237, 236, 234, 232, 230, 228, 226, 224, 222, 220
	.db 218, 216, 213, 211, 209, 206, 204, 201, 199, 196, 193, 191, 188, 185, 182, 179
	.db 177, 174, 171, 168, 165, 162, 159, 156, 152, 149, 146, 143, 140, 137, 134, 131
	.db 128, 124, 121, 118, 115, 112, 109, 106, 103,  99,  96,  93,  90,  87,  84,  81
	.db  78,  76,  73,  70,  67,  64,  62,  59,  56,  54,  51,  49,  46,  44,  42,  39
	.db  37,  35,  33,  31,  29,  27,  25,  23,  21,  19,  18,  16,  15,  13,  12,  10
	.db   9,   8,   7,   6,   5,   4,   3,   3,   2,   1,   1,   0,   0,   0,   0,   0
	.db   0,   0,   0,   0,   0,   0,   1,   1,   2,   3,   3,   4,   5,   6,   7,   8
	.db   9,  10,  12,  13,  15,  16,  18,  19,  21,  23,  25,  27,  29,  31,  33,  35
	.db  37,  39,  42,  44,  46,  49,  51,  54,  56,  59,  62,  64,  67,  70,  73,  76
	.db  78,  81,  84,  87,  90,  93,  96,  99, 103, 106, 109, 112, 115, 118, 121, 124

NOTES:
	.db 262, 294, 330, 392, 440
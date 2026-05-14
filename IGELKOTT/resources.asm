.macro LOADX
	ldi XL, low(@0)
	ldi XH, high(@0)
.endmacro

.macro LOADY
	ldi YL, low(@0)
	ldi YH, high(@0)
.endmacro

.macro LOADZ
	ldi ZL, low(@0 * 2)
	ldi ZH, high(@0 * 2)
.endmacro

.macro ADDX
	add XL, @0
	adc XH, r2
.endmacro

.macro ADDIX
	subi XL, -@0
	adc XH, r2
.endmacro

.macro ADDY
	add YL, @0
	adc YH, r2
.endmacro

.macro ADDIY
	subi YL, -@0
	adc YH, r2
.endmacro

.macro ADDZ
	add ZL, @0
	adc ZH, r2
.endmacro

.macro ADDIZ
	subi ZL, -@0
	adc ZH, r2
.endmacro

.macro STI
	push r16
	ldi r16, @1
	sts @0, r16
	pop r16
.endmacro

.macro LIJ ;@0 TABLE, @1 Register
	ldi ZL, low(@0)
	ldi ZH, high(@0)
	addz @1
.endmacro
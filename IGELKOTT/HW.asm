HW:
	sbi DDRB, 1

	ldi r16, 0b00000100
	out DDRD, r16

	ldi r16, 0b11111000
	out PORTD, r16

	clr r2

	ret
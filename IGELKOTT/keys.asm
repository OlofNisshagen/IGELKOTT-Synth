.equ KEYS_AMOUNT = 25

.dseg
	KEYS_PRESSED:		.byte	4

.cseg

INITIALIZE_KEYS:
	loadx KEYS_PRESSED
	st X+, r2
	st X+, r2
	st X+, r2
	st X+, r2
	ret

CHECK_KEYS:
	;Se ifall det är skillnad, en key har tryckts ned elle rlyfts. 
	;Debounce
	;Ifall den har tryckts ned, hitta en ny oscillator för den
	;Ifall den har lyfts, hitta rätt oscillator och sätt dess phasestate till release



	ret

CHECK_BUTTONS:
	ret

UPDATE_KNOBS:
	ret
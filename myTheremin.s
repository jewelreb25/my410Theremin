	.data
dataVal:	.byte 0

	.text
	.global GPIO_init
	.global ADC_init
	.global SS3_init
	.global poll_ADC
	.global myTheremin
	.global updateFreq

ptr_to_dataVal:	.word dataVal

;speaker : DAC output from U17-why
myTheremin:
	PUSH{r4-r12, lr}
	BL GPIO_init
	BL ADC_init
	BL SS3_init
	POP{r4-r12, pc}
;lllop: B lllop
lloop:
	; E5
    MOV r0, #379
    BL updateFreq
    BL delay1s

    ; E5
    MOV r0, #379
    BL updateFreq
    BL delay1s
    ; E5
    MOV r0, #379
    BL updateFreq
    BL delay1s
    ; C5
    MOV r0, #478
    BL updateFreq
    BL delay1s              ; dotted quarter = 1.5x dela
    ; E5
    MOV r0, #379
    BL updateFreq
    BL delay1s
    ; G5
    MOV r0, #319
    BL updateFreq
    BL delay1s             ; hold longer (half note)
    BL delay1s
    ; G4
    MOV r0, #638
    BL updateFreq
    BL delay1s

    B lloop


delay1s:
	PUSH {lr}
	MOV r0, #0x1100;INTERVAL ONE SECOND
	MOVT r0, #0x1A
delayLoop:
	SUB r0, r0, #1
 	CMP r0, #0
	BNE delayLoop
	POP{pc}

updateFreq:
	PUSH{lr}
	MOV r2, #0x8000
	MOVT r2, #0x4002
	STR r0, [r2, #0x110]
	ASR r0, #1
	STR r0, [r2, #0x118]
	POP{pc}

;polls ADC for a value and then store it in r0
poll_ADC:
	PUSH{r4-r12,lr}
    ;wait for conversion on SS3 raw interrupt
    MOV r4, #0x8000
    MOVT r4, #0x4003
    LDRB r1, [r0, #0x004]
    AND r1, r1, #8
    CMP r1, #8
    BNE loop

	;connect DAC to speakr: H5 to
	;pin 7 of J19 =speaker, J24= speaker source select
	;H5 is DAC output and power supply header
	LDR r1, ptr_to_dataVal
loop:
	;read data in FIFO3
	LDR r0, [r4, #0x0A8]	;ADCSSFIFO3- stores the conversion results for samples collected
	STR r0, [r1]			;with sample sequencer 3
	;B loop					;store in dataVal to transmit
	;clear the SS3 interrupt
	MOV r2, #0x8			;clear the IN3 bit in the ASCISC register
	STRB r2, [r0, #0x00C]
	POP{r4-r12,pc}

.end



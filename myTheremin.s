	.data
dataVal:	.byte 0

	.text
	.global GPIO_init
	.global ADC_init
	.global SS2_init
	.global poll_ADC
	.global myTheremin
	.global updateFreq
	.global updateVolume

ptr_to_dataVal:	.word dataVal

	;connect DAC to speakr: H5 to
	;pin 7 of J19 =speaker, J24= speaker source select
	;H5 is DAC output and power supply header
;speaker : DAC output from U17-why

myTheremin:
	PUSH{r4-r12, lr}
	BL GPIO_init
	BL ADC_init
	BL SS2_init
	POP{r4-r12, pc}

delay1s:
	PUSH {lr}
	MOV r0, #0x1000;INTERVAL ONE SECOND
	MOVT r0, #0xA
delayLoop:
	SUB r0, r0, #1
 	CMP r0, #0
	BNE delayLoop
	POP{pc}

updateFreq:
	PUSH{lr}
	MOV r2, #0x8000
	MOVT r2, #0x4002
	CMP r0, #0
	ITTT EQ
	LDREQ r3, [r2, #0x110]
	STREQ r3, [r2, #0x118]
	BEQ uFend
	STR r0, [r2, #0x110]
	ASR r0, #1
	STR r0, [r2, #0x118]
uFend:
	POP{pc}

updateVolume:
	PUSH{lr}
	MOV r2, #0x8000
	MOVT r2, #0x4002
	STR r0, [r2, #0x118]
	POP{pc}

;polls ADC for a value and then store it in r0
;r0= struct with pitch and volume
poll_ADC:
	PUSH{r4-r12,lr}
    MOV r4, #0x8000
    MOVT r4, #0x4003

	;read data in FIFO2
waitPitch:
	LDR r3, [r4, #0x08C]
	UBFX r5, r3, #8, #1
	CMP r5, #0
	BNE waitPitch
	LDR r3, [r4, #0x088]	;ADCSSFIFO2- stores the conversion results for samples collected
	STR r3, [r0]			;with sample sequencer & store in dataVal to transmit
	LDR r3, [r4, #0x088]
	STR r3, [r0, #4]

	;clear the SS2 interrupt
	MOV r2, #0x4			;clear the IN2 bit in the ASCISC register
	STRB r2, [r4, #0x00C]
	POP{r4-r12,pc}

.end


